extends SceneTree
var app
var failures=[]
var picked=""
func _initialize():call_deferred("run")
func check(ok:bool,msg:String):
 print(msg,": ",ok)
 if not ok:failures.append(msg)
func hit(code:String,lon:float,lat:float):
 app.map.selected="";app.map.center=Vector2(lon,-lat);app.map.zoom=25;app.map.constrain()
 picked="";app.map.pick(app.map.project(lon,lat));check(picked==code,"Select "+code+" received "+picked)
func shot(name:String):
 await create_timer(.3).timeout
 root.get_texture().get_image().save_png("/tmp/v19_"+name+".png")
func run():
 app=load("res://main.tscn").instantiate();app.skip_monthly_sync=true;root.add_child(app)
 await process_frame;await process_frame
 app.journey.store.path="user://qa19.json"
 app.map.country_picked.connect(func(code):picked=code)
 for row in [["GUF",-53.1,4.1],["GLP",-61.68,16.16],["MTQ",-61.02,14.65],["PMD",-16.95,32.75],["PAZ",-25.50,37.79],["REU",55.53,-21.12],["FXC",9.1,42.2],["FRA",2.3,48.85],["PRT",-8.0,39.5],["ESC",-16.58,28.30],["MCO",7.419,43.732],["VAT",12.453,41.904],["NRU",166.932,-.52],["TUV",179.20,-8.52]]:hit(row[0],row[1],row[2])
 check(app.territory_name("GUF")=="Guyane / France","Territory heading")
 for code in ["GUF","PMD","MTQ"]:
  app.show_country(code);await shot(code)
  check(app.modal.get_node("SheetTitle").text.replace("\n"," ")==app.territory_name(code),"Full heading "+code)
  for topic in app.TOPICS:app.show_country(code,topic);await process_frame
 var old=app.read_json("res://data/territory_sources/base_countries.json")
 var old_cities=app.read_json("res://data/territory_sources/base_cities.json")
 app.monthly_sync.patch={"countries":old,"cities":old_cities}
 app.monthly_sync.apply_to(app)
 check(app.countries.has("PMD") and app.countries.GUF.parent_code=="FRA","V18 cache migration preserves territories")
 var funchal={}
 for city in app.cities:
  if city.name=="Funchal":funchal=city
 check(funchal.get("code")=="PMD","Funchal retains Madeira after old cache")
 check(app.countries.GUF.population!=app.countries.FRA.population,"Local population differs from parent")
 app.show_city(funchal);await shot("Funchal")
 app.close_modal();app.select_country("PMD");app.map.focus("PMD");await shot("map")
 var members=0
 for code in app.countries:
  if app.countries[code].un:members+=1
 check(members==193,"193 UN member records")
 app.show_country("ALD");check(app.selected=="ALA","Old Aland favorite redirect")
 print("TERRITORIES19: ","PASS" if failures.is_empty() else failures)
 quit(0 if failures.is_empty() else 1)
