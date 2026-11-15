extends Control
var polygons:Array=[]
var opened:Dictionary={}
var explored:Dictionary={}
func _draw():
 draw_rect(Rect2(Vector2.ZERO,size),Color("0b202b"))
 for country in polygons:
  var color=Color("d8bd82") if explored.has(country.code) else (Color("77aab7") if opened.has(country.code) else Color("32494e"))
  for poly in country.rings:
   var points=PackedVector2Array()
   for p in poly[0]:points.append(Vector2((float(p[0])+180.0)/360.0*size.x,(90.0-float(p[1]))/180.0*size.y))
   if points.size()>3 and not Geometry2D.triangulate_polygon(points).is_empty():draw_colored_polygon(points,color)
