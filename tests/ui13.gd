extends SceneTree
var app
var errors=[]
func _initialize():call_deferred("run")
func check(ok:bool,msg:String):
 if not ok:errors.append(msg);push_error(msg)
func texts(node:Node)->String:
 var s=""
 if node is Label or node is Button or node is RichTextLabel:s+=node.text+"\n"
 for child in node.get_children():s+=texts(child)
 return s
func shot(name:String):
 await process_frame;await process_frame
 root.get_texture().get_image().save_png("/tmp/ui13_"+name+".png")
func run():
 app=load("res://main.tscn").instantiate();app.skip_monthly_sync=true;root.add_child(app)
 await process_frame;await process_frame
 app.monthly_sync.state={};app.monthly_sync.jobs=[]
 app.show_updates();await shot("updates")
 check("Aucune actualisation mensuelle complète" in texts(app.sheet),"No fabricated completion on fresh installation")
 check("Dernière échéance terminée" not in texts(app.sheet),"Base cycle not reported as fetched")
 app.show_quality();await shot("quality")
 app.show_country("FRA","Population");await shot("population")
 check("Année de référence" in texts(app.sheet),"Population reference year visible")
 check("Signaler une erreur" in texts(app.sheet),"Country reporting available")
 for p in app.people:
  if p.qid=="Q468234":app.show_person(p);break
 await shot("bishop")
 check("1944" in texts(app.sheet) and "Dates à vérifier" not in texts(app.sheet),"Corrected Bishop shown")
 app.show_feedback("Essai test","",true);await shot("feedback")
 check("Rien n’est envoyé automatiquement" in texts(app.sheet),"Local feedback is explicit")
 var report={"version":"Méridien V13","date":"2026-11-15","context":"Exemple","source":"","comment":"Texte de test","kind":"Essai"}
 app.show_saved_feedback(report);await shot("saved")
 check("Copier pour partager" in texts(app.sheet),"Manual sharing available")
 print("UI V13: ","PASS" if errors.is_empty() else errors)
 quit(0 if errors.is_empty() else 1)
