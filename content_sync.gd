extends Node
# Data-only update channel. Empty URL in this edition: no network requests.
const CONFIG_PATH="res://data/update_config.json"
const CACHE_PATH="user://content_update.json"
const META_PATH="user://content_update_meta.json"
const MAX_PAYLOAD=100*1024*1024
var config:Dictionary={}
var cached:Dictionary={}
var meta:Dictionary={}
var request:HTTPRequest
var pending:Dictionary={}
var phase=""
var last_message=""

func _ready():
	config=read_dictionary(CONFIG_PATH)
	meta=read_dictionary(META_PATH)
	var candidate=read_dictionary(CACHE_PATH)
	if not valid_bundle(candidate):candidate=read_dictionary(CACHE_PATH+".bak")
	if valid_bundle(candidate) and candidate.revision>int(config.get("bundled_revision",0)):cached=candidate
	request=HTTPRequest.new();request.timeout=30;request.body_size_limit=MAX_PAYLOAD
	add_child(request);request.request_completed.connect(completed)

func read_dictionary(path:String)->Dictionary:
	if not FileAccess.file_exists(path):return {}
	var value=JSON.parse_string(FileAccess.get_file_as_string(path))
	return value if value is Dictionary else {}

func content(key:String,fallback):
	return cached.get("data",{}).get(key,fallback)

func configured()->bool:
	return config.get("enabled",false) and str(config.get("manifest_url","")).begins_with("https://")

func status_text()->String:
	if not configured():return "Service en ligne non activé dans cette édition. Les données sont celles du 14 novembre 2026 ; les observations UCDP restent datées de septembre 2026. Aucune nouvelle guerre ne peut apparaître automatiquement aujourd’hui."
	return "Vérification hebdomadaire activée. Révision enregistrée : "+str(cached.get("revision",0))+". "+last_message+" Les contenus téléchargés sont appliqués au prochain lancement."

func check_if_due():
	var now=Time.get_unix_time_from_system()
	if now-float(meta.get("checked_at",0))>=604800 and now-float(meta.get("attempted_at",0))>=3600:check_now()

func check_now():
	if not configured() or phase!="":return
	meta["attempted_at"]=Time.get_unix_time_from_system();write_meta()
	phase="manifest";request.body_size_limit=65536
	var error=request.request(config.manifest_url)
	if error!=OK:fail("Vérification impossible ; la copie hors connexion est conservée.")

func origin(url:String)->String:
	if not url.begins_with("https://"):return ""
	return url.substr(8).split("/")[0]

func completed(result:int,code:int,_headers:PackedStringArray,body:PackedByteArray):
	if result!=HTTPRequest.RESULT_SUCCESS or code!=200:
		fail("Serveur indisponible ou réponse non valide ; copie conservée.");return
	var parsed=JSON.parse_string(body.get_string_from_utf8())
	if not parsed is Dictionary:fail("Format de mise à jour non valide.");return
	if phase=="manifest":
		if parsed.get("schema",0)!=1 or not parsed.get("revision",null) is float or parsed.get("revision",0)<1:
			fail("Version de manifeste non prise en charge.");return
		if int(parsed.get("min_app_code",3))>19:fail("Cette mise à jour nécessite une nouvelle version de l’application.");return
		if parsed.revision<=maxf(float(cached.get("revision",0)),float(config.get("bundled_revision",0))):mark_checked();phase="";last_message="Aucune nouvelle révision.";return
		var url=str(parsed.get("url",""));var hash=str(parsed.get("sha256",""))
		var reg=RegEx.new();reg.compile("^[0-9a-f]{64}$")
		if origin(url)=="" or origin(url)!=origin(config.manifest_url) or reg.search(hash)==null or parsed.get("bytes",0)<=0 or parsed.get("bytes",0)>MAX_PAYLOAD:
			fail("Manifeste rejeté : origine, taille ou empreinte incorrecte.");return
		pending=parsed;phase="payload";request.body_size_limit=int(parsed.bytes)
		var error=request.request(url)
		if error!=OK:fail("Téléchargement impossible ; copie conservée.")
	elif phase=="payload":
		var hashing=HashingContext.new();hashing.start(HashingContext.HASH_SHA256);hashing.update(body)
		if body.size()!=int(pending.bytes) or hashing.finish().hex_encode()!=pending.sha256 or parsed.get("revision",0)!=pending.revision or not valid_bundle(parsed):
			fail("Contenu rejeté : contrôle d’intégrité ou de structure échoué.");return
		var merged=cached.duplicate(true) if not cached.is_empty() else {"schema":1,"revision":0,"data":{}}
		for key in parsed.data:
			if key=="articles":
				var old:Dictionary=merged.data.get("articles",{});old.merge(parsed.data.articles,true);merged.data.articles=old
			else:merged.data[key]=parsed.data[key]
		merged.revision=parsed.revision
		if not valid_bundle(merged):fail("Contenu fusionné non valide.");return
		var file=FileAccess.open(CACHE_PATH+".tmp",FileAccess.WRITE)
		if file==null:fail("Espace de stockage indisponible.");return
		file.store_string(JSON.stringify(merged));file.close()
		if not valid_bundle(read_dictionary(CACHE_PATH+".tmp")):fail("Écriture incomplète ; copie précédente conservée.");return
		var target=ProjectSettings.globalize_path(CACHE_PATH)
		if FileAccess.file_exists(CACHE_PATH):
			if FileAccess.file_exists(CACHE_PATH+".bak"):DirAccess.remove_absolute(target+".bak")
			if DirAccess.rename_absolute(target,target+".bak")!=OK:fail("Impossible de préserver la copie précédente.");return
		if DirAccess.rename_absolute(target+".tmp",target)!=OK:
			if FileAccess.file_exists(CACHE_PATH+".bak"):DirAccess.rename_absolute(target+".bak",target)
			fail("Enregistrement impossible ; copie précédente conservée.");return
		cached=merged;mark_checked();phase="";last_message="Nouvelle révision téléchargée. Relancez Méridien pour l’appliquer."

func valid_bundle(value)->bool:
	if not value is Dictionary or value.get("schema",0)!=1 or not value.get("revision",null) is float and not value.get("revision",null) is int or value.get("revision",0)<1 or not value.get("data",null) is Dictionary:return false
	var data:Dictionary=value.data
	if data.is_empty():return false
	if data.has("events")!=data.has("observation_info"):return false
	var country_codes=read_dictionary("res://data/countries.json")
	for key in data:
		if key not in ["articles","cities","people","cuisines","conflict_history","events","observation_info","recipes"]:return false
		if key=="recipes":
			if not valid_recipes(data[key],country_codes):return false
			continue
		if key=="observation_info":
			if not data[key] is Dictionary:return false
			for field in ["period","version","retrieved"]:
				if not data[key].get(field,null) is String:return false
			continue
		if key in ["articles","cuisines"]:
			if not data[key] is Dictionary:return false
			for item in data[key].values():
				if not item is Dictionary:return false
				if key=="articles" and (not item.get("text",null) is String or not item.get("title",null) is String or not str(item.get("url","")).begins_with("https://")):return false
				if key=="cuisines" and (not item.get("article",null) is String or not country_codes.has(item.get("code",""))):return false
		else:
			if not data[key] is Array:return false
			for item in data[key]:
				if not item is Dictionary:return false
				if key!="events" and not item.get("name",null) is String:return false
				if key=="events":
					for field in ["code","id","date","end","location","country","region","a","b","sources","status"]:
						if not item.get(field,null) is String:return false
					for field in ["type","lat","lon","best","low","high","precision"]:
						if not item.get(field,null) is float and not item.get(field,null) is int:return false
					if absf(item.lat)>90 or absf(item.lon)>190 or int(item.type) not in [1,2,3] or item.best<0:return false
					if not country_codes.has(item.code):return false
				if key=="cities":
					if not country_codes.has(item.get("code","")) or not item.get("id",null) is String or not item.get("capital",null) is bool:return false
					if item.get("population")!=null:
						if not item.population is float and not item.population is int:return false
						if item.population<0 or not item.get("population_year") is float and not item.get("population_year") is int:return false
						if not str(item.get("population_url","")).begins_with("https://"):return false
					for field in ["lat","lon"]:
						if not item.get(field,null) is float and not item.get(field,null) is int:return false
					if absf(item.lat)>90 or absf(item.lon)>190:return false
				if key=="people":
					if not country_codes.has(item.get("code","")):return false
					for field in ["qid","group","birth","place"]:
						if not item.get(field,null) is String:return false
				if key=="conflict_history":
					for field in ["id","article","period","wiki"]:
						if not item.get(field,null) is String:return false
					if not item.get("codes",null) is Array:return false
					for code in item.codes:
						if not country_codes.has(code):return false
					for field in ["start","lat","lon"]:
						if not item.get(field,null) is float and not item.get(field,null) is int:return false
					if item.get("end")!=null and not item.end is float and not item.end is int:return false
					if item.get("end")!=null and item.end<item.start:return false
					if absf(item.lat)>90 or absf(item.lon)>190:return false
	return true

func mark_checked():
	meta["checked_at"]=Time.get_unix_time_from_system();write_meta()
func write_meta():
	var file=FileAccess.open(META_PATH,FileAccess.WRITE)
	if file:file.store_string(JSON.stringify(meta))
func fail(message:String):
	last_message=message;phase="";pending={}

func valid_recipes(book,codes:Dictionary)->bool:
	if not book is Dictionary:return false
	for key in ["recipes","countries","unavailable"]:
		if not book.get(key,null) is Dictionary:return false
	if book.recipes.size()>3000:return false
	for id in book.recipes:
		var r=book.recipes[id]
		if not r is Dictionary:return false
		for key in ["id","name","servings","note"]:
			if not r.get(key,null) is String:return false
		if r.id!=id or not r.get("minutes",null) is float and not r.get("minutes",null) is int or r.minutes<=0:return false
		for key in ["ingredients","steps"]:
			if not r.get(key,null) is Array or r[key].is_empty() or r[key].size()>100:return false
			for line in r[key]:
				if not line is String or line.is_empty():return false
		if not r.get("source",null) is Dictionary or not str(r.source.get("url","")).begins_with("https://"):return false
	for code in book.countries:
		if not codes.has(code):return false
		var entry=book.countries[code]
		if not entry is Dictionary or not entry.get("note",null) is String or not entry.get("dishes",null) is Array:return false
		if entry.dishes.is_empty() or entry.dishes.size()>6:return false
		var seen={}
		for id in entry.dishes:
			if not id is String or not book.recipes.has(id) or seen.has(id):return false
			seen[id]=true
	for code in book.unavailable:
		if not codes.has(code) or not book.unavailable[code] is String or book.countries.has(code):return false
	return true
