extends RefCounted
var app
var store
var bridge
var screen:Dictionary={}
var back_stack:Array=[]
var country_origin:Dictionary={}
var reading:Dictionary={}
var date=""
var home_open=""
var last_poll=0.0
var save_warning=false
func _init(owner):
 app=owner;store=preload("res://journey_store.gd").new();store.load_state()
 store.discoveries=app.read_json("res://data/discoveries.json");store.questions=app.read_json("res://data/quiz.json");store.routes=app.read_json("res://data/journeys.json")
 bridge=preload("res://notification_bridge.gd").new();date=store.today()
 var catalog=[]
 for d in store.discoveries:
  if d.has("date"):catalog.append({"id":d.id,"title":d.title,"date":d.date})
 bridge.update_catalog(catalog)
 for code in app.visited:store.data.opened[code]=true
func capture(keep_tracking:bool=false):
 if reading.is_empty() or not is_instance_valid(app.scroll):return
 reading.scroll=app.scroll.scroll_vertical
 var expanded=[]
 for i in app.sheet.get_child_count():
  var c=app.sheet.get_child(i)
  if c is VBoxContainer and c.get_child_count()>1 and c.get_child(0) is Button and c.get_child(0).toggle_mode and c.get_child(0).button_pressed:expanded.append(i)
 reading.expanded=expanded;store.data.last_read=reading.duplicate(true);store.save()
 if not keep_tracking:reading={}
func track(value:Dictionary):
 reading=value.duplicate(true);store.data.last_read=reading.duplicate(true);store.save()
func poll():
 if Time.get_ticks_msec()-last_poll<1500:return
 last_poll=Time.get_ticks_msec()
 if not store.last_save_ok and not save_warning:
  app.show_toast("Stockage indisponible : la progression ne peut pas être sauvegardée.");save_warning=true
 elif store.last_save_ok:save_warning=false
 var now=store.today()
 if now!=date:
  date=now;home_open="";app.home_card()
  # A quiz already started stays on its own date; today's hub changes immediately.
  if screen.get("kind")=="hub":rerender()
 bridge.refresh()
 var link=bridge.take_link()
 if link!="" and not store.discovery(link).is_empty():navigate({"kind":"discovery","id":link},true)
func open_hub():
 country_origin={};navigate({"kind":"hub"},true)
func navigate(dest:Dictionary,fresh:bool=false):
 if is_instance_valid(app.scroll):screen.scroll=app.scroll.scroll_vertical
 capture()
 if fresh:back_stack=[]
 elif not screen.is_empty():back_stack.append(screen.duplicate(true))
 render(dest)
func rerender():
 var target=screen.duplicate(true)
 if is_instance_valid(app.scroll):target.scroll=app.scroll.scroll_vertical
 render(target)
func render(dest:Dictionary):
 screen=dest.duplicate(true);country_origin={}
 match dest.kind:
  "hub":hub()
  "discovery":show_discovery(dest.id)
  "quiz":show_quiz(dest.get("date",date))
  "routes":show_routes()
  "route":show_route(dest.id,int(dest.get("step",-1)))
  "saved_question":show_saved_question(dest.id)
  "notifications":notification_settings()
  "carnet":carnet()
  "progress":progress_map()
  "person":
   for p in app.people:
    if p.qid==dest.id and p.code==dest.code:app.show_person(p);break
  "city":
   for c in app.cities:
    if str(c.id)==str(dest.id):app.show_city(c);break
  "recipe":app.show_recipe(dest.code,dest.id)
 if dest.has("scroll"):restore_position.call_deferred(int(dest.scroll),dest.get("expanded",[]))
func back():
 capture()
 if not country_origin.is_empty():
  var target=country_origin.duplicate(true);country_origin={};render(target);return
 if not back_stack.is_empty():render(back_stack.pop_back());return
 screen={};app.close_modal()
func modal(title:String,subtitle:String=""):
 app.open_modal(title,subtitle)
 button(app.sheet,"← Retour",back)
func save_button(key:String):
 button(app.sheet,"Retirer du carnet" if key in store.data.saved else "Enregistrer dans mon carnet",func():store.toggle_saved(key);rerender())
func sources(rows:Array):
 app.eyebrow("Sources · consultées pour cette édition")
 for s in rows:app.source_button(str(s.title),str(s.url))
func country(code:String,topic:String):
 if is_instance_valid(app.scroll):screen.scroll=app.scroll.scroll_vertical
 capture();country_origin=screen.duplicate(true);app.show_country(code,topic)
func attach_country(code:String,topic:String):
 store.data.opened[code]=true
 track({"kind":"country","code":code,"topic":topic,"scroll":0})
 if not country_origin.is_empty():
  app.scroll.size.y-=48
  app.fixed_button(app.modal,"← Revenir au "+("parcours" if country_origin.kind=="route" else "contenu de découverte"),Vector2(20,app.modal.size.y-53),Vector2(476,44),back,true)
func hub():
 modal("Découvrir","À VOTRE RYTHME · HORS CONNEXION")
 var d=store.discovery_for(date)
 app.heading("Ce jour-là, quelque part dans le monde")
 if not d.is_empty():button(app.sheet,d.title,func():navigate({"kind":"discovery","id":d.id}))
 else:app.note("Aucun événement vérifié pour cette date.")
 app.note("Une date, un pays, une histoire à découvrir aujourd’hui.")
 app.heading("Trois questions pour voyager")
 app.note("Histoire, cultures et horizons lointains : laissez-vous surprendre par le quiz du jour.")
 var q=store.data.quizzes.get(date,{});var run=q.get("attempts",[{"complete":false,"answers":[]}])[-1]
 button(app.sheet,("Voir mon résultat" if run.complete else "Reprendre" if not run.answers.is_empty() else "Faire le quiz du jour")+" · "+str(q.get("ids",[0,1,2]).size())+" questions",func():navigate({"kind":"quiz","date":date}))
 button(app.sheet,"Parcours · quelques étapes pour comprendre",func():navigate({"kind":"routes"}))
 button(app.sheet,"Mon carnet de découvertes",func():navigate({"kind":"carnet"}))
 if store.data.engaged:button(app.sheet,"Mes rappels facultatifs",func():navigate({"kind":"notifications"}))
 app.note("Ces contenus sont embarqués et enrichis avec les nouvelles versions. La consultation mensuelle des sources est indépendante.")
func show_discovery(id:String):
 var d=store.discovery(id)
 if d.is_empty():hub();return
 modal("Découverte",str(app.countries[d.code].name)+" · "+d.theme)
 app.heading(d.title)
 app.paragraph(app.sheet,d.body)
 if d.topic=="Géographie":
  var maps=app.relief_maps.get("countries",{}).get(d.code,{}).get("maps",[])
  if not maps.is_empty():
   app.relief_image(maps[0]);app.note("Repère géographique : carte de relief du pays.")
   app.relief_legend();app.source_button("Carte · GEBCO / GMT et licence",app.relief_maps.meta.license_url)
 sources(d.sources)
 button(app.sheet,"Ouvrir "+app.countries[d.code].name+" · "+d.topic,func():country(d.code,d.topic))
 save_button("d:"+id)
 button(app.sheet,"✓ Déjà lue" if store.data.read.has(id) else "J’ai lu cette découverte",func():store.mark_read(d);app.home_card();rerender(),true,true)
 if store.data.read.has(id):app.note("Ce pays compte désormais parmi vos pays explorés. Aucun point n’est perdu si vous faites une pause.")
 if store.data.engaged:button(app.sheet,"Choisir un rappel de découverte",func():navigate({"kind":"notifications"}))
 track({"kind":"discovery","id":id,"scroll":0})
func show_quiz(day:String):
 var record=store.quiz(day);var run=record.attempts[-1]
 modal("Quiz du jour",day+" · "+("PREMIÈRE TENTATIVE" if record.attempts.size()==1 else "ENTRAÎNEMENT"))
 if run.complete:
  app.heading(str(run.score)+" / "+str(record.ids.size()))
  app.note("Premier résultat : "+str(record.attempts[0].score)+" / "+str(record.ids.size())+". Les entraînements sont conservés séparément. Aucun score n’est perdu après une absence.")
  for id in record.ids:
   var q=store.question(id)
   button(app.sheet,q.question,func():navigate({"kind":"saved_question","id":id}))
  button(app.sheet,"Nouvelle tentative · entraînement",func():store.practice(day);rerender())
  button(app.sheet,"Choisir un rappel facultatif",func():navigate({"kind":"notifications"}))
  return
 var review=not run.answers.is_empty() and not run.answers[-1].reviewed
 var index=run.answers.size()-1 if review else run.answers.size()
 var q=store.question(record.ids[index])
 app.eyebrow(str(index+1)+" / "+str(record.ids.size())+" · "+q.theme)
 app.heading(q.question)
 if review:
  var ans=run.answers[-1]
  app.stat("Votre réponse",q.options[int(ans.choice)],"Correct" if ans.correct else "Réponse correcte : "+str(q.options[int(q.correct)]))
  app.paragraph(app.sheet,q.explanation)
  sources(q.sources)
  button(app.sheet,"Ouvrir la fiche · "+app.countries[q.code].name,func():country(q.code,q.topic))
  save_button("q:"+q.id)
  button(app.sheet,"Voir le résultat" if index==record.ids.size()-1 else "Question suivante",func():store.advance(day);app.home_card();screen.erase("scroll");render(screen),true,true)
 else:
  var choice={"value":-1};var buttons=[]
  var validate=button(app.sheet,"Valider ma réponse",func():
   if choice.value>=0:store.answer(day,choice.value);screen.erase("scroll");render(screen),true,true)
  validate.disabled=true
  for original in store.options_for(q,day):
   var b=button(app.sheet,q.options[original],func():
    choice.value=original
    for other in buttons:other.button_pressed=false
    buttons[store.options_for(q,day).find(original)].button_pressed=true
    validate.disabled=false)
   b.toggle_mode=true;buttons.append(b)
  app.sheet.move_child(validate,app.sheet.get_child_count()-1)
func show_saved_question(id:String):
 var q=store.question(id)
 if q.is_empty():hub();return
 modal("Une réponse à découvrir",q.theme)
 app.heading(q.question);app.paragraph(app.sheet,q.options[int(q.correct)],22);app.paragraph(app.sheet,q.explanation)
 sources(q.sources);save_button("q:"+id)
 button(app.sheet,"Ouvrir la fiche · "+app.countries[q.code].name,func():country(q.code,q.topic))
func show_routes():
 modal("Parcours","3 À 5 ÉTAPES · REPRISE LIBRE")
 for r in store.routes:
  var p=store.data.routes.get(r.id,{})
  button(app.sheet,r.title+" · "+r.duration,func():navigate({"kind":"route","id":r.id}))
  app.note(str(p.get("done",[]).size())+" / "+str(r.steps.size())+" étapes terminées")
func show_route(id:String,step:int=-1):
 var r=store.route(id)
 if r.is_empty():show_routes();return
 var p=store.route_progress(id)
 if step<0:step=int(p.current)
 step=clampi(step,0,r.steps.size()-1);p.current=step;store.save();screen.step=step
 modal("Parcours",r.duration+" · "+str(p.done.size())+" / "+str(r.steps.size()))
 app.heading(r.title);app.note(r.intro)
 if p.has("completed"):app.note("Parcours terminé. Vous pouvez le relire à votre rythme.")
 var s=r.steps[step]
 app.heading(str(step+1)+". "+s.title);app.paragraph(app.sheet,s.body)
 sources(s.get("sources",[]))
 if s.has("discovery_id"):button(app.sheet,"Lire la découverte de cette étape",func():navigate({"kind":"discovery","id":s.discovery_id}))
 button(app.sheet,"Lire la fiche · "+app.countries[s.code].name+" · "+s.topic,func():country(s.code,s.topic))
 button(app.sheet,"✓ Étape terminée" if step in p.done else "Étape terminée",func():store.complete_step(id,step);render({"kind":"route","id":id,"step":int(p.current)}),true,true)
 app.heading("Toutes les étapes")
 for i in r.steps.size():button(app.sheet,("✓ " if i in p.done else "")+str(i+1)+". "+r.steps[i].title,func():render({"kind":"route","id":id,"step":i}))
 track({"kind":"route","id":id,"step":step,"scroll":0})
func carnet():
 modal("Mon carnet","SUR CET APPAREIL · SANS COMPTE")
 if not store.data.last_read.is_empty():button(app.sheet,"Reprendre ma dernière lecture",resume)
 app.stat("Pays ouverts",str(store.data.opened.size()),"Fiches ouvertes, avec les pays sélectionnés dans les anciennes versions. Cela ne signifie pas que le pays est connu.")
 app.stat("Pays explorés",str(store.data.explored.size()),"Une découverte marquée comme lue ou une étape terminée.")
 button(app.sheet,"Voir ma carte de progression",func():navigate({"kind":"progress"}))
 app.heading("Mes pays favoris")
 if app.bookmarks.is_empty():app.note("Vos favoris apparaîtront ici. Les favoris des versions précédentes sont conservés.")
 for code in app.bookmarks:
  if app.countries.has(code):button(app.sheet,app.countries[code].name,func():country(code,"L’essentiel"))
 app.heading("Découvertes sauvegardées")
 for key in store.data.saved:
  var id=str(key).get_slice(":",1);var d=store.discovery(id) if key.begins_with("d:") else store.question(id)
  if not d.is_empty():button(app.sheet,d.get("title",d.get("question","")),func():navigate({"kind":"discovery" if key.begins_with("d:") else "saved_question","id":id}))
 app.heading("Mes parcours")
 for id in store.data.routes:
  var r=store.route(id);var p=store.data.routes[id]
  if not r.is_empty():button(app.sheet,r.title+" · "+str(p.done.size())+" / "+str(r.steps.size()),func():navigate({"kind":"route","id":id}))
 app.heading("Mes quiz")
 var days=store.data.quizzes.keys();days.sort();days.reverse()
 for day in days:
  var q=store.data.quizzes[day];var first=q.attempts[0]
  if first.answers.is_empty():continue
  button(app.sheet,str(day)+" · "+(str(first.score)+" / "+str(q.ids.size()) if first.complete else "À reprendre"),func():navigate({"kind":"quiz","date":day}))
  if q.attempts.size()>1:
   var scores=[]
   for attempt in q.attempts.slice(1):scores.append(str(attempt.score)+" / "+str(q.ids.size()) if attempt.complete else "en cours")
   app.note("Entraînements : "+", ".join(scores))
 app.heading("Pays explorés")
 for code in store.data.explored:
  if app.countries.has(code):button(app.sheet,app.countries[code].name,func():country(code,"L’essentiel"))
func resume():
 var dest=store.data.last_read.duplicate(true)
 if dest.is_empty():return
 var position=int(dest.get("scroll",0));var folds=dest.get("expanded",[])
 if dest.kind=="country":country(dest.code,dest.topic)
 else:navigate(dest)
 restore_position.call_deferred(position,folds)
func restore_position(position:int,folds:Array):
 await app.get_tree().process_frame
 for i in folds:
  if int(i)<app.sheet.get_child_count():
   var c=app.sheet.get_child(int(i))
   if c is VBoxContainer and c.get_child_count()>1 and c.get_child(0) is Button:c.get_child(0).button_pressed=true
 await app.get_tree().process_frame
 if is_instance_valid(app.scroll):app.scroll.scroll_vertical=position
func progress_map():
 modal("Mon monde découvert","OUVERT ≠ EXPLORÉ")
 var mini=preload("res://progress_map.gd").new();mini.custom_minimum_size=Vector2(0,245);mini.polygons=app.read_json("res://data/polygons.json");mini.opened=store.data.opened;mini.explored=store.data.explored;app.sheet.add_child(mini)
 app.note("Bleu clair : fiche ouverte. Or : découverte lue ou étape terminée. Gris : pas encore ouvert. Chaque découverte compte, sans objectif obligatoire.")
 for code in store.data.opened:
  if app.countries.has(code):button(app.sheet,("✓ " if store.data.explored.has(code) else "○ ")+app.countries[code].name,func():country(code,"L’essentiel"))
func notification_settings():
 modal("Rappels facultatifs","VOTRE RYTHME, VOTRE CHOIX")
 if not bridge.available():app.note("Les rappels locaux Android sont disponibles dans l’APK. Cette version web ne programme pas de notifications en arrière-plan. La découverte et le quiz changent à la date locale quand vous ouvrez l’application.");return
 app.note("Un sujet concret à découvrir. Aucun rattrapage des rappels manqués. Android peut retarder l’heure selon la batterie ou vos réglages. Après un arrêt forcé, rouvrez l’application pour réactiver la programmation.")
 app.stat("État Android",bridge.status())
 var prefs=store.data.notifications
 var freq=OptionButton.new();freq.custom_minimum_size.y=48
 for item in ["Aucune notification","Chaque jour","Chaque lundi"]:freq.add_item(item)
 freq.selected=["none","daily","weekly"].find(prefs.frequency);app.sheet.add_child(freq)
 app.label(app.sheet,"Heure locale souhaitée")
 var hour=SpinBox.new();hour.min_value=0;hour.max_value=23;hour.value=prefs.hour;hour.custom_minimum_size.y=48;hour.suffix="h";app.sheet.add_child(hour)
 var minute=SpinBox.new();minute.min_value=0;minute.max_value=59;minute.value=prefs.minute;minute.custom_minimum_size.y=48;minute.suffix="min";app.sheet.add_child(minute)
 button(app.sheet,"Enregistrer ce choix",func():
  var mode=["none","daily","weekly"][freq.selected];var compact=[]
  for d in store.discoveries:
   if d.has("date"):compact.append({"id":d.id,"title":d.title,"date":d.date})
  if bridge.configure(mode,int(hour.value),int(minute.value),compact):
   store.data.notifications={"frequency":mode,"hour":int(hour.value),"minute":int(minute.value)};store.save();app.show_toast("Choix enregistré. Autorisez les notifications dans Android si vous le souhaitez.")
  else:app.show_toast("Impossible d’enregistrer ce choix.")
 )
 button(app.sheet,"Réglages de notification Android",func():bridge.settings())
 button(app.sheet,"Actualiser l’état de l’autorisation",func():bridge.refresh();rerender())

func button(parent:Node,text:String,callback:Callable,light:bool=true,chosen:bool=false)->Button:
 var b=app.button(parent,text,callback,light,chosen)
 b.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;b.clip_text=true
 return b

# Compact, independent daily accordions. Their content never captures map gestures
# outside the cards; closing is remembered for this local date only.
func home_banners(parent:Control):
 var y=14.0
 for kind in ["discovery","quiz"]:
  if not store.daily_visible(kind,date):continue
  if kind=="quiz":
   var card=app.panel(parent,Vector2(16,y),Vector2(448,106),app.DARK,12)
   var invite=app.fixed_button(card,"",Vector2(8,6),Vector2(380,94),func():navigate({"kind":"quiz","date":date},true))
   invite.tooltip_text="Ouvrir le quiz du jour"
   var title=app.fixed_label(invite,"Quiz du jour",Vector2(12,7),Vector2(350,30),21,app.CREAM,true)
   title.mouse_filter=Control.MOUSE_FILTER_IGNORE
   var phrase=app.fixed_label(invite,"Trois questions pour faire le tour du monde. À vous de jouer !",Vector2(12,40),Vector2(350,44),14,Color("dce5e3"))
   phrase.mouse_filter=Control.MOUSE_FILTER_IGNORE
   app.fixed_button(card,"x",Vector2(396,6),Vector2(44,44),func():store.dismiss_daily("quiz",date);app.home_card()).tooltip_text="Masquer pour aujourd’hui"
   y+=114;continue
  var expanded=home_open==kind
  var height=380.0 if expanded else 54.0
  var card=app.panel(parent,Vector2(16,y),Vector2(448,height),app.CREAM if expanded else app.DARK,12)
  var title="Suggestion du jour" if kind=="discovery" else "Quiz du jour"
  var toggle=app.fixed_button(card,title+("  -" if expanded else "  +"),Vector2(8,5),Vector2(380,44),func():home_open="" if home_open==kind else kind;app.home_card(),expanded)
  toggle.add_theme_font_size_override("font_size",15)
  var close=app.fixed_button(card,"x",Vector2(396,5),Vector2(44,44),func():store.dismiss_daily(kind,date);home_open="";app.home_card(),expanded)
  close.tooltip_text="Masquer pour aujourd’hui"
  if expanded:
   var sc=ScrollContainer.new();sc.position=Vector2(14,58);sc.size=Vector2(420,height-72);sc.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED;card.add_child(sc)
   var box=VBoxContainer.new();box.size_flags_horizontal=Control.SIZE_EXPAND_FILL;box.add_theme_constant_override("separation",10);sc.add_child(box)
   home_discovery(box)
  y+=height+8
func home_sources(box:VBoxContainer,rows:Array):
 for source in rows:
  button(box,"Source : "+source.title,func():OS.shell_open(source.url))
func home_discovery(box:VBoxContainer):
 var d=store.discovery_for(date)
 if d.is_empty():return
 app.label(box,d.title,22,app.INK,true)
 app.label(box,date_label(date)+" · "+app.countries[d.code].name,13,app.MUTED)
 app.paragraph(box,d.body,16)
 home_sources(box,d.sources)
 button(box,"Ouvrir la fiche du pays",func():navigate({"kind":"discovery","id":d.id},true);country(d.code,d.topic))
 button(box,"Retirer du carnet" if "d:"+d.id in store.data.saved else "Enregistrer dans le carnet",func():store.toggle_saved("d:"+d.id);app.home_card())
 button(box,"J’ai lu cette suggestion",func():store.mark_read(d);home_open="";app.home_card(),true,true)
func date_label(value:String)->String:
 var parts=value.split("-")
 var months=["janvier","février","mars","avril","mai","juin","juillet","août","septembre","octobre","novembre","décembre"]
 return str(int(parts[2]))+" "+months[int(parts[1])-1]+" "+parts[0]
