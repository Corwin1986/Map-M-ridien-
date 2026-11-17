import json,urllib.request,urllib.parse,time,re
from pathlib import Path
R=Path(__file__).resolve().parents[1];D=R/'data';T=D/'territory_sources';meta=json.load(open(D/'territories.json'));c=json.load(open(D/'countries.json'));a=json.load(open(D/'articles.json'))
def fetch(base,params):
 u=base+'?'+urllib.parse.urlencode(params)
 for attempt in range(3):
  try:
   req=urllib.request.Request(u,headers={'User-Agent':'MeridienAtlas/19 (offline educational atlas, source attribution)'})
   return json.load(urllib.request.urlopen(req,timeout=35))
  except Exception as e:
   if attempt==2:raise
   time.sleep(1)
rows=list(meta['new'].items());titles={};errors=[]
for start in range(0,len(rows),40):
 batch=rows[start:start+40];cache=T/f'entities_{start}.json'
 try:
  if cache.exists():r=json.load(open(cache))
  else:r=fetch('https://www.wikidata.org/w/api.php',{'action':'wbgetentities','format':'json','ids':'|'.join(x['qid'] for _,x in batch),'props':'sitelinks','sitefilter':'frwiki'});cache.write_text(json.dumps(r))
  for code,x in batch:
   title=r.get('entities',{}).get(x['qid'],{}).get('sitelinks',{}).get('frwiki',{}).get('title',x['title']);titles[code]=title
 except Exception as e:
  print('entities fallback',str(e),flush=True)
  titles.update({k:v['title'] for k,v in batch})
for start in range(0,len(rows),1):
 batch=rows[start:start+1];cache=T/f'single_{start}.json'
 try:
  if cache.exists():r=json.load(open(cache))
  else:r=fetch('https://fr.wikipedia.org/w/api.php',{'action':'query','format':'json','prop':'extracts|revisions','explaintext':1,'exlimit':'max','rvprop':'ids|timestamp','redirects':1,'titles':'|'.join(titles[k] for k,_ in batch)});cache.write_text(json.dumps(r,ensure_ascii=False))
  redirects={x['from']:x['to'] for group in ['normalized','redirects'] for x in r.get('query',{}).get(group,[])}
  for code,x in batch:
   title=titles[code]
   for _ in range(4):title=redirects.get(title,title)
   page=next((p for p in r.get('query',{}).get('pages',{}).values() if p['title']==title and 'missing' not in p),None)
   if not page or len(page.get('extract',''))<100:errors.append(code);continue
   text=page['extract'];rev=page.get('revisions',[{}])[0]
   a[code]={'title':title,'text':text,'url':'https://fr.wikipedia.org/?curid='+str(page['pageid']),'history':'https://fr.wikipedia.org/w/index.php?title='+urllib.parse.quote(title)+'&action=history','license':'CC BY-SA 4.0','retrieved':'2026-11-17','revision_id':rev.get('revid'),'source_timestamp':rev.get('timestamp')}
   c[code]['wiki']=title
   print(code,'=>',title,len(text),flush=True)
 except Exception as e:errors.extend(k for k,_ in batch);print('batch failure',str(e),flush=True)
 time.sleep(.2)
for code in errors:
 # Honest geographic record if an encyclopaedic extract is unavailable.
 name=c[code]['name'];parent=c[c[code]['parent_code']]['name']
 a[code]={'title':name,'text':name+' est une unité géographique représentée séparément dans Natural Earth. Son rattachement cartographique est '+parent+'. Le tracé et le rattachement sont indicatifs ; ils ne tranchent pas les éventuelles revendications. Le texte encyclopédique détaillé n’a pas pu être enregistré dans cette édition.','url':meta['source'],'license':'Domaine public · Natural Earth','retrieved':'2026-11-17'}
(D/'countries.json').write_text(json.dumps(c,ensure_ascii=False,separators=(',',':')));(D/'articles.json').write_text(json.dumps(a,ensure_ascii=False,separators=(',',':')))
(T/'article_audit.json').write_text(json.dumps({'titles':titles,'missing':errors},ensure_ascii=False,indent=2))
print('FINISHED',len(rows)-len(errors),'articles, unavailable',errors,flush=True)
