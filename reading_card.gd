extends PanelContainer
# Informational cards own their vertical touch gesture, including their labels.
# They contain no actionable controls; buttons elsewhere keep their native taps.
var owner_scroll:ScrollContainer
var finger=-1
var origin=Vector2.ZERO
var previous=Vector2.ZERO
var dragged=false
var scroll_value=0.0
var velocity=0.0
var last_ms=0
var suppress_until=0
func _ready():
 mouse_filter=Control.MOUSE_FILTER_PASS
 var parent=get_parent()
 while parent:
  if parent is ScrollContainer:owner_scroll=parent;break
  parent=parent.get_parent()
func _input(event):
 if not is_visible_in_tree() or not is_instance_valid(owner_scroll):return
 if event is InputEventScreenTouch:
  if event.pressed:
   velocity=0
   if finger<0 and get_global_rect().has_point(event.position) and owner_scroll.get_global_rect().has_point(event.position):
    finger=event.index;origin=event.position;previous=origin;dragged=false
    scroll_value=owner_scroll.scroll_vertical;last_ms=Time.get_ticks_msec()
    get_viewport().set_input_as_handled()
  elif event.index==finger:
   finger=-1;suppress_until=Time.get_ticks_msec()+150
   if event.canceled or Time.get_ticks_msec()-last_ms>120:velocity=0
   get_viewport().set_input_as_handled()
 elif event is InputEventScreenDrag and event.index==finger:
  if origin.distance_to(event.position)>8:dragged=true
  if dragged:
   var delta=event.position.y-previous.y
   var now=Time.get_ticks_msec()
   velocity=clampf(-delta/maxf(float(now-last_ms)/1000.0,0.016),-1800,1800)
   scroll_value-=delta;apply_scroll();last_ms=now
  previous=event.position;get_viewport().set_input_as_handled()
 elif (event is InputEventMouseButton or event is InputEventMouseMotion) and event.device==-1:
  if finger>=0 or (Time.get_ticks_msec()<suppress_until and owner_scroll.get_global_rect().has_point(event.position)):get_viewport().set_input_as_handled()
func apply_scroll():
 var bar=owner_scroll.get_v_scroll_bar()
 scroll_value=clampf(scroll_value,0,maxf(0,bar.max_value-bar.page))
 owner_scroll.scroll_vertical=int(scroll_value)
func _process(delta):
 if not is_visible_in_tree():velocity=0;return
 if finger<0 and absf(velocity)>8 and is_instance_valid(owner_scroll):
  if absf(owner_scroll.scroll_vertical-scroll_value)>2:velocity=0;return
  scroll_value+=velocity*delta;apply_scroll();velocity*=exp(-8.0*delta)
