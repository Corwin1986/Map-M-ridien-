extends Control
# One gesture owner for the entire strip, including the selected tab.
# No nested buttons/scroll containers competing for touch or synthetic mouse events.
signal chosen(topic: String)
var topics: Array = []
var active := ""
var offset := 0.0
var velocity := 0.0
var finger := -1
var origin := Vector2.ZERO
var previous := Vector2.ZERO
var dragged := false
var last_ms := 0
var suppress_until := 0
var pills: Array[Rect2] = []
var extent := 0.0
var font: Font

func _ready():
 mouse_filter=Control.MOUSE_FILTER_STOP
 clip_contents=true
 font=preload("res://assets/body.ttf")
 var x=0.0
 for topic in topics:
  var width=maxf(84,font.get_string_size(topic,HORIZONTAL_ALIGNMENT_LEFT,-1,16).x+28)
  pills.append(Rect2(x,2,width,46));x+=width+8
 extent=x-8
 offset=clampf(offset,0,maximum())
 queue_redraw()

func maximum() -> float:return maxf(0,extent-size.x)

func _draw():
 if font==null:return
 for i in topics.size():
  var rect=pills[i];rect.position.x-=offset
  var style=StyleBoxFlat.new()
  style.bg_color=Color("eee7d5") if topics[i]==active else Color("f3f0e7")
  style.set_corner_radius_all(7)
  draw_style_box(style,rect)
  if topics[i]==active:draw_line(rect.position+Vector2(12,45),rect.end-Vector2(12,1),Color("b39555"),3)
  draw_string(preload("res://assets/bold.ttf") if topics[i]==active else font,rect.position+Vector2(14,29),topics[i],HORIZONTAL_ALIGNMENT_LEFT,-1,16,Color("10232c"))
 # Subtle progress rail makes the off-screen topics discoverable.
 if maximum()>0:
  draw_line(Vector2(0,55),Vector2(size.x,55),Color("deddd4"),1)
  var thumb=size.x*size.x/extent
  var x=(size.x-thumb)*offset/maximum()
  draw_line(Vector2(x,55),Vector2(x+thumb,55),Color("b29862"),2)

func begin(at:Vector2,index:int):
 finger=index;origin=at;previous=at;dragged=false;velocity=0;last_ms=Time.get_ticks_msec()

func drag(at:Vector2):
 if origin.distance_to(at)>8:dragged=true
 if dragged:
  var dx=at.x-previous.x
  offset=clampf(offset-dx,0,maximum())
  var now=Time.get_ticks_msec()
  velocity=clampf(-dx/maxf((now-last_ms)/1000.0,0.016),-1600,1600)
  last_ms=now;queue_redraw()
 previous=at

func finish(at:Vector2,cancelled:bool=false):
 finger=-1
 if cancelled:velocity=0;return
 if Time.get_ticks_msec()-last_ms>100:velocity=0
 if dragged:return
 velocity=0
 if not get_global_rect().has_point(at):return
 var local=at-global_position+Vector2(offset,0)
 for i in pills.size():
  if pills[i].has_point(local):
   if topics[i]!=active:chosen.emit(topics[i])
   return

func _input(event):
 if not is_visible_in_tree():return
 if event is InputEventScreenTouch:
  if event.pressed and finger==-1 and get_global_rect().has_point(event.position):
   begin(event.position,event.index);get_viewport().set_input_as_handled()
  elif not event.pressed and event.index==finger:
   suppress_until=Time.get_ticks_msec()+200
   get_viewport().set_input_as_handled();finish(event.position,event.canceled)
 elif event is InputEventScreenDrag and event.index==finger:
  drag(event.position);get_viewport().set_input_as_handled()
 elif event is InputEventMouseButton or event is InputEventMouseMotion:
  if event.device==-1:
   if get_global_rect().has_point(event.position) or finger>=0:get_viewport().set_input_as_handled()
   return
  if Time.get_ticks_msec()<suppress_until:return
  if event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT:
   if event.pressed and get_global_rect().has_point(event.position):
    begin(event.position,-2);get_viewport().set_input_as_handled()
   elif not event.pressed and finger==-2:
    get_viewport().set_input_as_handled();finish(event.position)
  elif event is InputEventMouseMotion and finger==-2:
   drag(event.position);get_viewport().set_input_as_handled()

func _process(delta):
 if finger==-1 and absf(velocity)>5:
  offset=clampf(offset+velocity*delta,0,maximum())
  velocity*=exp(-9*delta)
  if offset==0 or offset==maximum():velocity=0
  queue_redraw()

func _notification(what):
 if what==NOTIFICATION_APPLICATION_FOCUS_OUT:
  finger=-1;velocity=0
