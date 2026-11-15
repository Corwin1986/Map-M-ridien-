"""Weekly research input. Does not label new events as new wars or publish to users."""
import urllib.request,urllib.parse,re,json,csv,io,datetime,hashlib
from pathlib import Path
base='https://ucdp.uu.se/downloads/'
headers={'User-Agent':'MeridienAtlas/1.2 editorial source monitoring'}
def get(url):return urllib.request.urlopen(urllib.request.Request(url,headers=headers),timeout=45).read()
def collect(output='pending-review'):
 out=Path(output);out.mkdir(parents=True,exist_ok=True)
 html=get(base+'index.html').decode('utf-8','replace')
 links=re.findall(r'''(?:href|src)=["']([^"']*GEDEvent_v\d+_\d+_\d+\.csv)["']''',html,re.I)
 if not links:raise RuntimeError('No Candidate CSV found: inspect the UCDP download page; no release has been generated.')
 def version(url):return tuple(map(int,re.search(r'v(\d+)_(\d+)_(\d+)',url).groups()))
 url=urllib.parse.urljoin(base,max(links,key=version));parts=urllib.parse.urlparse(url)
 if parts.scheme!='https' or parts.netloc!='ucdp.uu.se':raise RuntimeError('Unexpected source host')
 raw=get(url);rows=list(csv.DictReader(io.StringIO(raw.decode('utf-8-sig'))))
 countries=sorted(set(r.get('country','') for r in rows));periods=sorted(set((r.get('date_start','') or r.get('year',''))[:7] for r in rows))
 report={'source':url,'sha256':hashlib.sha256(raw).hexdigest(),'retrieved':datetime.datetime.now(datetime.timezone.utc).isoformat(),'rows':len(rows),'countries':countries,'periods':periods,'publication_status':'REQUIRES_EDITORIAL_REVIEW','instructions':'Events are not automatically distinct wars. Compare with the catalogue, verify chronology and independent sources, preserve citations, then prepare a reviewed data patch.'}
 (out/'ucdp_candidate.csv').write_bytes(raw);(out/'review.json').write_text(json.dumps(report,ensure_ascii=False,indent=2))
 print(json.dumps(report,ensure_ascii=False,indent=2))
if __name__=='__main__':collect()
