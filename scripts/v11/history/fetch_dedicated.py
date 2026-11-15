import json,urllib.request,urllib.parse,concurrent.futures,time,re
from pathlib import Path
out=Path(__file__).parent
T={'ABW':"Histoire d'Aruba",'AGO':"Histoire de l'Angola",'AND':"Histoire de l'Andorre",'ATG':"Histoire d'Antigua-et-Barbuda",'BGD':'Histoire du Bangladesh','BHS':'Histoire des Bahamas','SHN':'Histoire de Sainte-Hélène','BLZ':'Histoire du Belize','BMU':'Histoire des Bermudes','BRB':'Histoire de la Barbade','BRN':'Histoire de Brunei','BTN':'Histoire du Bhoutan','BVT':"Île Bouvet",'BWA':'Histoire du Botswana','CCK':'Îles Cocos','COK':'Histoire des îles Cook','CXR':'Île Christmas','CYM':'Histoire des îles Caïmans','CZE':'Histoire de la Tchéquie','FJI':'Histoire des Fidji','FLK':'Histoire des îles Malouines','FRO':'Histoire des îles Féroé','GRD':'Histoire de la Grenade','GUM':'Histoire de Guam','GUY':'Histoire du Guyana','HMD':'Îles Heard-et-MacDonald','KHM':'Histoire du Cambodge','KIR':'Histoire des Kiribati','KNA':'Histoire de Saint-Christophe-et-Niévès','KOR':'Histoire de la Corée du Sud','LBR':'Histoire du Liberia','LCA':'Histoire de Sainte-Lucie','LIE':'Histoire du Liechtenstein','LSO':'Histoire du Lesotho','LTU':'Histoire de la Lituanie','LVA':'Histoire de la Lettonie','MAF':'Histoire de Saint-Martin','MHL':'Histoire des îles Marshall','MMR':'Histoire de la Birmanie','MNE':'Histoire du Monténégro','MNP':'Îles Mariannes du Nord','MUS':"Histoire de l'île Maurice",'MYS':'Histoire de la Malaisie','OMN':"Histoire d'Oman",'PLW':'Histoire des Palaos','PNG':'Histoire de la Papouasie-Nouvelle-Guinée','PRK':'Histoire de la Corée du Nord','SAU':"Histoire de l'Arabie saoudite",'SGP':'Histoire de Singapour','SGS':'Géorgie du Sud-et-les îles Sandwich du Sud','SMR':'Histoire de Saint-Marin','SWZ':"Histoire de l'Eswatini",'SXM':'Saint-Martin (royaume des Pays-Bas)','TKM':'Histoire du Turkménistan','TON':'Histoire des Tonga','UMI':'Îles mineures éloignées des États-Unis','VAT':'Histoire du Vatican','VCT':'Histoire de Saint-Vincent-et-les-Grenadines','VGB':'Histoire des îles Vierges britanniques','VNM':'Histoire du Viêt Nam','WSM':'Histoire des Samoa','ATC':'Îles Ashmore-et-Cartier','BES':'Pays-Bas caribéens','SJM':'Svalbard et Jan Mayen','IOA':"Territoires australiens de l'océan Indien"}
res={}
def one(pair):
 code,title=pair
 u='https://fr.wikipedia.org/w/api.php?'+urllib.parse.urlencode({'action':'query','format':'json','prop':'extracts|revisions','explaintext':1,'rvprop':'ids|timestamp','redirects':1,'titles':title})
 try:
  d=json.load(urllib.request.urlopen(urllib.request.Request(u,headers={'User-Agent':'MeridienAtlas/11.0 (educational atlas; attributed Wikimedia content)'}),timeout=35))
  for a in d.get('query',{}).get('pages',{}).values():
   if a.get('extract'):
    rev=a.get('revisions',[{}])[0]
    return code,{'title':a['title'],'pageid':a['pageid'],'text':a['extract'],'url':'https://fr.wikipedia.org/?curid='+str(a['pageid']),'history':'https://fr.wikipedia.org/w/index.php?title='+urllib.parse.quote(a['title'])+'&action=history','license':'CC BY-SA 4.0','retrieved':'2026-11-15','revision_id':rev.get('revid',0),'source_timestamp':rev.get('timestamp','')}
 except Exception as e:print(code,type(e).__name__,flush=True)
 return code,{}
with concurrent.futures.ThreadPoolExecutor(max_workers=3) as pool:
 for code,a in pool.map(one,T.items()):
  if a:res[code]=a
  print(code,a.get('title'),len(a.get('text','')),flush=True)
  (out/'dedicated_articles.json').write_text(json.dumps(res,ensure_ascii=False,separators=(',',':')))
