"""Resolve curated records and reuse every cached Wikimedia response. Limited concurrency, global backoff."""
import json,urllib.request,urllib.parse,time,hashlib,threading,concurrent.futures
from pathlib import Path
D=Path(__file__).resolve().parents[1]/'data';C=D/'source_v12/cache';C.mkdir(parents=True,exist_ok=True)
lock=threading.Lock();next_request=0.0
UA={'User-Agent':'MeridienAtlas/1.2 (offline educational atlas; attributed Wikimedia content)'}
def fetch(base,params):
 global next_request
 for attempt in range(4):
  with lock:
   now=time.monotonic();delay=max(0,next_request-now);next_request=max(next_request,now)+5
  if delay:time.sleep(delay)
  try:
   return json.load(urllib.request.urlopen(urllib.request.Request(base+'?'+urllib.parse.urlencode(params),headers=UA),timeout=40))
  except Exception as e:
   delay=int(getattr(e,'headers',{}).get('Retry-After','30'))+2 if getattr(e,'code',0)==429 else 8
   print('Backoff',delay,str(e),flush=True)
   with lock:next_request=max(next_request,time.monotonic()+delay)
   if attempt==3:return {}
 return {}
def record(page):
 return {'title':page['title'],'text':page['extract'],'url':'https://fr.wikipedia.org/?curid='+str(page['pageid']),'history':'https://fr.wikipedia.org/w/index.php?title='+urllib.parse.quote(page['title'])+'&action=history','retrieved':'2026-11-14','license':'CC BY-SA 4.0','scope':'intro'}
known={};absent=set()
def ingest(r):
 q=r.get('query',{});redirects={x['from']:x['to'] for x in q.get('normalized',[])+q.get('redirects',[])};pages={p['title']:p for p in q.get('pages',{}).values()}
 for title in list(pages)+list(redirects):
  resolved=title
  for _ in range(8):
   if resolved not in redirects:break
   resolved=redirects[resolved]
  page=pages.get(resolved,{})
  if len(page.get('extract',''))>=60 and 'disambiguation' not in page.get('pageprops',{}):known[title]=record(page)
  elif page:absent.add(title)
for p in C.glob('extract_*.json'):ingest(json.load(open(p)))
entities={}
for p in C.glob('entities_*.json'):entities.update(json.load(open(p)).get('entities',{}))
cities=json.load(open(D/'cities.json'));people=json.load(open(D/'people.json'));arts=json.load(open(D/'articles.json'))
ids=sorted(set(str(x.get('qid') or '') for x in cities+people if str(x.get('qid') or '').startswith('Q'))-set(entities))
for i in range(0,len(ids),50):
 batch=ids[i:i+50];r=fetch('https://www.wikidata.org/w/api.php',{'action':'wbgetentities','ids':'|'.join(batch),'props':'labels|descriptions|sitelinks','languages':'fr|en','sitefilter':'frwiki','format':'json'})
 if r.get('entities'):
  key=hashlib.sha256('|'.join(batch).encode()).hexdigest()[:16];(C/('entities_'+key+'.json')).write_text(json.dumps(r,ensure_ascii=False));entities.update(r['entities'])
 print('Additional entities',min(i+50,len(ids)),'/',len(ids),flush=True)
title_keys={}
for city in cities:
 e=entities.get(city.get('qid',''),{});title=e.get('sitelinks',{}).get('frwiki',{}).get('title',city.get('wiki') or city['name']);city['wiki']=title
 key='city_'+city['id']
 if not arts.get(key,{}).get('text'):title_keys.setdefault(title,[]).append(key)
for person in people:
 e=entities.get(person['qid'],{});person['name']=e.get('labels',{}).get('fr',{}).get('value',person['name']);person['description']=e.get('descriptions',{}).get('fr',{}).get('value','')
 person['article']='person_'+person['qid'];person['wiki']=e.get('sitelinks',{}).get('frwiki',{}).get('title','')
 if person['wiki'] and not arts.get(person['article'],{}).get('text'):title_keys.setdefault(person['wiki'],[]).append(person['article'])
for filename in ['conflict_history.json','cuisines.json']:
 rows=json.load(open(D/filename));rows=list(rows.values()) if isinstance(rows,dict) else rows
 for row in rows:
  if row.get('wiki') and not arts.get(row['article'],{}).get('text'):title_keys.setdefault(row['wiki'],[]).append(row['article'])
for title,keys in title_keys.items():
 if title in known:
  for key in keys:arts[key]=known[title]
pending=[t for t in title_keys if t not in known and t not in absent]
print('Cached abstracts',len(known),'remaining titles',len(pending),flush=True)
def request_batch(batch):
 r=fetch('https://fr.wikipedia.org/w/api.php',{'action':'query','prop':'extracts|pageprops','explaintext':1,'exintro':1,'exlimit':20,'titles':'|'.join(batch),'format':'json','redirects':1})
 if r.get('query'):
  key=hashlib.sha256('|'.join(batch).encode()).hexdigest()[:16];(C/('extract_'+key+'.json')).write_text(json.dumps(r,ensure_ascii=False))
 return r
batches=[pending[i:i+20] for i in range(0,len(pending),20)]
with concurrent.futures.ThreadPoolExecutor(max_workers=2) as pool:
 for n,r in enumerate(pool.map(request_batch,batches)):
  ingest(r)
  for title in batches[n]:
   if title in known:
    for key in title_keys[title]:arts[key]=known[title]
  if n%5==0:(D/'articles.json').write_text(json.dumps(arts,ensure_ascii=False,separators=(',',':')))
  print('Remaining batches',n+1,'/',len(batches),flush=True)
# Prefer existing full texts over new abstracts for the same source page.
full_by_url={a.get('url'):a for a in arts.values() if a.get('scope')!='intro' and a.get('text')}
for key,a in list(arts.items()):
 if a.get('scope')=='intro' and a.get('url') in full_by_url:arts[key]=full_by_url[a['url']]
for p in C.glob('fullfood_*.json'):arts['food_'+p.stem.split('_',1)[1]]=json.load(open(p))
missing=[]
for title,keys in title_keys.items():
 for key in keys:
  if not arts.get(key,{}).get('text'):
   arts[key]={'title':title,'url':'https://fr.wikipedia.org/w/index.php?search='+urllib.parse.quote(title),'retrieved':'2026-11-14','scope':'missing'};missing.append((key,title))
for filename,obj in [('articles.json',arts),('cities.json',cities),('people.json',people)]:
 (D/filename).write_text(json.dumps(obj,ensure_ascii=False,separators=(',',':')))
(D/'source_v12/missing_articles.json').write_text(json.dumps(missing,ensure_ascii=False,indent=2))
print('DONE',len(arts),'missing',len(missing),flush=True)
