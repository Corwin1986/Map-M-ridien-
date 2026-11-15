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
 if DisplayServer.get_name()!="headless":root.get_texture().get_image().save_png("/tmp/sports9_"+name+".png")
func run():
 app=load("res://main.tscn").instantiate();app.skip_monthly_sync=true;root.add_child(app)
 await process_frame;await process_frame
 check(not app.sports.has("licenses"),"No registered-player data remains")
 for code in app.countries:
  var selected:Array=app.sports.countries[code].selection
  check(selected.size()<=6,"Six sports maximum "+code)
  if app.countries[code].get("un",false):check(not selected.is_empty(),"UN member has sport content "+code)
 for code in ["BOL","USA","DZA","IND","TUV"]:
  app.show_country(code,"Sport");await process_frame
  var content=texts(app.sheet)
  check(not "licenci" in content.to_lower(),"No license block "+code)
  check("Sports populaires" in content,"New heading "+code)
  if code=="BOL":await shot("bolivia")
  for sport in app.sports.countries[code].selection:
   app.show_sport(code,sport);await process_frame
   check(not "plus de passage exploitable" in texts(app.sheet),"Sport content "+code+" "+sport)
 app.show_sport("USA","Basket-ball");await shot("usa")
 check("2024" in texts(app.sheet) and "Celtics" in texts(app.sheet),"USA honors and clubs")
 app.show_sport("BOL","Football");await shot("bolivia_football")
 check("1963" in texts(app.sheet),"Bolivia honors")
 app.show_country("ATA","Sport");await process_frame
 check(app.sports.countries.ATA.selection.is_empty(),"No fictional Antarctic national team")
 print("SPORTS V9: ","PASS" if errors.is_empty() else errors)
 quit(0 if errors.is_empty() else 1)
