extends SceneTree
func _initialize():call_deferred("run")
func run():
 var m=load("res://map.gd").new()
 var read=func(path):return JSON.parse_string(FileAccess.get_file_as_string(path))
 m.configure(read.call("res://data/polygons.json"),read.call("res://data/countries.json"),[],[],[])
 DirAccess.make_dir_recursive_absolute("res://assets/map_meshes")
 for shape in m.shapes:
  if shape.mesh:ResourceSaver.save(shape.mesh,"res://assets/map_meshes/"+shape.code+".res")
  if shape.holes:ResourceSaver.save(shape.holes,"res://assets/map_meshes/"+shape.code+"_holes.res")
 print("Saved ",m.shapes.size()," mesh entities")
 m.free();quit()
