extends RefCounted
const PATH="user://feedback_v1.json"
static func read_reports(path:String=PATH)->Array:
	if not FileAccess.file_exists(path):return []
	var value=JSON.parse_string(FileAccess.get_file_as_string(path))
	return value if value is Array else []
static func save_report(record:Dictionary,path:String=PATH)->bool:
	if FileAccess.file_exists(path) and not JSON.parse_string(FileAccess.get_file_as_string(path)) is Array:return false
	var reports=read_reports(path)
	if reports.size()>=200:return false
	reports.append(record)
	var f=FileAccess.open(path+".tmp",FileAccess.WRITE)
	if f==null:return false
	f.store_string(JSON.stringify(reports));f.close()
	var check=JSON.parse_string(FileAccess.get_file_as_string(path+".tmp"))
	if not check is Array or check.size()!=reports.size():return false
	return DirAccess.rename_absolute(ProjectSettings.globalize_path(path+".tmp"),ProjectSettings.globalize_path(path))==OK
