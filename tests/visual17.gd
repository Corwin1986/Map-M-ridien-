extends SceneTree
var app
func _initialize():call_deferred("run")
func shot(name:String):
 await create_timer(0.3).timeout
 root.get_texture().get_image().save_png("/tmp/v17_"+name+".png")
func run():
 app=load("res://main.tscn").instantiate();app.skip_monthly_sync=true;root.add_child(app)
 await process_frame;await process_frame
 app.journey.store.path="user://qa17_visual.json"
 app.journey.store.data.daily_closed={};app.journey.store.data.quizzes={}
 app.home_card();await shot("home")
 app.show_country("ITA");await shot("country")
 app.show_country("FRA","Histoire");await shot("history")
 app.show_country("NER","Géographie");await shot("relief")
 app.show_country("COD");await shot("long_name")
 app.show_compare();await shot("compare")
 app.journey.open_hub();await shot("discover")
 app.journey.navigate({"kind":"quiz","date":app.journey.date});await shot("quiz")
 app.show_bookmarks();await shot("carnet")
 for suffix in ["",".tmp",".bak"]:DirAccess.remove_absolute(ProjectSettings.globalize_path(app.journey.store.path+suffix))
 print("VISUAL V17: screenshots complete")
 quit()
