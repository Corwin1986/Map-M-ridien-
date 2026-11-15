extends RefCounted
const THEMES=["Géographie","Histoire","Culture","Gastronomie","Personnalités"]
var path="user://journey_v1.json"
var data:Dictionary={}
var discoveries:Array=[]
var questions:Array=[]
var routes:Array=[]
var last_save_ok=true
func _init():
 data={"schema":1,"opened":{},"explored":{},"read":{},"saved":[],"quizzes":{},"routes":{},"last_read":{},"dismissed":"","notifications":{"frequency":"none","hour":18,"minute":0},"engaged":false,"daily_closed":{},"quiz_queue":[],"quiz_cycle":0,"queue_initialized":false}
func load_state():
 for suffix in ["",".bak"]:
  if not FileAccess.file_exists(path+suffix):continue
  var value=JSON.parse_string(FileAccess.get_file_as_string(path+suffix))
  if value is Dictionary and value.get("schema")==1:
   data.merge(value,true);return
func save()->bool:
 var f=FileAccess.open(path+".tmp",FileAccess.WRITE)
 if f==null:last_save_ok=false;return false
 f.store_string(JSON.stringify(data));f.close()
 var value=JSON.parse_string(FileAccess.get_file_as_string(path+".tmp"))
 if not value is Dictionary:last_save_ok=false;return false
 if FileAccess.file_exists(path):
  var old=JSON.parse_string(FileAccess.get_file_as_string(path))
  if old is Dictionary:DirAccess.copy_absolute(ProjectSettings.globalize_path(path),ProjectSettings.globalize_path(path+".bak"))
 last_save_ok=DirAccess.rename_absolute(ProjectSettings.globalize_path(path+".tmp"),ProjectSettings.globalize_path(path))==OK
 return last_save_ok
static func today()->String:return Time.get_date_string_from_system(false)
static func day_number(date:String)->int:return int(Time.get_unix_time_from_datetime_string(date+"T00:00:00")/86400)
static func permutation(n:int,seed_value:int)->Array:
 var out=range(n);var seed_n=seed_value
 for i in range(n-1,0,-1):
  seed_n=(seed_n*48271)%2147483647
  var j=seed_n%(i+1);var temp=out[i];out[i]=out[j];out[j]=temp
 return out
func discovery_for(date:String)->Dictionary:
 for d in discoveries:
  if d.get("date","")==date.substr(5,5):return d
 return {}
func daily_visible(kind:String,date:String)->bool:
 if data.daily_closed.get(kind,"")==date:return false
 if kind=="discovery":
  var d=discovery_for(date)
  return not d.is_empty() and data.read.get(d.id,"")!=date
 var record=data.quizzes.get(date,{})
 return record.is_empty() or not record.attempts[0].complete
func dismiss_daily(kind:String,date:String):
 data.daily_closed[kind]=date;save()
func discovery(id:String)->Dictionary:
 for d in discoveries:
  if d.id==id:return d
 return {}
func question(id:String)->Dictionary:
 for q in questions:
  if q.id==id:return q
 return {}
func daily_questions(date:String)->Array:
 if data.quizzes.has(date):return data.quizzes[date].ids
 if not data.queue_initialized:
  var seen=[]
  for record in data.quizzes.values():
   for id in record.ids:
    if id not in seen:seen.append(id)
  refill_queue(seen)
  data.queue_initialized=true
 var ids=[]
 for i in mini(3,questions.size()):
  if data.quiz_queue.is_empty():refill_queue(data.get("quiz_recent",[])+ids)
  ids.append(data.quiz_queue.pop_front())
 data.quiz_recent=ids.duplicate()
 return ids
func refill_queue(avoid:Array=[]):
 data.quiz_cycle+=1
 var pools=[]
 for t in THEMES.size():
  var pool=[]
  for q in questions:
   if q.theme==THEMES[t]:pool.append(q.id)
  var shuffled=[]
  for index in permutation(pool.size(),1515+int(data.quiz_cycle)*7919+t*113):shuffled.append(pool[index])
  pools.append(shuffled)
 var order=[]
 var remaining=true
 while remaining:
  remaining=false
  for pool in pools:
   if not pool.is_empty():order.append(pool.pop_front());remaining=true
 # At migration, previously seen questions move to the next complete cycle.
 # At a boundary, postpone recent IDs rather than repeating them immediately.
 var delayed=[]
 for id in order:
  if id in avoid:delayed.append(id)
  else:data.quiz_queue.append(id)
 if data.queue_initialized:data.quiz_queue.append_array(delayed)
 if data.quiz_queue.is_empty():data.quiz_queue=order
func options_for(q:Dictionary,date:String)->Array:return permutation(4,714+int(q.id.trim_prefix("q"))*31+posmod(day_number(date),100000))
func quiz(date:String)->Dictionary:
 if not data.quizzes.has(date):
  data.quizzes[date]={"ids":daily_questions(date),"attempts":[{"answers":[],"score":0,"complete":false}]};save()
 return data.quizzes[date]
func attempt(date:String)->Dictionary:return quiz(date).attempts[-1]
func answer(date:String,choice:int)->bool:
 var record=quiz(date);var run=record.attempts[-1]
 if run.complete or run.answers.size()>=record.ids.size():return false
 var q=question(record.ids[run.answers.size()]);var correct=choice==int(q.correct)
 run.answers.append({"choice":choice,"correct":correct,"reviewed":false})
 if correct:run.score+=1
 data.engaged=true;return save()
func advance(date:String):
 var run=attempt(date)
 if run.answers.is_empty():return
 run.answers[-1].reviewed=true
 if run.answers.size()==quiz(date).ids.size():run.complete=true
 save()
func practice(date:String):
 var record=quiz(date)
 if record.attempts[-1].complete:record.attempts.append({"answers":[],"score":0,"complete":false});save()
func mark_read(d:Dictionary):
 data.read[d.id]=today();data.explored[d.code]=true;data.engaged=true;save()
func toggle_saved(key:String):
 if key in data.saved:data.saved.erase(key)
 else:data.saved.append(key)
 save()
func route(id:String)->Dictionary:
 for r in routes:
  if r.id==id:return r
 return {}
func route_progress(id:String)->Dictionary:
 if not data.routes.has(id):data.routes[id]={"done":[],"current":0,"started":today()};save()
 return data.routes[id]
func complete_step(id:String,index:int):
 var r=route(id);var p=route_progress(id)
 if index<0 or index>=r.steps.size():return
 if index not in p.done:p.done.append(index)
 data.explored[r.steps[index].code]=true;data.engaged=true
 p.current=mini(index+1,r.steps.size()-1)
 if p.done.size()==r.steps.size():p.completed=today()
 save()
