extends SceneTree
var failures=[]
func check(value:bool,message:String):
	print(message,": ",value)
	if not value:failures.append(message)
func _initialize():call_deferred("run")
func touch(at:Vector2,pressed:bool):
	var e=InputEventScreenTouch.new();e.index=0;e.position=at;e.pressed=pressed;Input.parse_input_event(e)
func run():
	var app=load("res://main.tscn").instantiate();root.add_child(app)
	await process_frame;await process_frame
	check(app.top.get_child_count()==4,"No global tabs on home")
	app.select_country("HND");await process_frame
	check(not is_instance_valid(app.modal),"Country first shows summary only")
	app.show_country("HND","Histoire");await process_frame;await process_frame
	var body
	for node in app.sheet.get_children():
		if node is RichTextLabel and node.text.length()>1000:body=node;break
	check(body!=null,"History reader found")
	var at=body.global_position+Vector2(90,24)
	print("Body position ",body.global_position," scroll ",app.scroll.get_global_rect())
	touch(at,true);await process_frame
	var drag=InputEventScreenDrag.new();drag.index=0;drag.position=at-Vector2(0,110);drag.relative=Vector2(0,-110);Input.parse_input_event(drag)
	await process_frame
	check(app.scroll.scroll_vertical>=100,"Swipe scrolls text")
	check(body.get_selected_text()=="","Swipe does not select text")
	touch(drag.position,false);await process_frame
	body.velocity=0;app.scroll.scroll_vertical=0;await process_frame;await process_frame
	at=body.global_position+Vector2(90,24)
	touch(at,true);await create_timer(0.7).timeout;await process_frame
	print("Selected: ",body.get_selected_text())
	check(not body.get_selected_text().is_empty(),"Long press selects a word")
	var previous=app.scroll.scroll_vertical
	drag=InputEventScreenDrag.new();drag.index=0;drag.position=at+Vector2(120,45);drag.relative=Vector2(120,45);Input.parse_input_event(drag);await process_frame
	check(app.scroll.scroll_vertical==previous,"Selection drag does not scroll")
	touch(drag.position,false);await process_frame
	touch(at,true);drag=InputEventScreenDrag.new();drag.index=0;drag.position=at-Vector2(0,95);drag.relative=Vector2(0,-95);Input.parse_input_event(drag);await process_frame
	check(app.scroll.scroll_vertical>=90 and body.get_selected_text()=="","Next gesture returns to scrolling")
	touch(drag.position,false)
	app.show_country("FRA","Relief");await process_frame
	check(app.active_topic=="Relief","Relief country tab")
	root.get_texture().get_image().save_png(OS.get_user_data_dir()+"/qa_fix_relief.png")
	app.close_modal();app.selected="";app.home_card();await process_frame;await process_frame
	root.get_texture().get_image().save_png(OS.get_user_data_dir()+"/qa_fix_home.png")
	print("TOUCH CHECKS: ","PASS" if failures.is_empty() else failures)
	quit(0 if failures.is_empty() else 1)
