extends SceneTree
const R=preload("res://reliability.gd")
const F=preload("res://feedback_store.gd")
const S=preload("res://monthly_sync.gd")
var errors=[]
func _initialize():call_deferred("run")
func check(ok:bool,msg:String):
 if not ok:errors.append(msg);push_error(msg)
func run():
 check(not R.person_issues({"birth":"1943","death":"1983","description":"né en 1944"},{}).is_empty(),"Mismatch detected")
 check(R.person_issues({"birth":"1944","death":"1983","description":"né en 1944"},{}).is_empty(),"Consistent dates accepted")
 check(R.person_issues({"birth":"1900","death":"","description":""},{"text":"Personne née en 1900. Elle publie en 1940."}).is_empty(),"Later unrelated year ignored")
 check(R.person_issues({"birth":"1937","death":"2006","description":"président (1979–2003)"},{}).is_empty(),"Term of office never confused with life dates")
 check(R.person_issues({"birth":"1815","death":"1854"},{"text":"Né le 12 février à Douglas, mort le 18 novembre 1854."}).is_empty(),"Missing birth year does not use death year")
 var p="user://qa13_feedback.json"
 if FileAccess.file_exists(p):DirAccess.remove_absolute(ProjectSettings.globalize_path(p))
 check(F.save_report({"comment":"Premier"},p),"First report saved")
 check(F.save_report({"comment":"Second"},p),"Second report saved")
 check(F.read_reports(p).size()==2,"Reports survive reopening")
 DirAccess.remove_absolute(ProjectSettings.globalize_path(p))
 var sync=S.new();sync.state={"category_checks":{"Articles":"2026-10-15T12:00:00"}}
 sync.jobs=[{"kind":"wiki_check","done":true,"checked_at":"2026-11-15T12:00:00"},{"kind":"wiki_extract","done":false,"last_error":"HTTP 503"}]
 check(sync.last_check("Articles")=="2026-10-15T12:00:00","Partial refresh preserves previous complete date")
 var rows=sync.category_rows()
 check(rows[4].status=="À reprendre" and rows[4].done==1 and rows[4].total==2,"Partial status accurate")
 sync.jobs[1].done=true;sync.jobs[1].checked_at="2026-11-15T12:30:00"
 check(sync.last_check("Articles")=="2026-11-15T12:30:00","Complete category records latest date")
 sync.free()
 var people=JSON.parse_string(FileAccess.get_file_as_string("res://data/people.json"))
 var articles=JSON.parse_string(FileAccess.get_file_as_string("res://data/articles.json"))
 var countries=JSON.parse_string(FileAccess.get_file_as_string("res://data/countries.json"))
 for person in people:
  if person.qid=="Q468234":check(person.birth=="1944" and R.person_issues(person,articles.get(person.article,{})).is_empty(),"Bishop corrected in every country")
 var report=R.audit(people,articles,countries)
 var out=FileAccess.open("/tmp/audit13.json",FileAccess.WRITE);out.store_string(JSON.stringify(report,"  "));out.close()
 print("AUDIT profiles: ",report.profiles_checked," flagged: ",report.profiles_flagged)
 print("RELIABILITY V13: ","PASS" if errors.is_empty() else errors)
 quit(0 if errors.is_empty() else 1)
