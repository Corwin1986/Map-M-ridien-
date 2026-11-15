import json,urllib.request,urllib.parse,time,hashlib,os
from pathlib import Path
D=Path(__file__).resolve().parents[1]/'data';CACHE=D/'source_v12/cache';CACHE.mkdir(parents=True,exist_ok=True)
UA={'User-Agent':'MeridienAtlas/1.2 (offline educational atlas; attributed Wikimedia content)'}
def fetch(base,params):
 url=base+'?'+urllib.parse.urlencode(params)
 for attempt in range(4):
  try:
   time.sleep(3)
   return json.load(urllib.request.urlopen(urllib.request.Request(url,headers=UA),timeout=40))
  except Exception as e:
   delay=int(getattr(e,'headers',{}).get('Retry-After','30')) if getattr(e,'code',0)==429 else 5
   print('Retry',getattr(e,'code',str(e)),delay,flush=True)
   if attempt==3:return {}
   time.sleep(min(max(delay,5),60))
cs=json.load(open(D/'cities.json'));people=json.load(open(D/'people.json'))
ids=sorted(set(x.get('qid','') for x in cs+people if str(x.get('qid') or '').startswith('Q')))
entities={}
for cached_path in CACHE.glob('entities_*.json'):
 entities.update(json.load(open(cached_path)).get('entities',{}))
ids=[qid for qid in ids if qid not in entities]
for i in range(0,len(ids),50):
 batch=ids[i:i+50];key=hashlib.sha256('|'.join(batch).encode()).hexdigest()[:16];p=CACHE/('entities_'+key+'.json')
 if p.exists():r=json.load(open(p))
 else:
  r=fetch('https://www.wikidata.org/w/api.php',{'action':'wbgetentities','ids':'|'.join(batch),'props':'labels|descriptions|sitelinks','languages':'fr|en','sitefilter':'frwiki','format':'json'})
  if r.get('entities'):p.write_text(json.dumps(r,ensure_ascii=False))
 entities.update(r.get('entities',{}));print('Entities',min(i+50,len(ids)),'/',len(ids),flush=True)
(D/'source_v12/entities.json').write_text(json.dumps(entities,ensure_ascii=False))
arts=json.load(open(D/'articles.json'))
title_keys={}
for c in cs:
 key='city_'+c['id'];e=entities.get(c.get('qid',''),{});title=e.get('sitelinks',{}).get('frwiki',{}).get('title',c.get('wiki') or c['name'])
 c['wiki']=title
 if arts.get(key,{}).get('text'):continue
 title_keys.setdefault(title,[]).append(key)
for p in people:
 e=entities.get(p['qid'],{});p['name']=e.get('labels',{}).get('fr',{}).get('value',p['name']);p['description']=e.get('descriptions',{}).get('fr',{}).get('value','')
 title=e.get('sitelinks',{}).get('frwiki',{}).get('title','');p['article']='person_'+p['qid'];p['wiki']=title
 if title and not arts.get(p['article'],{}).get('text'):title_keys.setdefault(title,[]).append(p['article'])
# Additional catalogues are prepared independently while entities are fetched.
for filename,prefix in [('conflict_history.json','war_'),('cuisines.json','food_')]:
 if (D/filename).exists():
  rows=json.load(open(D/filename))
  if isinstance(rows,dict):rows=list(rows.values())
  for row in rows:
   if row.get('wiki') and not arts.get(row['article'],{}).get('text'):title_keys.setdefault(row['wiki'],[]).append(row['article'])
titles=list(title_keys)
for i in range(0,len(titles),20):
 batch=titles[i:i+20];key=hashlib.sha256('|'.join(batch).encode()).hexdigest()[:16];p=CACHE/('extract_'+key+'.json')
 if p.exists():r=json.load(open(p))
 else:
  r=fetch('https://fr.wikipedia.org/w/api.php',{'action':'query','prop':'extracts|pageprops','explaintext':1,'exintro':1,'exlimit':20,'titles':'|'.join(batch),'format':'json','redirects':1})
  if r.get('query'):p.write_text(json.dumps(r,ensure_ascii=False))
 q=r.get('query',{});redirects={x['from']:x['to'] for x in q.get('normalized',[])+q.get('redirects',[])}
 pages={v['title']:v for v in q.get('pages',{}).values()}
 for title in batch:
  resolved=title
  for _ in range(8):
   if resolved not in redirects:break
   resolved=redirects[resolved]
  a=pages.get(resolved,{})
  if len(a.get('extract',''))<60 or 'disambiguation' in a.get('pageprops',{}):continue
  record={'title':a['title'],'text':a['extract'],'url':'https://fr.wikipedia.org/?curid='+str(a['pageid']),'history':'https://fr.wikipedia.org/w/index.php?title='+urllib.parse.quote(a['title'])+'&action=history','retrieved':'2026-11-14','license':'CC BY-SA 4.0','scope':'intro'}
  for k in title_keys[title]:arts[k]=record
 if i%100==0:
  (D/'articles.json').write_text(json.dumps(arts,ensure_ascii=False,separators=(',',':')))
 print('Introductions',min(i+20,len(titles)),'/',len(titles),flush=True)
for filename,obj in [('articles.json',arts),('cities.json',cs),('people.json',people)]:
 (D/filename).write_text(json.dumps(obj,ensure_ascii=False,separators=(',',':')))
print('DONE',len(arts),flush=True)
