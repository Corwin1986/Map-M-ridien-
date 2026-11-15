extends SceneTree
var app
var failed=[]
func _initialize():call_deferred("run")
func check(ok:bool,message:String):
 print(message,": ",ok)
 if not ok:failed.append(message)
func bounded(m)->bool:
 var a=m.geographic(Vector2.ZERO);var b=m.geographic(m.size)
 return a.x>=-180.001 and a.y>=-90.001 and b.x<=180.001 and b.y<=90.001
func shot(name:String):
 await process_frame;await process_frame
 root.get_texture().get_image().save_png("/tmp/qa7_"+name+".png")
func run():
 app=load("res://main.tscn").instantiate();app.skip_monthly_sync=true;root.add_child(app)
 await process_frame;await process_frame
 var m=app.map
 var original=m.size
 for dims in [Vector2(540,774),Vector2(540,1100),Vector2(960,540)]:
  m.size=dims;m.world_view();check(bounded(m),"World viewport filled "+str(dims))
  for z in [1.0,2.0,10.0,38.0]:
   m.zoom=z
   for center in [Vector2(-9999,-9999),Vector2(9999,9999),Vector2(-9999,9999),Vector2(9999,-9999)]:
    m.center=center;m.constrain();check(bounded(m),"No overscroll "+str(dims)+" "+str(z)+" "+str(center))
  m.world_view();m.change_zoom(2);var half=m.size/(2*m.factor())
  check(half.y<90,"Zoom exposes available north/south navigation")
  m.change_zoom(0.0001,Vector2.ZERO);check(bounded(m),"Minimum zoom clamped at corner")
 m.size=original;m.world_view()
 for code in ["RUS","NZL","ATA","FJI","USA"]:
  m.focus(code);check(bounded(m),"Focus bounds "+code)
 m.world_view();await shot("map")
 m.change_zoom(2);m.center=Vector2(999,999);m.constrain();await shot("edge")
 check(app.TOPICS.has("Sport"),"Sport in horizontal strip")
 var s=app.sports
 var mock={"X":{"text":"== Transports ==\nFootball Road\n== Sport ==\nTennis and rugby.\n== Culture ==\nOutside"}}
 var txt=app.SportsData.country_text({"article":"X"},mock)
 check("Tennis" in txt and not "Football Road" in txt and not "Outside" in txt,"Sports boundaries exclude Transports and next section")
 mock.X.text="== Sport ==\nNew tennis result\n== Culture ==\nOutside"
 check("New tennis result" in app.SportsData.country_text({"article":"X"},mock),"Updated articles immediately feed sport")
 for code in app.countries:
  check(s.countries.has(code) and s.countries[code].selection.size()<=6,"Country sports record "+code)
 app.show_country("FRA","Sport");await shot("sports")
 app.scroll.scroll_vertical=500;await shot("sports_scrolled")
 app.show_sport("DZA","Football");await shot("detail")
 app.show_country("ATA","Sport");await shot("unavailable")
 check(s.countries.ATA.selection.is_empty(),"No invented Antarctic sports")
 print("SPORTS AND MAP V7: ","PASS" if failed.is_empty() else failed)
 quit(0 if failed.is_empty() else 1)
