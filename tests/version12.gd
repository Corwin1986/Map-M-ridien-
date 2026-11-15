extends SceneTree
var app
var failures=[]
func _initialize():call_deferred("run")
func check(value:bool,message:String):
	print(message,": ",value)
	if not value:failures.append(message)
func shot(name:String):
	await process_frame;await process_frame
	root.get_texture().get_image().save_png(OS.get_user_data_dir()+"/qa12_"+name+".png")
func run():
	app=load("res://main.tscn").instantiate();root.add_child(app)
	await process_frame;await process_frame
	check(app.cities.size()>1000,"Cities expanded")
	var states={};var algeria=[]
	for city in app.cities:
		if city.code=="USA":states[city.region]=states.get(city.region,0)+1
		if city.code=="DZA":algeria.append(city.name)
	check(states.size()==51,"50 US states and DC")
	check(algeria.size()==10 and "Oran" in algeria and "Constantine" in algeria,"Algerian cities")
	app.show_country("DZA","Villes");await shot("cities")
	check(app.scroll.position.y==208,"Pinned topic selector")
	# Actual buttons: next from Villes -> Conflits and all-topic chooser.
	app.modal.get_child(app.modal.get_child_count()-1).pressed.emit();await process_frame
	check(app.active_topic=="Conflits","Next topic button")
	await shot("conflicts")
	app.show_topics("DZA","Conflits");await shot("topics")
	check(app.sheet.get_child(0).get_child_count()==12,"All topics reachable without swiping")
	app.sheet.get_child(0).get_child(10).pressed.emit();await process_frame
	check(app.active_topic=="Gastronomie","Topic chooser callback")
	await shot("food")
	app.show_country("TUR","Personnages historiques");await shot("people")
	app.show_country("USA","Villes");await shot("states")
	app.show_state_cities("California");await shot("california")
	var count=0
	for war in app.conflict_history:
		if "DZA" in war.codes:count+=1
	check(count>=4,"Algerian conflict history")
	app.show_conflict_hub();await shot("wars")
	app.set_mode("Conflits");await shot("map")
	check(app.map.wars.size()>=150,"Historical map layer")
	app.show_updates();await shot("updates")
	check(not app.content_sync.configured(),"Live updates disabled explicitly")
	app.show_country("HND","Histoire");await process_frame;await process_frame
	var body
	for node in app.sheet.get_children():
		if node is RichTextLabel and node.text.length()>1000:body=node;break
	var at=body.global_position+Vector2(90,24)
	var touch=InputEventScreenTouch.new();touch.index=0;touch.position=at;touch.pressed=true;Input.parse_input_event(touch)
	var drag=InputEventScreenDrag.new();drag.index=0;drag.position=at-Vector2(0,110);drag.relative=Vector2(0,-110);Input.parse_input_event(drag);await process_frame
	check(app.scroll.scroll_vertical>=100 and body.get_selected_text()=="","Text swipe regression")
	touch=InputEventScreenTouch.new();touch.index=0;touch.position=drag.position;touch.pressed=false;Input.parse_input_event(touch)
	print("VERSION12 CHECKS: ","PASS" if failures.is_empty() else failures)
	quit(0 if failures.is_empty() else 1)
