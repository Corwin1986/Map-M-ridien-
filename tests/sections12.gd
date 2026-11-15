extends SceneTree
var app
var errors=[]
func _initialize():call_deferred("run")
func check(ok:bool,msg:String):
	if not ok:errors.append(msg);push_error(msg)
func joined(rows:Array)->String:
	var text=""
	for row in rows:text+=str(row.title)+"\n"+str(row.text)+"\n"
	return text
func shot(name:String):
	await process_frame;await process_frame
	if DisplayServer.get_name()!="headless":root.get_texture().get_image().save_png("/tmp/sections12_"+name+".png")
func run():
	app=load("res://main.tscn").instantiate();app.skip_monthly_sync=true;root.add_child(app)
	await process_frame;await process_frame
	check(not "Relief" in app.TOPICS and not "Langues" in app.TOPICS,"Old tabs removed")
	for topic in ["Population","Religion","Langue","Géographie"]:check(topic in app.TOPICS,"New tab "+topic)
	var fixture="== Population ==\nDemographics.\n=== Langues ===\nLanguage only.\n=== Religions ===\nReligion only.\n=== Fécondité ===\nFertility.\n== Géographie ==\nLandscape.\n=== Climat ===\nClimate."
	var split=app.TopicSections.extract(fixture)
	check(not "Religion only" in joined(split.Population),"Nested religions excluded from population")
	check(not "Language only" in joined(split.Population),"Nested languages excluded from population")
	check("Fertility" in joined(split.Population),"Fertility retained")
	check("Climate" in joined(split["Géographie"]),"Nested geography retained")
	var counts={"Population":0,"Religion":0,"Langue":0,"Géographie":0}
	for code in app.countries:
		var data=app.TopicSections.extract(app.articles.get(code,{}).get("text",""))
		for topic in counts:
			if not data[topic].is_empty():counts[topic]+=1
		if code in ["NER","FRA","USA","IND","JPN"]:
			for topic in counts:check(not data[topic].is_empty(),code+" "+topic+" documented")
	var n=app.TopicSections.extract(app.articles.NER.text)
	check("Émigration" in joined(n.Population) and "Fécondité" in joined(n.Population) and "Haoussas" in joined(n.Population),"Niger demographics migration fertility ethnicity retained")
	check(not "Religions" in joined(n.Population) and not "Langues" in joined(n.Population),"Niger tabs isolated")
	for topic in ["Population","Religion","Langue","Géographie"]:
		app.show_country("NER",topic);await shot(topic)
		if topic=="Géographie":
			check(app.sheet.get_child(0) is TextureRect,"Relief map is first content")
			var toggle
			for child in app.sheet.get_children():
				if child is VBoxContainer and child.get_child_count()>1 and child.get_child(0) is Button:toggle=child.get_child(0);break
			check(is_instance_valid(toggle),"Geography text is collapsible")
			if is_instance_valid(toggle):toggle.button_pressed=true;await shot("geography_open");check(toggle.get_parent().get_child(1).visible,"Geography expands inline")
	app.show_country("USA","Géographie");await process_frame
	for b in app.sheet.get_children():
		if b is Button and b.text=="Alaska":b.pressed.emit();break
	await shot("alaska")
	check(app.active_topic=="Géographie" and app.sheet.get_child(0) is TextureRect,"Region switch stays in Geography")
	print("Coverage by existing source sections: ",counts)
	print("SECTIONS V12: ","PASS" if errors.is_empty() else errors)
	quit(0 if errors.is_empty() else 1)
