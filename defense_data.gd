extends RefCounted
const EQUIPMENT_TITLE="List_of_countries_by_level_of_military_equipment"
const EQUIPMENT_URL="https://en.wikipedia.org/wiki/"+EQUIPMENT_TITLE

static func indicator(payload, indicator_id:String, countries:Dictionary) -> Dictionary:
 if not payload is Array or payload.size()!=2 or not payload[0] is Dictionary or not payload[1] is Array:return {}
 if int(payload[0].get("pages",0))!=1:return {}
 var result={}
 for row in payload[1]:
  if not row is Dictionary:return {}
  var code=str(row.get("countryiso3code",""));var value=row.get("value")
  if not countries.has(code) or value==null:continue
  if not row.get("indicator") is Dictionary or row.indicator.get("id")!=indicator_id:return {}
  if not value is float and not value is int:return {}
  var year=int(row.get("date",0))
  if value<0 or not is_finite(float(value)) or year<1900 or year>int(Time.get_date_dict_from_system().year):return {}
  result[code]={"value":value,"year":year,"source":"https://data.worldbank.org/indicator/"+indicator_id}
 return result if result.size()>100 else {}

static func clean(text:String) -> String:
 var regex=RegEx.new();regex.compile("(?s)<sup\\b.*?</sup>|<style\\b.*?</style>");text=regex.sub(text,"",true)
 regex.compile("<[^>]+>");text=regex.sub(text,"",true)
 text=text.replace("&#160;"," ").replace("&nbsp;"," ").replace("&amp;","&").replace("&#39;","'").replace("&quot;",'"')
 return text.strip_edges()

static func equipment(payload,countries:Dictionary) -> Dictionary:
 if not payload is Dictionary or not payload.get("parse") is Dictionary:return {}
 var parsed:Dictionary=payload.parse
 if not parsed.get("text") is Dictionary:return {}
 var html=str(parsed.text.get("*",""))
 var regex=RegEx.new();regex.compile('(?s)<table\\b[^>]*class="[^"]*wikitable[^\"]*"[^>]*>(.*?)</table>')
 var match_table=regex.search(html)
 if match_table==null:return {}
 var table=match_table.get_string(1)
 # Fail closed if the producer changes the columns.
 var required=["Main battle tanks","Aircraft carriers","Cruisers","Destroyers","Frigates","Corvettes","Nuclear submarines","Non-nuclear submarines","Combat aircraft","Attack helicopters"]
 var last=-1
 for h in required:
  var pos=table.find(h)
  if pos<last or pos<0:return {}
  last=pos
 var aliases={"Turkey":"TUR","South Korea":"KOR","North Korea":"PRK","Russia":"RUS","Iran":"IRN","Syria":"SYR","Venezuela":"VEN","Vietnam":"VNM","DR Congo":"COD","Czech Republic":"CZE","Ivory Coast":"CIV","Myanmar":"MMR"}
 for code in countries:aliases[countries[code].en]=code
 regex.compile("(?s)<tr\\b[^>]*>(.*?)</tr>")
 var cell_regex=RegEx.new();cell_regex.compile("(?s)<td\\b[^>]*>(.*?)</td>")
 var result={}
 for row in regex.search_all(table):
  var cells=cell_regex.search_all(row.get_string(1))
  if cells.size()!=17:continue
  var name=clean(cells[0].get_string(1));var code=str(aliases.get(name,""))
  if code.is_empty():continue
  var record={"source":EQUIPMENT_URL,"revision":int(parsed.get("revid",0)),"retrieved":Time.get_date_string_from_system(),"uncertain":row.get_string(1).contains("Citation_needed"),"year":null}
  var columns={"tanks":3,"carriers":4,"combat_aircraft":12,"attack_helicopters":13,"submarines_nuclear":10,"submarines_conventional":11}
  for field in columns:
   var text=clean(cells[columns[field]].get_string(1)).replace(",","").replace(" ","")
   record[field]=int(text) if text.is_valid_int() and int(text)>=0 else null
  result[code]=record
 return result if result.size()>100 else {}

static func ranking(records:Dictionary,field:String,countries:Dictionary,same_year:bool=true) -> Dictionary:
 var years={}
 for code in records:
  if not countries.has(code) or not (countries[code].get("un",false) or countries[code].get("independent",false)):continue
  var record=records[code]
  if record.get(field)==null:continue
  if same_year:years[int(record.get("year",0))]=years.get(int(record.get("year",0)),0)+1
 var year=0
 # Latest common year covering at least 100 states; otherwise the broadest year.
 for y in years:
  if years[y]>=100:year=maxi(year,y)
 if same_year and year==0:
  var count=0
  for y in years:
   if years[y]>count:count=years[y];year=y
 var values=[]
 for code in records:
  if not countries.has(code) or not (countries[code].get("un",false) or countries[code].get("independent",false)):continue
  var record=records[code]
  if record.get(field)==null or (same_year and int(record.get("year",0))!=year):continue
  # Unsourced equipment rows are shown as estimates but never ranked.
  if not same_year and record.get("uncertain",true):continue
  values.append({"code":code,"value":float(record[field])})
 values.sort_custom(func(a,b):return a.value>b.value if a.value!=b.value else a.code<b.code)
 var ranks={};var last_value=-1.0;var rank=0
 for i in values.size():
  if values[i].value!=last_value:rank=i+1
  ranks[values[i].code]=rank;last_value=values[i].value
 return {"ranks":ranks,"count":values.size(),"year":year}
