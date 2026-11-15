extends SceneTree
var g
func _initialize():call_deferred("run")
func shot(name:String):
	await process_frame
	await process_frame
	await create_timer(0.25).timeout
	root.get_texture().get_image().save_png(OS.get_user_data_dir()+"/qa_"+name+".png")
func run():
	g=load("res://main.tscn").instantiate();root.add_child(g)
	await shot("home")
	g.map.focus("FRA");g.select_country("FRA")
	await shot("selected")
	g.show_country("FRA")
	await shot("country")
	g.show_country("FRA","Histoire")
	await shot("history")
	g.show_compare()
	await shot("compare")
	g.set_mode("Conflits");g.map.focus("UKR")
	await shot("conflicts")
	g.show_event(0)
	await shot("event")
	g.show_search();g.search_input.text="Istanbul";g.search_input.text_changed.emit("Istanbul")
	await shot("search")
	g.show_explore()
	await shot("explore")
	g.show_about()
	await shot("about")
	quit()
