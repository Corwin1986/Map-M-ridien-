import json,time,urllib.request,urllib.parse
from pathlib import Path
D=Path(__file__).resolve().parents[1]/'data';C=D/'source_v12/cache';foods=json.load(open(D/'cuisines.json'))
overrides={'USA':'Cuisine des États-Unis','KWT':'Cuisine du Koweït','BHR':'Cuisine de Bahreïn','MDV':'Cuisine des Maldives','TLS':'Cuisine du Timor oriental','HND':'Cuisine du Honduras','CRI':'Cuisine du Costa Rica','TTO':'Cuisine de Trinité-et-Tobago','BHS':'Cuisine des Bahamas','GUY':'Cuisine du Guyana','SUR':'Cuisine du Suriname','MAC':'Cuisine de Macao','YEM':'Cuisine du Yémen','ARE':'Cuisine des Émirats arabes unis','QAT':'Cuisine du Qatar','CPV':'Cuisine du Cap-Vert','MOZ':'Cuisine du Mozambique','SYC':'Cuisine des Seychelles','BIH':'Cuisine de Bosnie-Herzégovine','UNK':'Cuisine du Kosovo','NZL':'Cuisine de Nouvelle-Zélande','PNG':'Cuisine de Papouasie-Nouvelle-Guinée','WSM':'Cuisine des Samoa','TON':'Cuisine des Tonga','VUT':'Cuisine du Vanuatu','SLB':'Cuisine des Îles Salomon','AND':"Cuisine d'Andorre"}
# Store the corrections separately until the running extraction finishes.
(D/'source_v12/cuisine_title_overrides.json').write_text(json.dumps(overrides,ensure_ascii=False))
codes='DZA TUR FRA USA IND CHN JPN ITA MAR TUN LBN GRC ESP PRT MEX THA VNM KOR IRN EGY SEN ETH CAN BRA ARG PER GBR DEU RUS IDN PAK AUS NZL BEL CHE'.split()
for code in codes:
 title=overrides.get(code,foods[code]['wiki']);p=C/('fullfood_'+code+'.json')
 if p.exists():continue
 for attempt in range(3):
  try:
   time.sleep(5)
   url='https://fr.wikipedia.org/w/api.php?'+urllib.parse.urlencode({'action':'query','prop':'extracts|pageprops','titles':title,'explaintext':1,'format':'json','redirects':1})
   r=json.load(urllib.request.urlopen(urllib.request.Request(url,headers={'User-Agent':'MeridienAtlas/1.2 (offline educational atlas; attributed content)'}),timeout=40));page=next(iter(r.get('query',{}).get('pages',{}).values()))
   if len(page.get('extract',''))<60 or 'disambiguation' in page.get('pageprops',{}):print('Missing food',code,title,flush=True);break
   a={'title':page['title'],'text':page['extract'],'url':'https://fr.wikipedia.org/?curid='+str(page['pageid']),'history':'https://fr.wikipedia.org/w/index.php?title='+urllib.parse.quote(page['title'])+'&action=history','retrieved':'2026-11-14','license':'CC BY-SA 4.0'}
   p.write_text(json.dumps(a,ensure_ascii=False));print('Full food',code,len(a['text']),flush=True);break
  except Exception as e:
   pause=int(getattr(e,'headers',{}).get('Retry-After','30')) if getattr(e,'code',0)==429 else 10
   print('Pause',pause,code,str(e),flush=True);time.sleep(min(pause,60))
print('FOOD DONE',flush=True)
