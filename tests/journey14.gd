extends SceneTree
const Store=preload("res://journey_store.gd")
var errors=[]
func _initialize():call_deferred("run")
func check(ok:bool,text:String):
 if not ok:errors.append(text);push_error(text)
func run():
 var s=Store.new();s.path="user://qa14_journey.json"
 for suffix in ["",".tmp",".bak"]:DirAccess.remove_absolute(ProjectSettings.globalize_path(s.path+suffix))
 s.discoveries=JSON.parse_string(FileAccess.get_file_as_string("res://data/discoveries.json"));s.questions=JSON.parse_string(FileAccess.get_file_as_string("res://data/quiz.json"));s.routes=JSON.parse_string(FileAccess.get_file_as_string("res://data/journeys.json"))
 check(s.discoveries.size()>=60,"60 discoveries");check(s.questions.size()>=150,"150 questions");check(s.routes.size()>=6,"6 routes")
 if s.discoveries.size()<60:quit(1);return
 check(s.discovery_for("2026-11-15").id==s.discovery_for("2026-11-15").id,"Daily stable")
 check(s.discovery_for("2026-11-15").id!=s.discovery_for("2026-11-16").id,"Day changes")
 var unique={};var q_seen={}
 for i in 60:
  var date=Time.get_date_string_from_unix_time(1794700800+i*86400)
  unique[s.discovery_for(date).id]=true
  var ids=s.daily_questions(date)
  check(ids.size()==5,"Five daily questions")
  if i<30:
   for id in ids:check(not q_seen.has(id),"No question repeated within 30 days");q_seen[id]=true
 check(unique.size()==60,"Discovery cycle without close repeat")
 var date="2026-11-15";var ids=s.daily_questions(date)
 for i in 5:s.answer(date,int(s.question(ids[i]).correct));s.advance(date)
 check(s.quiz(date).attempts[0].score==5 and s.quiz(date).attempts[0].complete,"First result stored")
 s.practice(date);s.answer(date,(int(s.question(ids[0]).correct)+1)%4)
 var re=Store.new();re.path=s.path;re.questions=s.questions;re.routes=s.routes;re.discoveries=s.discoveries;re.load_state()
 check(re.quiz(date).attempts.size()==2 and re.quiz(date).attempts[0].score==5,"First score protected from practice")
 check(re.attempt(date).answers.size()==1 and not re.attempt(date).answers[0].reviewed,"Answered explanation resumes")
 re.mark_read(s.discoveries[0]);check(re.data.explored.has(s.discoveries[0].code),"Reading validates exploration")
 re.data.opened["FRA"]=true;check(not re.data.explored.has("FRA") or s.discoveries[0].code=="FRA","Open does not imply explored")
 re.complete_step(s.routes[0].id,0);re.toggle_saved("d:"+s.discoveries[0].id)
 re.data.last_read={"kind":"country","code":"FRA","topic":"Histoire","scroll":500,"expanded":[2]};re.save()
 var again=Store.new();again.path=s.path;again.load_state()
 check(again.data.last_read.scroll==500 and again.data.routes[s.routes[0].id].done.size()==1,"Reading and route persisted")
 var f=FileAccess.open(s.path,FileAccess.WRITE);f.store_string("broken");f.close();again.load_state();check(again.data.schema==1,"Backup recovery")
 for suffix in ["",".tmp",".bak"]:DirAccess.remove_absolute(ProjectSettings.globalize_path(s.path+suffix))
 print("JOURNEY V14: ","PASS" if errors.is_empty() else errors);quit(0 if errors.is_empty() else 1)
