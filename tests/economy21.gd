extends SceneTree
const D=preload("res://defense_data.gd")
const S=preload("res://monthly_sync.gd")
var errors=[]
func _initialize():call_deferred("run")
func check(ok:bool,title:String):
 print(title,": ",ok)
 if not ok:errors.append(title)
func run():
 var app=load("res://main.tscn").instantiate();app.skip_monthly_sync=true;root.add_child(app)
 await process_frame;await process_frame
 check(app.defense.gdp_pc.size()==212,"GDP per capita 212 territories")
 check(app.defense.personnel_detail.size()==174,"Personnel coverage 174 countries")
 check(app.defense.personnel_official.size()==31,"NATO official estimates 31 countries")
 check(app.defense.personnel_detail.FRA.active==203900 and app.defense.personnel_detail.USA.reserve==804800,"Personnel columns match cited source")
 check(app.defense.personnel_detail.FRA.year==null and app.defense.personnel_detail.FRA.edition_year==2026,"Source edition is not observation year")
 check(app.defense.personnel_official.USA.value==1321900 and app.defense.personnel_official.FRA.value==202000,"NATO thousands correctly converted")
 var rank=D.ranking(app.defense.gdp,"value",app.countries)
 check(rank.ranks.USA==1 and rank.ranks.CHN==2 and rank.year==2025,"GDP common-year ranking")
 check(app.military_rank("equipment","tanks","FRA").begins_with("Non classé"),"Undated equipment not ranked")
 var sync=app.monthly_sync;sync.app=app;sync.storage_path="user://qa_economy21.json"
 sync.state={"cycle":"2026-11-15","plan_version":7};sync.jobs=[sync.job("facts","https://example.com",4,"")];sync.jobs[0].done=true
 sync.prepare_jobs("2026-11-15")
 check(sync.jobs.size()==3 and sync.jobs[0].done and sync.state.plan_version==8,"Plan migration preserves completed checkpoints")
 var previous=app.defense.gdp.FRA.duplicate(true)
 sync.patch={"defense":{"gdp":{"FRA":{"value":1,"year":2020}}}}
 sync.apply_to(app)
 check(app.defense.gdp.FRA==previous,"Old cache cannot replace newer GDP")
 sync.patch={};sync.jobs=[]
 var j={"kind":"gdp_pc"}
 var before=sync.semantic_snapshot(j)
 check(sync.consume(j,FileAccess.get_file_as_bytes("res://data/source_v21/gdp_pc.json"),Time.get_date_dict_from_system()),"Monthly GDP per capita response accepted")
 check(before==sync.semantic_snapshot(j),"Consultation date alone is not a data change")
 app.defense.gdp_pc.FRA.value+=1
 check(before!=sync.semantic_snapshot(j),"Actual value change detected")
 var malformed={"parse":{"text":{"*":"changed table"}}}
 check(D.personnel_detail(malformed,app.countries).is_empty(),"Malformed personnel table fails closed")
 sync.jobs=[{"kind":"gdp_pc","done":true,"outcome":"changed"},{"kind":"wb","indicator":"NY.GDP.MKTP.CD","done":true,"outcome":"unchanged"},{"kind":"personnel_detail","done":false,"outcome":"unavailable","last_error":"HTTP 503"}]
 var rows=sync.category_rows()
 check(rows[2].changed==1 and rows[2].unchanged==1 and rows[6].unavailable==1,"Update summary counts outcomes separately")
 check(sync.valid_patch(sync.patch),"New cache format valid")
 app.show_country("FRA","Économie");await process_frame;await process_frame
 if DisplayServer.get_name()!="headless":root.get_texture().get_image().save_png("res://tests/economy21.png")
 app.show_country("USA","Militaire");await process_frame;await process_frame
 if DisplayServer.get_name()!="headless":root.get_texture().get_image().save_png("res://tests/military21.png")
 app.show_compare();await process_frame;await process_frame
 app.show_updates();await process_frame
 for suffix in ["",".bak",".tmp"]:
  if FileAccess.file_exists(sync.storage_path+suffix):DirAccess.remove_absolute(ProjectSettings.globalize_path(sync.storage_path+suffix))
 print("ECONOMY21: ","PASS" if errors.is_empty() else errors)
 quit(0 if errors.is_empty() else 1)
