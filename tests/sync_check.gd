extends SceneTree
var failures=[]
func _initialize():call_deferred("run")
func check(value:bool,message:String):
	print(message,": ",value)
	if not value:failures.append(message)
func bytes(value)->PackedByteArray:return JSON.stringify(value).to_utf8_buffer()
func digest(value:PackedByteArray)->String:
	var h=HashingContext.new();h.start(HashingContext.HASH_SHA256);h.update(value);return h.finish().hex_encode()
func run():
	var saved={}
	for path in ["user://content_update.json","user://content_update.json.bak","user://content_update_meta.json"]:
		if FileAccess.file_exists(path):saved[path]=FileAccess.get_file_as_bytes(path)
	var sync=load("res://content_sync.gd").new();root.add_child(sync);await process_frame
	sync.cached={}
	check(not sync.configured(),"Offline edition performs no request")
	var war={"id":"test_future","article":"test_future","name":"Fixture de validation","wiki":"Test","start":2027,"end":null,"codes":["FRA"],"lat":48.8,"lon":2.3,"period":"2027"}
	var bundle={"schema":1,"revision":1,"data":{"conflict_history":[war],"articles":{"test_future":{"title":"Fixture","text":"Texte de validation uniquement.","url":"https://example.org/source"}}}}
	check(sync.valid_bundle(bundle),"Future-year data accepted")
	var events=JSON.parse_string(FileAccess.get_file_as_string("res://data/events.json"))
	check(sync.valid_bundle({"schema":1,"revision":2,"data":{"events":events,"observation_info":{"period":"septembre 2026","version":"26.0.9","retrieved":"2026-11-14"}}}),"Dated observation update accepted")
	check(not sync.valid_bundle({"schema":1,"revision":2,"data":{"events":events}}),"Observations without dates rejected")
	check(not sync.valid_bundle({"schema":2,"revision":1,"data":bundle.data}),"Unknown schema rejected")
	var broken=bundle.duplicate(true);broken.data.conflict_history[0].lat=999
	check(not sync.valid_bundle(broken),"Invalid coordinates rejected")
	broken=bundle.duplicate(true);broken.data.conflict_history[0].codes=["FAKE"]
	check(not sync.valid_bundle(broken),"Unknown country rejected")
	sync.config={"enabled":true,"manifest_url":"https://atlas.example/manifest.json"};sync.phase="manifest"
	sync.completed(HTTPRequest.RESULT_SUCCESS,200,PackedStringArray(),bytes({"schema":1,"revision":2,"url":"https://other.example/content.json","sha256":"a".repeat(64),"bytes":20}))
	check(sync.phase=="" and sync.cached.is_empty(),"Foreign-origin payload rejected")
	var body=bytes(bundle)
	sync.pending={"revision":1,"sha256":"a".repeat(64),"bytes":body.size()};sync.phase="payload"
	sync.completed(HTTPRequest.RESULT_SUCCESS,200,PackedStringArray(),body)
	check(sync.cached.is_empty(),"Checksum failure preserves cache")
	sync.pending={"revision":1,"sha256":digest(body),"bytes":body.size()};sync.phase="payload"
	sync.completed(HTTPRequest.RESULT_SUCCESS,200,PackedStringArray(),body)
	check(sync.cached.get("revision",0)==1 and FileAccess.file_exists("user://content_update.json"),"Validated data saved atomically")
	var second={"schema":1,"revision":2,"data":{"articles":{"new":{"title":"Second fixture","text":"Delta","url":"https://example.org/new"}}}}
	body=bytes(second);sync.pending={"revision":2,"sha256":digest(body),"bytes":body.size()};sync.phase="payload"
	sync.completed(HTTPRequest.RESULT_SUCCESS,200,PackedStringArray(),body)
	check(sync.cached.data.articles.has("test_future") and sync.cached.data.articles.has("new"),"Article delta preserves previous content")
	check(FileAccess.file_exists("user://content_update.json.bak"),"Previous revision backed up")
	var old=sync.cached.duplicate(true);sync.phase="payload";sync.completed(HTTPRequest.RESULT_CANT_CONNECT,0,PackedStringArray(),PackedByteArray())
	check(sync.cached==old,"Network failure retains validated content")
	for path in ["user://content_update.json","user://content_update.json.bak","user://content_update.json.tmp","user://content_update_meta.json"]:
		if FileAccess.file_exists(path):DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
		if saved.has(path):
			var f=FileAccess.open(path,FileAccess.WRITE);f.store_buffer(saved[path]);f.close()
	print("SYNC CHECKS: ","PASS" if failures.is_empty() else failures)
	quit(0 if failures.is_empty() else 1)
