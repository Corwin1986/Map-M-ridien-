import json,time,urllib.request,urllib.parse,concurrent.futures
from pathlib import Path
D=Path(__file__).resolve().parents[1]/'data';C=D/'source_population';C.mkdir(exist_ok=True)
cities=json.load(open(D/'cities.json'));known={}
for f in C.glob('batch*.json'):known.update(json.load(open(f)))
ids=sorted({c['qid'] for c in cities if str(c.get('qid') or '').startswith('Q')}-known.keys())
def fetch(pair):
 i,batch=pair
 url='https://www.wikidata.org/w/api.php?'+urllib.parse.urlencode({'action':'wbgetentities','ids':'|'.join(batch),'props':'claims','format':'json'})
 for attempt in range(3):
  try:
   req=urllib.request.Request(url,headers={'User-Agent':'MeridienAtlas/2.2 (population ordering; educational offline atlas)'})
   entities=json.load(urllib.request.urlopen(req,timeout=55)).get('entities',{})
   result={qid:{'P1082':e.get('claims',{}).get('P1082',[])} for qid,e in entities.items()}
   (C/('batch_'+batch[0]+'.json')).write_text(json.dumps(result,ensure_ascii=False));time.sleep(5);return result
  except Exception as e:
   delay=max(30,int(getattr(e,'headers',{}).get('Retry-After','30'))) if getattr(e,'code',0)==429 else 10
   print('Retry',i,str(e),'delay',delay,flush=True);time.sleep(delay)
 return {}
batches=[(i,ids[i:i+50]) for i in range(0,len(ids),50)]
with concurrent.futures.ThreadPoolExecutor(max_workers=1) as pool:
 for n,r in enumerate(pool.map(fetch,batches)):
  known.update(r);print('Population batches',n+1,'/',len(batches),flush=True)
missing=[]
for city in cities:
 options=[]
 for s in known.get(city.get('qid'),{}).get('P1082',[]):
  if s.get('rank')=='deprecated':continue
  q=s.get('qualifiers',{})
  if any(p in q for p in ['P518','P1540','P1539','P21','P27','P172']):continue
  value=s.get('mainsnak',{}).get('datavalue',{}).get('value',{}).get('amount')
  if value is None or float(value)<=0:continue
  dates=[x.get('datavalue',{}).get('value',{}).get('time','') for x in q.get('P585',[])]
  date=max(dates,default='')
  if not date.startswith('+') or date[1:11]>'2026-11-14':continue
  refs=[]
  for ref in s.get('references',[]):
   refs += [x.get('datavalue',{}).get('value','') for x in ref.get('snaks',{}).get('P854',[]) if x.get('datavalue',{}).get('type')=='string']
  options.append((date,s.get('rank')=='preferred',len(refs)>0,int(float(value)),s.get('id',''),refs))
 if options:
  date,_,_,value,sid,refs=max(options)
  city.update(population=value,population_year=int(date[1:5]),population_date=date[1:11],population_source='Wikidata · P1082',population_url='https://www.wikidata.org/wiki/'+city['qid']+'#P1082',population_statement=sid,population_references=refs)
 else:
  city['population']=None;city['population_year']=None;missing.append(city['name'])
(D/'cities.json').write_text(json.dumps(cities,ensure_ascii=False,separators=(',',':')))
(C/'coverage.json').write_text(json.dumps({'known':len(cities)-len(missing),'missing':missing},ensure_ascii=False,indent=2))
print('DONE',len(cities)-len(missing),'/',len(cities),'Missing',missing,flush=True)
for code in ['FRA','TUR','DZA','USA']:
 print(code,[(c['name'],c.get('population'),c.get('population_year')) for c in sorted([c for c in cities if c['code']==code],key=lambda c:-(c.get('population') or -1))][:10],flush=True)
