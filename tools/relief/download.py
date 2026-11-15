from pathlib import Path
import urllib.request,re,concurrent.futures
root=Path(__file__).parent
base='https://oceania.generic-mapping-tools.org/server/earth/earth_gebco/earth_gebco_02m_g/'
names=re.findall(r'href="([^"]+\.jp2)"',(root/'index.html').read_text())
def get(n):
 p=root/n
 if not p.exists(): urllib.request.urlretrieve(base+n,p)
 return n,p.stat().st_size
with concurrent.futures.ThreadPoolExecutor(max_workers=5) as ex:
 for r in ex.map(get,names): print(*r,flush=True)
