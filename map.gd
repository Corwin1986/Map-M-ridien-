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
		var holes: Array = []
		var lines := PackedVector2Array()
		for poly in rings:
			outer.append(poly[0])
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
		shapes.append({"code":entry.code, "polys":rings,"mesh":make_mesh(outer),"holes":make_mesh(holes),"lines":lines,"bounds":bounds})
	queue_redraw()

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
	selected = code
	var c: Dictionary = countries[code]
	center = Vector2(c.label[0], -c.label[1])
	var area: float = float(c.get("area", 0))
	zoom = clampf(9000.0 / sqrt(maxf(area, 10000)), 2.4, 18)
	constrain()
	queue_redraw()

func world_view():
	zoom = minimum_zoom()
	center = Vector2.ZERO
	constrain()
	queue_redraw()

func _draw():
	constrain()
	draw_rect(Rect2(Vector2.ZERO,size), Color("0a1c27"))
	var k := factor()
	var off := size/2.0 - center*k
	for lon in range(-180,181,30):
		draw_line(project(lon,85),project(lon,-85),Color("142d39"),1)
	for lat in range(-60,81,30):
		draw_line(project(-180,lat),project(180,lat),Color("142d39"),1)
	draw_line(project(-180,0),project(180,0),Color("21404a"),1)
	draw_set_transform(off,0,Vector2(k,k))
	var use_raster:=base_texture!=null
	if use_raster:
		draw_texture_rect(population_texture if mode=="Population" else base_texture,Rect2(-180,-90,360,180),false)
	var visible_world:=Rect2(geographic(Vector2.ZERO),size/k)
	for shape in shapes:
		if use_raster and shape.code!=selected:continue
		if not visible_world.intersects(shape.bounds):continue
		var color := Color("28424a")
		var cc: Dictionary = countries.get(shape.code,{})
		if mode == "Population":
			var pop: float = float(cc.get("population",0) if cc.get("population") != null else 0)
			color = Color("243c46").lerp(Color("c6ab74"),clampf(log(maxf(pop,1))/20.0-0.2,0,1))
		if shape.code == selected:
			color = Color("9f8f65")
		if shape.mesh:draw_mesh(shape.mesh,null,Transform2D.IDENTITY,color)
		if shape.holes:draw_mesh(shape.holes,null,Transform2D.IDENTITY,Color("0a1c27"))
		draw_multiline(shape.lines,Color("4d6365") if shape.code != selected else gold,0.7/k,true)
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
	var drawn: Array[Rect2] = []
	for code in countries:
		var c: Dictionary = countries[code]
		if zoom < 2.0 and float(c.get("area",0)) < 900000:
			continue
		if zoom < 4.0 and float(c.get("area",0)) < 150000:
			continue
		if zoom < 9 and float(c.get("area",0)) < 10000:
			continue
		var p := project(c.label[0],c.label[1])
		if not Rect2(Vector2(15,15),size-Vector2(30,30)).has_point(p):
			continue
		var txt: String = c.name
		var fs := 12 if code != selected else 14
		var ts := font.get_string_size(txt,HORIZONTAL_ALIGNMENT_LEFT,-1,fs)
		var rect := Rect2(p-Vector2(ts.x/2,fs),ts+Vector2(8,6))
		var overlap := false
		for other in drawn:
			if other.intersects(rect): overlap = true
		if overlap and code != selected:continue
		drawn.append(rect)
		draw_string(font,p+Vector2(-ts.x/2,1),txt,HORIZONTAL_ALIGNMENT_LEFT,-1,fs,Color("080f16"))
		draw_string(font,p+Vector2(-ts.x/2,0),txt,HORIZONTAL_ALIGNMENT_LEFT,-1,fs,Color("f0e4ca") if code == selected else Color("b9c7c7"))
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
	# Small islands remain reachable at low zoom.
	var nearest := ""
	var distance := 10.0
	for code in countries:
		var c: Dictionary=countries[code]
		var d:=project(c.label[0],c.label[1]).distance_to(pos)
		if d<distance:nearest=code;distance=d
	if nearest!="":country_picked.emit(nearest)

func _gui_input(event):
	if (event is InputEventMouseButton or event is InputEventMouseMotion) and event.device == -1:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:change_zoom(1.2,event.position)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:change_zoom(1/1.2,event.position)
		elif event.button_index == MOUSE_BUTTON_LEFT:
			dragging=event.pressed
			if event.pressed:drag_start=event.position;last_pos=event.position;moved=false
			elif not moved:pick(event.position)
	elif event is InputEventMouseMotion and dragging:
		if event.position.distance_to(drag_start)>6:moved=true
		if moved:center -= event.relative/factor();constrain();queue_redraw()
	elif event is InputEventScreenTouch:
		if event.pressed:
			fingers[event.index]=event.position
			if fingers.size()==1:drag_start=event.position;moved=false;gesture=false
			else:gesture=true;moved=true
		else:
			if fingers.size()==1 and not moved and not gesture:pick(event.position)
			fingers.erase(event.index)
	elif event is InputEventScreenDrag:
		if fingers.size()==2:
			var keys=fingers.keys()
			var before:float=fingers[keys[0]].distance_to(fingers[keys[1]])
			fingers[event.index]=event.position
			var after:float=fingers[keys[0]].distance_to(fingers[keys[1]])
			if before>5:change_zoom(after/before,(fingers[keys[0]]+fingers[keys[1]])/2)
		else:
			if event.position.distance_to(drag_start)>6:moved=true
			center-=event.relative/factor();constrain();queue_redraw()
			fingers[event.index]=event.position
	accept_event()
