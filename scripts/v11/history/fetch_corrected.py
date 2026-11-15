import json,urllib.request,urllib.parse
from pathlib import Path
out=Path(__file__).parent
T={'CYP':'Chypre (pays)','ECU':'Équateur (pays)','BLM':'Saint-Barthélemy (Antilles françaises)','MSR':'Montserrat (Antilles)','REU':'La Réunion'}
res={}
for code,title in T.items():
 u='https://fr.wikipedia.org/w/api.php?'+urllib.parse.urlencode({'action':'query','format':'json','prop':'extracts|revisions','explaintext':1,'rvprop':'ids|timestamp','redirects':1,'titles':title})
 try:
  d=json.load(urllib.request.urlopen(urllib.request.Request(u,headers={'User-Agent':'MeridienAtlas/11.0 (educational atlas; attributed Wikimedia content)'}),timeout=30))
  for a in d.get('query',{}).get('pages',{}).values():
   if a.get('extract'):
    rev=a.get('revisions',[{}])[0]
    res[code]={'title':a['title'],'pageid':a['pageid'],'text':a['extract'],'url':'https://fr.wikipedia.org/?curid='+str(a['pageid']),'history':'https://fr.wikipedia.org/w/index.php?title='+urllib.parse.quote(a['title'])+'&action=history','license':'CC BY-SA 4.0','retrieved':'2026-11-15','revision_id':rev.get('revid',0),'source_timestamp':rev.get('timestamp','')}
  print(code,len(res.get(code,{}).get('text','')),flush=True)
 except Exception as e:print(code,type(e).__name__,str(e)[:100],flush=True)
(out/'corrected_articles.json').write_text(json.dumps(res,ensure_ascii=False,separators=(',',':')))
