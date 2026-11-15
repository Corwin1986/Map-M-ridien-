extends SceneTree
const Sync=preload("res://monthly_sync.gd")
func _initialize():call_deferred("run")
func run():
 var sync=Sync.new();sync.storage_path="user://qa5_network.json";root.add_child(sync)
 # Use this workspace's mandatory proxy only in the test harness, never in APK.
 var proxy=OS.get_environment("HTTPS_PROXY").trim_prefix("http://").trim_prefix("https://").trim_suffix("/")
 if not proxy.is_empty():
  sync.request.set_https_proxy(proxy.get_slice(":",0),int(proxy.get_slice(":",1)))
  var certificate=X509Certificate.new()
  if certificate.load(OS.get_environment("SSL_CERT_FILE"))==OK:sync.request.set_tls_options(TLSOptions.client(certificate))
 var urls=["https://api.worldbank.org/v2/country/all/indicator/NY.GDP.MKTP.CD?format=json&mrnev=1&per_page=400",sync.url(Sync.WIKI,{"action":"query","prop":"extracts|revisions|pageprops","rvprop":"ids|timestamp","pageids":1095,"explaintext":1,"exintro":1,"format":"json","maxlag":5}),"https://ucdp.uu.se/downloads/candidateged/GEDEvent_v26_0_9.csv"]
 var ok=true
 for address in urls:
  var r=await sync.fetch(address)
  print("LIVE ",address.get_slice("/",2)," code=",r.code," result=",r.result," bytes=",r.body.size())
  if r.code!=200:ok=false
  await create_timer(2).timeout
 print("LIVE HTTP: ","PASS" if ok else "FAIL")
 quit(0 if ok else 1)
