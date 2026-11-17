extends SceneTree
const D=preload("res://defense_data.gd")
func _initialize():
 var countries=JSON.parse_string(FileAccess.get_file_as_string("res://data/countries.json"))
 var d=JSON.parse_string(FileAccess.get_file_as_string("res://data/defense.json"))
 for pair in [["gdp","NY.GDP.MKTP.CD"],["gdp_pc","NY.GDP.PCAP.CD"]]:
  d[pair[0]]=D.indicator(JSON.parse_string(FileAccess.get_file_as_string("res://data/source_v21/"+pair[0]+".json")),pair[1],countries)
 d.personnel_detail=D.personnel_detail(JSON.parse_string(FileAccess.get_file_as_string("res://data/source_v21/personnel.json")),countries)
 for category in ["gdp","gdp_pc","personnel_detail"]:
  print(category,": ",d[category].size())
  if d[category].is_empty():quit(1);return
 var f=FileAccess.open("res://data/defense.json",FileAccess.WRITE);f.store_string(JSON.stringify(d));f.close();quit()
