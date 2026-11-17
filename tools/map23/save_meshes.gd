extends SceneTree
func _initialize():
 var data=JSON.parse_string(FileAccess.get_file_as_string('res://tools/map23/meshes.json'))
 for code in data:
  for kind in ['outer','holes']:
   var d=data[code][kind]
   var path='res://assets/map_meshes/'+code+('_holes' if kind=='holes' else '')+'.res'
   if d.indices.is_empty():
    if FileAccess.file_exists(path):DirAccess.remove_absolute(path)
    continue
   var v=PackedVector3Array()
   for p in d.vertices:v.append(Vector3(p[0],p[1],0))
   var a=[];a.resize(Mesh.ARRAY_MAX);a[Mesh.ARRAY_VERTEX]=v;a[Mesh.ARRAY_INDEX]=PackedInt32Array(d.indices)
   var mesh=ArrayMesh.new();mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,a)
   assert(ResourceSaver.save(mesh,path)==OK)
 print('ALL MESHES SAVED')
 quit()
