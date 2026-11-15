extends RefCounted

# Conservative discrepancy detection, not an adjudication of historical truth.
static func person_issues(person:Dictionary,article:Dictionary)->Array:
	var issues:Array=[]
	var evidence={"birth":[],"death":[]}
	var text=str(article.get("text","")).split("\n")[0].substr(0,600)+"\n"+str(person.get("description",""))
	for field in ["birth","death"]:
		var reg=RegEx.new()
		reg.compile("\\b"+("né(?:e)?" if field=="birth" else "(?:mort(?:e)?|décédé(?:e)?)")+"\\s+(?:le\\s+|en\\s+|vers\\s+)?(?:[0-9]{1,2}(?:er)?\\s+(?:janvier|février|mars|avril|mai|juin|juillet|août|septembre|octobre|novembre|décembre)\\s+)?([12][0-9]{3})\\b")
		var match_date=reg.search(text)
		if match_date and match_date.get_string(1) not in evidence[field]:evidence[field].append(match_date.get_string(1))
		var value=str(person.get(field,""))
		for candidate in evidence[field]:
			if value.is_valid_int() and int(value)>0 and value!=candidate:
				issues.append({"field":field,"stored":value,"other":candidate,"message":("Naissance" if field=="birth" else "Décès")+" : "+value+" dans la fiche, "+candidate+" dans la description ou le texte. Dates à vérifier."})
	if str(person.get("birth","")).is_valid_int() and str(person.get("death","")).is_valid_int():
		if int(person.birth)>int(person.death):issues.append({"field":"dates","message":"La naissance indiquée est postérieure au décès. Dates à vérifier."})
	return issues

static func audit(people:Array,articles:Dictionary,countries:Dictionary)->Dictionary:
	var flagged={};var checked={};var missing_years=[]
	for person in people:
		var key=str(person.qid)
		if checked.has(key):continue
		checked[key]=true
		var issues=person_issues(person,articles.get(person.get("article","person_"+key),{}))
		if not issues.is_empty():flagged[key]={"name":person.name,"issues":issues}
	for code in countries:
		var c=countries[code]
		if c.get("population")!=null and float(c.population)>0 and (c.get("pop_year")==null or int(c.get("pop_year",0))==0):missing_years.append(code)
	return {"checked_at":Time.get_date_string_from_system(),"profiles_checked":checked.size(),"profiles_flagged":flagged.size(),"issues":flagged,"population_year_missing":missing_years,"scope":"Contrôle de cohérence des années biographiques et présence du millésime des populations. Aucune certification de l’ensemble des faits."}
