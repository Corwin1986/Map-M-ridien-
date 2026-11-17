extends Control
signal war_picked(index: int)
var wars:Array=[]
var war_from:=1826
var war_to:=2026
signal country_picked(code: String)
signal event_picked(index: int)
signal city_picked(city: Dictionary)
signal place_picked(index: int)

var countries: Dictionary = {}
var shapes: Array = []
var tiny_points:Array=[]
var cities: Array = []
var events: Array = []
var places: Array = []
var selected := ""
var mode := "Pays"
var zoom := 1.85
var center := Vector2(15, 25)
var fingers: Dictionary = {}
var drag_start := Vector2.ZERO
var last_pos := Vector2.ZERO
var moved := false
var dragging := false
var gesture := false
var pan_velocity := Vector2.ZERO
var last_pan_ms := 0
var label_sizes:Dictionary={}

func stop_motion():
	pan_velocity=Vector2.ZERO

func pan_by(delta:Vector2):
	center-=delta/factor()
	constrain()
	queue_redraw()

func record_pan(delta:Vector2):
	var now=Time.get_ticks_msec()
	var dt=clampf(float(now-last_pan_ms)/1000.0,0.008,0.05)
	pan_velocity=pan_velocity.lerp((delta/dt).limit_length(2200.0),0.55)
	last_pan_ms=now
	pan_by(delta)

func _process(delta:float):
	if not is_visible_in_tree():
		stop_motion()
		return
	if dragging or not fingers.is_empty():return
	if pan_velocity.length()<12:
		if pan_velocity!=Vector2.ZERO:
			stop_motion();queue_redraw()
		return
	var before=center
	var dt=minf(delta,0.05)
	pan_by(pan_velocity*dt)
	if is_equal_approx(before.x,center.x):pan_velocity.x=0
	if is_equal_approx(before.y,center.y):pan_velocity.y=0
	pan_velocity*=exp(-7.5*dt)

func is_moving()->bool:
	return dragging or not fingers.is_empty() or pan_velocity.length()>=12

var font = preload("res://assets/body.ttf")
var bold = preload("res://assets/bold.ttf")
var gold := Color("d8bd82")
var event_type := 0
var history_period := "Toutes les époques"
var disputes: Array = []
var base_texture: Texture2D
var population_texture: Texture2D

func configure(data: Array, cs: Dictionary, city_data: Array, ev: Array, pl: Array):
	countries = cs
	var line_lods:Dictionary={}
	if FileAccess.file_exists("res://data/map_lines.json"):
		line_lods=JSON.parse_string(FileAccess.get_file_as_string("res://data/map_lines.json"))
	for code in countries:
		label_sizes[code]=[font.get_string_size(countries[code].name,HORIZONTAL_ALIGNMENT_LEFT,-1,12),font.get_string_size(countries[code].name,HORIZONTAL_ALIGNMENT_LEFT,-1,14)]
	cities = city_data
	events = ev
	places = pl
	if ResourceLoader.exists("res://assets/basemap.png"):
		base_texture=load("res://assets/basemap.png")
		population_texture=load("res://assets/population.png")
	if FileAccess.file_exists("res://data/disputes.json"):
		disputes=JSON.parse_string(FileAccess.get_file_as_string("res://data/disputes.json"))
	for entry in data:
		var rings: Array = []
		for poly in entry.rings:
			var prings: Array = []
			for ring in poly:
				var points := PackedVector2Array()
				for pt in ring:
					points.append(Vector2(pt[0], -pt[1]))
				if points.size() > 3:
					prings.append(points)
			if prings.size() > 0:
				rings.append(prings)
		var outer: Array = []
		var part_bounds:Array=[]
		var holes: Array = []
		var lines := PackedVector2Array()
		for poly in rings:
			outer.append(poly[0])
			var pb=Rect2(poly[0][0],Vector2.ZERO)
			for point in poly[0]:pb=pb.expand(point)
			part_bounds.append(pb)
			for hole in poly.slice(1):holes.append(hole)
			var ring: PackedVector2Array=poly[0]
			for j in ring.size()-1:
				lines.append(ring[j]);lines.append(ring[j+1])
		var bounds:=Rect2()
		var first:=true
		for ring in outer:
			for p in ring:
				if first:bounds=Rect2(p,Vector2.ZERO);first=false
				else:bounds=bounds.expand(p)
		var tiny=true
		for pb in part_bounds:
			if maxf(pb.size.x,pb.size.y)>1.0:tiny=false
		if tiny:
			for pb in part_bounds:tiny_points.append({"code":entry.code,"bounds":pb})
		var lods:Array=[]
		for raw in line_lods.get(entry.code,[]):
			var packed=PackedVector2Array()
			for p in raw:packed.append(Vector2(p[0],p[1]))
			lods.append(packed)
		shapes.append({"code":entry.code, "polys":rings,"mesh":cached_mesh(entry.code,outer,false),"holes":cached_mesh(entry.code,holes,true),"lines":lines,"lods":lods,"bounds":bounds})
	queue_redraw()

func cached_mesh(code:String,rings:Array,holes:bool):
	if rings.is_empty():return null
	var path="res://assets/map_meshes/"+code+("_holes" if holes else "")+".res"
	if ResourceLoader.exists(path):return load(path)
	return make_mesh(rings)

func make_mesh(rings:Array):
	var vertices:=PackedVector3Array()
	var indices:=PackedInt32Array()
	for ring in rings:
		var tri:=Geometry2D.triangulate_polygon(ring)
		var offset:=vertices.size()
		for p in ring:vertices.append(Vector3(p.x,p.y,0))
		for i in tri:indices.append(i+offset)
	if indices.is_empty():return null
	var arrays:=[];arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX]=vertices;arrays[Mesh.ARRAY_INDEX]=indices
	var mesh:=ArrayMesh.new();mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
	return mesh

func factor() -> float:
	return size.x / 360.0 * zoom

func project(lon: float, lat: float) -> Vector2:
	return (Vector2(lon, -lat) - center) * factor() + size / 2.0

func geographic(pos: Vector2) -> Vector2:
	return (pos - size / 2.0) / factor() + center

func change_zoom(mult: float, anchor: Vector2 = Vector2(-1, -1)):
	if anchor.x < 0:
		anchor = size / 2.0
	stop_motion()
	var before := geographic(anchor)
	zoom = clampf(zoom * mult, minimum_zoom(), maxf(38.0,minimum_zoom()))
	center += before - geographic(anchor)
	constrain()
	queue_redraw()

func minimum_zoom() -> float:
	# Cover the complete viewport. A portrait screen cannot show the whole
	# rectangular world at once without letterboxing; horizontal panning stays available.
	return maxf(1.0,2.0*size.y/maxf(size.x,1.0))

func constrain():
	if size.x<=0 or size.y<=0:return
	zoom=clampf(zoom,minimum_zoom(),maxf(38.0,minimum_zoom()))
	var half=size/(2.0*factor())
	center.x=clampf(center.x,-180.0+half.x,180.0-half.x)
	center.y=clampf(center.y,-90.0+half.y,90.0-half.y)

func _ready():
	resized.connect(func():constrain();queue_redraw())
	constrain()

func focus(code: String):
	stop_motion()
	selected = code
	var c: Dictionary = countries[code]
	center = Vector2(c.label[0], -c.label[1])
	var area: float = float(c.get("area", 0))
	zoom = clampf(9000.0 / sqrt(maxf(area, 10000)), 2.4, 18)
	constrain()
	queue_redraw()

func world_view():
	stop_motion()
	zoom = minimum_zoom()
	center = Vector2.ZERO
	constrain()
	queue_redraw()

var ocean:GradientTexture2D
func _draw():
	constrain()
	if ocean==null:
		ocean=GradientTexture2D.new();ocean.width=8;ocean.height=256
		ocean.gradient=Gradient.new();ocean.gradient.colors=PackedColorArray([Color("102d3a"),Color("081d28")]);ocean.fill_to=Vector2(0,1)
	draw_texture_rect(ocean,Rect2(Vector2.ZERO,size),false)
	var k := factor()
	var off := size/2.0 - center*k
	for lon in range(-180,181,30):
		draw_line(project(lon,85),project(lon,-85),Color("142d39"),1)
	for lat in range(-60,81,30):
		draw_line(project(-180,lat),project(180,lat),Color("142d39"),1)
	draw_line(project(-180,0),project(180,0),Color("21404a"),1)
	draw_set_transform(off,0,Vector2(k,k))
	var use_raster:=base_texture!=null and zoom<5.0
	if use_raster:
		draw_texture_rect(population_texture if mode=="Population" else base_texture,Rect2(-180,-90,360,180),false)
	var visible_world:=Rect2(geographic(Vector2.ZERO),size/k)
	for shape in shapes:
		var highlighted:bool=shape.code==selected or (selected!="" and countries.get(shape.code,{}).get("parent_code","")==selected)
		if use_raster and not highlighted:continue
		if not visible_world.intersects(shape.bounds):continue
		var color := Color("355963")
		var cc: Dictionary = countries.get(shape.code,{})
		if mode == "Population":
			var pop: float = float(cc.get("population",0) if cc.get("population") != null else 0)
			color = Color("243c46").lerp(Color("c6ab74"),clampf(log(maxf(pop,1))/20.0-0.2,0,1))
		if highlighted:
			color = Color("c6ad72")
		if shape.mesh:draw_mesh(shape.mesh,null,Transform2D.IDENTITY,color)
		if shape.holes:draw_mesh(shape.holes,null,Transform2D.IDENTITY,Color("0a1c27"))
		var border=shape.lines
		if shape.lods.size()==3:
			var level=0 if k>50 else (1 if k>15 else 2)
			if is_moving():level=mini(level+1,2)
			border=shape.lods[level]
		draw_multiline(border,Color("4d6365") if not highlighted else Color("f0d89b"),(0.7 if not highlighted else 1.4)/k,not is_moving())
	draw_set_transform(Vector2.ZERO)
	for line in disputes:
		for i in line.size()-1:
			var a:=project(line[i][0],line[i][1])
			var b:=project(line[i+1][0],line[i+1][1])
			draw_dashed_line(a,b,Color("d1af79"),1.1,4)
	if mode == "Conflits":
		for war in wars:
			if war.start>war_to or int(war.end if war.end!=null else war_to)<war_from:continue
			var wp:=project(war.lon,war.lat)
			if not Rect2(Vector2.ZERO,size).has_point(wp):continue
			draw_circle(wp,9,Color(gold,0.15));draw_circle(wp,4,gold)
	elif mode == "Observations":
		for e in events:
			if event_type > 0 and e.type != event_type:
				continue
			var p := project(e.lon,e.lat)
			if not Rect2(Vector2.ZERO,size).has_point(p):
				continue
			var col: Color = [Color("eb8e7b"),Color("dcaf68"),Color("c19cce")][int(e.type)-1]
			draw_circle(p,7,Color(col,0.13))
			draw_circle(p,2.8,col)
	elif mode == "Repères" or mode == "Géographie" or mode == "Histoire":
		for i in places.size():
			var pl: Dictionary = places[i]
			if mode == "Repères" and pl.kind != "stratégique":
				continue
			if mode == "Géographie" and pl.kind != "nature":
				continue
			if mode == "Histoire" and (pl.kind != "histoire" or (history_period != "Toutes les époques" and pl.era != history_period)):
				continue
			var p := project(pl.lon,pl.lat)
			draw_circle(p,7,Color("0a1c27"))
			draw_circle(p,5,gold,false,1.5)
			if zoom>1.7:
				draw_string(font,p+Vector2(10,4),pl.short,HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color("e5d9ba"))
	if zoom>=9:
		for item in tiny_points:
			if maxf(item.bounds.size.x,item.bounds.size.y)*k>=14:continue
			var point=(item.bounds.get_center()-center)*k+size/2.0
			if Rect2(Vector2.ZERO,size).has_point(point):draw_circle(point,4,gold if item.code==selected else Color("b7c9c8"),false,1.2,true)
	var drawn: Array[Rect2] = []
	for code in countries:
		var c: Dictionary = countries[code]
		if c.has("alias_of"):continue
		if zoom < 2.0 and float(c.get("area",0)) < 900000:
			continue
		if zoom < 4.0 and float(c.get("area",0)) < 150000:
			continue
		if zoom < 9 and float(c.get("area",0)) < 10000:
			continue
		var p := project(c.label[0],c.label[1])
		if not Rect2(Vector2(15,15),size-Vector2(30,30)).has_point(p):
			continue
		if code==selected and mode=="Pays" and zoom>=6:
			for city in cities:
				if city.code==code and project(city.lon,city.lat).distance_to(p)<38:
					p.y+=26;break
		var txt: String = c.name
		var fs := 12 if code != selected else 14
		var ts:Vector2 = label_sizes[code][1 if code==selected else 0]
		var rect := Rect2(p-Vector2(ts.x/2,fs),ts+Vector2(8,6))
		var overlap := false
		for other in drawn:
			if other.intersects(rect): overlap = true
		if overlap and code != selected:continue
		drawn.append(rect)
		draw_string(font,p+Vector2(-ts.x/2,1),txt,HORIZONTAL_ALIGNMENT_LEFT,-1,fs,Color("e8d8af") if code==selected else Color("080f16"))
		draw_string(font,p+Vector2(-ts.x/2,0),txt,HORIZONTAL_ALIGNMENT_LEFT,-1,fs,Color("10232c") if code == selected else Color("d3dfdc"))
	if selected != "" and mode == "Pays" and zoom>=6:
		for city in cities:
			if city.code != selected:continue
			var p := project(city.lon,city.lat)
			draw_circle(p,4,gold)
			draw_circle(p,2,Color("071b24"))
			draw_string(bold,p+Vector2(7,-6),city.name,HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("fff0cb"))
	var sea := project(-33,10)
	if zoom < 3:
		draw_string(font,sea,"O C É A N  A T L A N T I Q U E",HORIZONTAL_ALIGNMENT_CENTER,-1,10,Color("547280"))
	draw_string(font,Vector2(14,size.y-12),"Natural Earth · frontières indicatives",HORIZONTAL_ALIGNMENT_LEFT,-1,10,Color("91a4ab"))

func pick(pos: Vector2):
	if mode == "Conflits":
		var closest:=-1;var distance:=20.0
		for i in wars.size():
			var war:Dictionary=wars[i]
			if war.start>war_to or int(war.end if war.end!=null else war_to)<war_from:continue
			var d:=project(war.lon,war.lat).distance_to(pos)
			if d<distance:closest=i;distance=d
		if closest>=0:war_picked.emit(closest);return
	if mode == "Observations":
		var closest := -1
		var dist := 18.0
		for i in events.size():
			var e: Dictionary = events[i]
			if event_type > 0 and e.type != event_type:continue
			var d := project(e.lon,e.lat).distance_to(pos)
			if d < dist:closest=i;dist=d
		if closest>=0:
			event_picked.emit(closest)
			return
	if mode == "Repères" or mode == "Géographie" or mode == "Histoire":
		for i in places.size():
			var pl: Dictionary = places[i]
			if mode == "Repères" and pl.kind != "stratégique":continue
			if mode == "Géographie" and pl.kind != "nature":continue
			if mode == "Histoire" and (pl.kind != "histoire" or (history_period != "Toutes les époques" and pl.era != history_period)):continue
			if project(pl.lon,pl.lat).distance_to(pos)<20:
				place_picked.emit(i)
				return
	if selected != "" and mode == "Pays" and zoom>=6:
		for city in cities:
			if city.code == selected and project(city.lon,city.lat).distance_to(pos)<14:
				city_picked.emit(city)
				return
	var marker:=marker_at(pos)
	if marker!="":country_picked.emit(marker);return
	var pt := geographic(pos)
	for shape in shapes:
		for poly in shape.polys:
			if Geometry2D.is_point_in_polygon(pt,poly[0]):
				var in_hole := false
				for hole in poly.slice(1):
					if Geometry2D.is_point_in_polygon(pt,hole):in_hole=true
				if not in_hole:
					country_picked.emit(shape.code)
					return

func marker_at(pos:Vector2)->String:
	if zoom<9:return ""
	var nearest="";var distance=10.0;var k=factor()
	for item in tiny_points:
		if maxf(item.bounds.size.x,item.bounds.size.y)*k>=14:continue
		var point=(item.bounds.get_center()-center)*k+size/2.0
		var d=point.distance_to(pos)
		if d<distance:nearest=item.code;distance=d
	return nearest

func _gui_input(event):
	if (event is InputEventMouseButton or event is InputEventMouseMotion) and event.device == -1:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:change_zoom(1.2,event.position)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:change_zoom(1/1.2,event.position)
		elif event.button_index == MOUSE_BUTTON_LEFT:
			dragging=event.pressed
			if event.pressed:stop_motion();last_pan_ms=Time.get_ticks_msec();drag_start=event.position;last_pos=event.position;moved=false
			elif not moved:pick(event.position)
			elif Time.get_ticks_msec()-last_pan_ms>100:stop_motion()
	elif event is InputEventMouseMotion and dragging:
		if event.position.distance_to(drag_start)>6:moved=true
		if moved:record_pan(event.relative)
	elif event is InputEventScreenTouch:
		if event.pressed:
			stop_motion();last_pan_ms=Time.get_ticks_msec()
			fingers[event.index]=event.position
			if fingers.size()==1:drag_start=event.position;moved=false;gesture=false
			else:gesture=true;moved=true
		else:
			if fingers.size()==1 and not moved and not gesture:pick(event.position)
			if gesture or Time.get_ticks_msec()-last_pan_ms>100:stop_motion()
			fingers.erase(event.index)
			queue_redraw()
	elif event is InputEventScreenDrag:
		if fingers.size()==2:
			var keys=fingers.keys()
			var before:float=fingers[keys[0]].distance_to(fingers[keys[1]])
			fingers[event.index]=event.position
			var after:float=fingers[keys[0]].distance_to(fingers[keys[1]])
			if before>5:change_zoom(after/before,(fingers[keys[0]]+fingers[keys[1]])/2)
		else:
			if event.position.distance_to(drag_start)>6:moved=true
			if moved:record_pan(event.relative)
			fingers[event.index]=event.position
	accept_event()
