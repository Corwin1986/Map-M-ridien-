import json,time,urllib.request,urllib.parse,hashlib
from pathlib import Path
D=Path(__file__).resolve().parents[1]/'data';C=D/'source_recipes';C.mkdir(exist_ok=True)
p=D/'recipes.json';data=json.load(open(p));rows=list(data['recipes'].values())
known={}
def ingest(r):
 q=r.get('query',{});redirects={x['from']:x['to'] for x in q.get('normalized',[])+q.get('redirects',[])};pages={p['title']:p for p in q.get('pages',{}).values()}
 for t in list(pages)+list(redirects):
  n=t
  for _ in range(6):n=redirects.get(n,n)
  a=pages.get(n,{})
  if a.get('pageid',-1)>0 and 'disambiguation' not in a.get('pageprops',{}):known[t]=a
for cache in C.glob('source_*.json'):ingest(json.load(open(cache)))
titles=sorted(set(r['wiki'] for r in rows)-set(known))
for i in range(0,len(titles),20):
 batch=titles[i:i+20];params={'action':'query','prop':'extracts|pageprops','explaintext':1,'exintro':1,'exlimit':20,'titles':'|'.join(batch),'redirects':1,'format':'json'}
 url='https://en.wikipedia.org/w/api.php?'+urllib.parse.urlencode(params)
 for attempt in range(3):
  try:
   r=json.load(urllib.request.urlopen(urllib.request.Request(url,headers={'User-Agent':'MeridienAtlas/2.1 (educational offline atlas; cultural recipe references)'}),timeout=35));break
  except Exception as e:
   print('Retry',str(e),flush=True);time.sleep(10);r={}
 if r:
  (C/('source_'+hashlib.sha256('|'.join(batch).encode()).hexdigest()[:12]+'.json')).write_text(json.dumps(r,ensure_ascii=False));ingest(r)
 print('Sources',min(i+20,len(titles)),'/',len(titles),flush=True);time.sleep(3)
missing=[]
for recipe in rows:
 a=known.get(recipe['wiki'])
 if a:
  recipe['source']={'title':a['title'],'url':'https://en.wikipedia.org/?curid='+str(a['pageid']),'history':'https://en.wikipedia.org/w/index.php?title='+urllib.parse.quote(a['title'])+'&action=history','checked':'2026-11-14','language':'en','scope':'Cultural reference; recipe independently adapted'}
 else:missing.append((recipe['id'],recipe['wiki']))
p.write_text(json.dumps(data,ensure_ascii=False,separators=(',',':')))
(C/'missing.json').write_text(json.dumps(missing,ensure_ascii=False,indent=2));print('MISSING',missing,flush=True)
