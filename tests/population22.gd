extends SceneTree
var app
var failed=[]
func _initialize():call_deferred("run")
func check(ok:bool,message:String):
 print(message,": ",ok)
 if not ok:failed.append(message)
func run():
 app=load("res://main.tscn").instantiate();root.add_child(app)
 await process_frame;await process_frame
 var valid=true
 for code in app.countries:
  var last=INF
  for city in app.ranked_cities(code):
   var value=float(city.population if city.get("population")!=null else -1)
   if value>last:valid=false
   last=value
 check(valid,"All country lists descending, unknown values last")
 check(app.ranked_cities("TUR")[0].name=="Istanbul","Istanbul precedes capital Ankara")
 var fra=app.ranked_cities("FRA")
 check(fra[0].name=="Paris" and fra[1].name=="Marseille" and fra[2].name=="Lyon","French city population order")
 check(app.ranked_cities("USA","California")[0].en=="Los Angeles","US cities sorted within state")
 var backup=app.cities
 app.cities=[{"code":"FRA","name":"Z","population":null},{"code":"FRA","name":"B","population":100},{"code":"FRA","name":"A","population":100},{"code":"FRA","name":"C","population":200}]
 var sorted=app.ranked_cities("FRA")
 check(sorted[0].name=="C" and sorted[1].name=="A" and sorted[3].name=="Z","Ties alphabetical and unknown population last")
 app.cities=backup
 check(app.content_sync.valid_bundle({"schema":1,"revision":1,"data":{"cities":app.cities}}),"Population catalogue passes update validation")
 app.show_country("TUR","Villes");await process_frame;await process_frame
 root.get_texture().get_image().save_png(OS.get_user_data_dir()+"/qa22_cities.png")
 app.show_state_cities("California");await process_frame;await process_frame
 root.get_texture().get_image().save_png(OS.get_user_data_dir()+"/qa22_state.png")
 print("POPULATION CHECKS: ","PASS" if failed.is_empty() else failed)
 quit(0 if failed.is_empty() else 1)
