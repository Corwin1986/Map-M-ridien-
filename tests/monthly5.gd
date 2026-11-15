extends SceneTree
const Sync=preload("res://monthly_sync.gd")
const Data=preload("res://monthly_data.gd")
var errors=[]
class Atlas extends RefCounted:
 var defense:Dictionary={}
 var countries:Dictionary
 var cities:Array
 var articles:Dictionary
 var events:Array
 var observation_info={"version":"26.0.9","period":"septembre 2026","retrieved":"2026-11-14"}
func _initialize():call_deferred("run")
func check(value:bool,label:String):
 print(label,": ",value)
 if not value:errors.append(label)
func json_file(path):return JSON.parse_string(FileAccess.get_file_as_string(path))
func response(text:String,code:int=200):return {"result":HTTPRequest.RESULT_SUCCESS,"code":code,"body":text.to_utf8_buffer(),"headers":[]}
func run():
 check(Sync.cycle_for({"year":2026,"month":9,"day":15})=="2026-09-15","On 15 uses current month")
 check(Sync.cycle_for({"year":2026,"month":9,"day":18})=="2026-09-15","Missed 15 catches up on 18")
 check(not Sync.needs_cycle("2026-10-15",{"year":2026,"month":11,"day":12}),"November 12 skips if October done")
 check(Sync.needs_cycle("2026-03-15",{"year":2026,"month":7,"day":12}),"Four-month absence catches June deadline")
 check(Sync.cycle_for({"year":2027,"month":1,"day":12})=="2026-12-15","Year rollover")
 check(Sync.cycle_for({"year":2028,"month":3,"day":1})=="2028-02-15","Leap-year month")
 var a=Atlas.new();a.countries=json_file("res://data/countries.json");a.cities=json_file("res://data/cities.json");a.articles=json_file("res://data/articles.json");a.events=json_file("res://data/events.json")
 var today={"year":2026,"month":11,"day":15}
 var wb=json_file("res://tests/fixtures/wb.txt")
 var updated=Data.world_bank(wb,a.countries,"SP.POP.TOTL",today)
 check(updated.size()==256 and updated.FRA.population>0,"Real World Bank response accepted")
 check(Data.world_bank({"error":"bad"},a.countries,"SP.POP.TOTL",today).is_empty(),"Malformed statistics rejected")
 var bad=wb.duplicate(true)
 for row in bad[1]:
  if row.countryiso3code=="FRA":row.value=-2
 check(Data.world_bank(bad,a.countries,"SP.POP.TOTL",today).is_empty(),"Negative population rejected")
 var facts=Data.country_facts(json_file("res://tests/fixtures/facts.txt"),a.countries)
 check(facts.size()==256 and facts.FRA.capital==a.countries.FRA.capital,"Country facts preserve translated unchanged capital")
 var cities=Data.populations(json_file("res://tests/fixtures/wd.txt"),a.cities,"2026-11-14")
 check(cities.size()==1283,"Real Wikidata response accepted")
 var version=Data.candidate_version(FileAccess.get_file_as_string("res://tests/fixtures/ucdp.txt"))
 check(version=="26.0.9","Find latest public UCDP CSV")
 var event_data=Data.events(FileAccess.get_file_as_string("res://data/ucdp_raw.csv"),a.countries,"26.0.9")
 check(event_data.get("events",[]).size()==2014,"Parse actual UCDP CSV incl quoted fields")
 check(Data.csv_rows('a,b\n"x,y","line\nnext"\n').size()==2,"CSV quoted newline")
 var sync=Sync.new();sync.storage_path="user://qa5_sync.json";sync.request_gap=0
 for suffix in ["",".bak",".tmp"]:
  if FileAccess.file_exists(sync.storage_path+suffix):DirAccess.remove_absolute(ProjectSettings.globalize_path(sync.storage_path+suffix))
 root.add_child(sync)
 sync.state={"plan_version":7,"completed_cycle":"2026-10-15","cycle":"2026-11-15"}
 sync.jobs=[sync.job("wb","https://api.worldbank.org/pop",50,"Population",{"indicator":"SP.POP.TOTL"}),sync.job("facts","https://raw.githubusercontent.com/facts",50,"Pays")]
 sync.transport_override=func(address):return response(FileAccess.get_file_as_string("res://tests/fixtures/wb.txt")) if address.ends_with("pop") else response("unavailable",503)
 var complete=await sync.run(a,today)
 check(not complete and sync.state.completed_cycle=="2026-10-15","Failure never validates monthly deadline")
 check(sync.jobs[0].done and not sync.jobs[1].done,"Successful step checkpointed")
 check(sync.patch.has("countries"),"Successful data retained despite other provider failure")
 check(not sync.due(today,Time.get_unix_time_from_system()),"Retry cooldown respected")
 sync.queue_free();await process_frame
 sync=Sync.new();sync.storage_path="user://qa5_sync.json";sync.request_gap=0;root.add_child(sync)
 check(sync.jobs[0].done and not sync.jobs[1].done,"Interrupted job restored from disk")
 sync.state.retry_at=0;sync.state.host_retry={}
 var calls=[]
 sync.transport_override=func(address):calls.append(address);return response(FileAccess.get_file_as_string("res://tests/fixtures/facts.txt"))
 var percentages=[]
 sync.progress.connect(func(value,_label):percentages.append(value))
 complete=await sync.run(a,today)
 check(complete and sync.state.completed_cycle=="2026-11-15","Successful completion records deadline")
 check(calls.size()==1 and calls[0].ends_with("facts"),"Resume downloads only unfinished steps")
 check(percentages[-1]==100,"100 percent only after successful save")
 check(not sync.due(today),"Repeated opening does not update again")
 # Revision check appends extract jobs, retains full articles and attribution.
 sync.app=a;sync.patch={};sync.jobs=[]
 var j=sync.job("wiki_check","",10,"",{"groups":{"France":["FRA"]}})
 check(sync.consume(j,FileAccess.get_file_as_string("res://tests/fixtures/wiki.txt").to_utf8_buffer(),today),"Article revision response accepted")
 check(sync.jobs.size()==1 and sync.jobs[0].full,"Changed complete article stays complete")
 var extract={"query":{"pages":{"1095":{"pageid":1095,"title":"France","extract":"Texte de contrôle suffisamment long pour représenter une notice encyclopédique complète.","revisions":[{"revid":999999,"timestamp":"2026-11-14T12:00:00Z"}]}}}}
 check(sync.consume(sync.jobs[0],JSON.stringify(extract).to_utf8_buffer(),today),"Article refresh accepted")
 check(sync.patch.articles.FRA.revision_id==999999 and sync.patch.articles.FRA.license=="CC BY-SA 4.0","Revision and attribution preserved")
 # Rate limiting: no repeated calls to a host and Retry-After is honored.
 sync.state={"plan_version":7,"completed_cycle":"2026-10-15","cycle":"2026-11-15"};sync.jobs=[sync.job("facts","https://raw.githubusercontent.com/one",50,""),sync.job("facts","https://raw.githubusercontent.com/two",50,"")]
 calls.clear()
 sync.transport_override=func(address):
  calls.append(address)
  var r=response("rate limited",429);r.headers=["Retry-After: 40000"];return r
 complete=await sync.run(a,today)
 check(not complete and calls.size()==1,"429 stops requests to the same provider")
 check(sync.state.host_retry["raw.githubusercontent.com"]>Time.get_unix_time_from_system()+39990,"Retry-After retained")
 # Cancel during a request: no false completion and no discarded saved content.
 sync.state={"plan_version":7,"completed_cycle":"2026-10-15","cycle":"2026-11-15"};sync.jobs=[sync.job("facts","https://raw.githubusercontent.com/one",100,"")]
 sync.transport_override=func(_address):
  sync.cancel();return response(FileAccess.get_file_as_string("res://tests/fixtures/facts.txt"))
 complete=await sync.run(a,today)
 check(not complete and not sync.jobs[0].done and sync.state.completed_cycle=="2026-10-15","Cancellation leaves deadline pending")
 sync.state.completed_cycle="2026-11-15"
 # Corrupt primary cache restores the last valid backup.
 sync.save_cache();sync.save_cache()
 var f=FileAccess.open(sync.storage_path,FileAccess.WRITE);f.store_string("BROKEN");f.close()
 var recovery=Sync.new();recovery.storage_path=sync.storage_path;root.add_child(recovery)
 check(recovery.state.get("completed_cycle","")=="2026-11-15","Corrupt cache falls back to backup")
 for suffix in ["",".bak",".tmp"]:
  if FileAccess.file_exists(sync.storage_path+suffix):DirAccess.remove_absolute(ProjectSettings.globalize_path(sync.storage_path+suffix))
 print("MONTHLY V5: ","PASS" if errors.is_empty() else errors)
 quit(0 if errors.is_empty() else 1)
