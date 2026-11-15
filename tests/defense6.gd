extends SceneTree
const Data=preload("res://defense_data.gd")
var app
var failed=[]
func _initialize():call_deferred("run")
func check(ok:bool,label:String):
 print(label,": ",ok)
 if not ok:failed.append(label)
func run():
 app=load("res://main.tscn").instantiate();app.skip_monthly_sync=true;root.add_child(app)
 await process_frame;await process_frame
 check(app.TOPICS.has("Militaire"),"Military topic available")
 check(app.defense.personnel.size()==174,"Personnel dataset coverage")
 check(app.defense.gdp.size()==212,"GDP dataset coverage")
 check(app.defense.equipment.size()==148,"Equipment parser coverage")
 check(app.defense.equipment.FRA.tanks==222 and app.defense.equipment.FRA.combat_aircraft==282,"Correct equipment columns despite split budget cells")
 check(app.defense.equipment.TUR.uncertain,"Unsourced row flagged")
 var rank=Data.ranking(app.defense.equipment,"tanks",app.countries,false)
 check(not rank.ranks.has("TUR") and rank.ranks.has("FRA"),"Unsourced equipment excluded from ranks")
 var economic=Data.ranking(app.defense.gdp,"value",app.countries)
 check(economic.ranks.get("USA")==1 and economic.ranks.get("CHN")==2,"Economic ranking based on GDP")
 check(economic.count>=100,"Economic ranking common year coverage")
 var records={"FRA":{"value":50,"year":2024},"TUR":{"value":50,"year":2024},"DZA":{"value":10,"year":2024},"USA":{"value":100,"year":2020}}
 rank=Data.ranking(records,"value",app.countries)
 check(rank.ranks.FRA==1 and rank.ranks.TUR==1 and rank.ranks.DZA==3 and not rank.ranks.has("USA"),"Ties shared; different years excluded")
 records={"FRA":{"value":50,"year":2024},"TUR":{"value":null,"year":2024}}
 check(not Data.ranking(records,"value",app.countries).ranks.has("TUR"),"Unknown data never ranked as zero")
 var sync=app.monthly_sync
 sync.app=app
 check(sync.consume({"kind":"defense_personnel"},FileAccess.get_file_as_bytes("res://tests/fixtures/personnel6.json"),Time.get_date_dict_from_system()),"Monthly personnel adapter")
 check(sync.consume({"kind":"defense_equipment"},FileAccess.get_file_as_bytes("res://tests/fixtures/equipment6.json"),Time.get_date_dict_from_system()),"Monthly equipment adapter")
 check(sync.valid_patch(sync.patch),"Defense cache validation")
 var broken={"parse":{"text":{"*":"<table>changed format</table>"}}}
 check(Data.equipment(broken,app.countries).is_empty(),"Changed equipment format rejected")
 app.show_country("FRA","Militaire");await process_frame;await process_frame
 root.get_texture().get_image().save_png(OS.get_user_data_dir()+"/qa6_military.png")
 app.scroll.scroll_vertical=450;await process_frame;await process_frame
 root.get_texture().get_image().save_png(OS.get_user_data_dir()+"/qa6_equipment.png")
 app.show_compare();await process_frame;await process_frame
 root.get_texture().get_image().save_png(OS.get_user_data_dir()+"/qa6_compare.png")
 app.scroll.scroll_vertical=360;await process_frame;await process_frame
 root.get_texture().get_image().save_png(OS.get_user_data_dir()+"/qa6_compare_military.png")
 app.show_country("ATA","Militaire");await process_frame
 check(app.defense_value("personnel","ATA")=="Non renseigné","Uncovered territory handled")
 print("DEFENSE V6: ","PASS" if failed.is_empty() else failed)
 quit(0 if failed.is_empty() else 1)
