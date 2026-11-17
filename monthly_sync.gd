extends Node
const ContentPolicy=preload("res://content_policy.gd")
const DefenseData = preload("res://defense_data.gd")
const Validator = preload("res://content_sync.gd")
const Data = preload("res://monthly_data.gd")
const PATH="user://monthly_data_v1.json"
const BASE_CYCLE="2026-10-15" # Embedded data collected November 14, before November's deadline.
const WIKI="https://fr.wikipedia.org/w/api.php"
const WD="https://www.wikidata.org/w/api.php"
const HEADERS=["User-Agent: MeridienAtlas/7.0 (Android offline educational atlas; monthly data refresh)","Accept: application/json,text/csv,text/html"]
signal progress(value:float,detail:String)
var state:Dictionary={}
var patch:Dictionary={}
var jobs:Array=[]
var request:HTTPRequest
var response:Dictionary={}
var app
var running=false
var cancelled=false
var current_weight=0.0
var completed_weight=0.0
var last_progress=0.0
var message=""
var failed_hosts:Dictionary={}
var failures=0
var storage_path=PATH
var request_gap=2.0
var max_seconds=900.0
# Deterministic transport injection for offline regression tests only.
var transport_override=Callable()

static func cycle_for(date:Dictionary) -> String:
 var year=int(date.year);var month=int(date.month)
 if int(date.day)<15:
  month-=1
  if month==0:month=12;year-=1
 return "%04d-%02d-15" % [year,month]

static func needs_cycle(last:String,date:Dictionary) -> bool:
 return last<cycle_for(date)

func _ready():
 load_cache()
 request=HTTPRequest.new();request.timeout=12;request.body_size_limit=24*1024*1024;request.use_threads=true
 request.request_completed.connect(func(result,code,headers,body):response={"result":result,"code":code,"headers":headers,"body":body})
 add_child(request)

func load_cache():
 for path in [storage_path,storage_path+".bak"]:
  if not FileAccess.file_exists(path):continue
  var parser=JSON.new()
  if parser.parse(FileAccess.get_file_as_string(path))!=OK:continue
  var value=parser.data
  if not value is Dictionary or value.get("schema",0)!=1 or not value.get("state") is Dictionary or not value.get("patch") is Dictionary or not value.get("jobs") is Array:continue
  if not valid_patch(value.patch):continue
  state=value.state;patch=ContentPolicy.clean_data(value.patch);jobs=value.jobs;return
 state={"completed_cycle":BASE_CYCLE,"retry_at":0};patch={};jobs=[]

func valid_patch(value:Dictionary) -> bool:
 if value.has("defense"):
  if not value.defense is Dictionary:return false
  for category in value.defense:
   if category not in ["gdp","personnel","equipment"] or not value.defense[category] is Dictionary:return false
   for row in value.defense[category].values():
    if not row is Dictionary:return false
    if category!="equipment" and (not row.get("value") is float and not row.get("value") is int):return false
 for key in value:
  if key not in ["countries","cities","articles","events","observation_info","defense"]:return false
  if key in ["countries","articles","observation_info"] and not value[key] is Dictionary:return false
  if key in ["cities","events"] and not value[key] is Array:return false
 if value.has("countries"):
  for c in value.countries.values():
   if not c is Dictionary:return false
   for field in ["code","name","en","capital","region","iso2","currency"]:
    if not c.get(field) is String:return false
   if not c.get("languages") is Array or not c.get("borders") is Array:return false
   for field in ["population","area","gdp","gdp_year","lat","lon"]:
    if c.get(field)!=null and not c.get(field) is float and not c.get(field) is int:return false
 if value.has("articles"):
  for a in value.articles.values():
   if not a is Dictionary or not a.get("text") is String or not a.get("title") is String:return false
   if not str(a.get("url","")).begins_with("https://fr.wikipedia.org/"):return false
 if value.has("events")!=value.has("observation_info"):return false
 var subset={}
 for key in ["cities","events","observation_info"]:
  if value.has(key):subset[key]=value[key]
 if not subset.is_empty():
  var validator=Validator.new()
  var valid=validator.valid_bundle({"schema":1,"revision":1,"data":subset})
  validator.free()
  if not valid:return false
 return true

func save_cache() -> bool:
 var value={"schema":1,"state":state,"patch":patch,"jobs":jobs}
 var file=FileAccess.open(storage_path+".tmp",FileAccess.WRITE)
 if file==null:return false
 file.store_string(JSON.stringify(value));file.flush();file.close()
 var check=JSON.parse_string(FileAccess.get_file_as_string(storage_path+".tmp"))
 if not check is Dictionary or not valid_patch(check.get("patch",{})):return false
 var target=ProjectSettings.globalize_path(storage_path)
 if FileAccess.file_exists(storage_path):
  if FileAccess.file_exists(storage_path+".bak"):DirAccess.remove_absolute(target+".bak")
  if DirAccess.rename_absolute(target,target+".bak")!=OK:return false
 if DirAccess.rename_absolute(target+".tmp",target)!=OK:
  if FileAccess.file_exists(storage_path+".bak"):DirAccess.rename_absolute(target+".bak",target)
  return false
 return true

func due(date:Dictionary=Time.get_date_dict_from_system(),now:float=Time.get_unix_time_from_system()) -> bool:
 return needs_cycle(str(state.get("completed_cycle",BASE_CYCLE)),date) and now>=float(state.get("retry_at",0))

func apply_to(target):
 patch=ContentPolicy.clean_data(patch)
 if patch.has("defense"):target.defense.merge(patch.defense,true)
 if patch.has("countries"):target.countries.merge(patch.countries.duplicate(true),true)
 if patch.has("cities"):target.cities=patch.cities.duplicate(true)
 if patch.has("articles"):target.articles.merge(patch.articles,true)
 if patch.has("events"):
  target.events=patch.events.duplicate(true);target.observation_info=patch.observation_info.duplicate(true)
 if target.has_method("apply_territory_overlay"):target.apply_territory_overlay()

func url(base:String,params:Dictionary) -> String:
 var pairs=[]
 for key in params:pairs.append(str(key).uri_encode()+"="+str(params[key]).uri_encode())
 return base+"?"+"&".join(pairs)

func job(kind:String,address:String,weight:float,label:String,extra:Dictionary={}) -> Dictionary:
 var j={"kind":kind,"url":address,"weight":weight,"label":label,"done":false}
 j.merge(extra);return j

func prepare_jobs(cycle:String):
 if state.get("cycle","")==cycle and not jobs.is_empty() and state.get("plan_version",0)==7:return
 state.cycle=cycle;state.plan_version=7;jobs=[]
 jobs.append(job("facts","https://raw.githubusercontent.com/mledoze/countries/master/countries.json",4,"Pays et territoires"))
 for indicator in ["SP.POP.TOTL","NY.GDP.MKTP.CD"]:
  jobs.append(job("wb","https://api.worldbank.org/v2/country/all/indicator/"+indicator+"?format=json&mrnev=1&per_page=400",6,"Populations et économie",{"indicator":indicator}))
 jobs.append(job("defense_personnel","https://api.worldbank.org/v2/country/all/indicator/MS.MIL.TOTL.P1?format=json&mrnev=1&per_page=400",2,"Effectifs militaires"))
 jobs.append(job("defense_equipment",url("https://en.wikipedia.org/w/api.php",{"action":"parse","page":DefenseData.EQUIPMENT_TITLE,"prop":"text|revid","format":"json","maxlag":5}),2,"Inventaires militaires"))
 jobs.append(job("ucdp_index","https://ucdp.uu.se/downloads/index.html",4,"Dernière publication des conflits"))
 var ids=[]
 for c in app.cities:
  var qid=str(c.get("qid",""))
  if qid.begins_with("Q") and qid not in ids:ids.append(qid)
 ids.sort()
 var batches=ceili(ids.size()/50.0)
 for i in range(0,ids.size(),50):
  var batch=ids.slice(i,i+50)
  jobs.append(job("wd",url(WD,{"action":"wbgetentities","ids":"|".join(batch),"props":"claims","format":"json","maxlag":5}),20.0/maxi(1,batches),"Population des villes",{"ids":batch}))
 var groups={}
 for key in app.articles:
  var a:Dictionary=app.articles[key]
  if not a.has("text"):continue
  var title=str(a.get("title",""))
  if title.is_empty():continue
  if not groups.has(title):groups[title]=[]
  groups[title].append(key)
 var titles=groups.keys();titles.sort();batches=ceili(titles.size()/40.0)
 for i in range(0,titles.size(),40):
  var subset={}
  for title in titles.slice(i,i+40):subset[title]=groups[title]
  jobs.append(job("wiki_check",url(WIKI,{"action":"query","prop":"revisions|pageprops","rvprop":"ids|timestamp","redirects":1,"titles":"|".join(subset.keys()),"format":"json","maxlag":5}),56.0/maxi(1,batches),"Vérification des articles",{"groups":subset}))
 save_cache()

func emit_progress(detail:String,part:float=0):
 var value=minf(99,completed_weight+current_weight*clampf(part,0,0.95))
 last_progress=maxf(last_progress,value)
 progress.emit(last_progress,detail)

func _process(_delta):
 if running and request.get_http_client_status()==HTTPClient.STATUS_BODY:
  var length=request.get_body_size()
  if length>0:emit_progress(message,float(request.get_downloaded_bytes())/length)

func cancel():
 cancelled=true
 if running:
  request.cancel_request();response={"result":HTTPRequest.RESULT_REQUEST_FAILED,"code":0,"headers":[],"body":PackedByteArray()}

func fetch(address:String) -> Dictionary:
 if transport_override.is_valid():return await transport_override.call(address)
 response={}
 if not address.begins_with("https://") or address.get_slice("/",2) not in ["api.worldbank.org","raw.githubusercontent.com","www.wikidata.org","fr.wikipedia.org","en.wikipedia.org","ucdp.uu.se"]:
  return {"result":HTTPRequest.RESULT_REQUEST_FAILED,"code":0,"headers":[],"body":PackedByteArray()}
 var err=request.request(address,HEADERS)
 if err!=OK:return {"result":HTTPRequest.RESULT_CANT_CONNECT,"code":0,"headers":[],"body":PackedByteArray()}
 while response.is_empty():await get_tree().process_frame
 return response

func run(target,date:Dictionary=Time.get_date_dict_from_system()) -> bool:
 if running:return false
 app=target;apply_to(app);prepare_jobs(cycle_for(date))
 running=true;cancelled=false;failed_hosts={};failures=0;last_progress=0
 completed_weight=0
 for j in jobs:
  if j.get("done",false):completed_weight+=float(j.weight)
 var started=Time.get_ticks_msec()
 var cursor=0
 while cursor<jobs.size():
  var j:Dictionary=jobs[cursor];cursor+=1
  if j.get("done",false):continue
  if cancelled or (Time.get_ticks_msec()-started)/1000.0>max_seconds:break
  var host=str(j.url).get_slice("/",2)
  if failed_hosts.has(host) or Time.get_unix_time_from_system()<float(state.get("host_retry",{}).get(host,0)):failures+=1;continue
  message=j.label;current_weight=float(j.weight);emit_progress(message)
  j.attempted_at=Time.get_datetime_string_from_system()
  var r=await fetch(j.url)
  if cancelled:break
  var ok=false
  if r.get("result",-1)==HTTPRequest.RESULT_SUCCESS and int(r.get("code",0))==200:
   ok=consume(j,r.body,date)
  if ok:
   j.checked_at=Time.get_datetime_string_from_system();j.last_error=""
   j.done=true;completed_weight+=float(j.weight);current_weight=0
   if not save_cache():
    j.done=false;failures+=1;message="Stockage indisponible. Données précédentes conservées.";break
  else:
   j.last_error="Réponse non exploitable" if int(r.get("code",0))==200 else ("Connexion indisponible" if int(r.get("code",0))==0 else "Erreur HTTP "+str(int(r.get("code",0))))
   failures+=1;failed_hosts[host]=true
   var retry=Time.get_unix_time_from_system()+21600
   for h in r.get("headers",[]):
    if str(h).to_lower().begins_with("retry-after:"):
     var seconds=str(h).split(":",true,1)[1].strip_edges()
     if seconds.is_valid_int():retry=maxf(retry,Time.get_unix_time_from_system()+int(seconds))
   if not state.has("host_retry"):state.host_retry={}
   state.host_retry[host]=retry
   save_cache()
   if int(r.get("code",0))==0:break
  emit_progress(message)
  if request_gap>0:await get_tree().create_timer(request_gap).timeout
 var complete=true
 for j in jobs:
  if not j.get("done",false):complete=false
 var previous=str(state.get("completed_cycle",BASE_CYCLE))
 if complete:
  state.completed_cycle=state.cycle;state.completed_at=Time.get_datetime_string_from_system();state.retry_at=0
  if not save_cache():state.completed_cycle=previous;complete=false
 if not complete:
  state.retry_at=Time.get_unix_time_from_system()+(21600 if failures>0 else 3600)
  save_cache()
 remember_category_checks()
 running=false;current_weight=0
 apply_to(app)
 if complete:progress.emit(100,"Données actualisées. Ouverture de Méridien…")
 else:progress.emit(last_progress,"Actualisation incomplète. Ouverture avec les données disponibles.")
 return complete

func category_for(j:Dictionary)->String:
 var kind=str(j.get("kind",""))
 if kind=="wb":return "Population des pays" if j.get("indicator","")=="SP.POP.TOTL" else "Économie · PIB"
 return {"facts":"Fiches pays","wd":"Population des villes","wiki_check":"Articles","wiki_extract":"Articles","ucdp_index":"Événements UCDP","ucdp_csv":"Événements UCDP","defense_personnel":"Effectifs militaires","defense_equipment":"Équipement militaire"}.get(kind,"Autres")

func category_rows()->Array:
 var rows:Array=[]
 for category in ["Population des pays","Population des villes","Économie · PIB","Fiches pays","Articles","Événements UCDP","Effectifs militaires","Équipement militaire"]:
  var row={"name":category,"total":0,"done":0,"error":"","attempted_at":"","checked_at":str(state.get("category_checks",{}).get(category,""))}
  for j in jobs:
   if category_for(j)!=category:continue
   row.total+=1
   if str(j.get("attempted_at",""))>row.attempted_at:row.attempted_at=j.attempted_at
   if j.get("done",false):row.done+=1
   elif j.get("last_error","")!="":row.error=j.last_error
  if row.total>0 and row.done==row.total:
   for j in jobs:
    if category_for(j)==category and str(j.get("checked_at",""))>row.checked_at:row.checked_at=j.checked_at
  row.status="Aucune consultation enregistrée" if row.total==0 else ("Consultation terminée" if row.done==row.total else ("À reprendre" if row.error!="" else "En attente ou interrompue"))
  rows.append(row)
 return rows

func remember_category_checks():
 if not state.has("category_checks"):state.category_checks={}
 for row in category_rows():
  if row.total>0 and row.done==row.total and row.checked_at!="":state.category_checks[row.name]=row.checked_at
 save_cache()

func last_check(category:String)->String:
 for row in category_rows():
  if row.name==category:return row.checked_at
 return ""

func consume(j:Dictionary,body:PackedByteArray,date:Dictionary) -> bool:
 var text=body.get_string_from_utf8()
 if j.kind=="ucdp_index":
  var version=Data.candidate_version(text)
  if version.is_empty():return false
  var split=version.split(".")
  if int(split[0])+2000>int(date.year):return false
  # The file is rechecked monthly: an unchanged release can contain corrections.
  jobs.append(job("ucdp_csv","https://ucdp.uu.se/downloads/candidateged/GEDEvent_v"+version.replace(".","_")+".csv",float(j.weight)/2.0,"Événements de conflits",{"version":version}))
  j.weight=float(j.weight)/2.0
  return true
 if j.kind=="ucdp_csv":
  var parsed=Data.events(text,app.countries,j.version)
  if parsed.is_empty():return false
  # Never replace a newer observation set with an older publication.
  var old=str(app.observation_info.get("version","0.0.0")).split(".");var new=str(j.version).split(".")
  if old.size()==3 and int(old[0])*100+int(old[2])>int(new[0])*100+int(new[2]):return false
  patch.merge(parsed,true);app.events=parsed.events;app.observation_info=parsed.observation_info;return true
 var payload=JSON.parse_string(text)
 if j.kind in ["defense_personnel","defense_equipment"]:
  var updated=DefenseData.indicator(payload,"MS.MIL.TOTL.P1",app.countries) if j.kind=="defense_personnel" else DefenseData.equipment(payload,app.countries)
  if updated.is_empty():return false
  var category="personnel" if j.kind=="defense_personnel" else "equipment"
  if not patch.has("defense"):patch.defense={}
  patch.defense[category]=updated;app.defense[category]=updated;return true
 if j.kind=="facts":
  var updated=Data.country_facts(payload,app.countries)
  if updated.is_empty():return false
  patch.countries=updated;app.countries=updated;return true
 if j.kind=="wb":
  if j.indicator=="NY.GDP.MKTP.CD":
   var economic=DefenseData.indicator(payload,j.indicator,app.countries)
   if economic.is_empty():return false
   if not patch.has("defense"):patch.defense={}
   patch.defense.gdp=economic;app.defense.gdp=economic
  var updated=Data.world_bank(payload,app.countries,j.indicator,date)
  if updated.is_empty():return false
  patch.countries=updated;app.countries=updated;return true
 if j.kind=="wd":
  if not payload is Dictionary or not payload.get("entities") is Dictionary:return false
  for id in j.ids:
   if not payload.entities.has(id):return false
  var updated=Data.populations(payload,app.cities,"%04d-%02d-%02d" % [date.year,date.month,date.day])
  if updated.is_empty():return false
  patch.cities=updated;app.cities=updated;return true
 if not payload is Dictionary or payload.has("error") or not payload.get("query") is Dictionary:return false
 if j.kind=="wiki_check":return wiki_check(j,payload.query)
 if j.kind=="wiki_extract":return wiki_extract(j,payload.query)
 return false

func wiki_check(j:Dictionary,q:Dictionary) -> bool:
 if not q.get("pages") is Dictionary:return false
 var redirects={}
 for row in q.get("normalized",[])+q.get("redirects",[]):redirects[row.from]=row.to
 var by_title={}
 for page in q.pages.values():by_title[page.get("title","")]=page
 var changed=[]
 for title in j.groups:
  var resolved=title
  for unused in range(10):
   if not redirects.has(resolved):break
   resolved=redirects[resolved]
  var page:Dictionary=by_title.get(resolved,{})
  if page.is_empty():return false
  # A deleted/disambiguated page is checked but never overwrites usable offline text.
  if page.has("missing") or page.has("invalid") or page.get("pageprops",{}).has("disambiguation"):continue
  var revisions=page.get("revisions",[])
  if revisions.is_empty():return false
  var revision=revisions[0];var keys=[];var full=false
  for key in j.groups[title]:
   var a=app.articles[key]
   var different=int(a.get("revision_id",0))!=int(revision.get("revid",0))
   if not a.has("revision_id"):different=str(revision.get("timestamp",""))>=str(a.get("retrieved",""))+"T00:00:00Z"
   if different:
    keys.append(key)
    if a.get("scope","")!="intro":full=true
  if not keys.is_empty():changed.append({"pageid":int(page.pageid),"keys":keys,"full":full})
 if not changed.is_empty():
  var share=float(j.weight)*0.9/changed.size();j.weight=float(j.weight)*0.1
  for c in changed:
   var params={"action":"query","prop":"extracts|revisions|pageprops","rvprop":"ids|timestamp","pageids":c.pageid,"explaintext":1,"exsectionformat":"wiki","format":"json","maxlag":5}
   if not c.full:params.exintro=1
   jobs.append(job("wiki_extract",url(WIKI,params),share,"Actualisation des textes",c))
 return true

func wiki_extract(j:Dictionary,q:Dictionary) -> bool:
 if not q.get("pages") is Dictionary:return false
 var page:Dictionary=q.pages.get(str(int(j.pageid)),{})
 if page.has("missing") or page.get("pageprops",{}).has("disambiguation"):return true
 var text=str(page.get("extract",""))
 if text.length()<50 or text.length()>1500000:return false
 var revs=page.get("revisions",[])
 if revs.is_empty():return false
 if not patch.has("articles"):patch.articles={}
 for key in j["keys"]:
  var record=app.articles[key].duplicate(true)
  record.title=page.title;record.text=ContentPolicy.clean_text(text);record.pageid=page.pageid
  record.url="https://fr.wikipedia.org/?curid="+str(int(page.pageid))
  record.history="https://fr.wikipedia.org/w/index.php?title="+str(page.title).uri_encode()+"&action=history"
  record.retrieved=Time.get_date_string_from_system(true);record.license="CC BY-SA 4.0"
  record.revision_id=revs[0].revid;record.source_timestamp=revs[0].timestamp
  if j.full:record.erase("scope")
  patch.articles[key]=record;app.articles[key]=record
 return true

func status_text() -> String:
 var last=str(state.get("completed_cycle",BASE_CYCLE))
 return "Échéance du 15 : dernière échéance satisfaite "+last+". Vérification automatique au lancement, depuis cet appareil. Les dates des sources peuvent être antérieures. Carte, sélections éditoriales et recettes restent embarquées ; les populations, le PIB, les effectifs militaires, les inventaires d’équipement, les fiches de pays, les textes associés et les événements UCDP sont vérifiés en ligne."
