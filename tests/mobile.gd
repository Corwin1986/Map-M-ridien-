extends SceneTree
var app
func _initialize():call_deferred("run")
func capture(name:String):
	await process_frame;await process_frame
	root.get_texture().get_image().save_png(OS.get_user_data_dir()+"/qa_mobile_"+name+".png")
func run():
	app=load("res://main.tscn").instantiate();root.add_child(app)
	await capture("home")
	var start=Time.get_ticks_msec()
	for i in 60:
		app.map.center.x+=0.1
		app.map.queue_redraw()
		await process_frame
	print("PAN BENCHMARK: 60 frames in ",Time.get_ticks_msec()-start," ms (software GPU)")
	app.map.focus("FRA");app.show_country("FRA","Villes")
	await capture("cities")
	app.show_country("FRA","Économie")
	await capture("tabs")
	app.show_history_hub()
	await capture("timeline")
	app.set_mode("Histoire");app.map.focus("GRC")
	await capture("history_map")
	app.show_country_events("PSE",0)
	await capture("events")
	app.show_conflict(app.conflicts[0])
	await capture("conflict_reader")
	app.queue_free();await process_frame;quit()
