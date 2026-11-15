extends SceneTree
var app
var errors=[]
func _initialize():call_deferred("run")
func check(ok:bool,msg:String):
 if not ok:errors.append(msg);push_error(msg)
func texts(node:Node)->String:
 var result=""
 if node is Label or node is Button or node is RichTextLabel:result+=str(node.text)+"\n"
 for child in node.get_children():result+=texts(child)
 return result
func shot(name:String):
 await process_frame;await process_frame
 if DisplayServer.get_name()!="headless":root.get_texture().get_image().save_png("/tmp/catalog10_"+name+".png")
func run():
 app=load("res://main.tscn").instantiate();app.skip_monthly_sync=true;root.add_child(app)
 await process_frame;await process_frame
 check(app.TOPICS.has("Personnalités marquantes"),"Renamed personalities tab")
 check(app.people.size()>10000,"Expanded global people catalogue")
 for surname in ["Berlusconi","Maldini","Ferrari"]:check(not app.people_for("ITA","Tous les domaines",surname).is_empty(),"Italian example present "+surname)
 for code in ["FRA","ITA","DZA","TUR","USA","IND","BRA","JPN"]:
  check(app.people_for(code).size()>10,"Expanded profiles "+code)
 app.show_country("ITA","Conflits");await process_frame
 var list=texts(app.sheet)
 check(not "Guerre de Crimée" in list and not "Boxers" in list,"Minor Italian participation excluded from default list")
 check("Autres engagements" in list,"Secondary list reachable")
 app.show_secondary_conflicts("ITA");await process_frame
 check("Guerre de Crimée" in texts(app.sheet) and "Boxers" in texts(app.sheet),"Secondary engagements preserved")
 await shot("secondary")
 for war in app.conflict_history:
  check(app.conflict_roles.has(war.id),"Roles for "+war.id)
  for code in war.codes:check(app.conflict_roles.get(war.id,{}).has(code),"Country role "+war.id+code)
  if war.name=="Guerre de Crimée":
   app.show_war(war,"ITA");await process_frame
   check("Pourquoi ce pays est concerné" in texts(app.sheet),"Country-specific role explanation")
   await shot("war")
 app.show_people_catalog("ITA","Tous les domaines","Maldini",0);await process_frame
 check("Maldini" in texts(app.sheet),"People search")
 await shot("people_search")
 app.show_people_catalog("ITA","Sport","",0);await process_frame
 check("Voir davantage" in texts(app.sheet),"People pagination")
 print("ROLES / PERSONNALITES V10: ","PASS" if errors.is_empty() else errors)
 quit(0 if errors.is_empty() else 1)
