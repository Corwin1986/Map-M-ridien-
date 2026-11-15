extends SceneTree
var failures:Array=[]
func check(ok:bool,msg:String):
	if not ok:failures.append(msg);push_error(msg)
func _initialize():call_deferred("run")
func run():
	var g=load("res://main.tscn").instantiate();root.add_child(g)
	await process_frame
	check(g.countries.size()>240,"World coverage")
	check(g.cities.size()>1000,"City coverage")
	check(g.countries.has("SOL") and g.countries.SOL.name=="Somaliland","Distinct Somaliland record")
	check(g.countries.SLB.cities.size()>=1,"Solomon Islands city association")
	check(g.events.size()==2014,"UCDP event count")
	check(g.countries.FRA.pop_year==2024,"Population dates")
	check(g.articles.FRA.get("text","").length()>10000,"French article loaded")
	var history=false
	for sec in g.sections_of(g.articles.FRA.text):
		if sec.title=="Histoire":history=true
	check(history,"History section extraction")
	g.map.focus("BRA")
	g.map.pick(g.map.project(-52,-10))
	check(g.selected=="BRA","Country polygon hit test")
	var before=g.map.geographic(Vector2(170,220))
	g.map.change_zoom(1.1,Vector2(170,220))
	check(before.distance_to(g.map.geographic(Vector2(170,220)))<0.001,"Anchored zoom")
	for topic in ["L’essentiel","Histoire","Villes","Conflits","Géographie","Relief","Personnages historiques","Gastronomie","Langues","Économie","Institutions","Sources"]:
		g.show_country("FRA",topic);await process_frame
		check(is_instance_valid(g.modal),"Country tab "+topic)
	g.show_search("a");g.search_input.text="Japon";g.search_input.text_changed.emit("Japon")
	await process_frame
	var results=g.sheet.get_child(1)
	check(results.get_child_count()==1,"Search country filtering")
	results.get_child(0).pressed.emit()
	await process_frame
	check(g.compare_a=="JPN","Comparison selection callback")
	g.show_search();g.search_input.text_changed.emit("Istanbul");await process_frame
	check(g.sheet.get_child(1).get_child_count()==1,"City search")
	g.sheet.get_child(1).get_child(0).pressed.emit();await process_frame
	check(is_instance_valid(g.modal),"City reader")
	for mode in ["Pays","Conflits","Histoire","Géographie","Population","Repères"]:
		g.set_mode(mode);await process_frame
		check(g.map.mode==mode,"Map mode "+mode)
	g.show_conflict_hub();await process_frame
	g.show_event(0);await process_frame
	g.show_explore();await process_frame
	g.show_history_hub();await process_frame
	g.show_place(0);await process_frame
	g.show_bookmarks();await process_frame
	g.show_about();await process_frame
	for e in g.events:
		if e.low>e.best or e.best>e.high:
			check(g.estimate_caption(e).contains("discordantes"),"Flag contradictory estimates "+e.id)
		check(e.lat>=-90 and e.lat<=90 and e.lon>=-180 and e.lon<=180,"Event coordinate "+e.id)
	print("FUNCTIONAL CHECKS: ","PASS" if failures.is_empty() else failures)
	g.queue_free();await process_frame
	quit(0 if failures.is_empty() else 1)
