extends SceneTree
var app
var failures=[]
func _initialize():call_deferred("run")
func check(ok:bool,msg:String):
 print(msg,": ",ok)
 if not ok:failures.append(msg)
func touch(at:Vector2,pressed:bool):
 var e=InputEventScreenTouch.new();e.index=0;e.position=at;e.pressed=pressed;Input.parse_input_event(e)
 await process_frame
func swipe(a:Vector2,b:Vector2):
 await touch(a,true)
 var last=a
 for i in range(1,9):
  var e=InputEventScreenDrag.new();e.index=0;e.position=a.lerp(b,i/8.0);e.relative=e.position-last;last=e.position
  Input.parse_input_event(e);await process_frame
 await touch(b,false)
 await process_frame
func strip():return app.modal.get_node("TopicStrip")
func run():
 app=load("res://main.tscn").instantiate();app.skip_monthly_sync=true;root.add_child(app)
 await process_frame;await process_frame
 app.show_country("SAU");await process_frame;await process_frame
 check(app.modal.has_node("TopicStrip") and not app.modal.has_node("ChooseTopic"),"Horizontal strip replaces list selector")
 for n in range(10):
  var s=strip();s.velocity=0
  await swipe(Vector2(470,245),Vector2(100,245))
  s=strip();s.velocity=0
  check(s.offset>300,"Swipe after selection "+str(n))
  var target=-1
  for i in s.pills.size():
   var r=s.pills[i];var x=r.get_center().x-s.offset
   if x>30 and x<440 and s.topics[i]!=app.active_topic:target=i;break
  if target>=0:
   var expected=s.topics[target];var saved=s.offset
   var point=s.global_position+s.pills[target].get_center()-Vector2(s.offset,0)
   await touch(point,true);await touch(point,false);await process_frame
   check(app.active_topic==expected,"Tap opens topic "+str(n))
   check(abs(strip().offset-saved)<1,"Offset retained "+str(n))
  await swipe(Vector2(100,245),Vector2(470,245))
  strip().velocity=0;strip().offset=0;strip().queue_redraw()
 # Reach both ends without hidden or inaccessible final tabs.
 for n in range(6):await swipe(Vector2(475,245),Vector2(55,245))
 strip().velocity=0
 check(abs(strip().offset-strip().maximum())<1,"Last tab reachable")
 var last=strip().pills[-1].get_center()+strip().global_position-Vector2(strip().offset,0)
 await touch(last,true);await touch(last,false);await process_frame
 check(app.active_topic=="Sources","Final Sources tab opens")
 for n in range(6):await swipe(Vector2(55,245),Vector2(475,245))
 strip().velocity=0
 check(strip().offset==0,"Return to first tab after selection")
 # A drag beginning on the active tab must never select another topic.
 app.show_country("DZA","Histoire");await process_frame;await process_frame
 await swipe(Vector2(205,245),Vector2(40,245))
 check(app.active_topic=="Histoire" and strip().offset>80,"Selected tab draggable without accidental activation")
 strip().velocity=0
 # Article pan leaves tabs stationary and does not select text.
 for c in app.sheet.get_children():
  if c is VBoxContainer and c.get_child_count()>1 and c.get_child(0) is Button:
   c.get_child(0).button_pressed=true;break
 await process_frame;await process_frame
 var saved=strip().offset
 await swipe(Vector2(230,650),Vector2(230,420))
 check(app.scroll.scroll_vertical>80,"Article scrolls vertically")
 check(abs(strip().offset-saved)<1,"Article gesture leaves strip fixed")
 var selected_text=false
 for c in app.sheet.get_children():
  if c is RichTextLabel and c.get_selected_text()!="":selected_text=true
 check(not selected_text,"Pan does not select text")
 app.show_country("FRA");await process_frame;await process_frame
 check(strip().offset==0,"Different country starts at first tab")
 root.get_texture().get_image().save_png(OS.get_user_data_dir()+"/qa4_tabs.png")
 print("TABS V17: ","PASS" if failures.is_empty() else failures)
 quit(0 if failures.is_empty() else 1)
