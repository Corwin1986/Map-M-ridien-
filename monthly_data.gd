extends RefCounted
# Adapters only accept data; no executable content is downloaded.

static func world_bank(payload, countries:Dictionary, indicator:String, today:Dictionary) -> Dictionary:
 if not payload is Array or payload.size()!=2 or not payload[0] is Dictionary or not payload[1] is Array:return {}
 if int(payload[0].get("pages",0))!=1 or payload[1].size()<100:return {}
 var result=countries.duplicate(true)
 var count=0
 for row in payload[1]:
  if not row is Dictionary:continue
  var code=str(row.get("countryiso3code",""));var value=row.get("value")
  if not result.has(code) or value==null:continue
  if not value is float and not value is int:return {}
  var year=int(row.get("date",0))
  if year<1900 or year>int(today.year) or value<0 or not is_finite(float(value)):return {}
  if not row.get("indicator") is Dictionary or row.indicator.get("id","")!=indicator:return {}
  var c:Dictionary=result[code]
  if indicator=="SP.POP.TOTL":
   if year>=int(c.get("pop_year",0)):
    c.population=value;c.pop_year=year;c.pop_source="Banque mondiale · SP.POP.TOTL"
  else:
   if year>=int(c.get("gdp_year",0)):
    c.gdp=float(value)/1000000.0;c.gdp_year=year;c.gdp_source="Banque mondiale · NY.GDP.MKTP.CD"
  count+=1
 return result if count>100 else {}

static func country_facts(payload,countries:Dictionary) -> Dictionary:
 if not payload is Array or payload.size()<200:return {}
 var result=countries.duplicate(true)
 var special=["ISR","PSE","LKA","IDN","BDI","TWN","ESH","UNK","CYN"]
 var reference:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://data/facts_reference.json"))
 var translations={"Arabic":"arabe","French":"français","English":"anglais","Spanish":"espagnol","Portuguese":"portugais","German":"allemand","Italian":"italien","Russian":"russe","Turkish":"turc","Chinese":"chinois","Japanese":"japonais","Hindi":"hindi","Dutch":"néerlandais","Korean":"coréen","Persian (Farsi)":"persan"}
 var count=0
 for row in payload:
  if not row is Dictionary:return {}
  var code=str(row.get("cca3",""))
  if not result.has(code):continue
  if not row.get("languages",{}) is Dictionary or not row.get("currencies",{}) is Dictionary or not row.get("capital",[]) is Array:return {}
  var c:Dictionary=result[code]
  # Keep locally qualified capital names unless the source actually changes.
  var baseline:Dictionary=c.get("facts_baseline",reference.get(code,{}))
  if not baseline.is_empty():
   if row.get("capital",[])!=baseline.get("capital",[]) and code not in special:
    c.capital=", ".join(row.get("capital",[]))
   if row.get("languages",{})!=baseline.get("languages",{}):
    var names=[]
    for lang in row.get("languages",{}).values():names.append(translations.get(lang,lang))
    c.languages=names
  c.currency=", ".join(row.get("currencies",{}).keys())
  if row.get("area") is float or row.get("area") is int:
   if row.area>0 and row.area<200000000:c.area=row.area
  if row.get("unMember") is bool:c.un=row.unMember
  c.facts_baseline={"capital":row.get("capital",[]),"languages":row.get("languages",{})}
  count+=1
 return result if count>200 else {}

static func populations(payload,cities:Array,today:String) -> Array:
 if not payload is Dictionary or not payload.get("entities") is Dictionary or payload.entities.is_empty():return []
 var result=cities.duplicate(true)
 for city in result:
  var qid=str(city.get("qid",""))
  if not payload.entities.has(qid):continue
  var e=payload.entities[qid]
  if not e is Dictionary:return []
  var options=[]
  for s in e.get("claims",{}).get("P1082",[]):
   if s.get("rank","")=="deprecated":continue
   var q=s.get("qualifiers",{});var partial=false
   for key in ["P518","P1540","P1539","P21","P27","P172"]:
    if q.has(key):partial=true
   if partial:continue
   var value=s.get("mainsnak",{}).get("datavalue",{}).get("value",{})
   if not value is Dictionary:continue
   var amount=str(value.get("amount",""))
   if not amount.is_valid_float() or float(amount)<=0 or float(amount)>1000000000:continue
   for qualifier in q.get("P585",[]):
    var date=str(qualifier.get("datavalue",{}).get("value",{}).get("time",""))
    if not date.begins_with("+") or date.substr(1,10)>today or int(date.substr(1,4))<1800:continue
    options.append({"date":date.substr(1,10),"amount":int(float(amount)),"statement":s.get("id",""),"preferred":s.get("rank","")=="preferred"})
  options.sort_custom(func(a,b):return a.date>b.date if a.date!=b.date else a.preferred and not b.preferred)
  if options.is_empty():continue # No dated value: retain known data, never replace with zero.
  var p=options[0]
  if p.date<str(city.get("population_date","")):continue
  city.population=p.amount;city.population_year=int(p.date.left(4));city.population_date=p.date
  city.population_source="Wikidata · P1082";city.population_url="https://www.wikidata.org/wiki/"+qid+"#P1082"
  city.population_statement=p.statement;city.population_references=[]
 return result

static func candidate_version(html:String) -> String:
 var regex=RegEx.new();regex.compile("GEDEvent_v([0-9]+)_([0-9]+)_([0-9]+)\\.csv")
 var best=0;var version=""
 for m in regex.search_all(html):
  var year=int(m.get_string(1));var month=int(m.get_string(3))
  if m.get_string(2)!="0" or month<1 or month>12:continue
  var score=year*100+month
  if score>best:best=score;version=str(year)+".0."+str(month)
 return version

static func csv_rows(text:String) -> Array:
 # RFC 4180: quoted commas, escaped quotes and embedded line breaks.
 var rows=[];var row=[];var cell="";var quoted=false;var i=0
 while i<text.length():
  var ch=text[i]
  if ch=='"':
   if quoted and i+1<text.length() and text[i+1]=='"':cell+='"';i+=1
   else:quoted=not quoted
  elif ch=="," and not quoted:row.append(cell);cell=""
  elif ch=="\n" and not quoted:
   row.append(cell.trim_suffix("\r"));rows.append(row);row=[];cell=""
  else:cell+=ch
  i+=1
 if quoted:return []
 if not cell.is_empty() or not row.is_empty():row.append(cell.trim_suffix("\r"));rows.append(row)
 return rows

static func events(csv:String,countries:Dictionary,version:String) -> Dictionary:
 var rows=csv_rows(csv.trim_prefix("\ufeff"))
 if rows.size()<2:return {}
 var header=rows.pop_front();var columns={}
 for i in header.size():columns[header[i]]=i
 var required=["id","country","conflict_name","dyad_name","side_a","side_b","latitude","longitude","where_coordinates","adm_1","type_of_violence","where_prec","date_start","date_end","best","low","high","source_office","code_status"]
 for key in required:
  if not columns.has(key):return {}
 var names={"DR Congo (Zaire)":"COD","Myanmar (Burma)":"MMR","Russia (Soviet Union)":"RUS","Yemen (North Yemen)":"YEM","Turkey":"TUR","Iran":"IRN","Syria":"SYR","Venezuela":"VEN","Tanzania":"TZA","Ivory Coast":"CIV"}
 for code in countries:names[countries[code].en]=code
 var result=[];var unmapped=0;var seen={}
 for cells in rows:
  if cells.size()!=header.size():return {}
  var r={}
  for key in required:r[key]=cells[columns[key]]
  if seen.has(r.id):return {}
  seen[r.id]=true
  var code=names.get(r.country,"")
  var source_code=code
  if r.adm_1 in ["Gaza Strip","West Bank"]:code="PSE"
  if not countries.has(code):unmapped+=1;continue
  for k in ["latitude","longitude","best","low","high","type_of_violence","where_prec"]:
   if not str(r[k]).is_valid_float():return {}
  if absf(float(r.latitude))>90 or absf(float(r.longitude))>180 or float(r.best)<0 or int(r.type_of_violence) not in [1,2,3]:return {}
  var date=r.date_start.left(10);var end=r.date_end.left(10)
  if date.length()!=10 or end.length()!=10 or date>end:return {}
  result.append({"id":r.id,"country":r.country,"code":code,"source_code":source_code,"conflict":r.conflict_name,"actors":r.dyad_name,"a":r.side_a,"b":r.side_b,"lat":float(r.latitude),"lon":float(r.longitude),"location":r.where_coordinates,"region":r.adm_1,"type":int(r.type_of_violence),"precision":int(r.where_prec),"date":date,"end":end,"best":int(r.best),"low":int(r.low),"high":int(r.high),"sources":r.source_office,"status":r.code_status})
 if result.is_empty() or unmapped>maxi(2,int(rows.size()*0.05)):return {}
 var months=["janvier","février","mars","avril","mai","juin","juillet","août","septembre","octobre","novembre","décembre"]
 var bits=version.split(".")
 if bits.size()!=3:return {}
 var period=months[int(bits[2])-1]+" "+str(2000+int(bits[0]))
 return {"events":result,"observation_info":{"version":version,"period":period,"retrieved":Time.get_date_string_from_system(true),"unmapped":unmapped}}
