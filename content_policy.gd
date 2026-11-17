extends RefCounted
# Editorial scope applies to bundled data, cached data and refreshed extracts.
static func excluded(text:String)->bool:
 var t=text.to_lower().replace("é","e").replace("è","e").replace("\u00a0"," ")
 return "identite sexuelle" in t or "identites sexuelles" in t

static func clean_text(text:String)->String:
 if not excluded(text):return text
 var regex=RegEx.new();regex.compile("(?m)^(={2,6})[ \\t]*(.*?)[ \\t]*=+[ \\t]*$")
 var headings=regex.search_all(text);var output="";var cursor=0;var i=0
 while i<headings.size():
  var h=headings[i]
  if not excluded(h.get_string(2)):i+=1;continue
  var level=h.get_string(1).length();var j=i+1
  while j<headings.size() and headings[j].get_string(1).length()>level:j+=1
  var end=headings[j].get_start() if j<headings.size() else text.length()
  output+=text.substr(cursor,h.get_start()-cursor);cursor=end;i=j
 output+=text.substr(cursor)
 var paragraphs=[]
 for part in output.split("\n\n"):
  if not excluded(part):paragraphs.append(part)
 return "\n\n".join(paragraphs)

static func clean_data(value):
 if value is String:return clean_text(value)
 if value is Array:
  var result=[]
  for item in value:
   if item is Dictionary and excluded(str(item.get("title",""))):continue
   result.append(clean_data(item))
  return result
 if value is Dictionary:
  var result={}
  for key in value:
   if not excluded(str(key)):result[key]=clean_data(value[key])
  return result
 return value
