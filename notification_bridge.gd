extends RefCounted
var native
var activity
func _init():
 if OS.get_name()=="Android" and Engine.has_singleton("AndroidRuntime"):
  activity=Engine.get_singleton("AndroidRuntime").getActivity()
  native=JavaClassWrapper.wrap("fr.alexisuguz.meridien.discovery.DiscoveryNotifications")
func available()->bool:return native!=null and activity!=null
func status()->String:
 if not available():return "Indisponible dans cette version web ou sur cet appareil."
 return str(native.status(activity))
func configure(frequency:String,hour:int,minute:int,catalog:Array)->bool:
 if not available():return false
 return bool(native.configure(activity,frequency,hour,minute,JSON.stringify(catalog)))
func refresh():
 if available():native.refresh(activity)
func take_link()->String:
 if not available():return ""
 return str(native.consumeLink(activity))

func settings():
 if available():native.openSettings(activity)
func update_catalog(catalog:Array):
 if available():native.updateCatalog(activity,JSON.stringify(catalog))
