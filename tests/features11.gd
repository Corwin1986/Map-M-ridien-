extends SceneTree
var app
var errors=[]
func _initialize():call_deferred("run")
func check(ok:bool,msg:String):
	print(msg,": ",ok)
	if not ok:errors.append(msg);push_error(msg)
func texts(node:Node)->String:
	var result=""
	if node is Label or node is Button or node is RichTextLabel:result+=str(node.text)+"\n"
	for child in node.get_children():result+=texts(child)
	return result
func buttons(node:Node)->Array:
	var result=[]
	if node is Button:result.append(node)
	for child in node.get_children():result.append_array(buttons(child))
	return result
func shot(name:String):
	await process_frame;await process_frame
	if DisplayServer.get_name()!="headless":root.get_texture().get_image().save_png("/tmp/features11_"+name+".png")
func tap(p:Vector2):
	var e=InputEventScreenTouch.new();e.index=0;e.position=p;e.pressed=true;Input.parse_input_event(e);await process_frame
	e=InputEventScreenTouch.new();e.index=0;e.position=p;e.pressed=false;Input.parse_input_event(e);await process_frame;await process_frame
func run():
	app=load("res://main.tscn").instantiate();app.skip_monthly_sync=true;root.add_child(app)
	await process_frame;await process_frame
	app.show_country("ITA","Personnalités marquantes");await shot("categories")
	var category_buttons=buttons(app.sheet)
	var music
	for b in category_buttons:
		if b.text.begins_with("Musique"):music=b
	check(is_instance_valid(music),"Music category visible on country page")
	if is_instance_valid(music):
		await tap(music.get_global_rect().get_center())
		check("Vivaldi" in texts(app.sheet),"Touching category opens filtered musicians")
		await shot("music")
	for p in app.people_for("ITA"):
		if "Ötzi" in str(p.name):check(p.group!="Cinéma et scène","Ötzi corrected")
	app.show_country("FRA","Histoire");await shot("history_closed")
	var folds=[]
	for b in buttons(app.sheet):
		if b.toggle_mode:folds.append(b)
	check(folds.size()>3,"French history split into periods")
	if folds.size()>1:
		await tap(folds[0].get_global_rect().get_center())
		check(folds[0].button_pressed,"Touch opens chronological paragraph")
		check(folds[0].get_parent().get_child(1).visible,"Expanded text visible")
		await shot("history_open")
		await tap(folds[0].get_global_rect().get_center())
		check(not folds[0].get_parent().get_child(1).visible,"Second touch closes paragraph")
	for code in ["USA","ITA","CHN","BOL","CYP","ECU"]:
		app.show_country(code,"Histoire");await process_frame
		check(buttons(app.sheet).size()>1,"History available "+code)
	var saved_article=app.articles.FRA.duplicate(true)
	app.articles.FRA.text=str(app.articles.FRA.text).replace("== Histoire ==","== Histoire ==\n\nTest de contenu mensuel actualisé.")
	var refreshed=app.current_history("FRA")
	check("Test de contenu mensuel actualisé" in str(refreshed),"Refreshed source appears in historical accordions")
	app.articles.FRA=saved_article
	for code in ["FRA","USA","NPL","BOL","NZL","MCO","ATA"]:
		app.show_country(code,"Géographie");await shot("relief_"+code)
		check("ALTITUDE EN MÈTRES" in texts(app.sheet),"Relief legend "+code)
		for m in app.relief_maps.countries[code].maps:check(ResourceLoader.exists(m.file),"Bundled relief image "+code)
	app.show_country("USA","Géographie");await process_frame
	for b in buttons(app.sheet):
		if "Alaska" in b.text:b.pressed.emit();break
	await shot("alaska")
	check("ALTITUDE EN MÈTRES" in texts(app.sheet),"Switch relief region keeps legend")
	print("FEATURES V11: ","PASS" if errors.is_empty() else errors)
	quit(0 if errors.is_empty() else 1)
