extends RefCounted
# Extract from the CURRENT article, so monthly article refreshes are visible here.
static func country_text(record:Dictionary,articles:Dictionary)->String:
 var text:String=articles.get(record.get("article",""),{}).get("text","")
 if record.get("whole",false):return text
 var headings=RegEx.new();headings.compile("(?m)^(={2,5})[ \\t]*([^=\\n]+?)[ \\t]*\\1[ \\t]*$")
 var word=RegEx.new();word.compile("(?i)\\bsports?\\b")
 var all=headings.search_all(text)
 for i in all.size():
  var h=all[i]
  if word.search(h.get_string(2)):
   var finish=text.length()
   for j in range(i+1,all.size()):
    if all[j].get_string(1).length()<=h.get_string(1).length():finish=all[j].get_start();break
   return text.substr(h.get_end(),finish-h.get_end()).strip_edges()
 return ""

static func matches(text:String,aliases:Array,sport:String)->bool:
 var lower=text.to_lower()
 if sport=="Tennis":lower=lower.replace("tennis de table","")
 if sport=="Football":lower=lower.replace("football américain","")
 for alias in aliases:
  var re=RegEx.new();re.compile("(?i)(?<![a-zà-ÿ])"+str(alias)+"(?![a-zà-ÿ])")
  if re.search(lower):return true
 return false

static func passages(text:String,aliases:Array,sport:String)->Array:
 var result:Array=[]
 var selected_level=0
 for raw in text.split("\n"):
  var p=raw.strip_edges()
  if p.begins_with("="):
   var level=0
   while level<p.length() and p[level]=="=":level+=1
   if selected_level>0 and level<=selected_level:selected_level=0
   if matches(p,aliases,sport):selected_level=level
   continue
  if p.length()<25:continue
  if selected_level>0 or matches(p,aliases,sport):
   if p not in result:result.append(p)
 return result
