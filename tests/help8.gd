extends SceneTree
var app
var errors=[]
func _initialize():call_deferred("run")
func check(ok:bool,msg:String):
 print(msg,": ",ok)
 if not ok:errors.append(msg)
func tap(p:Vector2):
 var e=InputEventScreenTouch.new();e.index=0;e.position=p;e.pressed=true;Input.parse_input_event(e);await process_frame
 e=InputEventScreenTouch.new();e.index=0;e.position=p;e.pressed=false;Input.parse_input_event(e);await process_frame;await process_frame
func run():
 app=load("res://main.tscn").instantiate();app.skip_monthly_sync=true;root.add_child(app)
 await process_frame;await process_frame
 check(app.selection.get_child_count()==3,"Only zoom controls remain on idle map")
 root.get_texture().get_image().save_png("/tmp/help8_map.png")
 var before=app.map.center
 await tap(Vector2(495,48))
 check(is_instance_valid(app.modal),"Header i opens help")
 root.get_texture().get_image().save_png("/tmp/help8_guide.png")
 await tap(Vector2(484,152))
 check(not is_instance_valid(app.modal),"Cross closes help")
 check(app.map.center==before,"Closing help preserves map position")
 var point=app.map.project(0,-80)+app.map.global_position
 await tap(point)
 check(app.selected=="ATA","Uncovered Antarctica selected by touch")
 app.show_help();await process_frame
 var found=false
 for child in app.sheet.get_children():
  if child is Button and child.text.begins_with("Sources"):
   child.pressed.emit();found=true;break
 await process_frame
 check(found and is_instance_valid(app.modal),"About and sources remain reachable")
 print("HELP V8: ","PASS" if errors.is_empty() else errors)
 quit(0 if errors.is_empty() else 1)
