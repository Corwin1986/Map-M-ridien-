extends SceneTree
var app
var errors=[]
func _initialize():call_deferred("run")
func check(ok:bool,msg:String):
 print(msg,": ",ok)
 if not ok:errors.append(msg);push_error(msg)
func shot(name:String):
 await process_frame;await process_frame
 if DisplayServer.get_name()!="headless":root.get_texture().get_image().save_png("/tmp/v16_"+name+".png")
func controls(node:Node,type:String)->Array:
 var found=[]
 if node.is_class(type):found.append(node)
 for child in node.get_children():found.append_array(controls(child,type))
 return found
func touch(at:Vector2,pressed:bool):
 var e=InputEventScreenTouch.new();e.position=at;e.index=0;e.pressed=pressed;Input.parse_input_event(e)
func drag(from:Vector2,to:Vector2):
 var e=InputEventScreenDrag.new();e.position=to;e.relative=to-from;e.index=0;Input.parse_input_event(e)
func swipe_card(card:Control,label_start:bool):
 app.scroll.ensure_control_visible(card);await process_frame;await process_frame
 var visible=card.get_global_rect().intersection(app.scroll.get_global_rect())
 var at=visible.get_center()
 if not label_start:at.x=visible.position.x+5
 var before=app.scroll.scroll_vertical
 touch(at,true);await process_frame
 for i in range(1,6):
  drag(at+Vector2(0,-(i-1)*16),at+Vector2(0,-i*16));await process_frame
 touch(at+Vector2(0,-80),false);await process_frame
 check(app.scroll.scroll_vertical>before+35,"Swipe starting on "+("information text" if label_start else "gray card background"))
 card.velocity=0
func run():
 app=load("res://main.tscn").instantiate();app.skip_monthly_sync=true;root.add_child(app)
 await process_frame;await process_frame
 var j=app.journey;j.store.path="user://qa16_ui.json";j.store.data.daily_closed={};j.store.data.quizzes={};j.store.data.read={};j.home_open="";app.home_card()
 await shot("home")
 var invite
 for b in controls(app.selection,"Button"):
  if b.tooltip_text=="Ouvrir le quiz du jour":invite=b
 check(invite!=null,"Home quiz invitation exists")
 check(j.store.data.quizzes.is_empty(),"Invitation does not allocate questions before opening")
 invite.pressed.emit();await process_frame;await process_frame
 check(j.screen.kind=="quiz" and is_instance_valid(app.modal),"One tap opens full normal quiz page")
 await shot("quiz")
 j.open_hub();await shot("discover")
 app.show_country("ITA","L’essentiel");await process_frame;await process_frame
 var cards=controls(app.sheet,"PanelContainer")
 check(cards.size()>=5,"Country information cards exist")
 await swipe_card(cards[0],true)
 await swipe_card(cards[1],false)
 app.scroll.ensure_control_visible(cards[1]);await process_frame;await process_frame
 var before_wheel=app.scroll.scroll_vertical
 var wheel=InputEventMouseButton.new();wheel.position=cards[1].get_global_rect().intersection(app.scroll.get_global_rect()).get_center();wheel.button_index=MOUSE_BUTTON_WHEEL_DOWN;wheel.pressed=true
 Input.parse_input_event(wheel);await process_frame
 check(app.scroll.scroll_vertical>before_wheel,"Mouse wheel over gray card")
 await shot("country")
 var country_before=app.selected
 check(country_before=="ITA" and app.active_topic=="L’essentiel","Swipe does not open another page")
 app.show_compare();await process_frame;await process_frame
 cards=controls(app.sheet,"PanelContainer")
 await swipe_card(cards[4],true)
 check(app.scroll.scroll_vertical>0,"Comparison cards support same touch gesture")
 app.show_help();await process_frame
 for b in controls(app.sheet,"Button"):check(not b.text.to_lower().contains("signal") and not b.text.contains("retour après essai"),"No reporting entry in help")
 check(not app.has_method("show_feedback") and not app.has_method("show_feedback_list"),"Reporting pages removed")
 for suffix in ["",".tmp",".bak"]:DirAccess.remove_absolute(ProjectSettings.globalize_path(j.store.path+suffix))
 print("EXPERIENCE V16: ","PASS" if errors.is_empty() else errors)
 quit(0 if errors.is_empty() else 1)
