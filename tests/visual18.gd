extends SceneTree
var app
var failures=[]
func _initialize():call_deferred("run")
func check(ok:bool,msg:String):
 print(msg,": ",ok)
 if not ok:failures.append(msg)
func shot(name:String):
 await create_timer(0.25).timeout
 root.get_texture().get_image().save_png("/tmp/v18_"+name+".png")
func run():
 app=load("res://main.tscn").instantiate();app.skip_monthly_sync=true;root.add_child(app)
 await process_frame;await process_frame
 app.journey.store.path="user://qa18_visual.json"
 app.show_country("FRA");check(app.modal.modulate.a==0,"Initial country fades in")
 await shot("country")
 app.show_country("FRA","Villes");check(app.modal.modulate.a==1,"Topic switch has no repeated fade")
 await shot("cities")
 var longest="FRA"
 for code in app.countries:
  if str(app.countries[code].name).length()>str(app.countries[longest].name).length():longest=code
 app.show_country(longest);await shot("long_name")
 var t=app.modal.get_node("SheetTitle")
 check(t.get_line_count()==2 and t.text.replace("\n"," ")==str(app.countries[longest].name) and t.get_minimum_size().y<=t.size.y,"Longest country title fits header")
 app.show_people_catalog("ITA");await shot("people")
 app.open_modal("Lecture","STRUCTURE TYPOGRAPHIQUE")
 var sample="Introduction.\n\n== Première période ==\nTexte un.\n\n=== Une évolution ===\nTexte deux."
 var article=app.article_paragraph(app.sheet,sample)
 await shot("article")
 check(not article.get_parsed_text().contains("==") and article.get_parsed_text().contains("Une évolution"),"Article headings rendered without markup or loss")
 app.show_compare();check(app.nav_section==2,"Compare highlighted");await shot("compare")
 app.journey.open_hub();check(app.nav_section==1,"Discover highlighted");await shot("discover")
 app.show_bookmarks();check(app.nav_section==3,"Notebook highlighted");await shot("carnet")
 app.set_mode("Pays");await process_frame;check(app.nav_section==0,"Map highlighted")
 app.map.focus("FRA");app.map.selected="FRA";app.map.queue_redraw();await shot("map_selected")
 for suffix in ["",".tmp",".bak"]:DirAccess.remove_absolute(ProjectSettings.globalize_path(app.journey.store.path+suffix))
 print("VISUAL V18: ","PASS" if failures.is_empty() else failures)
 quit(0 if failures.is_empty() else 1)
