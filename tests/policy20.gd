extends SceneTree
const Policy=preload("res://content_policy.gd")
const Sync=preload("res://monthly_sync.gd")
var errors=[]
class Atlas extends RefCounted:
 var countries={}
 var cities=[]
 var articles={}
 var defense={}
 var events=[]
 var observation_info={}
func _initialize():call_deferred("run")
func check(ok:bool,msg:String):
 print(msg,": ",ok)
 if not ok:errors.append(msg)
func run():
 var source="Introduction\n\n=== Population ===\nAvant\n\n==== Identité sexuelle ====\nPassage retiré.\n\n===== Détail =====\nSous-section retirée.\n\n==== Sécurité ====\nAprès\n\n=== Culture ===\nCulture conservée."
 var cleaned=Policy.clean_text(source)
 check(not Policy.excluded(cleaned) and not "Passage retiré" in cleaned and not "Sous-section retirée" in cleaned,"Section and nested contents removed")
 check("Introduction" in cleaned and "Avant" in cleaned and "Après" in cleaned and "Culture conservée" in cleaned,"Adjacent sections preserved")
 check(Policy.clean_text(cleaned)==cleaned,"Idempotent filter")
 check(not Policy.excluded(Policy.clean_text("== IDENTITÉS SEXUELLES ==\nContenu final")),"Plural and uppercase")
 check(Policy.clean_text("Avant\n\nPhrase sur l’identité sexuelle.\n\nAprès")=="Avant\n\nAprès","Mention outside headings removed")
 var records=Policy.clean_data([{ "title":"Identité sexuelle","text":"Contenu"},{"title":"Population","text":"Nombre"}])
 check(records.size()==1 and records[0].title=="Population","Structured section removed")
 var articles=JSON.parse_string(FileAccess.get_file_as_string("res://data/articles.json"))
 var bad=[]
 for code in articles:
  if Policy.excluded(str(articles[code])):bad.append(code)
 check(bad.is_empty(),"All bundled article records clean")
 check("==== Sécurité ====" in articles.TUR.text and "=== Culture ===" in articles.TUR.text,"Turkey neighbors preserved")
 var app=Atlas.new();app.articles={"TUR":{"title":"Turquie","text":"Article initial assez long pour les tests de validation.","url":"https://fr.wikipedia.org/wiki/Turquie"}}
 var sync=Sync.new();sync.storage_path="user://qa20_policy.json";sync.app=app
 var old={"schema":1,"state":{"completed_cycle":"2026-10-15"},"jobs":[],"patch":{"articles":{"TUR":{"title":"Turquie","text":source,"url":"https://fr.wikipedia.org/wiki/Turquie"}}}}
 var file=FileAccess.open(sync.storage_path,FileAccess.WRITE);file.store_string(JSON.stringify(old));file.close()
 sync.load_cache();sync.apply_to(app)
 check(not Policy.excluded(app.articles.TUR.text) and not "Passage retiré" in app.articles.TUR.text,"Old installed cache filtered")
 var q={"pages":{"1":{"pageid":1,"title":"Turquie","extract":source,"revisions":[{"revid":123,"timestamp":"2026-11-17T00:00:00Z"}]}}}
 check(sync.wiki_extract({"pageid":1,"keys":["TUR"],"full":true},q),"Monthly extract accepted")
 check(not Policy.excluded(app.articles.TUR.text) and not Policy.excluded(sync.patch.articles.TUR.text),"Monthly refresh cannot restore section")
 check(sync.patch.articles.TUR.revision_id==123,"Source revision preserved")
 var content=load("res://content_sync.gd").new();content.cached={"data":{"articles":{"TUR":{"title":"Turquie","text":source}}}}
 check(not Policy.excluded(content.content("articles",{}).TUR.text),"Editorial cache also filtered")
 content.free();sync.free()
 for suffix in ["",".tmp",".bak"]:DirAccess.remove_absolute(ProjectSettings.globalize_path("user://qa20_policy.json"+suffix))
 print("POLICY20: ","PASS" if errors.is_empty() else errors);quit(0 if errors.is_empty() else 1)
