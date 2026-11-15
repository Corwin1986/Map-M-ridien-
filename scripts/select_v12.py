import json,collections,bz2,csv
from pathlib import Path
D=Path(__file__).resolve().parents[1]/'data'
cs=json.load(open(D/'countries.json'));old=json.load(open(D/'cities.json'));raw=json.load(open(D/'source_v12/cities10_raw.json'))['features']
alias={'SDS':'SSD','KOS':'UNK','SAH':'ESH','PSX':'PSE'}
by=collections.defaultdict(list)
for f in raw:
 p=f['properties'];c=alias.get(p['ADM0_A3'],p['ADM0_A3'])
 if c in cs:by[c].append(p)
curated={'DZA':['Alger','Oran','Constantine','Annaba','Sétif','Batna','Béjaïa','Tlemcen','Blida','Tamanrasset'],'FRA':['Paris','Marseille','Lyon','Toulouse','Nice','Nantes','Strasbourg','Montpellier','Bordeaux','Lille'],'IND':['Delhi','Bombay','Calcutta','Chennai','Bangalore','Hyderabad','Ahmedabad','Pune','Jaipur','Lucknow'],'TUR':['Istanbul','Ankara','Izmir','Bursa','Adana','Gaziantep','Konya','Antalya','Diyarbakir','Trabzon'],'CHN':['Pékin','Shanghai','Canton','Shenzhen','Chongqing','Tianjin','Chengdu','Wuhan','Nankin','Hangzhou']}
cities=[]
for code,c in cs.items():
 rows=by.get(code,[]);rows.sort(key=lambda x:-x['POP_MAX'])
 count=10 if (c.get('population') or 0)>80000000 else 8 if (c.get('population') or 0)>20000000 else 6 if (c.get('population') or 0)>5000000 else 4
 chosen=[]
 def add(p):
  if p not in chosen:chosen.append(p)
 if code=='USA':
  states=collections.defaultdict(list)
  for p in rows:states[p['ADM1NAME']].append(p)
  for state,rr in sorted(states.items()):
   if not state:continue
   for p in rr[:3]:add(p)
 else:
  for p in rows:
   if p['FEATURECLA']=='Admin-0 capital':add(p)
  for name in curated.get(code,[]):
   match=next((p for p in rows if name in [p['NAME'],p.get('NAME_FR')]),None)
   if match:add(match)
  for p in rows:
   if len(chosen)>=count:break
   add(p)
  chosen=chosen[:max(count,len(curated.get(code,[])))]
 for p in chosen:
  existing=next((x for x in old if x['id']==str(p['NE_ID'])),{})
  cities.append({'id':str(p['NE_ID']),'code':code,'name':existing.get('name') or p.get('NAME_FR') or p['NAME'],'en':p['NAME'],'capital':p['FEATURECLA']=='Admin-0 capital','lat':p['LATITUDE'],'lon':p['LONGITUDE'],'region':p['ADM1NAME'] if code=='USA' else '', 'qid':p.get('WIKIDATAID',''),'wiki':existing.get('wiki','')})
 # retain small territories absent from this layer, without inventing cities
 if not chosen:
  cities.extend(x for x in old if x['code']==code)
 c['cities']=[x['id'] for x in cities if x['code']==code]
# present-day territory of birth, explicitly not nationality
names={c['en']:k for k,c in cs.items()};names.update({'United States':'USA','Czech Republic':'CZE','Democratic Republic of the Congo':'COD','Republic of the Congo':'COG','Ivory Coast':'CIV','Myanmar':'MMR','Swaziland':'SWZ','Palestine':'PSE','East Timor':'TLS','Sao Tome and Principe':'STP','Cape Verde':'CPV'})
groups={'WRITER':'Littérature','POET':'Littérature','PHILOSOPHER':'Pensée','PHYSICIST':'Sciences','CHEMIST':'Sciences','BIOLOGIST':'Sciences','MATHEMATICIAN':'Sciences','ASTRONOMER':'Sciences','INVENTOR':'Sciences','PHYSICIAN':'Sciences','COMPUTER SCIENTIST':'Sciences','ECONOMIST':'Sciences humaines','HISTORIAN':'Sciences humaines','PSYCHOLOGIST':'Sciences humaines','SOCIAL ACTIVIST':'Société','POLITICIAN':'Histoire et politique','MILITARY PERSONNEL':'Histoire et politique','NOBLEMAN':'Histoire et politique','RELIGIOUS FIGURE':'Pensée','ACTOR':'Cinéma et scène','FILM DIRECTOR':'Cinéma et scène','PAINTER':'Arts','SCULPTOR':'Arts','ARCHITECT':'Arts','COMPOSER':'Musique','SINGER':'Musique','MUSICIAN':'Musique','EXPLORER':'Exploration','DIPLOMAT':'Histoire et politique'}
pby=collections.defaultdict(list)
with bz2.open(D/'source_v12/pantheon_2025.csv.bz2','rt') as f:
 for r in csv.DictReader(f):
  code=names.get(r['bplace_country']);group=groups.get(r['occupation'])
  if code and group and r['wd_id'].startswith('Q') and r['is_group']!='TRUE':
   pby[code].append({'qid':r['wd_id'],'name':r['name'],'group':group,'occupation':r['occupation'],'birth':r['birthyear'],'death':r['deathyear'],'place':r['bplace_name'],'association':'Lieu de naissance situé dans ce pays actuel','code':code,'score':float(r['hpi'] or 0),'gender':r['gender']})
people=[]
for code,rows in pby.items():
 rows.sort(key=lambda x:-x['score']);chosen=[]
 limit=10 if (cs[code].get('population') or 0)>20000000 else 6
 # Show different fields and include prominent women where the dataset has them.
 for group in ['Littérature','Sciences','Cinéma et scène','Histoire et politique','Arts','Musique','Pensée','Société']:
  r=next((r for r in rows if r['group']==group),None)
  if r and r not in chosen:chosen.append(r)
 for r in rows:
  if r['gender']=='F' and r not in chosen and sum(x['gender']=='F' for x in chosen)<2:chosen.append(r)
 for r in rows:
  if len(chosen)>=limit:break
  if r not in chosen:chosen.append(r)
 people.extend(chosen[:max(limit,len(chosen))])
for name,obj in [('countries.json',cs),('cities.json',cities),('people.json',people)]:
 (D/name).write_text(json.dumps(obj,ensure_ascii=False,separators=(',',':')))
print('CITIES',len(cities),'countries',len(set(x['code'] for x in cities)),'USA states',len(set(x.get('region') for x in cities if x['code']=='USA')))
print('PEOPLE',len(people),'countries',len(pby))
