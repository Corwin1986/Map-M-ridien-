extends SceneTree
var errors=[]
func _initialize():call_deferred('run')
func check(ok:bool,label:String):
 print(label,': ',ok)
 if not ok:errors.append(label)
func touch(m,index,pos,pressed):
 var e=InputEventScreenTouch.new();e.index=index;e.position=pos;e.pressed=pressed;m._gui_input(e)
func drag(m,index,pos,relative):
 var e=InputEventScreenDrag.new();e.index=index;e.position=pos;e.relative=relative;m._gui_input(e)
func run():
 var app=load('res://main.tscn').instantiate();app.skip_monthly_sync=true;root.add_child(app)
 await process_frame;await process_frame
 var m=app.map
 var expected=JSON.parse_string(FileAccess.get_file_as_string('res://tools/map23/meshes.json'))
 var complete=true;var original=0;var lighter=0
 for s in m.shapes:
  var d=expected[s.code].outer
  if s.mesh==null or s.mesh.surface_get_arrays(0)[Mesh.ARRAY_INDEX].size()!=d.indices.size():complete=false
  original+=s.lines.size();lighter+=s.lods[1].size()
 check(complete and m.shapes.size()==319,'All 319 shapes have complete exported triangles')
 check(lighter<original,'Border geometry reduced: '+str(original)+' -> '+str(lighter))
 for code in ['EGY','CAN']:
  m.focus(code);m.zoom=9;m.center=Vector2(30,-27) if code=='EGY' else Vector2(-100,-57);m.constrain();m.queue_redraw()
  await process_frame;await process_frame
  if DisplayServer.get_name()!='headless':
   await RenderingServer.frame_post_draw
   root.get_texture().get_image().save_png('res://tests/map23_'+code+'.png')
 m.selected='';m.center=Vector2.ZERO;m.zoom=10;m.constrain()
 var p=Vector2(250,350);touch(m,0,p,true)
 var start=m.center
 drag(m,0,p+Vector2(50,0),Vector2(50,0))
 check(m.center.x<start.x,'Touch follows finger')
 touch(m,0,p+Vector2(50,0),false)
 var release=m.center;m._process(0.016)
 check(m.center.x<release.x,'Inertia continues briefly after release')
 touch(m,0,p,true);check(m.pan_velocity==Vector2.ZERO,'New touch stops inertia')
 touch(m,1,p+Vector2(100,0),true);var z=m.zoom
 drag(m,1,p+Vector2(150,0),Vector2(50,0));check(m.zoom>z,'Pinch zoom still works')
 touch(m,1,p+Vector2(150,0),false);touch(m,0,p,false)
 check(m.pan_velocity==Vector2.ZERO,'Pinch release never flings map')
 m.center=Vector2(-999,-999);m.constrain();m.pan_velocity=Vector2(1000,1000);m._process(0.016)
 check(m.pan_velocity==Vector2.ZERO,'World boundaries stop inertia')
 m.center=Vector2.ZERO;m.pan_velocity=Vector2(1000,0)
 for i in 180:m._process(1.0/60)
 check(m.pan_velocity==Vector2.ZERO,'Inertia settles without endless redraw')
 print('MAP23: ','PASS' if errors.is_empty() else errors)
 quit(0 if errors.is_empty() else 1)
