extends SceneTree
var picked=""
func _initialize():call_deferred("run")
func run():
 var m=load("res://map.gd").new();m.size=Vector2(540,774);root.add_child(m)
 var read=func(p):return JSON.parse_string(FileAccess.get_file_as_string(p))
 m.configure(read.call("res://data/polygons.json"),read.call("res://data/countries.json"),[],[],[])
 m.country_picked.connect(func(code):picked=code)
 var failed=[];var count=0
 for shape in m.shapes:
  if shape.mesh==null:failed.append(shape.code+" missing mesh");continue
  var arrays=shape.mesh.surface_get_arrays(0);var v=arrays[Mesh.ARRAY_VERTEX];var idx=arrays[Mesh.ARRAY_INDEX];var point=Vector2.ZERO;var area=-1.0
  for i in range(0,idx.size(),3):
   var a=Vector2(v[idx[i]].x,v[idx[i]].y);var b=Vector2(v[idx[i+1]].x,v[idx[i+1]].y);var c=Vector2(v[idx[i+2]].x,v[idx[i+2]].y)
   var sz=absf((b-a).cross(c-a))
   if sz>area:area=sz;point=(a+b+c)/3
  m.center=point;m.zoom=38;m.constrain();picked="";m.pick(m.project(point.x,-point.y))
  if picked!=shape.code:failed.append(shape.code+" => "+picked)
  else:count+=1
 print("GEOMETRY19 ",count," / ",m.shapes.size()," selected; failures ",failed)
 quit(0 if failed.is_empty() else 1)
