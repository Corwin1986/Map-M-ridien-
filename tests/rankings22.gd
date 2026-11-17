extends SceneTree
var errors=[]
func _initialize():call_deferred("run")
func check(ok:bool,label:String):
 print(label,": ",ok)
 if not ok:errors.append(label)
func run():
 var app=load("res://main.tscn").instantiate();app.skip_monthly_sync=true;root.add_child(app)
 await process_frame;await process_frame
 var r=app.military_rankings
 check(r.global.size()==184 and r.active.size()==171,"Source coverage preserved")
 var total=0;var ranks=[]
 for code in r.global:
  check(app.countries.has(code),"Mapped global "+code)
  ranks.append(int(r.global[code].rank))
 ranks.sort()
 check(ranks==range(1,185),"Global ranks unique and complete")
 for code in r.active:
  var row=r.active[code];total+=int(row.value)
  var higher=0
  for other in r.active.values():
   if other.value>row.value:higher+=1
  if int(row.rank)!=higher+1:errors.append("Wrong active rank "+code)
  if int(row.year)!=2026:errors.append("Mixed year "+code)
 check(total==20440220,"Published active total matches")
 check(r.active.KOR.rank==r.active.VNM.rank,"Equal active counts share rank")
 check(app.military_position("global","FRA")=="6 / 184 · 2026","France global rank")
 check(app.military_position("active","FRA")=="21 / 171 · 2026","France personnel rank")
 check(app.military_position("global","GUF").begins_with("Non classé"),"Guyane does not inherit France rank")
 check(app.military_position("global","PSE").begins_with("Non classé"),"Unranked country not zero")
 app.show_country("FRA","Militaire");await process_frame;await process_frame
 if DisplayServer.get_name()!="headless":root.get_texture().get_image().save_png("res://tests/military22.png")
 app.show_compare();await process_frame;await process_frame
 app.scroll.scroll_vertical=600
 await process_frame;await process_frame
 if DisplayServer.get_name()!="headless":root.get_texture().get_image().save_png("res://tests/compare22.png")
 print("RANKINGS22: ","PASS" if errors.is_empty() else errors)
 quit(0 if errors.is_empty() else 1)
