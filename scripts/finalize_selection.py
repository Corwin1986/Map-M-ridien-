import json,bz2,csv
from pathlib import Path
D=Path(__file__).resolve().parents[1]/'data';people=json.load(open(D/'people.json'))
raw=list(csv.DictReader(bz2.open(D/'source_v12/pantheon_2025.csv.bz2','rt')))
curated={'TUR':[('Mustafa Kemal Atatürk','Histoire et politique'),('Nâzım Hikmet','Littérature'),('Orhan Pamuk','Littérature'),('Yaşar Kemal','Littérature'),('Aziz Sancar','Sciences'),('Halide Edib Adıvar','Littérature'),('Kemal Sunal','Cinéma et scène')],'DZA':[('Emir Abdelkader','Histoire et politique'),('Assia Djebar','Littérature'),('Kateb Yacine','Littérature'),('Mouloud Mammeri','Littérature')],'FRA':[('Marie Curie','Sciences'),('Josephine Baker','Cinéma et scène'),('Louis Pasteur','Sciences'),('Simone de Beauvoir','Littérature')],'USA':[('Abraham Lincoln','Histoire et politique'),('Benjamin Franklin','Sciences'),('Maya Angelou','Littérature'),('Katherine Johnson','Sciences'),('Albert Einstein','Sciences')],'IND':[('Rabindranath Tagore','Littérature'),('B. R. Ambedkar','Histoire et politique'),('C. V. Raman','Sciences'),('Sarojini Naidu','Littérature')]}
cs=json.load(open(D/'countries.json'))
for code,items in curated.items():
 extra=[]
 for name,group in items:
  r=next((r for r in raw if r['name']==name),None)
  if not r:raise ValueError(name)
  existing=next((p for p in people if p['code']==code and p['qid']==r['wd_id']),None)
  if existing:extra.append(existing);continue
  extra.append({'qid':r['wd_id'],'name':r['name'],'group':group,'occupation':r['occupation'],'birth':r['birthyear'],'death':r['deathyear'],'place':r['bplace_name'],'association':'Lien biographique et parcours lié à '+cs[code]['name']+' ; voir la notice sourcée','code':code,'score':float(r['hpi'] or 0),'gender':r['gender']})
 people=extra+[p for p in people if not any(p['code']==x['code'] and p['qid']==x['qid'] for x in extra)]
(D/'people.json').write_text(json.dumps(people,ensure_ascii=False,separators=(',',':')))
# Delhi and New Delhi share an urban area: keep the capital and include Lucknow instead of duplicating that urban centre.
cities=json.load(open(D/'cities.json'));rows=[f['properties'] for f in json.load(open(D/'source_v12/cities10_raw.json'))['features']]
for code,remove,target in [('IND','Delhi','Lucknow'),('TUR','Tarse','Diyarbakır')]:
 p=next((p for p in rows if p['ADM0_A3']==code and target in [p['NAME'],p.get('NAME_FR')]),None)
 if p and not any(c['code']==code and c['id']==str(p['NE_ID']) for c in cities):
  cities=[c for c in cities if not (c['code']==code and c['name']==remove)]
  cities.append({'id':str(p['NE_ID']),'code':code,'name':p.get('NAME_FR') or p['NAME'],'en':p['NAME'],'capital':False,'lat':p['LATITUDE'],'lon':p['LONGITUDE'],'region':'','qid':p.get('WIKIDATAID') or '', 'wiki':''})
for code,c in cs.items():c['cities']=[x['id'] for x in cities if x['code']==code]
for filename,obj in [('people.json',people),('cities.json',cities),('countries.json',cs)]:
 (D/filename).write_text(json.dumps(obj,ensure_ascii=False,separators=(',',':')))
print('Final selection',len(cities),len(people))
