extends SceneTree
var app
var errors=[]
func _initialize():call_deferred("run")
func check(ok:bool,msg:String):
 print(msg,": ",ok)
 if not ok:errors.append(msg);push_error(msg)
func shot(name:String):
 await process_frame;await process_frame
 if DisplayServer.get_name()!="headless":root.get_texture().get_image().save_png("/tmp/v14_"+name+".png")
func run():
 app=load("res://main.tscn").instantiate();app.skip_monthly_sync=true
 app.monthly_sync=preload("res://monthly_sync.gd").new();app.monthly_sync.storage_path="user://qa14_monthly.json"
 root.add_child(app);await process_frame;await process_frame
 var j=app.journey;j.store.path="user://qa14_ui.json";j.store.data.quizzes={};j.store.data.routes={};j.store.data.read={};j.store.data.saved=[];j.store.data.explored={};j.store.data.opened={}
 if j.store.discoveries.size()<60:check(false,"Real editorial catalogue ready");quit(1);return
 await shot("home")
 var favorites=app.bookmarks.duplicate();app.bookmarks=["FRA","TUR"]
 j.open_hub();await shot("hub")
 var d=j.store.discovery_for(j.date);j.navigate({"kind":"discovery","id":d.id});await shot("discovery")
 app.scroll.scroll_vertical=400;await process_frame
 j.country(d.code,d.topic);await process_frame;await process_frame
 check(app.selected==d.code and app.active_topic==d.topic,"Discovery opens correct country and topic")
 j.back();await process_frame;await process_frame;await process_frame
 check(j.screen.kind=="discovery" and app.scroll.scroll_vertical>0,"Country returns to discovery reading position")
 j.navigate({"kind":"quiz","date":j.date});await shot("quiz")
 j.store.answer(j.date,int(j.store.question(j.store.quiz(j.date).ids[0]).correct));j.render(j.screen);await shot("answer")
 check(not j.store.attempt(j.date).answers[-1].reviewed,"Explanation saved before Next")
 var r=j.store.routes[0];j.navigate({"kind":"route","id":r.id});await shot("route")
 j.store.complete_step(r.id,0);j.country(r.steps[0].code,r.steps[0].topic);await process_frame;j.back();await process_frame
 check(j.screen.kind=="route" and j.store.route_progress(r.id).done.size()==1,"Route return keeps progress")
 app.show_country("FRA","Histoire");await process_frame
 for c in app.sheet.get_children():
  if c is VBoxContainer and c.get_child_count()>1 and c.get_child(0) is Button:c.get_child(0).button_pressed=true;break
 await process_frame;app.scroll.scroll_vertical=300;await process_frame
 app.show_bookmarks();await process_frame
 check(j.store.data.last_read.kind=="country" and j.store.data.last_read.topic=="Histoire","Last country/topic retained")
 check(app.bookmarks==["FRA","TUR"],"Legacy favorites preserved")
 j.resume();await process_frame;await process_frame;await process_frame
 check(app.active_topic=="Histoire" and app.scroll.scroll_vertical>0,"Reading resumes expanded section and scroll")
 j.capture(true);check(not j.reading.is_empty(),"Periodic save preserves active reading tracking")
 j.open_hub();j.capture(true);check(j.reading.is_empty(),"Saving a non-reading screen does not revive a stale reading")
 j.store.mark_read(d);app.show_bookmarks();await shot("carnet")
 j.navigate({"kind":"progress"});await shot("progress")
 # Delayed recorded response, while using the application.
 var sync=app.monthly_sync;sync.state={"plan_version":7,"completed_cycle":"2026-10-15","cycle":sync.cycle_for(Time.get_date_dict_from_system())};sync.jobs=[sync.job("facts","https://raw.githubusercontent.com/facts",100,"Pays")];sync.request_gap=0
 sync.transport_override=func(_url):
  await create_timer(0.6).timeout
  return {"result":HTTPRequest.RESULT_SUCCESS,"code":200,"headers":[],"body":FileAccess.get_file_as_string("res://tests/fixtures/facts.txt").to_utf8_buffer()}
 app.run_monthly_startup();await process_frame
 app.continue_monthly();j.open_hub()
 check(sync.running and not sync.cancelled,"Continue hides overlay without cancelling update")
 check(is_instance_valid(app.modal) and j.screen.kind=="hub","App usable during update")
 await create_timer(1.5).timeout
 check(not sync.running and sync.jobs[0].done,"Update checkpoint finishes behind app")
 app.bookmarks=favorites
 for path in ["user://qa14_ui.json","user://qa14_monthly.json"]:
  for suffix in ["",".tmp",".bak"]:DirAccess.remove_absolute(ProjectSettings.globalize_path(path+suffix))
 print("EXPERIENCE V14: ","PASS" if errors.is_empty() else errors)
 quit(0 if errors.is_empty() else 1)
