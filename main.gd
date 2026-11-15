extends Control

const BODY = preload("res://assets/body.ttf")
const TITLE = preload("res://assets/title.ttf")
const BOLD = preload("res://assets/bold.ttf")
const TopicSections = preload("res://topic_sections.gd")
const Reliability = preload("res://reliability.gd")
const ReadingCard = preload("res://reading_card.gd")
const TopicStrip = preload("res://topic_strip.gd")
const TouchText = preload("res://touch_text.gd")
const SportsData = preload("res://sports_data.gd")
const DefenseData = preload("res://defense_data.gd")
const MonthlySync = preload("res://monthly_sync.gd")
const ContentSync = preload("res://content_sync.gd")
const TOPICS = ["L’essentiel","Histoire","Villes","Conflits","Géographie","Population","Religion","Langue","Économie","Militaire","Institutions","Personnalités marquantes","Gastronomie","Sport","Sources"]
const PEOPLE_DOMAINS = {"Histoire et politique":"Politique et histoire","Musique":"Musique","Sport":"Sport","Sciences et inventions":"Sciences","Arts et littérature":"Arts et littérature","Cinéma et scène":"Cinéma et scène","Industrie et économie":"Industrie et économie","Exploration et société":"Exploration et société"}
const MapView = preload("res://map.gd")
const INK = Color("10232c")
const MUTED = Color("64777a")
const CREAM = Color("f3f0e7")
const GOLD = Color("d8bd82")
const DARK = Color("0b202b")
var journey
var day_card:Control
var reading_save_time=0.0
var countries: Dictionary
var articles: Dictionary
var cities: Array
var events: Array
var conflict_history: Array
var people: Array
var cuisines: Dictionary
var sports: Dictionary
var defense: Dictionary
var recipe_book: Dictionary
var specialties: Dictionary
var conflict_roles: Dictionary
var history_periods: Dictionary
var relief_maps: Dictionary
var content_sync
var monthly_sync
var skip_monthly_sync := false
var boot_overlay:Control
var boot_bar:ProgressBar
var boot_detail:Label
var atlas_year := 2026
var war_from := 1826
var war_to := 2026
var conflicts: Array
var places: Array
var country_order: Array = []
var map: Control
var top: Control
var bottom: Control
var selection: Control
var modal: Control
var sheet: VBoxContainer
var scroll: ScrollContainer
var tabs: HBoxContainer
var search_input: LineEdit
var selected := ""
var topic_offset := 0.0
var topic_country := ""
var active_topic := "L’essentiel"
var mode := "Pays"
var bookmarks: Array = []
var visited: Array = []
var compare_a := "FRA"
var compare_b := "TUR"
var compare_pick := ""
var full_read := false
var toast_label: Label
var observation_info:Dictionary={"period":"septembre 2026","version":"26.0.9","retrieved":"2026-11-13"}
var event_counts: Dictionary = {}

func screen_height() -> float:
	return get_viewport_rect().size.y

func read_json(path: String):
	return JSON.parse_string(FileAccess.get_file_as_string(path))

func _ready():
	get_tree().auto_accept_quit = false
	var theme_new := Theme.new()
	theme_new.default_font = BODY
	theme_new.default_font_size = 16
	theme = theme_new
	content_sync=ContentSync.new();add_child(content_sync)
	countries = read_json("res://data/countries.json")
	articles = read_json("res://data/articles.json")
	cities = read_json("res://data/cities.json")
	events = read_json("res://data/events.json")
	conflicts = read_json("res://data/conflicts.json")
	places = read_json("res://data/places.json")
	conflict_history=content_sync.content("conflict_history",read_json("res://data/conflict_history.json"))
	atlas_year=maxi(2026,int(Time.get_date_dict_from_system().year))
	for war in conflict_history:atlas_year=maxi(atlas_year,int(war.start))
	war_to=atlas_year
	people=content_sync.content("people",read_json("res://data/people.json"))
	cuisines=content_sync.content("cuisines",read_json("res://data/cuisines.json"))
	defense=read_json("res://data/defense.json")
	sports=read_json("res://data/sports.json")
	specialties=read_json("res://data/specialties.json")
	conflict_roles=read_json("res://data/conflict_roles.json")
	history_periods=read_json("res://data/history_periods.json")
	relief_maps=read_json("res://data/relief_maps.json")
	recipe_book=content_sync.content("recipes",read_json("res://data/recipes.json"))
	articles.merge(content_sync.content("articles",{}),true)
	cities=content_sync.content("cities",cities)
	events=content_sync.content("events",events)
	observation_info=content_sync.content("observation_info",observation_info)
	if monthly_sync==null:monthly_sync=MonthlySync.new()
	add_child(monthly_sync)
	monthly_sync.apply_to(self)
	for code in defense.get("gdp",{}):
		var record:Dictionary=defense.gdp[code]
		if countries.has(code) and int(record.year)>=int(countries[code].get("gdp_year",0)):
			countries[code].gdp=float(record.value)/1000000.0
			countries[code].gdp_year=record.year
			countries[code].gdp_source="Banque mondiale · NY.GDP.MKTP.CD"
	country_order = countries.keys()
	country_order.sort_custom(func(a,b):return countries[a].name.naturalnocasecmp_to(countries[b].name)<0)
	for ev in events:
		event_counts[ev.code] = event_counts.get(ev.code,0)+1
	if FileAccess.file_exists("user://carnet.json"):
		var saved = read_json("user://carnet.json")
		if saved is Dictionary:
			bookmarks = saved.get("bookmarks",[])
			visited = saved.get("visited",[])
	journey=preload("res://discovery_ui.gd").new(self)
	map = MapView.new()
	add_child(map)
	map.position = Vector2(0,104)
	map.size = Vector2(540,screen_height()-186)
	map.clip_contents = true
	map.configure(read_json("res://data/polygons.json"),countries,cities,events,places)
	map.war_to=atlas_year
	map.wars=conflict_history
	map.war_picked.connect(show_war_cluster)
	map.country_picked.connect(select_country)
	map.event_picked.connect(show_event_cluster)
	map.city_picked.connect(show_city)
	map.place_picked.connect(show_place)
	build_header()
	build_footer()
	home_card()
	toast_label = Label.new()
	toast_label.position = Vector2(25,screen_height()-124)
	toast_label.size = Vector2(490,42)
	toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast_label.add_theme_color_override("font_color",GOLD)
	toast_label.add_theme_stylebox_override("normal",box(DARK,12))
	toast_label.visible = false
	add_child(toast_label)
	journey.poll()
	if not skip_monthly_sync and monthly_sync.due():run_monthly_startup()


func box(color: Color, radius: int = 12, border: Color = Color.TRANSPARENT) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color=color
	s.set_corner_radius_all(radius)
	s.content_margin_left=14;s.content_margin_right=14
	s.content_margin_top=10;s.content_margin_bottom=10
	if border.a>0:s.set_border_width_all(1);s.border_color=border
	return s

func clear(node: Node):
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()

func panel(parent: Node, pos: Vector2, dims: Vector2, color: Color, radius: int=18) -> Panel:
	var p:=Panel.new();parent.add_child(p);p.position=pos;p.size=dims
	p.add_theme_stylebox_override("panel",box(color,radius))
	return p

func label(parent: Node, txt: String, font_size: int=16, color: Color=INK, serif: bool=false) -> Label:
	var l:=Label.new();l.text=txt;l.add_theme_font_size_override("font_size",font_size)
	l.add_theme_color_override("font_color",color)
	l.add_theme_font_override("font",TITLE if serif else BODY)
	l.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	parent.add_child(l)
	return l

func fixed_label(parent: Node, txt: String, pos: Vector2, dims: Vector2, fs: int=16, color: Color=INK, serif: bool=false) -> Label:
	var l=label(parent,txt,fs,color,serif);l.position=pos;l.size=dims
	return l

func button(parent: Node, txt: String, call: Callable, light: bool=true, chosen: bool=false) -> Button:
	var b:=Button.new();b.text=txt;b.custom_minimum_size=Vector2(0,46)
	b.add_theme_font_size_override("font_size",15)
	b.add_theme_color_override("font_color",INK if light or chosen else Color("dce5e3"))
	b.add_theme_color_override("font_hover_color",INK if light else Color.WHITE)
	b.add_theme_color_override("font_pressed_color",INK)
	b.add_theme_stylebox_override("normal",box(GOLD if chosen else (Color("e8e8df") if light else Color("18313d")),10))
	b.add_theme_stylebox_override("hover",box(Color("e6d8b9") if light else Color("34505a"),10))
	b.add_theme_stylebox_override("pressed",box(GOLD,10))
	b.add_theme_stylebox_override("focus",box(Color.TRANSPARENT,10,Color("b39152")))
	b.pressed.connect(call);parent.add_child(b)
	return b

func fixed_button(parent:Node,txt:String,pos:Vector2,dims:Vector2,call:Callable,light:bool=false,chosen:bool=false) -> Button:
	var b=button(parent,txt,call,light,chosen);b.position=pos;b.size=dims
	return b

func space(parent:Node,h:float=10):
	var s:=Control.new();s.custom_minimum_size.y=h;parent.add_child(s)

func paragraph(parent:Node,txt:String,fs:int=17,color:Color=INK):
	var r:=TouchText.new();r.fit_content=true;r.scroll_active=false
	r.size.x=460
	r.selection_enabled=false;r.add_theme_font_override("normal_font",BODY)
	r.add_theme_font_size_override("normal_font_size",fs);r.add_theme_color_override("default_color",color)
	r.add_theme_constant_override("line_separation",6);r.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	parent.add_child(r)
	r.text=txt
	return r

func heading(txt:String):
	space(sheet,8);label(sheet,txt,25,INK,true);space(sheet,2)

func eyebrow(txt:String):
	label(sheet,txt.to_upper(),11,MUTED)

func note(txt:String):
	paragraph(sheet,txt,13,MUTED)

func rule():
	space(sheet,6)
	var r:=HSeparator.new();sheet.add_child(r)
	space(sheet,6)

func source_button(txt:String,url:String):
	var b=button(sheet,txt+"  ↗",func():OS.shell_open(url))
	b.alignment=HORIZONTAL_ALIGNMENT_LEFT
	b.text_overrun_behavior=TextServer.OVERRUN_TRIM_ELLIPSIS

func flag(parent:Node,code:String,pos:Vector2,dims:Vector2):
	var path="res://assets/flags/"+str(countries[code].get("iso2",""))+".svg"
	if ResourceLoader.exists(path):
		var t:=TextureRect.new();t.texture=load(path);t.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;t.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;t.position=pos;t.size=dims;t.mouse_filter=Control.MOUSE_FILTER_IGNORE;parent.add_child(t)

func build_header():
	top=panel(self,Vector2.ZERO,Vector2(540,104),DARK,0)
	fixed_label(top,"MÉRIDIEN V16",Vector2(24,23),Vector2(350,42),29,Color("eee7d6"),true)
	fixed_label(top,"LE MONDE, AVEC DU CONTEXTE",Vector2(26,68),Vector2(390,22),10,Color("9badae"))
	var search_btn=fixed_button(top,"",Vector2(420,27),Vector2(44,44),func():show_search())
	search_btn.icon=preload("res://assets/search.svg");search_btn.expand_icon=true;search_btn.add_theme_constant_override("icon_max_width",22);search_btn.tooltip_text="Rechercher un pays"
	fixed_button(top,"i",Vector2(474,27),Vector2(42,44),show_help)

func build_footer():
	if is_instance_valid(bottom):bottom.queue_free()
	bottom=panel(self,Vector2(0,screen_height()-76),Vector2(540,76),DARK,0)
	var items=[["Carte",func():journey.screen={};journey.country_origin={};set_mode("Pays")],["Découvrir",func():journey.open_hub()],["Comparer",func():journey.screen={};journey.country_origin={};show_compare()],["Carnet",show_bookmarks]]
	for i in items.size():
		var b=fixed_button(bottom,items[i][0],Vector2(6+i*134,12),Vector2(128,48),items[i][1]);b.add_theme_font_size_override("font_size",13)

func set_mode(m:String):
	close_modal();mode=m;map.mode=m;map.event_type=0;map.queue_redraw()
	top.queue_free();build_header();home_card()
	if m=="Conflits":show_toast("Conflits historiques · 1826–"+str(atlas_year))

func home_card():
	if is_instance_valid(selection):selection.queue_free()
	selection=Control.new();add_child(selection)
	selection.mouse_filter=Control.MOUSE_FILTER_IGNORE
	selection.position=Vector2(0,104);selection.size=Vector2(540,screen_height()-186)
	fixed_button(selection,"+",Vector2(476,20),Vector2(44,44),func():map.change_zoom(1.5))
	fixed_button(selection,"-",Vector2(476,71),Vector2(44,44),func():map.change_zoom(1/1.5))
	if mode=="Pays" and selected=="" and journey!=null:journey.home_banners(selection)
	if mode=="Histoire":
		var p=panel(selection,Vector2(20,screen_height()-400),Vector2(500,188),DARK,16)
		fixed_label(p,"UNE CARTE, PLUSIEURS ÉPOQUES",Vector2(18,15),Vector2(460,22),11,GOLD)
		fixed_label(p,map.history_period,Vector2(18,43),Vector2(460,45),25,Color.WHITE,true)
		fixed_label(p,"Touchez un repère. Les frontières affichées restent contemporaines.",Vector2(18,92),Vector2(460,40),13,Color("b3c4c8"))
		fixed_button(p,"Choisir une époque  →",Vector2(18,137),Vector2(464,44),show_history_hub,false)
	elif mode=="Conflits":
		var p=panel(selection,Vector2(20,screen_height()-428),Vector2(500,216),DARK,16)
		fixed_label(p,"DEUX SIÈCLES DE CONFLITS",Vector2(18,15),Vector2(460,22),11,GOLD)
		fixed_label(p,"Comprendre les conflits depuis 1826.",Vector2(18,43),Vector2(460,60),22,Color.WHITE,true)
		fixed_label(p,"Sélection historique · 1826–"+str(atlas_year)+"\nLes repères ne représentent pas des lignes de front.",Vector2(18,108),Vector2(460,43),12,Color("b3c4c8"))
		fixed_button(p,"Dossiers et filtres  →",Vector2(18,160),Vector2(464,44),show_conflict_hub,false)
	elif mode=="Observations":
		var p=panel(selection,Vector2(20,screen_height()-380),Vector2(500,168),DARK,18)
		fixed_label(p,"OBSERVATIONS UCDP · "+str(observation_info.period).to_upper()+"",Vector2(18,14),Vector2(460,35),13,GOLD)
		fixed_label(p,"Événements documentés, pas de suivi en direct.",Vector2(18,50),Vector2(460,45),18,Color.WHITE)
		fixed_button(p,"Filtres et méthode",Vector2(18,110),Vector2(464,44),show_recent_conflict_hub)
	elif selected!="" and mode=="Pays":
		var c:Dictionary=countries[selected]
		var p=panel(selection,Vector2(20,screen_height()-410),Vector2(500,198),CREAM,18)
		flag(p,selected,Vector2(18,22),Vector2(49,34))
		var cname=fixed_label(p,c.name,Vector2(81,14),Vector2(350,47),28,INK,true)
		cname.autowrap_mode=TextServer.AUTOWRAP_OFF;cname.clip_text=true;cname.text_overrun_behavior=TextServer.OVERRUN_TRIM_ELLIPSIS
		fixed_button(p,"×",Vector2(445,13),Vector2(40,42),func():selected="";map.selected="";map.queue_redraw();home_card(),true)
		fixed_label(p,c.capital+"  ·  "+c.region,Vector2(20,65),Vector2(460,30),14,MUTED)
		fixed_label(p,num(c.population)+" habitants"+year_suffix(c),Vector2(20,100),Vector2(460,27),16,INK)
		fixed_button(p,"Plus d’infos sur le pays  →",Vector2(18,143),Vector2(464,44),func():show_country(selected),true,true)

func select_country(code:String):
	if journey!=null:journey.screen={};journey.country_origin={};journey.store.data.opened[code]=true;journey.store.save()
	selected=code;map.selected=code;map.queue_redraw()
	if code not in visited:visited.append(code);save_carnet()
	mode="Pays";map.mode="Pays";map.queue_redraw();home_card()

func close_modal():
	if journey!=null:journey.capture()
	if is_instance_valid(modal):
		modal.hide();modal.queue_free();modal=null
	compare_pick=""

func open_modal(title_text:String,subtitle:String=""):
	close_modal()
	modal=panel(self,Vector2(12,116),Vector2(516,screen_height()-198),CREAM,20)
	var title_label=fixed_label(modal,title_text,Vector2(20,14),Vector2(426,46),28,INK,true)
	title_label.autowrap_mode=TextServer.AUTOWRAP_OFF;title_label.clip_text=true;title_label.text_overrun_behavior=TextServer.OVERRUN_TRIM_ELLIPSIS
	fixed_button(modal,"×",Vector2(450,14),Vector2(44,44),ui_back,true)
	fixed_label(modal,subtitle,Vector2(21,64),Vector2(472,34),12,MUTED)
	scroll=ScrollContainer.new();scroll.position=Vector2(20,106);scroll.size=Vector2(478,screen_height()-322);scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED;modal.add_child(scroll)
	sheet=VBoxContainer.new();sheet.size_flags_horizontal=Control.SIZE_EXPAND_FILL;sheet.add_theme_constant_override("separation",10);scroll.add_child(sheet)

func num(value) -> String:
	if value==null:return "Non renseigné"
	var s=str(int(value));var out=""
	for i in s.length():
		if i>0 and (s.length()-i)%3==0:out+=" "
		out+=s[i]
	return out

func year_suffix(c:Dictionary) -> String:
	return " · "+str(int(c.pop_year)) if c.get("population")!=null and c.get("pop_year")!=null else ""

func stat(title_text:String,value:String,caption:String=""):
	var wrap:=ReadingCard.new();wrap.add_theme_stylebox_override("panel",box(Color("e9e8df"),12));sheet.add_child(wrap)
	var v:=VBoxContainer.new();wrap.add_child(v)
	label(v,title_text.to_upper(),10,MUTED)
	label(v,value,21,INK)
	if caption!="":label(v,caption,12,MUTED)

func show_country(code:String,topic:String="L’essentiel"):
	selected=code;map.selected=code;map.queue_redraw();home_card()
	if code not in visited:visited.append(code);save_carnet()
	active_topic=topic;full_read=false
	var c:Dictionary=countries[code]
	open_modal(c.name,c.region+"  /  "+c.capital)
	# The strip lives outside article scrolling and keeps its position on selection.
	scroll.position.y=172;scroll.size.y-=66
	if topic_country!=code:topic_offset=0;topic_country=code
	var strip=TopicStrip.new()
	strip.name="TopicStrip";strip.position=Vector2(20,104);strip.size=Vector2(478,60)
	strip.topics=TOPICS;strip.active=topic;strip.offset=topic_offset
	modal.add_child(strip)
	strip.chosen.connect(func(next_topic):
		topic_offset=strip.offset
		show_country.call_deferred(code,next_topic))
	match topic:
		"L’essentiel":
			eyebrow("Pays et territoires")
			var first=article_intro(code)
			if first!="":paragraph(sheet,shorten(first,430))
			stat("Population",num(c.population),data_caption(str(c.pop_source),c.get("pop_year"),"Population des pays"))
			stat("Capitale",c.capital)
			stat("Superficie",(num(c.area)+" km²" if float(c.area)>0 else "Non renseignée"),"Périmètre territorial propre à la source")
			stat("Langues renseignées",(", ".join(c.languages) if c.languages.size()>0 else "Non renseignées"))
			stat("Monnaie",c.currency if c.currency!="" else "Non renseignée")
			if c.get("disputed",false) or code in ["ISR","PSE","UKR","RUS","MAR","ESH","TWN","UNK","CYN"]:
				note("Territoires ou statuts contestés : le tracé est celui de Natural Earth. Il ne constitue pas une prise de position. Les capitales et les périmètres statistiques peuvent suivre des conventions différentes selon les sources.")
			button(sheet,"☆ Enregistré" if code in bookmarks else "☆ Ajouter à mon carnet",func():toggle_bookmark(code);show_country(code))
			button(sheet,"Centrer la carte sur ce pays",func():close_modal();map.focus(code);home_card())
		"Villes":country_cities(code)
		"Personnalités marquantes":country_people(code)
		"Gastronomie":country_food(code)
		"Sport":country_sports(code)
		"Conflits":country_conflicts(code)
		"Militaire":country_military(code)
		"Sources":country_sources(code)
		"Population","Religion","Langue":country_society(code,topic)
		"Économie":
			stat("Monnaie",c.currency if c.currency!="" else "Non renseignée")
			if float(c.gdp)>0:stat("PIB nominal · repère historique",num(c.gdp)+" millions USD",data_caption(str(c.get("gdp_source","Natural Earth")),c.gdp_year,"Économie · PIB"))
			show_article_topic(code,["économie","agriculture","industrie","ressources"],"Économie et ressources")
		"Institutions":
			stat("Appartenance à l’ONU","État membre" if c.un else "Non membre ou territoire","Source : mledoze/countries · voir les précisions de l’article")
			show_article_topic(code,["politique","institution","gouvernement","relations"],"Institutions et relations")
		"Géographie":country_relief(code)
		"Histoire":country_history(code)
	if journey!=null:journey.attach_country(code,topic)
	space(sheet,12)

func article_intro(key:String) -> String:
	var a:Dictionary=articles.get(key,{})
	var text:String=a.get("text","")
	return text.split("\n\n==")[0].strip_edges()

func shorten(txt:String,limit:int) -> String:
	if txt.length()<=limit:return txt
	var chunk:=txt.substr(0,limit)
	var end:=chunk.rfind(". ")
	if end>limit/2:return chunk.substr(0,end+1)
	return chunk+"…"

func sections_of(txt:String) -> Array:
	var regex:=RegEx.new();regex.compile("(?m)^== ([^=\n]+) ==\\s*$")
	var matches=regex.search_all(txt)
	var sections:Array=[]
	for i in matches.size():
		var start=matches[i].get_end()
		var end=matches[i+1].get_start() if i+1<matches.size() else txt.length()
		sections.append({"title":matches[i].get_string(1).strip_edges(),"text":txt.substr(start,end-start).strip_edges()})
	return sections

func clean_text(txt:String) -> String:
	var regex:=RegEx.new();regex.compile("(?m)^={2,6}\\s*(.*?)\\s*={2,6}\\s*$")
	var cleaned=regex.sub(txt,"\n$1\n",true).strip_edges()
	regex.compile("\\n{3,}")
	return regex.sub(cleaned,"\n\n",true)

func show_article_topic(key:String,terms:Array,title_text:String):
	var a:Dictionary=articles.get(key,{})
	var text:String=a.get("text","")
	var result=""
	for sec in sections_of(text):
		for term in terms:
			if str(sec.title).to_lower().contains(term):
				result+="\n"+(str(sec.title)+"\n\n" if str(sec.title)!=title_text else "")+str(sec.text)+"\n"
				break
	heading(title_text)
	if result.strip_edges()=="":
		result=article_intro(key)
		note("L’article ne contient pas de section distincte pour ce thème. Voici sa présentation générale ; l’article complet permet de poursuivre.")
	if result!="":
		paragraph(sheet,shorten(clean_text(result),6000))
		if result.length()>6000:button(sheet,"Lire toute cette rubrique  →",func():show_text_reader(title_text,a,result))
	else:paragraph(sheet,"Le texte de cet article n’a pas pu être inclus. Sa source reste accessible ci-dessous.")
	article_credit(a)
	button(sheet,"Lire le texte enregistré",func():show_text_reader(str(a.get("title",title_text)),a,text))

func history_fold(title_text:String,txt:String):
	var section=VBoxContainer.new();section.add_theme_constant_override("separation",8);sheet.add_child(section)
	var toggle=button(section,"▸  "+title_text,func():pass)
	toggle.alignment=HORIZONTAL_ALIGNMENT_LEFT;toggle.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	toggle.custom_minimum_size.y=58;toggle.toggle_mode=true
	var body=VBoxContainer.new();body.visible=false;section.add_child(body)
	toggle.toggled.connect(func(opened):
		if opened and body.get_child_count()==0:
			paragraph(body,clean_text(txt));space(body,10)
		body.visible=opened
		toggle.text=("▾  " if opened else "▸  ")+title_text
		toggle.add_theme_stylebox_override("normal",box(GOLD if opened else Color("e8e8df"),10)))
	return toggle

func country_history(code:String):
	eyebrow("Histoire · au fil des époques")
	heading("Les grandes périodes")
	note("Touchez une période pour la déplier, puis touchez-la à nouveau pour la refermer. Le découpage suit l’histoire propre à ce pays.")
	var record:Dictionary=current_history(code)
	if record.is_empty() or record.get("coverage","")=="unavailable":
		note(record.get("note","La chronologie de ce territoire n’est pas encore documentée dans cette édition."))
		var fallback:Dictionary=articles.get(code,{})
		if fallback.has("url"):source_button("Consulter l’article source",fallback.url)
		return
	if record.get("intro","")!="":history_fold("Vue d’ensemble",record.intro)
	for period in record.get("periods",[]):
		history_fold(str(period.title),str(period.text))
	if record.get("note","")!="":note(record.note)
	article_credit(record.get("source",articles.get(code,{})))

func current_history(code:String)->Dictionary:
	var record:Dictionary=history_periods.get(code,{})
	var article:Dictionary=articles.get(record.get("article_key",code),{})
	var txt:String=article.get("text","")
	# Preserve the bundled chronology unless the same source article was refreshed.
	if txt=="" or txt.sha256_text()==record.get("text_sha256","") or article.get("title","")!=record.get("source",{}).get("title",""):return record
	var historical=""
	if record.get("basis","") in ["country_history","reviewed_paragraph_periods"]:
		for sec in sections_of(txt):
			if "histoire" in str(sec.title).to_lower():historical+=str(sec.text)+"\n\n"
	elif record.get("basis","")=="country_historical_sections":
		for sec in sections_of(txt):
			for period in record.get("periods",[]):
				if sec.title==period.title:historical+="== "+str(sec.title)+" ==\n"+str(sec.text)+"\n\n"
	else:historical=txt
	if historical.strip_edges()=="":return record
	var regex=RegEx.new();regex.compile("(?m)^(={2,6})[ \\t]+([^\\n]+?)[ \\t]+=+[ \\t]*$")
	var found=regex.search_all(historical);var depth=7;var headings:Array=[]
	for match_item in found:depth=mini(depth,match_item.get_string(1).length())
	for match_item in found:
		if match_item.get_string(1).length()==depth:headings.append(match_item)
	var fresh=record.duplicate(true);fresh.source=article;fresh.periods=[];fresh.intro=""
	if headings.is_empty():fresh.periods=[{"title":"Repères historiques · texte actualisé","text":historical}]
	else:
		fresh.intro=historical.substr(0,headings[0].get_start()).strip_edges()
		for i in headings.size():
			var h=headings[i];var start=h.get_end();var end=headings[i+1].get_start() if i+1<headings.size() else historical.length()
			if h.get_string(2).to_lower() in ["notes et références","notes","références","sources","bibliographie","annexes","voir aussi","liens externes","compléments"]:break
			fresh.periods.append({"title":h.get_string(2),"text":historical.substr(start,end-start).strip_edges()})
	fresh.coverage="periods";fresh.note="Texte actualisé depuis la source. Les périodes reprennent ses titres ; leur découpage peut évoluer."
	return fresh

func relief_legend():
	var meta:Dictionary=relief_maps.get("meta",{})
	label(sheet,"LÉGENDE · ALTITUDE EN MÈTRES",11,MUTED)
	var grid=GridContainer.new();grid.columns=2;grid.add_theme_constant_override("h_separation",16);grid.add_theme_constant_override("v_separation",6);sheet.add_child(grid)
	for item in meta.get("legend",[]):
		var row=HBoxContainer.new();row.custom_minimum_size.x=220;row.size_flags_horizontal=Control.SIZE_EXPAND_FILL;row.add_theme_constant_override("separation",8);grid.add_child(row)
		var swatch=ColorRect.new();swatch.color=Color(str(item.color));swatch.custom_minimum_size=Vector2(20,16);swatch.size_flags_vertical=Control.SIZE_SHRINK_CENTER;swatch.mouse_filter=Control.MOUSE_FILTER_IGNORE;row.add_child(swatch)
		var caption=label(row,str(item.label),12);caption.size_flags_horizontal=Control.SIZE_EXPAND_FILL;caption.custom_minimum_size.x=182
	note("Trait de contour : pays ou territoire sélectionné. Frontières indicatives.")

func relief_image(map_record:Dictionary,tall:bool=false):
	var texture=load(str(map_record.file)) as Texture2D
	if texture==null:
		note("Carte indisponible dans cette copie.")
		return
	var frame=TextureRect.new();frame.texture=texture;frame.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;frame.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	frame.custom_minimum_size=Vector2(0,440 if tall else 295);frame.size_flags_horizontal=Control.SIZE_EXPAND_FILL;frame.mouse_filter=Control.MOUSE_FILTER_IGNORE
	sheet.add_child(frame)

func country_relief(code:String,index:int=0):
	var record:Dictionary=relief_maps.get("countries",{}).get(code,{})
	var maps:Array=record.get("maps",[])
	if maps.is_empty():note("La carte de relief de ce territoire n’est pas disponible dans cette édition.")
	else:
		index=clampi(index,0,maps.size()-1)
		relief_image(maps[index])
		label(sheet,str(maps[index].title),14)
		if maps.size()>1:
			for i in maps.size():
				button(sheet,str(maps[i].title),func():show_country(code,"Géographie");clear(sheet);country_relief(code,i),true,i==index)
		button(sheet,"Agrandir la carte  ↗",func():show_relief_map(code,index))
		relief_legend()
		if maps[index].get("note","")!="":note(maps[index].note)
		if record.get("note","")!="":note(record.note)
	heading("Comprendre la géographie")
	var c:Dictionary=countries[code]
	var overview="Superficie : "+(num(c.area)+" km²" if float(c.area)>0 else "non renseignée")+"."
	var neighbors:Array=[]
	for n in c.borders:
		if countries.has(n):neighbors.append(countries[n].name)
	if not neighbors.is_empty():overview+="\n\nVoisins terrestres : "+", ".join(neighbors)+"."
	history_fold("Repères géographiques",overview)
	var sections:Dictionary=TopicSections.extract(str(articles.get(code,{}).get("text","")))
	for sec in sections["Géographie"]:history_fold(sec.title,sec.text)
	if sections["Géographie"].is_empty():note("Aucun texte géographique distinct n’est disponible dans l’article enregistré pour ce territoire.")
	var meta:Dictionary=relief_maps.get("meta",{})
	history_fold("Sources et lecture de la carte",str(meta.get("description","")))
	if meta.has("source_url"):source_button("Altitudes · GEBCO 2025 / GMT",meta.source_url)
	if meta.has("license_url"):source_button("Licence et attribution des cartes",meta.license_url)
	article_credit(articles.get(code,{}))

func country_society(code:String,topic:String):
	var c:Dictionary=countries[code]
	if topic=="Population":
		stat("Population",num(c.population)+" habitants",data_caption(str(c.pop_source),c.get("pop_year"),"Population des pays"))
		note("Démographie, fécondité, groupes de population et migrations. Les chiffres conservent la date et le périmètre indiqués par leur source.")
	elif topic=="Langue":
		stat("Langues renseignées",(", ".join(c.languages) if c.languages.size()>0 else "Non renseignées"))
		note("Cette liste n’est pas exhaustive. Les langues parlées et leurs statuts sont précisés dans les textes ci-dessous lorsqu’ils sont documentés.")
	else:heading("Religions et croyances")
	var sections:Dictionary=TopicSections.extract(str(articles.get(code,{}).get("text","")))
	for sec in sections[topic]:history_fold(sec.title,sec.text)
	if sections[topic].is_empty():note("Aucune section distincte sur ce thème dans l’article enregistré. La source reste accessible ci-dessous.")
	article_credit(articles.get(code,{}))

func show_relief_map(code:String,index:int):
	var record:Dictionary=relief_maps.countries[code]
	open_modal("Carte du relief",countries[code].name+" · "+str(record.maps[index].title))
	relief_image(record.maps[index],true)
	relief_legend()
	if record.maps[index].get("note","")!="":note(record.maps[index].note)
	note(record.get("note",""))
	button(sheet,"← Revenir au pays",func():show_country(code,"Géographie"))

func article_credit(a:Dictionary):
	space(sheet,4)
	note("Extrait de Wikipédia en français · contributeurs de « "+str(a.get("title","cet article"))+" » · CC BY-SA 4.0. Copie du "+str(a.get("retrieved","2026-11-13"))+". Le texte peut contenir des informations plus anciennes.")
	if a.has("url"):source_button("Consulter la source et ses mises à jour",a.url)
	if a.has("source_timestamp"):note("Révision de l’article : "+str(a.source_timestamp).split("T")[0])
	note("Dernière consultation complète des sources d’articles : "+display_check("Articles"))
	if a.has("history"):source_button("Historique et auteurs",a.history)

func show_text_reader(title_text:String,a:Dictionary,txt:String):
	open_modal(title_text,"LECTURE · TEXTE ENREGISTRÉ HORS CONNEXION")
	if a.get("scope","")=="intro":note("Cette copie contient la présentation de l’article, pas son texte intégral. La source permet de poursuivre la lecture.")
	if txt=="":paragraph(sheet,"Cet article n’est pas disponible dans la copie embarquée.")
	else:paragraph(sheet,clean_text(txt))
	article_credit(a)

func show_city(city:Dictionary):
	open_modal(city.name,countries[city.code].name+"  /  "+("Capitale" if city.capital else "Grande ville"))
	button(sheet,"← Revenir au pays",func():show_country(city.code,"Villes"))
	button(sheet,"Voir sur la carte",func():close_modal();selected=city.code;map.selected=city.code;map.center=Vector2(city.lon,-city.lat);map.zoom=18;map.queue_redraw();home_card())
	if str(city.get("qid","")).begins_with("Q"):source_button("Identité et références du lieu","https://www.wikidata.org/wiki/"+str(city.qid))
	if city.get("population")!=null:
		stat("Population",num(city.population)+" habitants",data_caption("Wikidata · périmètre du lieu décrit",city.population_year,"Population des villes"))
		source_button("Source de la population · Wikidata",city.population_url)
	var key="city_"+str(city.id)
	var intro=article_intro(key)
	if intro!="":paragraph(sheet,shorten(intro,1600))
	if articles.get(key,{}).get("scope","")=="intro":
		note("Présentation encyclopédique enregistrée hors connexion. L’article détaillé et son histoire sont accessibles depuis la source.")
		article_credit(articles[key])
	else:show_article_topic(key,["histoire"],"L’histoire de la ville")

	if journey!=null:journey.track({"kind":"city","id":str(city.id),"scroll":0})

func country_sources(code:String):
	heading("D’où viennent ces informations ?")
	note("Les statistiques conservent leur année et leur source. Les textes sont des extraits encyclopédiques, pas une vérification éditoriale indépendante de chaque affirmation.")
	var c:Dictionary=countries[code]
	var population_url="https://data.worldbank.org/indicator/SP.POP.TOTL?locations="+str(c.iso2).to_upper() if str(c.pop_source).contains("Banque mondiale") else "https://www.naturalearthdata.com/downloads/50m-cultural-vectors/50m-admin-0-countries-2/"
	source_button("Population : "+str(c.pop_source)+year_suffix(c),population_url)
	source_button("Faits géographiques : mledoze/countries","https://github.com/mledoze/countries")
	source_button("Carte : Natural Earth","https://www.naturalearthdata.com/about/terms-of-use/")
	article_credit(articles.get(code,{}))
	source_button("Événements : UCDP Candidate "+str(observation_info.version)+"","https://ucdp.uu.se/downloads/")
	button(sheet,"Méthode, licences et confidentialité",show_about)

func country_conflicts(code:String):
	eyebrow("Histoire des conflits · 1826–"+str(atlas_year))
	heading("Rôle direct ou majeur")
	note("Conflits sur le territoire, belligérants principaux et interventions militaires importantes. Les participations limitées sont regroupées dans « Autres engagements ».")
	var primary=0
	var secondary=0
	for war in conflict_history:
		if code not in war.codes:continue
		var link:Dictionary=conflict_roles.get(war.id,{}).get(code,{})
		if link.get("tier","")=="direct":
			primary+=1
			war_button(war,code)
			note(link.get("role",""))
		else:secondary+=1
	if primary==0:note("Aucun dossier de cette sélection n’est classé ici comme rôle direct ou majeur. Cela ne signifie pas une absence historique de conflit.")
	if secondary>0:button(sheet,"Autres engagements · "+str(secondary)+" →",func():show_secondary_conflicts(code))
	note("Les frontières et les États ont changé. Chaque dossier précise le lien historique au pays actuel. Sélection non exhaustive.")
	button(sheet,"Histoire générale du pays",func():show_country(code,"Histoire"))
	button(sheet,"Les conflits du monde",show_conflict_hub)
	heading("Événements récents")
	var count:int=event_counts.get(code,0)
	note("Observations UCDP : "+str(observation_info.period)+". Ces événements de violence organisée sont distincts de la sélection historique ci-dessus.")
	if count>0:button(sheet,str(count)+" événements recensés · consulter",func():show_country_events(code,0))
	button(sheet,"État des mises à jour",show_updates)

func show_secondary_conflicts(code:String):
	open_modal("Autres engagements",countries[code].name+" · CONFLITS")
	note("Participations limitées à une coalition, soutiens et autres liens historiques. Ils ne sont pas assimilés à un rôle majeur.")
	for war in conflict_history:
		if code not in war.codes:continue
		var link:Dictionary=conflict_roles.get(war.id,{}).get(code,{})
		if link.get("tier","")!="direct":
			war_button(war,code)
			note(link.get("role","Lien à qualifier : ne figure pas dans la sélection principale."))
	button(sheet,"← Rôle direct ou majeur",func():show_country(code,"Conflits"))

func show_country_events(code:String,page:int):
	var ids:Array=[]
	for i in events.size():
		if events[i].code==code:ids.append(i)
	open_modal(countries[code].name,"ÉVÉNEMENTS · "+str(observation_info.period).to_upper()+" · PAGE "+str(page+1))
	if page>0:button(sheet,"← Page précédente",func():show_country_events(code,page-1))
	for i in ids.slice(page*40,(page+1)*40):
		var e:Dictionary=events[i]
		var b=button(sheet,e.date+" · "+e.location+"  →",func():show_event(i));b.alignment=HORIZONTAL_ALIGNMENT_LEFT;b.text_overrun_behavior=TextServer.OVERRUN_TRIM_ELLIPSIS
	if ids.size()>(page+1)*40:button(sheet,"Page suivante →",func():show_country_events(code,page+1))
	button(sheet,"← Dossier du pays",func():show_country(code,"Conflits"))

func show_event_cluster(index:int):
	var e:Dictionary=events[index]
	var origin:Vector2=map.project(e.lon,e.lat)
	var ids:Array=[]
	for i in events.size():
		var item:Dictionary=events[i]
		if map.event_type>0 and item.type!=map.event_type:continue
		if map.project(item.lon,item.lat).distance_to(origin)<12:ids.append(i)
	if ids.size()<2:show_event(index);return
	open_modal("Événements à proximité",str(ids.size())+" ÉVÉNEMENTS · ZOOMEZ POUR LES DISTINGUER")
	for i in ids:
		var item:Dictionary=events[i]
		var b=button(sheet,item.date+" · "+item.location+"  →",func():show_event(i));b.alignment=HORIZONTAL_ALIGNMENT_LEFT;b.text_overrun_behavior=TextServer.OVERRUN_TRIM_ELLIPSIS

func estimate_caption(e:Dictionary) -> String:
	if e.low>e.best or e.best>e.high:
		return "La source contient des bornes discordantes. La fourchette n’est pas affichée ; l’estimation centrale ci-dessus est reproduite telle quelle et reste à vérifier."
	return "Fourchette UCDP : "+str(int(e.low))+" à "+str(int(e.high))+". Estimation préliminaire ; ce n’est pas le bilan total d’un conflit."

func show_event(index:int):
	var e:Dictionary=events[index]
	open_modal(e.location,e.date+"  /  "+str(countries.get(e.code,{}).get("name",e.country)))
	eyebrow("Événement UCDP n° "+str(e.id))
	var types=["Violence impliquant un État","Violence entre acteurs non étatiques","Violence unilatérale contre des civils"]
	heading(types[int(e.type)-1])
	paragraph(sheet,"Acteurs recensés :\n"+str(e.a)+"\n"+str(e.b))
	note("Noms des acteurs conservés dans la langue du jeu de données. Période : "+e.date+" au "+e.end+".")
	stat("Décès estimés pour cet événement",str(int(e.best)),estimate_caption(e))
	paragraph(sheet,"Localisation : "+e.location+"\n"+e.region)
	if e.get("source_code",e.code)!=e.code:
		note("Rattachement géographique dans l’atlas : Palestine (Gaza ou Cisjordanie). Le champ « country » du jeu UCDP indique « "+e.country+" » ; ce codage d’origine est conservé dans les données source.")
	note("Précision géographique UCDP : "+str(int(e.precision))+" (1 = lieu précis ; valeurs supérieures = localisation plus approximative). Le marqueur ne représente pas une ligne de front.")
	heading("Sources recensées")
	paragraph(sheet,e.sources,14)
	note("Statut de codage : "+e.status+". Source : UCDP Candidate "+str(observation_info.version)+", "+str(observation_info.period)+". Les informations peuvent être révisées.")
	for co in conflicts:
		if e.code in co.codes:button(sheet,"Contexte : "+co.name+"  →",func():show_conflict(co))
	source_button("UCDP · données et méthode","https://ucdp.uu.se/downloads/")
	if countries.has(e.code):button(sheet,"Ouvrir le pays",func():show_country(e.code,"Conflits"))

func show_conflict(co:Dictionary):
	var a:Dictionary=articles.get(co.article,{})
	open_modal(co.name,"ORIGINES, CHRONOLOGIE ET SOURCES")
	eyebrow("Comprendre le contexte")
	var intro=article_intro(co.article)
	if intro!="":paragraph(sheet,shorten(intro,1800))
	else:paragraph(sheet,"Les repères ci-dessous permettent de replacer les événements dans leur contexte historique.")
	heading("Repères chronologiques")
	for item in co.timeline:
		paragraph(sheet,"• "+str(item),16)
	note("Sélection de repères historiques. Elle ne décrit pas à elle seule la situation actuelle. Pour l’observation récente, la carte couvre "+str(observation_info.period)+".")
	button(sheet,"Lire le dossier encyclopédique complet",func():show_text_reader(co.name,a,str(a.get("text",""))))
	for code in co.codes:
		if countries.has(code):button(sheet,countries[code].name+" · événements et fiche  →",func():show_country(code,"Conflits"))
	article_credit(a)
	source_button("Données récentes : UCDP","https://ucdp.uu.se/downloads/")

func show_recent_conflict_hub():
	open_modal("Conflits et tensions","UCDP · "+str(observation_info.period).to_upper()+" · PAS DE SUIVI EN DIRECT")
	paragraph(sheet,"La carte localise "+str(events.size())+" événements de violence organisée recensés par l’UCDP pour "+str(observation_info.period)+". Elle distingue trois catégories, sans colorier un pays entier comme une zone de combat.")
	heading("Filtrer la carte")
	var types=["Tous les événements","Impliquant un État","Entre acteurs non étatiques","Contre les civils"]
	for i in types.size():
		button(sheet,types[i],func():map.event_type=i;close_modal();mode="Observations";map.mode=mode;home_card();map.queue_redraw())
	note("Rose : implication d’un État. Ocre : acteurs non étatiques. Mauve : violence unilatérale. Une tension diplomatique sans événement répondant à ces critères n’apparaît pas nécessairement.")
	heading("Comprendre les origines")
	for co in conflicts:button(sheet,co.name+"  →",func():show_conflict(co))
	source_button("Définitions et périmètre UCDP","https://ucdp.uu.se/downloads/")

func normalized(txt:String) -> String:
	var s=txt.to_lower()
	var aa="àâäéèêëîïôöùûüçœ";var bb="aaaeeeeiioouuuco"
	for i in aa.length():s=s.replace(aa[i],bb[i])
	return s

func show_search(pick_side:String=""):
	open_modal("Chercher un lieu","PAYS, TERRITOIRES ET GRANDES VILLES")
	compare_pick=pick_side
	search_input=LineEdit.new();search_input.placeholder_text="France, Istanbul, Japon…";search_input.custom_minimum_size.y=50
	search_input.add_theme_stylebox_override("normal",box(Color.WHITE,10));search_input.add_theme_color_override("font_color",INK)
	search_input.add_theme_color_override("font_placeholder_color",MUTED)
	sheet.add_child(search_input)
	var results:=VBoxContainer.new();results.add_theme_constant_override("separation",8);sheet.add_child(results)
	search_input.text_changed.connect(func(txt):populate_search(results,txt))
	populate_search(results,"")

func populate_search(results:VBoxContainer,txt:String):
	clear(results)
	var q=normalized(txt)
	var n:=0
	for code in country_order:
		var c:Dictionary=countries[code]
		if q!="" and not normalized(c.name+" "+c.capital+" "+c.en).contains(q):continue
		var b=button(results,c.name+"  ·  "+c.region,func():
			if compare_pick!="":
				if compare_pick=="a":compare_a=code
				else:compare_b=code
				show_compare()
			else:close_modal();map.focus(code);select_country(code)
		)
		b.alignment=HORIZONTAL_ALIGNMENT_LEFT;b.text_overrun_behavior=TextServer.OVERRUN_TRIM_ELLIPSIS
		n+=1
	if compare_pick=="" and q!="":
		for city in cities:
			if normalized(city.name).contains(q):
				var b=button(results,city.name+" · "+countries[city.code].name+"  →",func():show_city(city));b.alignment=HORIZONTAL_ALIGNMENT_LEFT
				n+=1
	if n==0:label(results,"Aucun lieu trouvé. Essayez un autre nom.",16,MUTED)

func military_rank(category:String,field:String,code:String) -> String:
	var ranking=DefenseData.ranking(defense.get(category,{}),field,countries,category!="equipment")
	if not ranking.ranks.has(code):return "Non classé · donnée non comparable"
	var text=str(ranking.ranks[code])+" / "+str(ranking.count)
	return text+(" · "+str(ranking.year) if category!="equipment" else " · sélection documentée")

func defense_value(category:String,code:String,field:String="value") -> String:
	var record:Dictionary=defense.get(category,{}).get(code,{})
	if record.get(field)==null:return "Non renseigné"
	var text=num(record[field])
	if category=="gdp":
		var billions=float(record[field])/1000000000.0
		text=("%.1f" % billions).replace(".",",")+" Md USD" if billions>=1 else num(float(record[field])/1000000.0)+" M USD"
	if record.get("year")!=null:text+=" · "+str(int(record.year))
	return text

func country_military(code:String):
	eyebrow("Forces armées · sources et millésimes")
	stat("Effectifs militaires et paramilitaires actifs",defense_value("personnel",code),"Banque mondiale / IISS · réservistes exclus")
	stat("Rang par effectifs",military_rank("personnel","value",code),"Même année de référence ; États renseignés seulement")
	note("Les effectifs disponibles sont principalement datés de 2020. Ils ne représentent pas nécessairement les forces actuelles. Une absence de donnée ne signifie pas une absence d’armée.")
	source_button("Effectifs : définition et données", "https://data.worldbank.org/indicator/MS.MIL.TOTL.P1")
	heading("Équipement")
	var equipment:Dictionary=defense.get("equipment",{}).get(code,{})
	note("Inventaire indicatif : millésimes non harmonisés et informations parfois anciennes. Les quantités ne mesurent ni la disponibilité ni la qualité des matériels. Ces repères ne constituent pas un classement mondial de puissance.")
	if equipment.get("uncertain",false):note("La ligne de ce pays manque de références dans la source : chiffres à vérifier, exclus des classements.")
	for pair in [["tanks","Chars de combat"],["combat_aircraft","Avions de combat"],["attack_helicopters","Hélicoptères d’attaque"],["carriers","Porte-avions"],["submarines_nuclear","Sous-marins nucléaires"],["submarines_conventional","Sous-marins conventionnels"]]:
		stat(pair[1],defense_value("equipment",code,pair[0]),"Date non harmonisée · inventaire indicatif")
	for pair in [["tanks","Rang indicatif · chars"],["combat_aircraft","Rang indicatif · aviation de combat"]]:
		stat(pair[1],military_rank("equipment",pair[0],code),"Sous-ensemble de pays avec références ; pas un rang mondial exhaustif")
	source_button("Inventaire et références",DefenseData.EQUIPMENT_URL)
	source_button("Historique des contributions","https://en.wikipedia.org/w/index.php?title="+DefenseData.EQUIPMENT_TITLE+"&action=history")
	heading("Puissance militaire globale")
	paragraph(sheet,"Aucun rang universel ne résume la puissance militaire. Les effectifs et matériels ne suffisent pas : entraînement, disponibilité, logistique et alliances comptent aussi. Le classement Global Firepower est consultable chez son éditeur ; il n’est pas reproduit comme une donnée libre dans Méridien.")
	source_button("Consulter le classement Global Firepower","https://www.globalfirepower.com/countries-listing.php")
	show_article_topic(code,["armée","défense","militaire","forces armées"],"Défense et organisation")

func comparison_cell(grid:GridContainer,title_text:String,text:String):
	var wrap:=ReadingCard.new();wrap.size_flags_horizontal=Control.SIZE_EXPAND_FILL;wrap.custom_minimum_size.x=220;wrap.add_theme_stylebox_override("panel",box(Color("e5e5db"),10));grid.add_child(wrap)
	var v:=VBoxContainer.new();wrap.add_child(v);label(v,title_text,10,MUTED);label(v,text,17,INK)

func show_compare():
	open_modal("Comparer deux pays","LES MÊMES REPÈRES, CÔTE À CÔTE")
	var a:Dictionary=countries[compare_a];var b:Dictionary=countries[compare_b]
	button(sheet,a.name+"  ·  changer",func():show_search("a"))
	button(sheet,b.name+"  ·  changer",func():show_search("b"))
	var grid:=GridContainer.new();grid.columns=2;grid.size_flags_horizontal=Control.SIZE_EXPAND_FILL;grid.add_theme_constant_override("h_separation",12);grid.add_theme_constant_override("v_separation",12);sheet.add_child(grid)
	for key in ["name","capital","population","gdp","economic_rank","personnel","personnel_rank","tanks","tank_rank","combat_aircraft","aircraft_rank","area","languages","currency"]:
		var titles={"name":"PAYS","capital":"CAPITALE","population":"POPULATION","gdp":"PIB NOMINAL","economic_rank":"RANG ÉCONOMIQUE · PIB","personnel":"MILITAIRES + PARAMILITAIRES ACTIFS","personnel_rank":"RANG PAR EFFECTIFS","tanks":"CHARS · INVENTAIRE INDICATIF","tank_rank":"RANG CHARS · SÉLECTION","combat_aircraft":"AVIONS DE COMBAT · INDICATIF","aircraft_rank":"RANG AVIATION · SÉLECTION","area":"SUPERFICIE","languages":"LANGUES","currency":"MONNAIE"}
		for c in [a,b]:
			var txt=""
			match key:
				"population":txt=num(c.population)+year_suffix(c)
				"gdp":txt=defense_value("gdp",c.code)
				"economic_rank":txt=military_rank("gdp","value",c.code)
				"personnel":txt=defense_value("personnel",c.code)
				"personnel_rank":txt=military_rank("personnel","value",c.code)
				"tanks","combat_aircraft":
					txt=defense_value("equipment",c.code,key)+"\nDate non harmonisée"
					if defense.get("equipment",{}).get(c.code,{}).get("uncertain",false):txt+="\nRéférences insuffisantes"
				"tank_rank":txt=military_rank("equipment","tanks",c.code)
				"aircraft_rank":txt=military_rank("equipment","combat_aircraft",c.code)
				"area":txt=(num(c.area)+" km²" if float(c.area)>0 else "Non renseignée")
				"languages":txt=(", ".join(c.languages) if c.languages.size()>0 else "Non renseignées")
				_:txt=str(c[key])
			comparison_cell(grid,titles[key],txt)
	note("PIB nominal : milliards de dollars courants. Rang économique par PIB total, pas par richesse par habitant. Les rangs PIB et effectifs utilisent une année commune et les États renseignés. Les ex æquo partagent un rang.")
	note("Équipements : dates non harmonisées ; rangs limités au sous-ensemble avec références dans la source. Ils ne sont pas des classements mondiaux exhaustifs ni des mesures de puissance. Les données absentes ne valent jamais zéro.")
	source_button("PIB : Banque mondiale","https://data.worldbank.org/indicator/NY.GDP.MKTP.CD")
	source_button("Effectifs : Banque mondiale / IISS","https://data.worldbank.org/indicator/MS.MIL.TOTL.P1")
	source_button("Équipements : tableau et références",DefenseData.EQUIPMENT_URL)
	source_button("Puissance globale : classement de l’éditeur","https://www.globalfirepower.com/countries-listing.php")

func save_carnet():
	var f=FileAccess.open("user://carnet.json",FileAccess.WRITE)
	if f:f.store_string(JSON.stringify({"bookmarks":bookmarks,"visited":visited}))

func toggle_bookmark(code:String):
	if code in bookmarks:bookmarks.erase(code)
	else:bookmarks.append(code)
	save_carnet()

func show_bookmarks():
	journey.country_origin={};journey.navigate({"kind":"carnet"},true)

func show_place(index:int):
	var pl:Dictionary=places[index]
	open_modal(pl.name,"REPÈRE HISTORIQUE · "+str(pl.get("era","")) if pl.kind=="histoire" else "POURQUOI CET ENDROIT COMPTE")
	paragraph(sheet,pl.intro,20)
	var a:Dictionary=articles.get(pl.article,{})
	if pl.kind=="histoire":
		show_article_topic(pl.article,["histoire"],"Contexte historique")
		button(sheet,"← Choisir une époque",show_history_hub)
		return
	paragraph(sheet,shorten(article_intro(pl.article),4000))
	button(sheet,"Lire le dossier complet",func():show_text_reader(pl.name,a,str(a.get("text",""))))
	button(sheet,"Localiser sur la carte",func():close_modal();mode="Repères" if pl.kind=="stratégique" else "Géographie";map.mode=mode;map.center=Vector2(pl.lon,-pl.lat);map.zoom=8;top.queue_free();build_header();home_card();map.queue_redraw())
	article_credit(a)

func show_explore():
	open_modal("Explorer le monde","SUIVRE UN FIL, RELIER LES LIEUX")
	heading("Cartes thématiques du monde")
	for map_mode in ["Conflits","Histoire","Géographie","Repères","Population"]:
		button(sheet,map_mode+"  →",func():set_mode(map_mode))
	eyebrow("Une découverte au hasard")
	button(sheet,"Emmenez-moi quelque part  →",func():var code=country_order.pick_random();map.focus(code);show_country(code),true,true)
	heading("Parcours de découverte")
	button(sheet,"01 · Autour de la Méditerranée",func():show_route("Autour de la Méditerranée","Relier des rivages proches, des sociétés et des histoires différentes.",["GRC","TUR","EGY","ITA","TUN","FRA","ESP","MAR"]))
	button(sheet,"02 · Les routes maritimes",func():show_route("Les routes maritimes","Explorer les passages qui relient les océans.",[],true))
	button(sheet,"03 · Empires et indépendances",func():show_route("Empires et indépendances","Comparer des trajectoires historiques sans les réduire à un modèle unique.",["IND","DZA","GHA","VNM","BRA","HTI"]))
	button(sheet,"04 · Les grands fleuves",func():show_route("Les grands fleuves","Comprendre des pays à travers leurs bassins fluviaux.",["EGY","SDN","ETH","BRA","CHN","IND"]))
	heading("Remonter le temps")
	button(sheet,"Ouvrir la carte historique",func():set_mode("Histoire"))
	note("Les repères ci-dessous ouvrent l’histoire des pays concernés. La carte conserve les frontières contemporaines ; elle ne reconstitue pas les frontières anciennes.")
	var eras=[["Antiquité","Égypte, cités grecques et Rome",["EGY","GRC","ITA"]],["Moyen Âge","Routes, royaumes et échanges",["TUR","CHN","MLI"]],["XVe–XVIIIe siècles","Expansions maritimes et colonisations",["PRT","ESP","BRA"]],["XIXe siècle","Révolutions, nations et empires",["FRA","DEU","JPN"]],["1914–1945","Guerres mondiales et bouleversements",["DEU","FRA","POL","JPN"]],["Depuis 1945","Décolonisations et monde contemporain",["IND","DZA","ZAF","UKR"]]]
	for era in eras:button(sheet,era[0]+"  →",func():show_route(era[0],era[1],era[2],false,true))
	heading("Atlas des conflits")
	button(sheet,"Comprendre les conflits et leurs origines",show_conflict_hub)

func show_route(title_text:String,intro:String,codes:Array,maritime:bool=false,history:bool=false):
	open_modal(title_text,"PARCOURS DE DÉCOUVERTE")
	paragraph(sheet,intro,20)
	if maritime:
		for i in places.size():
			if places[i].kind=="stratégique":button(sheet,places[i].name+"  →",func():show_place(i))
	else:
		for code in codes:button(sheet,countries[code].name+"  →",func():map.focus(code);show_country(code,"Histoire" if history else "L’essentiel"))
	button(sheet,"← Tous les parcours",show_explore)

func show_history_hub():
	open_modal("Au fil du temps","REPÈRES HISTORIQUES SUR LA CARTE")
	note("Une sélection d’événements pour commencer l’exploration. Les frontières restent celles de la carte contemporaine. Les articles associés donnent le contexte et les sources.")
	for era in ["Toutes les époques","Antiquité","Moyen Âge","Époque moderne","XIXe siècle","XXe siècle"]:
		button(sheet,era+"  →",func():map.history_period=era;set_mode("Histoire");map.world_view())
	heading("Les repères")
	for i in places.size():
		if places[i].kind=="histoire":button(sheet,places[i].name+"  →",func():show_place(i))

func show_help():
	open_modal("Le monde à portée de main","QUELQUES GESTES POUR EXPLORER")
	heading("01 · Choisissez un pays")
	paragraph(sheet,"Touchez un pays sur la carte, puis « Plus d’infos sur le pays ». La loupe permet aussi de le rechercher.")
	heading("02 · Découvrez ses histoires")
	paragraph(sheet,"Histoire, villes, conflits, géographie, gastronomie, sport… Faites glisser le bandeau des rubriques pour tout découvrir.")
	heading("03 · Comparez deux pays")
	paragraph(sheet,"Touchez « Comparer » en bas, puis choisissez deux pays pour consulter leurs indicateurs côte à côte.")
	note("Glissez pour déplacer la carte. Pincez pour zoomer, ou utilisez + et −.")
	button(sheet,"C’est parti · ouvrir la carte",close_modal,true,true)
	button(sheet,"Sources, mises à jour et à propos",show_about)

func show_about():
	open_modal("À propos de Méridien","ATLAS HISTORIQUE, GÉOGRAPHIQUE ET GÉOPOLITIQUE")
	heading("Comprendre avant de conclure")
	paragraph(sheet,"Méridien rassemble une carte mondiale, des statistiques datées, des textes encyclopédiques et des événements documentés. Une source n’est pas infaillible : les sujets contestés demandent de confronter les références et de distinguer faits, interprétations et déclarations.")
	heading("Couverture et dates")
	var count:=0
	for a in articles.values():
		if a.has("text"):count+=1
	paragraph(sheet,str(countries.size())+" pays et territoires, "+str(cities.size())+" villes sélectionnées, "+str(count)+" articles embarqués et "+str(events.size())+" événements UCDP. Catalogues enrichis le 15 novembre 2026. Chaque population indique son année. Les événements couvrent "+str(observation_info.period)+" uniquement.")
	note("Les articles n’ont pas tous fait l’objet d’une relecture éditoriale indépendante. Des redirections et homonymies peuvent subsister. Les sources en ligne permettent de vérifier et d’actualiser les informations. Une actualisation directe est prévue à chaque échéance du 15, au lancement de l’application. Voir « Mises à jour du contenu ».")
	heading("Lire la carte")
	paragraph(sheet,"Pincez avec deux doigts pour zoomer, faites glisser la carte pour vous déplacer, puis touchez un pays ou un marqueur. Les boutons + et - permettent aussi de zoomer et dézoomer. Projection équirectangulaire : les surfaces et les distances sont déformées, particulièrement vers les pôles.")
	note("Les frontières suivent la représentation de Natural Earth et ne valent pas reconnaissance diplomatique. Certaines petites entités sont accessibles plus facilement par la recherche. Les repères géographiques sont une sélection, pas un inventaire exhaustif.")
	heading("Sources et licences")
	paragraph(sheet,"Carte et villes : Natural Earth, domaine public. Faits géographiques : mledoze/countries, ODbL 1.0. Population : Banque mondiale, indicateur SP.POP.TOTL, selon les conditions du jeu de données ; complément Natural Earth. Drapeaux : flag-icons, MIT. Textes : Wikipédia et ses contributeurs, CC BY-SA 4.0 ; textes conservés avec leurs liens vers les articles et historiques. La compilation d’extraits adaptée reste sous CC BY-SA 4.0.",15)
	paragraph(sheet,"Personnalités : Pantheon 2025 (Datawheel), CC BY-SA 4.0 ; Yu et al., Pantheon 1.0, Scientific Data (2016). Rattachements principalement par lieu de naissance, complétés par des liens biographiques explicites. Identifiants, descriptions et titres français : Wikidata (CC0).",15)
	source_button("Pantheon · licence et méthode","https://pantheon.world/data/permissions")
	paragraph(sheet,"Violences : UCDP Candidate Events Dataset "+str(observation_info.version)+". Hegre, Croicu, Eck et Högbladh (2020), Introducing the UCDP Candidate Events Dataset, Research & Politics. Les enregistrements ont été sélectionnés et reformattés pour cet atlas, sous CC BY 4.0. Les données sont préliminaires et ne mesurent pas toutes les formes de violence.",15)
	button(sheet,"Mises à jour du contenu",show_updates)
	button(sheet,"Fiabilité et contrôles du contenu",show_quality)
	source_button("Natural Earth","https://www.naturalearthdata.com/about/terms-of-use/")
	source_button("Wikipédia · CC BY-SA 4.0","https://creativecommons.org/licenses/by-sa/4.0/deed.fr")
	source_button("UCDP · données et codebook","https://ucdp.uu.se/downloads/")
	source_button("Banque mondiale · population","https://data.worldbank.org/indicator/SP.POP.TOTL")
	source_button("mledoze/countries · ODbL","https://github.com/mledoze/countries")
	source_button("Drapeaux · flag-icons","https://github.com/lipis/flag-icons")
	heading("Votre appareil, votre carnet")
	paragraph(sheet,"L’application fonctionne hors connexion. Elle ne demande ni compte, ni localisation, ni accès à vos contacts. Aucun outil publicitaire ou de mesure d’audience n’est intégré. Les favoris et les lieux consultés restent sur cet appareil. Les liens de sources ouvrent le navigateur externe, soumis à ses propres règles de confidentialité.")
	note("Méridien v13 · édition Android 13.0. Application construite avec Godot 4.6.3 (MIT) ; polices Noto (SIL Open Font License).")
	source_button("Licence de Godot","https://godotengine.org/license/")

func show_toast(txt:String):
	if not is_instance_valid(toast_label):return
	toast_label.text=txt;toast_label.visible=true
	await get_tree().create_timer(3).timeout
	if is_instance_valid(toast_label):toast_label.visible=false

func ui_back():
	if journey!=null and (not journey.screen.is_empty() or not journey.country_origin.is_empty()):journey.back()
	else:close_modal()

func _notification(what):
	if what==NOTIFICATION_APPLICATION_PAUSED and journey!=null:
		journey.capture(true)
		monthly_sync.save_cache()
	if what==NOTIFICATION_APPLICATION_RESUMED and is_instance_valid(map) and journey!=null:
		journey.last_poll=0;journey.poll()
		if not skip_monthly_sync and not monthly_sync.running and monthly_sync.due():run_monthly_startup()
	if what==NOTIFICATION_WM_GO_BACK_REQUEST:
		if is_instance_valid(boot_overlay) and boot_overlay.visible:continue_monthly();return
		if is_instance_valid(modal):ui_back()
		elif selected!="":selected="";map.selected="";map.queue_redraw();home_card()
		else:get_tree().quit()

func _process(delta):
	if journey==null:return
	journey.poll();reading_save_time+=delta
	if reading_save_time>8 and not journey.reading.is_empty():
		reading_save_time=0
		journey.capture(true)

func _unhandled_key_input(event):
	if event.is_action_pressed("ui_cancel"):
		if is_instance_valid(boot_overlay) and boot_overlay.visible:continue_monthly()
		elif is_instance_valid(modal):ui_back()

func country_cities(code:String):
	eyebrow("Villes importantes · sélection géographique")
	note("Villes sélectionnées classées par population décroissante. Le millésime est indiqué : les dates et les périmètres administratifs varient selon les sources. Les populations non renseignées sont placées à la fin.")
	if code=="USA":
		heading("Par État et district fédéral")
		var states:Array=[]
		for city in cities:
			if city.code==code and city.get("region","") not in states:states.append(city.get("region",""))
		states.sort()
		for state in states:button(sheet,state_name(state)+"  →",func():show_state_cities(state))
	else:
		var rows=ranked_cities(code)
		for city in rows:city_button(city)
		if rows.is_empty():paragraph(sheet,"Aucun centre urbain n’est présent dans la base retenue pour ce territoire. Capitale renseignée : "+countries[code].capital)

func ranked_cities(code:String,state:String="") -> Array:
	var rows:Array=[]
	for city in cities:
		if city.code==code and (state=="" or city.get("region","")==state):rows.append(city)
	rows.sort_custom(func(a,b):
		var ap=float(a.get("population") if a.get("population")!=null else -1)
		var bp=float(b.get("population") if b.get("population")!=null else -1)
		if ap!=bp:return ap>bp
		return str(a.name).naturalnocasecmp_to(str(b.name))<0)
	return rows

func city_button(city:Dictionary):
	var b=button(sheet,city.name+(" · capitale" if city.capital else "")+"  →",func():show_city(city))
	b.alignment=HORIZONTAL_ALIGNMENT_LEFT
	if city.get("population")!=null:
		note(num(city.population)+" habitants · "+str(int(city.population_year)))
	else:note("Population non renseignée")

func show_state_cities(state:String):
	open_modal(state_name(state),"ÉTATS-UNIS · POPULATION DÉCROISSANTE")
	for city in ranked_cities("USA",state):city_button(city)
	button(sheet,"← Tous les États",func():show_country("USA","Villes"))

func people_for(code:String,group:String="Tous les domaines",query:String="")->Array:
	var rows:Array=[]
	for person in people:
		if person.code==code and (group=="Tous les domaines" or person.group==group) and (query.strip_edges()=="" or query.to_lower() in (str(person.name)+" "+str(person.get("occupation_label",""))).to_lower()):rows.append(person)
	return rows

func person_button(person:Dictionary):
	var b=button(sheet,person.name+" · "+person.group+" →",func():show_person(person))
	b.alignment=HORIZONTAL_ALIGNMENT_LEFT
	b.text_overrun_behavior=TextServer.OVERRUN_TRIM_ELLIPSIS

func country_people(code:String):
	eyebrow("Personnalités marquantes · par domaine")
	var rows=people_for(code)
	heading("Des parcours à découvrir")
	note("Choisissez un domaine pour découvrir les personnalités liées à ce pays.")
	if rows.is_empty():
		note("Aucun profil documenté dans le catalogue de cette édition pour ce territoire.")
		return
	var grid=GridContainer.new();grid.columns=2;grid.add_theme_constant_override("h_separation",10);grid.add_theme_constant_override("v_separation",10);sheet.add_child(grid)
	for group in PEOPLE_DOMAINS:
		var count=people_for(code,group).size()
		if count==0:continue
		var b=button(grid,PEOPLE_DOMAINS[group]+"\n"+str(count)+(" personnalité" if count==1 else " personnalités")+"  →",func():show_people_catalog(code,group))
		b.size_flags_horizontal=Control.SIZE_EXPAND_FILL
		b.custom_minimum_size=Vector2(220,78)
		b.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	button(sheet,"Toutes les personnalités · "+str(rows.size())+" →",func():show_people_catalog(code),true,true)
	note("Figurer ici ne constitue ni un hommage ni une approbation. Les biographies présentent aussi les controverses. Seuls les domaines documentés pour ce pays sont proposés.")
	note("Sélection issue de Pantheon 2025, élargie par domaine. L’ordre s’appuie sur son indice de notoriété documentaire ; ce n’est pas un jugement d’importance. Le lien au pays est précisé dans chaque fiche.")

func catalog_filter(options:Array,current:String,callback:Callable):
	var pick=OptionButton.new();pick.custom_minimum_size=Vector2(0,48)
	pick.add_theme_stylebox_override("normal",box(Color("e8e8df"),10));pick.add_theme_color_override("font_color",INK)
	for item in options:pick.add_item(item)
	pick.selected=maxi(0,options.find(current));sheet.add_child(pick)
	pick.item_selected.connect(func(index):callback.call(options[index]))

func show_people_catalog(code:String,group:String="Tous les domaines",query:String="",page:int=0):
	open_modal(PEOPLE_DOMAINS.get(group,"Personnalités"),countries[code].name+" · PERSONNALITÉS")
	button(sheet,"← Choisir un autre domaine",func():show_country(code,"Personnalités marquantes"))
	var groups:Array=["Tous les domaines"]
	for person in people_for(code):
		if person.group not in groups:groups.append(person.group)
	catalog_filter(groups,group,func(value):show_people_catalog(code,value,query,0))
	var search=LineEdit.new();search.placeholder_text="Rechercher un nom";search.text=query;search.custom_minimum_size.y=48;sheet.add_child(search)
	search.add_theme_stylebox_override("normal",box(Color.WHITE,10));search.add_theme_color_override("font_color",INK);search.add_theme_color_override("font_placeholder_color",MUTED)
	search.text_submitted.connect(func(value):show_people_catalog(code,group,value,0))
	button(sheet,"Rechercher",func():show_people_catalog(code,group,search.text,0))
	var rows=people_for(code,group,query)
	note(str(rows.size())+" personnalités · page "+str(page+1)+" / "+str(maxi(1,ceili(rows.size()/12.0))))
	for i in range(page*12,mini(rows.size(),(page+1)*12)):person_button(rows[i])
	if rows.is_empty():note("Aucun résultat pour cette recherche. Essayez un autre nom ou domaine.")
	if page>0:button(sheet,"← Page précédente",func():show_people_catalog(code,group,query,page-1))
	if (page+1)*12<rows.size():button(sheet,"Voir davantage →",func():show_people_catalog(code,group,query,page+1))
	button(sheet,"← Vue du pays",func():show_country(code,"Personnalités marquantes"))

func show_person(person:Dictionary):
	open_modal(person.name,person.group.to_upper())
	if person.get("description","")!="":paragraph(sheet,person.description,20)
	elif person.get("occupation_label","")!="":paragraph(sheet,person.occupation_label,20)
	var key=person.get("article","person_"+str(person.qid));var a:Dictionary=articles.get(key,{})
	var issues=Reliability.person_issues(person,a)
	var uncertain_birth=false;var uncertain_death=false
	for issue in issues:
		if issue.field in ["birth","dates"]:uncertain_birth=true
		if issue.field in ["death","dates"]:uncertain_death=true
	if not issues.is_empty():
		heading("Dates à vérifier")
		for issue in issues:note(issue.message)
		note("Ce contrôle signale une divergence potentielle ; il ne permet pas à lui seul de trancher entre les sources.")
	stat("Naissance","À vérifier" if uncertain_birth else format_year(str(person.birth)),person.place)
	if person.has("birth_source_url"):source_button("Source de la date de naissance",person.birth_source_url)
	note(person.get("association","Lien documentaire"))
	if person.get("association_source","")!="":source_button("Référence du lien au pays",person.association_source)
	if str(person.get("death",""))!="":stat("Décès","À vérifier" if uncertain_death else format_year(str(person.death)),"Date conservée dans Pantheon 2025")

	if a.get("text","")!="":paragraph(sheet,clean_text(a.text));article_credit(a)
	else:note("Repères issus de Pantheon 2025 et de Wikidata. La biographie complète de ce profil est accessible en ligne ; elle n’est pas enregistrée dans cette édition.")
	if person.get("wiki","")!="":source_button("Lire la biographie en ligne","https://fr.wikipedia.org/wiki/"+str(person.wiki).uri_encode())
	else:source_button("Biographie liée à Wikidata","https://www.wikidata.org/wiki/Special:GoToLinkedPage/frwiki/"+person.qid)
	source_button("Wikidata · identité et références","https://www.wikidata.org/wiki/"+person.qid)
	source_button("Pantheon · données et méthode","https://pantheon.world/data/datasets")
	button(sheet,"← Toutes les figures",func():show_country(person.code,"Personnalités marquantes"))

	if journey!=null:journey.track({"kind":"person","id":person.qid,"code":person.code,"scroll":0})

func country_specialties(code:String,category:String="Toutes les spécialités")->Array:
	var rows:Array=[]
	for entry in specialties.get(code,[]):
		if category=="Toutes les spécialités" or entry.get("category","Plats")==category:rows.append(entry)
	return rows

func specialty_button(code:String,entry:Dictionary):
	var b=button(sheet,str(entry.name)+" →",func():show_specialty(code,entry))
	b.alignment=HORIZONTAL_ALIGNMENT_LEFT
	b.text_overrun_behavior=TextServer.OVERRUN_TRIM_ELLIPSIS
	b.custom_minimum_size.y=54

func country_food(code:String):
	eyebrow("Gastronomie · spécialités et recettes")
	heading("À la table du pays")
	var rows=country_specialties(code)
	if not rows.is_empty():
		note(str(rows.size())+" spécialités documentées. Voici une première sélection ; ouvrez le catalogue pour découvrir les autres.")
		for i in mini(6,rows.size()):specialty_button(code,rows[i])
		button(sheet,"Toutes les spécialités · "+str(rows.size())+" →",func():show_food_catalog(code),true,true)
		note("Les cuisines sont régionales et partagées. Les rattachements décrivent des traditions, pas des origines exclusives ni un classement de popularité.")
	else:note(recipe_book.get("unavailable",{}).get(code,"Le catalogue de spécialités reste à documenter pour ce territoire."))
	rule()
	var entry:Dictionary=cuisines.get(code,{})
	var a:Dictionary=articles.get(entry.get("article",""),{})
	if a.get("text","")!="":
		heading("Traditions culinaires")
		paragraph(sheet,shorten(clean_text(a.text),650))
		button(sheet,"Lire le dossier gastronomique",func():show_text_reader(a.title,a,a.text))
		article_credit(a)

func show_food_catalog(code:String,category:String="Toutes les spécialités",page:int=0):
	open_modal("Spécialités",countries[code].name+" · CUISINER ET DÉCOUVRIR")
	var groups:Array=["Toutes les spécialités"]
	for entry in country_specialties(code):
		var group=str(entry.get("category","Plats"))
		if group not in groups:groups.append(group)
	catalog_filter(groups,category,func(value):show_food_catalog(code,value,0))
	var rows=country_specialties(code,category)
	note(str(rows.size())+" spécialités · page "+str(page+1)+" / "+str(maxi(1,ceili(rows.size()/12.0))))
	for i in range(page*12,mini(rows.size(),(page+1)*12)):specialty_button(code,rows[i])
	if page>0:button(sheet,"← Page précédente",func():show_food_catalog(code,category,page-1))
	if (page+1)*12<rows.size():button(sheet,"Voir davantage →",func():show_food_catalog(code,category,page+1))
	button(sheet,"← Gastronomie du pays",func():show_country(code,"Gastronomie"))

func show_specialty(code:String,entry:Dictionary):
	open_modal(entry.name,countries[code].name+" · "+str(entry.get("category","GASTRONOMIE")).to_upper())
	if entry.get("region","")!="":eyebrow(entry.region)
	paragraph(sheet,entry.get("description",""))
	var source:Dictionary=entry.get("source",{})
	if source.get("url","")!="" and source.get("url","")!=entry.get("recipe_source",{}).get("url",""):
		source_button("Découvrir la spécialité · "+str(source.get("title","Source")),source.url)
	rule()
	heading("Recette")
	var recipe_id=str(entry.get("recipe_id",""))
	if recipe_book.recipes.has(recipe_id):
		var r:Dictionary=recipe_book.recipes[recipe_id]
		note("Préparation enregistrée, ingrédients et étapes disponibles hors connexion. Les adaptations sont précisées dans la recette.")
		button(sheet,"Ingrédients et préparation →",func():show_recipe(code,recipe_id),true,true)
	var recipe_source:Dictionary=entry.get("recipe_source",{})
	if recipe_source.get("url","")!="":
		source_button("Recette de référence · "+str(recipe_source.get("title","Source")),recipe_source.url)
		note("Ouvre le site de la recette ; connexion nécessaire. "+str(entry.get("recipe_note","")))
	elif not recipe_book.recipes.has(recipe_id):note("La spécialité est documentée ; aucune préparation détaillée n’est encore enregistrée dans cette édition.")
	button(sheet,"← Toutes les spécialités",func():show_food_catalog(code))

func recipe_button(code:String,id:String):
	var r:Dictionary=recipe_book.get("recipes",{}).get(id,{})
	if r.is_empty():return
	var b=button(sheet,str(r.name)+"  ·  Recette →",func():show_recipe(code,id),true)
	b.alignment=HORIZONTAL_ALIGNMENT_LEFT
	b.text_overrun_behavior=TextServer.OVERRUN_TRIM_ELLIPSIS
	b.custom_minimum_size.y=58

func show_country_recipes(code:String):
	open_modal("Recettes",countries[code].name+" · CUISINER LE MONDE")
	note("Choisissez un plat pour retrouver ses ingrédients et ses étapes. Les quantités proposées correspondent à une version familiale, avec des adaptations signalées.")
	for id in recipe_book.get("countries",{}).get(code,{}).get("dishes",[]):recipe_button(code,id)
	button(sheet,"← Gastronomie du pays",func():show_country(code,"Gastronomie"))

func show_recipe(code:String,id:String):
	var r:Dictionary=recipe_book.recipes[id]
	open_modal("Recette",countries[code].name+" · GASTRONOMIE")
	heading(r.name)
	stat("Quantités",r.servings)
	note("Temps indicatif : "+str(int(r.minutes))+" min. Vérifier les éventuels temps de trempage et de repos dans les étapes.")
	heading("Ingrédients")
	for ingredient in r.ingredients:paragraph(sheet,"• "+str(ingredient))
	heading("Préparation")
	for i in r.steps.size():
		label(sheet,"ÉTAPE "+str(i+1),12,MUTED)
		paragraph(sheet,r.steps[i])
	rule();note(r.note)
	if r.get("reference_recipe",false):note("Adaptation résumée d’une recette publiée : quantités et méthode vérifiées dans la référence ci-dessous. Cette préparation n’a pas été testée en cuisine par Méridien.")
	else:note("Adaptation maison non testée en cuisine. La source documente le plat ; elle ne valide pas les quantités proposées. Une recette publiée est privilégiée lorsqu’elle est disponible dans le catalogue.")
	var source:Dictionary=r.get("source",{})
	if source.get("url","")!="":source_button(("Recette de référence · " if r.get("reference_recipe",false) else "Origine et variantes · ")+str(source.get("title","Source")),source.url)
	button(sheet,"← Toutes les spécialités",func():show_food_catalog(code),true,true)
	button(sheet,"← Gastronomie",func():show_country(code,"Gastronomie"))

	if journey!=null:journey.track({"kind":"recipe","id":id,"code":code,"scroll":0})

func war_button(war:Dictionary,code:String=""):
	var b=button(sheet,war.period+" · "+war.name+"  →",func():show_war(war,code));b.alignment=HORIZONTAL_ALIGNMENT_LEFT;b.text_overrun_behavior=TextServer.OVERRUN_TRIM_ELLIPSIS

func show_conflict_hub():
	open_modal("Deux siècles de conflits","1826–"+str(atlas_year)+" · SÉLECTION HISTORIQUE")
	note("Guerres, conflits coloniaux, guerres civiles et violences de masse. Sélection documentaire non exhaustive ; certains conflits commencés avant 1826 se poursuivent dans la période. Les frontières affichées sont contemporaines.")
	var periods=[["Toute la période",1826,atlas_year],["1826–1913",1826,1913],["1914–1945",1914,1945],["1946–1990",1946,1990],["1991–"+str(atlas_year),1991,atlas_year]]
	for period in periods:button(sheet,period[0],func():war_from=period[1];war_to=period[2];show_conflict_hub(),true,war_from==period[1] and war_to==period[2])
	button(sheet,"Voir cette période sur la carte",func():map.war_from=war_from;map.war_to=war_to;set_mode("Conflits"))
	heading("Dossiers · "+str(war_from)+"–"+str(war_to))
	for war in conflict_history:
		if war.start<=war_to and int(war.end if war.end!=null else atlas_year)>=war_from:war_button(war)
	heading("Données récentes et actualisation")
	button(sheet,"Observations UCDP · "+str(observation_info.period)+"",show_recent_conflict_hub)
	button(sheet,"Mises à jour du contenu",show_updates)

func show_war_cluster(index:int):
	var selected_war:Dictionary=conflict_history[index]
	var point:Vector2=map.project(selected_war.lon,selected_war.lat)
	var near:Array=[]
	for war in conflict_history:
		if war.start<=map.war_to and int(war.end if war.end!=null else atlas_year)>=map.war_from and map.project(war.lon,war.lat).distance_to(point)<16:near.append(war)
	if near.size()<2:show_war(selected_war);return
	open_modal("Conflits à proximité","REPÈRES HISTORIQUES · LOCALISATION INDICATIVE")
	for war in near:war_button(war)

func show_war(war:Dictionary,code:String=""):
	open_modal(war.name,war.period)
	if code!="" and countries.has(code):
		heading("Pourquoi ce pays est concerné")
		var link:Dictionary=conflict_roles.get(war.id,{}).get(code,{})
		eyebrow(countries[code].name+" · "+str(link.get("role","Lien à qualifier")))
		paragraph(sheet,link.get("reason","Le rattachement de ce dossier doit encore être précisé ; il n’est pas classé comme un rôle majeur."))
		if link.get("source_url","")!="":source_button("Source du rattachement",link.source_url)
		button(sheet,"← Conflits du pays",func():show_country(code,"Conflits"))
		rule()
		heading("Histoire du conflit")
	if war.end==null:note("La date de fin n’est pas renseignée dans cette édition. Cette mention ne certifie pas qu’un conflit est encore actif aujourd’hui.")
	var a:Dictionary=articles.get(war.article,{})
	if a.get("text","")!="":
		paragraph(sheet,shorten(clean_text(a.text),6500))
		if a.text.length()>6500:button(sheet,"Lire le texte enregistré",func():show_text_reader(war.name,a,a.text))
		article_credit(a)
	else:
		note("Le résumé n’a pas pu être enregistré. Le dossier encyclopédique reste disponible à la source.")
		source_button("Lire le dossier","https://fr.wikipedia.org/wiki/"+war.wiki.uri_encode())
	note("Le point sur la carte est un repère de lecture, pas l’étendue d’un front ni la liste des batailles. Les noms de pays renvoient à des États impliqués ou à des territoires actuels concernés ; cette liste n’est pas exhaustive.")
	for involved_code in war.codes:
		if countries.has(involved_code):button(sheet,countries[involved_code].name+"  →",func():show_country(involved_code,"Conflits"))
	button(sheet,"← Les conflits de la période",show_conflict_hub)

func display_check(category:String)->String:
	var checked=monthly_sync.last_check(category)
	return "aucune enregistrée sur cet appareil" if checked=="" else checked.replace("T"," à ")

func data_caption(source:String,year,category:String)->String:
	var reference="Année de référence : "+str(int(year)) if year!=null and int(year)>0 else "Année de référence non renseignée"
	return source+"\n"+reference+"\nConsultation de la source : "+display_check(category)

func show_updates():
	open_modal("Mises à jour","LE 15 · DEPUIS VOTRE APPAREIL")
	stat("Échéance attendue",monthly_cycle_label())
	if monthly_sync.state.has("completed_at"):
		stat("Dernière échéance terminée",str(monthly_sync.state.get("completed_cycle","")),"Terminée le "+str(monthly_sync.state.completed_at).replace("T"," à "))
	else:note("Aucune actualisation mensuelle complète enregistrée sur cet appareil. La copie fournie dans l’application reste disponible.")
	note("Avant le 15 : échéance du mois précédent. À partir du 15 : mois en cours. Après une longue absence, seule la dernière échéance passée est rattrapée, à l’ouverture. Aucune intervention du créateur n’est nécessaire.")
	heading("Bilan par source")
	for row in monthly_sync.category_rows():
		var detail="Dernière consultation complète : "+("non enregistrée" if row.checked_at=="" else str(row.checked_at).replace("T"," à "))
		if row.total>0:detail+="\n"+str(row.done)+" / "+str(row.total)+" étapes acceptées pour l’échéance "+str(monthly_sync.state.get("cycle",""))
		if row.get("attempted_at","")!="":detail+="\nDernier essai : "+str(row.attempted_at).replace("T"," à ")
		if row.error!="":detail+="\n"+str(row.error)+". Données disponibles conservées."
		stat(row.name,row.status,detail)
	var retry=float(monthly_sync.state.get("retry_at",0))
	if retry>Time.get_unix_time_from_system():note("Nouvel essai automatique possible à la prochaine ouverture après "+Time.get_datetime_string_from_unix_time(int(retry)).replace("T"," ")+" UTC.")
	note("Une source consultée aujourd’hui peut publier des chiffres de 2024. La date de consultation et l’année de référence sont différentes. Une réponse acceptée ne signifie pas forcément qu’une valeur a changé.")
	stat("Conflits · observations disponibles",str(observation_info.period),"UCDP · version "+str(observation_info.version))
	history_fold("Ce qui reste embarqué", "Les sélections de personnalités, villes, sports, spécialités et dossiers historiques de conflits, les recettes et les cartes de relief/frontières sont livrées avec l’application. Les articles déjà enregistrés peuvent être actualisés, mais cela n’ajoute pas automatiquement une nouvelle personnalité ou un nouveau dossier de guerre. Une nouvelle édition est nécessaire pour enrichir ces sélections.")
	note("Les événements UCDP sont recherchés pendant l’actualisation mensuelle : ce n’est pas une surveillance en direct.")
	button(sheet,"Actualiser l’état affiché",show_updates)

func show_quality():
	open_modal("Fiabilité du contenu","SOURCES, DATES ET COHÉRENCE")
	var report=Reliability.audit(people,articles,countries)
	stat("Profils contrôlés",num(report.profiles_checked),"Contrôle automatique des années de naissance et décès")
	stat("Profils à vérifier",num(report.profiles_flagged),"Divergences potentielles : ce nombre n’est pas un nombre d’erreurs confirmées")
	note(report.scope)
	note("Les fiches concernées affichent les dates divergentes et un avertissement. L’absence d’alerte ne certifie pas une biographie. Les sources peuvent être anciennes, incomplètes ou contradictoires.")
	button(sheet,"Comprendre les mises à jour",show_updates)

func monthly_cycle_label() -> String:
	var cycle=MonthlySync.cycle_for(Time.get_date_dict_from_system()).split("-")
	var months=["janvier","février","mars","avril","mai","juin","juillet","août","septembre","octobre","novembre","décembre"]
	return "15 "+months[int(cycle[1])-1]+" "+cycle[0]

func continue_monthly():
	if is_instance_valid(boot_overlay):boot_overlay.hide()
	show_toast("Actualisation en cours. Vous pouvez explorer la carte.")

func run_monthly_startup():
	if monthly_sync.running:return
	boot_overlay=panel(self,Vector2.ZERO,Vector2(540,screen_height()),DARK,0)
	boot_overlay.name="MonthlyUpdateScreen"
	fixed_label(boot_overlay,"MÉRIDIEN V16",Vector2(32,58),Vector2(476,55),31,CREAM,true)
	var y=screen_height()*0.38
	fixed_label(boot_overlay,"Mise à jour en cours\ndes données",Vector2(32,y),Vector2(476,96),29,CREAM,true)
	fixed_label(boot_overlay,"Échéance du "+monthly_cycle_label(),Vector2(32,y+108),Vector2(476,40),15,GOLD)
	boot_bar=ProgressBar.new();boot_bar.position=Vector2(32,y+170);boot_bar.size=Vector2(476,18)
	boot_bar.show_percentage=false;boot_bar.add_theme_stylebox_override("background",box(Color("203a44"),9));boot_bar.add_theme_stylebox_override("fill",box(GOLD,9))
	boot_overlay.add_child(boot_bar)
	boot_detail=fixed_label(boot_overlay,"Préparation… 0 %",Vector2(32,y+208),Vector2(476,76),16,CREAM)
	fixed_button(boot_overlay,"Continuer avec les données disponibles",Vector2(32,screen_height()-110),Vector2(476,52),continue_monthly)
	var on_progress=func(value,detail):
		if is_instance_valid(boot_bar):boot_bar.value=value
		if is_instance_valid(boot_detail):boot_detail.text=detail+"\n"+str(int(value))+" %"
	monthly_sync.progress.connect(on_progress)
	await get_tree().process_frame
	var complete=await monthly_sync.run(self)
	monthly_sync.progress.disconnect(on_progress)
	map.countries=countries;map.cities=cities;map.events=events;map.queue_redraw()
	event_counts={}
	for ev in events:event_counts[ev.code]=event_counts.get(ev.code,0)+1
	if is_instance_valid(boot_overlay):boot_overlay.hide();boot_overlay.queue_free();boot_overlay=null
	show_toast("Consultation mensuelle terminée." if complete else "Actualisation partielle. Les données disponibles sont conservées.")


func state_name(state:String)->String:
	return {"California":"Californie","North Carolina":"Caroline du Nord","South Carolina":"Caroline du Sud","North Dakota":"Dakota du Nord","South Dakota":"Dakota du Sud","Florida":"Floride","Georgia":"Géorgie","Hawaii":"Hawaï","Louisiana":"Louisiane","New Mexico":"Nouveau-Mexique","Pennsylvania":"Pennsylvanie","Virginia":"Virginie","West Virginia":"Virginie-Occidentale","District of Columbia":"Washington · district fédéral"}.get(state,state)

func format_year(value:String)->String:
	if value=="" or value=="0":return "Non renseignée"
	if value.is_valid_int() and int(value)<0:return str(-int(value))+" av. J.-C."
	return value

func country_sports(code:String):
	eyebrow("Sport · cultures et performances")
	heading("Sports populaires et emblématiques")
	note("Touchez un sport pour découvrir ses grands résultats, ses champions et ses clubs. Jusqu’à six disciplines, sans ordre de popularité chiffré.")
	var record:Dictionary=sports.get("countries",{}).get(code,{})
	var selection:Array=record.get("selection",[])
	if selection.is_empty():
		note("La documentation sportive de ce pays ou territoire n’est pas encore suffisante dans cette édition. Aucun sport ni palmarès n’est déduit de celui d’un pays voisin.")
	for sport in selection:
		var b=button(sheet,str(sport)+"  →",func():show_sport(code,sport))
		b.alignment=HORIZONTAL_ALIGNMENT_LEFT
		b.custom_minimum_size.y=56
	if not selection.is_empty() and not SportsData.country_text(record,articles).is_empty():
		rule()
		var a:Dictionary=articles.get(record.get("article",""),{})
		button(sheet,"Lire le dossier sportif du pays",func():show_text_reader("Sport · "+str(countries[code].name),a,SportsData.country_text(record,articles)))
		article_credit(a)

func show_sport(code:String,sport:String):
	open_modal(sport,str(countries[code].name)+" · SPORT")
	button(sheet,"← Sports du pays",func():show_country(code,"Sport"))
	var record:Dictionary=sports.get("countries",{}).get(code,{})
	var a:Dictionary=articles.get(record.get("article",""),{})
	var curated:Dictionary=sports.get("curated",{}).get(code,{}).get(sport,{})
	if not curated.is_empty():
		note("Grands résultats et figures marquantes. Une sélection historique, pas un palmarès exhaustif.")
		heading("Palmarès et compétitions")
		paragraph(sheet,curated.honors)
		if not str(curated.get("figures","")).is_empty():
			heading("Champions et figures marquantes")
			paragraph(sheet,curated.figures)
		if not str(curated.get("clubs","")).is_empty():
			heading("Clubs représentatifs")
			paragraph(sheet,curated.clubs)
		rule()
		for source in curated.get("sources",[]):source_button(source.name,source.url)
		note("Ces repères éditoriaux restent ceux de cette édition. Les articles documentaires sont actualisés séparément lors de la synchronisation mensuelle.")
		return
	var passages:Array=SportsData.passages(SportsData.country_text(record,articles),sports.get("sports",{}).get(sport,[]),sport)
	note("Repères documentaires, sans prétendre à un palmarès exhaustif. Les résultats restent datés des compétitions citées ; ils ne constituent pas un classement actuel.")
	heading("Palmarès, champions et clubs")
	if passages.is_empty():
		note("Le texte actualisé ne contient plus de passage exploitable sur cette discipline. Consultez le dossier du pays ou la source.")
	else:
		for passage in passages:paragraph(sheet,clean_text(str(passage)))
		note("Seuls les titres, champions et clubs explicitement cités par la source sont repris. Les éléments non documentés ne sont pas complétés par estimation.")
	article_credit(a)
	button(sheet,"← Revenir aux sports du pays",func():show_country(code,"Sport"))
