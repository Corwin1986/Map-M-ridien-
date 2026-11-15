extends RefCounted

# Assign each source paragraph once, using its nearest thematic heading.
# Child headings override the parent: religions/languages inside demographics
# must not leak back into the population tab. Works on refreshed articles too.
static func category(title:String)->String:
	var t=title.to_lower()
	for term in ["religio","croyance","culte","confession"]:
		if term in t:return "Religion"
	for term in ["langue","linguist","idiome"]:
		if term in t:return "Langue"
	for term in ["démograph","population","peuplement","ethni","fécond","natalité","mortalité","migration","diaspora","espérance de vie"]:
		if term in t:return "Population"
	for term in ["géograph","relief","climat","géolog","topograph","hydrograph","environnement","biodivers","faune","flore","localisation","frontières"]:
		if term in t:return "Géographie"
	return ""

static func extract(text:String)->Dictionary:
	var result={"Population":[],"Religion":[],"Langue":[],"Géographie":[]}
	var regex=RegEx.new();regex.compile("(?m)^(={2,6})[ \\t]+([^\\n]+?)[ \\t]+=+[ \\t]*$")
	var headings=regex.search_all(text)
	var stack:Array=[]
	for i in headings.size():
		var h=headings[i];var level=h.get_string(1).length();var title=h.get_string(2).strip_edges()
		while not stack.is_empty() and int(stack[-1].level)>=level:stack.pop_back()
		var group=category(title)
		if group=="" and not stack.is_empty():group=stack[-1].group
		if title.to_lower() in ["notes et références","notes","références","bibliographie","voir aussi","liens externes","culture","histoire","économie","politique","éducation","enseignement","santé","sport","sports","médias","musique","cinéma","littérature","gastronomie","cuisine"]:group=""
		stack.append({"level":level,"group":group})
		var end=headings[i+1].get_start() if i+1<headings.size() else text.length()
		var body=text.substr(h.get_end(),end-h.get_end()).strip_edges()
		if group!="" and body!="":result[group].append({"title":title,"text":body})
	return result
