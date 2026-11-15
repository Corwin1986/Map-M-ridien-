"""Build a data-only release after editorial review. Never deploys by itself."""
import argparse,json,hashlib,datetime
from pathlib import Path

def validate(data):
 if not isinstance(data,dict) or not data:raise ValueError('Empty data')
 if ('events' in data)!=('observation_info' in data):raise ValueError('Events and their dates must be published together')
 if set(data)-{'articles','cities','people','cuisines','conflict_history','events','observation_info','recipes'}:raise ValueError('Unexpected keys')
 for key,items in data.items():
  if key=='recipes':
   if not isinstance(items,dict) or any(not isinstance(items.get(k),dict) for k in ['recipes','countries','unavailable']):raise ValueError('Invalid recipe book')
   for rid,r in items['recipes'].items():
    if not isinstance(r,dict) or r.get('id')!=rid or any(not isinstance(r.get(k),str) for k in ['name','servings','note']):raise ValueError('Invalid recipe')
    for k in ['ingredients','steps']:
     if not isinstance(r.get(k),list) or not r[k] or not all(isinstance(x,str) and x for x in r[k]):raise ValueError('Invalid recipe instructions')
    if not str(r.get('source',{}).get('url','')).startswith('https://'):raise ValueError('Missing recipe source')
   for entry in items['countries'].values():
    ids=entry.get('dishes',[])
    if not 1<=len(ids)<=6 or len(set(ids))!=len(ids) or any(x not in items['recipes'] for x in ids):raise ValueError('Invalid country recipe selection')
   continue
  if key=='observation_info':
   if not isinstance(items,dict) or any(not isinstance(items.get(k),str) for k in ['period','version','retrieved']):raise ValueError('Invalid observation metadata')
   continue
  if not isinstance(items,dict if key in ['articles','cuisines'] else list):raise ValueError('Wrong type '+key)
  for item in items.values() if isinstance(items,dict) else items:
   if not isinstance(item,dict):raise ValueError('Invalid record')
   if key=='articles' and (not isinstance(item.get('text'),str) or not isinstance(item.get('title'),str) or not str(item.get('url','')).startswith('https://')):raise ValueError('Invalid article')
   if key=='events':
    for field in ['code','id','date','end','location','country','region','a','b','sources','status']:
     if not isinstance(item.get(field),str):raise ValueError('Invalid event field '+field)
    for field in ['type','best','low','high','precision']:
     if not isinstance(item.get(field),(int,float)):raise ValueError('Invalid event number '+field)
    if item['type'] not in [1,2,3] or item['best']<0:raise ValueError('Invalid event type or estimate')
   if key in ['cities','conflict_history','events']:
    if not isinstance(item.get('lat'),(int,float)) or not isinstance(item.get('lon'),(int,float)) or not -90<=item['lat']<=90 or not -180<=item['lon']<=180:raise ValueError('Invalid coordinates')
   if key=='conflict_history':
    if not isinstance(item.get('start'),int) or not isinstance(item.get('codes'),list) or not item['codes']:raise ValueError('Invalid conflict')
    if item.get('end') is not None and item['end']<item['start']:raise ValueError('Invalid dates')

def build(data,revision,base_url,output):
 validate(data)
 if revision<1 or not base_url.startswith('https://'):raise ValueError('HTTPS and a positive increasing revision are required')
 output=Path(output);output.mkdir(parents=True,exist_ok=True)
 body=json.dumps({'schema':1,'revision':revision,'data':data},ensure_ascii=False,separators=(',',':')).encode()
 name=f'content-{revision}.json';(output/name).write_bytes(body)
 manifest={'schema':1,'revision':revision,'min_app_code':7 if 'cities' in data and any(x.get('population') is not None for x in data['cities']) else (6 if 'recipes' in data else 3),'published_at':datetime.datetime.now(datetime.timezone.utc).isoformat(),'url':base_url.rstrip('/')+'/'+name,'sha256':hashlib.sha256(body).hexdigest(),'bytes':len(body)}
 (output/'manifest.json').write_text(json.dumps(manifest,indent=2))
 return manifest
if __name__=='__main__':
 ap=argparse.ArgumentParser();ap.add_argument('--data',required=True,help='Reviewed JSON dictionary; articles may be a delta, other lists replace their catalogue');ap.add_argument('--revision',required=True,type=int);ap.add_argument('--base-url',required=True);ap.add_argument('--output',default='release');args=ap.parse_args()
 print(json.dumps(build(json.load(open(args.data)),args.revision,args.base_url,args.output),indent=2))
