extends SceneTree
const Sync=preload("res://monthly_sync.gd")
var failed=[]
func _initialize():call_deferred("run")
func check(ok:bool,msg:String):
 print(msg,": ",ok)
 if not ok:failed.append(msg)
func run():
 var sync=Sync.new();sync.storage_path="user://qa5_ui.json";sync.request_gap=0.1
 sync.state={"plan_version":6,"completed_cycle":"2025-01-15","cycle":Sync.cycle_for(Time.get_date_dict_from_system())};sync.patch={}
 sync.jobs=[sync.job("facts","https://raw.githubusercontent.com/facts",50,"Pays et territoires"),sync.job("wb","https://api.worldbank.org/pop",50,"Populations",{"indicator":"SP.POP.TOTL"})]
 sync.save_cache()
 sync.transport_override=func(address):
  await create_timer(0.7).timeout
  var fixture="facts" if address.ends_with("facts") else "wb"
  return {"result":HTTPRequest.RESULT_SUCCESS,"code":200,"headers":[],"body":FileAccess.get_file_as_bytes("res://tests/fixtures/"+fixture+".txt")}
 var app=load("res://main.tscn").instantiate();app.monthly_sync=sync;root.add_child(app)
 await process_frame;await process_frame
 check(is_instance_valid(app.boot_overlay) and app.map==null,"Due startup displays update screen before map")
 await create_timer(1.0).timeout
 check(app.boot_bar.value>=50 and app.boot_bar.value<100,"Progress reflects completed source steps")
 root.get_texture().get_image().save_png(OS.get_user_data_dir()+"/qa5_update.png")
 await create_timer(0.9).timeout
 check(app.boot_bar.value==100,"Screen reaches 100 after saving")
 root.get_texture().get_image().save_png(OS.get_user_data_dir()+"/qa5_complete.png")
 await create_timer(1.0).timeout
 check(not is_instance_valid(app.boot_overlay) and app.map!=null,"Map opens automatically after completion")
 app.queue_free();await process_frame
 sync=Sync.new();sync.storage_path="user://qa5_ui.json"
 var calls=[];sync.transport_override=func(_url):calls.append(true);return {}
 app=load("res://main.tscn").instantiate();app.monthly_sync=sync;root.add_child(app)
 await process_frame;await process_frame
 check(not is_instance_valid(app.boot_overlay) and app.map!=null and calls.is_empty(),"No pending deadline means normal startup without network")
 for suffix in ["",".bak",".tmp"]:
  if FileAccess.file_exists(sync.storage_path+suffix):DirAccess.remove_absolute(ProjectSettings.globalize_path(sync.storage_path+suffix))
 print("MONTHLY UI V5: ","PASS" if failed.is_empty() else failed)
 quit(0 if failed.is_empty() else 1)
