extends SceneTree
const Data=preload("res://defense_data.gd")
func _initialize():call_deferred("run")
func run():
 var countries=JSON.parse_string(FileAccess.get_file_as_string("res://data/countries.json"))
 var base=OS.get_cmdline_user_args()[0].trim_suffix("/")+"/" if not OS.get_cmdline_user_args().is_empty() else "res://tests/fixtures/defense_sources/"
 var output={"schema":1,"retrieved":"2026-11-14"}
 for pair in [["personnel","MS.MIL.TOTL.P1"],["gdp","NY.GDP.MKTP.CD"]]:
  output[pair[0]]=Data.indicator(JSON.parse_string(FileAccess.get_file_as_string(base+pair[0]+".json")),pair[1],countries)
 output.equipment=Data.equipment(JSON.parse_string(FileAccess.get_file_as_string(base+"equipment.json")),countries)
 for field in ["personnel","gdp","equipment"]:
  print(field,": ",output[field].size())
  if output[field].is_empty():quit(1);return
 var f=FileAccess.open("res://data/defense.json",FileAccess.WRITE);f.store_string(JSON.stringify(output));f.close()
 print("Personnel rank ",Data.ranking(output.personnel,"value",countries));print("GDP rank ",Data.ranking(output.gdp,"value",countries))
 quit()
