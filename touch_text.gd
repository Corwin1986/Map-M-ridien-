extends RichTextLabel
# Touch reading: pan immediately; native word selection only after a hold.
const HOLD_SECONDS := 0.55
const DRAG_SLOP := 9.0
const SYNTHETIC_DEVICE := 88
var finger := -1
var origin := Vector2.ZERO
var last_position := Vector2.ZERO
var held := 0.0
var moving := false
var selecting := false
var owner_scroll: ScrollContainer
var velocity := 0.0
var scroll_value := 0.0
var last_drag_ms := 0
var suppress_mouse_until := 0

func _ready():
	selection_enabled=false
	mouse_filter=Control.MOUSE_FILTER_IGNORE
	drag_and_drop_selection_enabled=false
	var ancestor=get_parent()
	while ancestor:
		if ancestor is ScrollContainer:
			owner_scroll=ancestor;break
		ancestor=ancestor.get_parent()

func _input(event):
	if not is_visible_in_tree() or not is_instance_valid(owner_scroll):return
	if (event is InputEventMouseButton or event is InputEventMouseMotion) and event.device==-1 and (finger>=0 or (Time.get_ticks_msec()<suppress_mouse_until and owner_scroll.get_global_rect().has_point(event.position))):
		get_viewport().set_input_as_handled();return
	if event is InputEventScreenTouch:
		if event.pressed:velocity=0
		if event.pressed and finger==-1:
			if not get_global_rect().has_point(event.position) or not owner_scroll.get_global_rect().has_point(event.position):return
			finger=event.index;origin=event.position;last_position=origin
			held=0;moving=false;selecting=false;velocity=0
			deselect();selection_enabled=false;mouse_filter=Control.MOUSE_FILTER_IGNORE
			scroll_value=owner_scroll.scroll_vertical;last_drag_ms=Time.get_ticks_msec()
			get_viewport().set_input_as_handled()
		elif event.index==finger and not event.pressed:
			if selecting:send_mouse(false,last_position)
			if Time.get_ticks_msec()-last_drag_ms>120:velocity=0
			finger=-1;selecting=false;mouse_filter=Control.MOUSE_FILTER_IGNORE
			suppress_mouse_until=Time.get_ticks_msec()+100
			get_viewport().set_input_as_handled()
	elif event is InputEventScreenDrag and event.index==finger:
		last_position=event.position
		if selecting:
			var motion=InputEventMouseMotion.new();motion.device=SYNTHETIC_DEVICE
			motion.position=event.position;motion.global_position=event.position
			motion.relative=event.relative;motion.button_mask=MOUSE_BUTTON_MASK_LEFT
			Input.parse_input_event(motion)
		else:
			if origin.distance_to(event.position)>DRAG_SLOP:moving=true
			if moving:
				var now=Time.get_ticks_msec()
				velocity=clampf(-event.relative.y/maxf(float(now-last_drag_ms)/1000.0,0.016),-1800,1800)
				last_drag_ms=now;scroll_value-=event.relative.y;apply_scroll()
		get_viewport().set_input_as_handled()

func apply_scroll():
	var bar=owner_scroll.get_v_scroll_bar()
	scroll_value=clampf(scroll_value,0,maxf(0,bar.max_value-bar.page))
	owner_scroll.scroll_vertical=int(scroll_value)

func send_mouse(pressed:bool,at:Vector2,double_click:bool=false):
	var event=InputEventMouseButton.new();event.device=SYNTHETIC_DEVICE
	event.position=at;event.global_position=at;event.button_index=MOUSE_BUTTON_LEFT
	event.pressed=pressed;event.double_click=double_click
	Input.parse_input_event(event)

func _process(delta):
	if not is_instance_valid(owner_scroll):return
	if finger>=0 and not moving and not selecting:
		held+=delta
		if held>=HOLD_SECONDS:
			selecting=true;velocity=0;selection_enabled=true;mouse_filter=Control.MOUSE_FILTER_STOP
			send_mouse(true,origin,true)
	elif finger==-1 and absf(velocity)>8:
		# Stop momentum if another gesture is using this same scroll container.
		if absf(owner_scroll.scroll_vertical-scroll_value)>2:velocity=0;return
		scroll_value+=velocity*delta;apply_scroll();velocity*=exp(-8.0*delta)
