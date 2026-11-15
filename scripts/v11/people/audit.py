import json, pathlib, concurrent.futures, urllib.request, time
base=pathlib.Path(__file__).resolve().parents[3]/'data';out=pathlib.Path(__file__).parent;cache=out/'wikidata';cache.mkdir(exist_ok=True)
people=json.load(open(base/'people.json'))
ids=sorted({p['qid'] for p in people if p['occupation']=='CELEBRITY'})
def get(q):
 f=cache/(q+'.json')
 if not f.exists():
  try:
   req=urllib.request.Request('https://www.wikidata.org/wiki/Special:EntityData/'+q+'.json',headers={'User-Agent':'MeridienEducationalAtlas/11.0 (source verification)'})
   f.write_bytes(urllib.request.urlopen(req,timeout=25).read())
  except Exception as e:return q,str(e)
 return q,'ok'
with concurrent.futures.ThreadPoolExecutor(max_workers=4) as pool:
 for q,s in pool.map(get,ids):
  if s!='ok':print(q,s)
print('downloaded',len(list(cache.glob('*.json'))))
