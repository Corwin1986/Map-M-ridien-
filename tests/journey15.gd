extends SceneTree
const Store=preload("res://journey_store.gd")
var errors=[]
func _initialize():call_deferred("run")
func check(ok:bool,msg:String):
 if not ok:errors.append(msg);push_error(msg)
func fresh():
 var s=Store.new();s.path="user://qa15_state.json"
 s.discoveries=JSON.parse_string(FileAccess.get_file_as_string("res://data/discoveries.json"));s.questions=JSON.parse_string(FileAccess.get_file_as_string("res://data/quiz.json"))
 return s
func run():
 var s=fresh()
 check(s.questions.size()==300,"300 editorial questions")
 check(s.discovery_for("2026-07-14").code=="FRA","July14 France")
 check(s.discovery_for("2028-02-29").code=="MAR","Leapday event")
 check(s.discovery_for("2026-11-15").id==s.discovery_for("2030-11-15").id,"Exact calendar anniversary stable across years")
 var dates={}
 for i in 366:
  var day=Time.get_date_string_from_unix_time(1704067200+i*86400)
  var d=s.discovery_for(day)
  check(not d.is_empty(),"All leapyear dates mapped")
  dates[d.id]=true
 check(dates.size()==366,"366 unique historical events")
 var seen={};var last=[]
 for i in 100:
  var day=Time.get_date_string_from_unix_time(1794700800+i*86400)
  var ids=s.quiz(day).ids.duplicate()
  check(ids.size()==3,"Three questions per new day")
  check(s.quiz(day).ids==ids,"Same day stable")
  for id in ids:check(not seen.has(id),"No repeats before complete catalogue");seen[id]=true
  last=ids
 check(seen.size()==300,"All 300 passed before repeat")
 var next=s.quiz("2030-11-15").ids
 for id in next:check(id not in last,"No adjacent cycle repeat")
 var remaining=s.data.quiz_queue.size();s.quiz("2030-11-15")
 check(s.data.quiz_queue.size()==remaining,"Relaunch does not consume queue")
 s.quiz("2031-06-12")
 check(s.data.quiz_queue.size()==remaining-3,"Absence consumes only next played daily set")
 var day="2031-06-12";var ids=s.quiz(day).ids
 for id in ids:s.answer(day,int(s.question(id).correct));s.advance(day)
 s.practice(day);s.answer(day,(int(s.question(ids[0]).correct)+1)%4)
 s.dismiss_daily("quiz",day);s.dismiss_daily("discovery",day)
 var re=fresh();re.load_state()
 check(re.quiz(day).attempts[0].score==3,"First score preserved across practice and restart")
 check(re.attempt(day).answers.size()==1 and not re.attempt(day).answers[0].reviewed,"Question explanation resumes after restart")
 check(not re.daily_visible("quiz",day) and re.daily_visible("quiz","2031-06-13"),"Daily closure persists and resets next day")
 var legacy=fresh();legacy.data.quizzes={"2026-11-14":{"ids":["q001","q002","q003","q004","q005"],"attempts":[{"answers":[],"score":4,"complete":true}]}}
 legacy.data.saved=["d:d01","q:q001"];var migrated=legacy.quiz("2026-11-15")
 for id in migrated.ids:check(id not in ["q001","q002","q003","q004","q005"],"Migration skips previous seen questions")
 check(legacy.quiz("2026-11-14").ids.size()==5 and legacy.data.saved==["d:d01","q:q001"],"Old five-question scores and saved content retained")
 check(not legacy.discovery("d01").is_empty(),"Legacy discovery remains readable")
 var catalog=s.discoveries;s.discoveries=[];check(s.discovery_for(day).is_empty(),"No event means no suggestion");s.discoveries=catalog
 for suffix in ["",".tmp",".bak"]:DirAccess.remove_absolute(ProjectSettings.globalize_path(s.path+suffix))
 print("JOURNEY V15: ","PASS" if errors.is_empty() else errors);quit(0 if errors.is_empty() else 1)
