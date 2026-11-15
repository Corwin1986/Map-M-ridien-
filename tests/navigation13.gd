extends SceneTree
var app
var failures=[]
func _initialize():call_deferred("run")
func check(value:bool,message:String):
 print(message,": ",value)
 if not value:failures.append(message)
func tap(at:Vector2):
 var e=InputEventScreenTouch.new();e.index=0;e.position=at;e.pressed=true;Input.parse_input_event(e)
 await process_frame
 e=InputEventScreenTouch.new();e.index=0;e.position=at;e.pressed=false;Input.parse_input_event(e)
 await process_frame;await process_frame
func run():
 app=load("res://main.tscn").instantiate();root.add_child(app)
 await process_frame;await process_frame
 app.show_country("DZA","Histoire");await process_frame;await process_frame
 check(app.bottom.get_child_count()==3,"Three footer buttons")
 root.get_texture().get_image().save_png(OS.get_user_data_dir()+"/qa13_country.png")
 for i in range(11):
  await tap(app.modal.get_node("ChooseTopic").get_global_rect().get_center())
  check(app.sheet.get_child(0) is GridContainer,"Touch opens chooser "+str(i))
  if not app.sheet.get_child(0) is GridContainer:break
  await tap(app.sheet.get_child(0).get_child((i+1)%12).get_global_rect().get_center())
  check(app.active_topic==app.TOPICS[(i+1)%12],"Touch changes topic "+str(i))
  app.scroll.scroll_vertical=350;await process_frame
 # A fast tap after a text gesture must not be swallowed by synthetic mouse suppression.
 app.show_country("HND","Histoire");await process_frame;await process_frame
 var at=app.scroll.get_global_rect().get_center()
 var e=InputEventScreenTouch.new();e.index=0;e.pressed=true;e.position=at;Input.parse_input_event(e)
 var drag=InputEventScreenDrag.new();drag.index=0;drag.position=at-Vector2(0,120);drag.relative=Vector2(0,-120);Input.parse_input_event(drag)
 e=InputEventScreenTouch.new();e.index=0;e.pressed=false;e.position=drag.position;Input.parse_input_event(e)
 await tap(app.modal.get_node("ChooseTopic").get_global_rect().get_center())
 check(app.sheet.get_child(0) is GridContainer,"Immediate change after reading gesture")
 root.get_texture().get_image().save_png(OS.get_user_data_dir()+"/qa13_topics.png")
 app.show_country("DZA","Sources");await process_frame;await process_frame
 await tap(app.modal.get_node("NextTopic").get_global_rect().get_center())
 check(app.active_topic=="L’essentiel","Next wraps around")
 await tap(app.modal.get_node("PreviousTopic").get_global_rect().get_center())
 check(app.active_topic=="Sources","Previous wraps around")
 app.set_mode("Pays");await process_frame;await process_frame
 root.get_texture().get_image().save_png(OS.get_user_data_dir()+"/qa13_home.png")
 print("NAVIGATION: ","PASS" if failures.is_empty() else failures)
 quit(0 if failures.is_empty() else 1)
