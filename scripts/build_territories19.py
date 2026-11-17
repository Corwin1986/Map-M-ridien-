import json,math,urllib.request,urllib.parse,time
from pathlib import Path
from collections import defaultdict
R=Path(__file__).resolve().parents[1];D=R/'data'
c=json.load(open(D/'territory_sources/base_countries.json'));a=json.load(open(D/'articles.json'));cities=json.load(open(D/'territory_sources/base_cities.json'))
w=json.load(open(D/'territory_sources/map_subunits.geojson'))
alias={'SDS':'SSD','KOS':'UNK','SAH':'ESH','PSX':'PSE','ALD':'ALA'}
sovs={'FR1':'FRA','GB1':'GBR','US1':'USA','AU1':'AUS','NZ1':'NZL','NL1':'NLD','FI1':'FIN','DN1':'DNK','CH1':'CHN','IS1':'ISR'}
# Non-island geographic partitions remain grouped under their existing country.
main={'KOX','KXI','CHX','INX','CHI','ZAX','RUA','RUE','ITX','TLP','TLX','ESX','ECD','RUK','USB','GNR','USK','RUC','ATB','AUZ','JPX','FSA','GGG','IOD','SGX','SGG','ATS','ATP','KOD'}
# Map-unit island groups not already identified by their own ISO record.
island_units={'PMD','PAZ','TZZ','PNB','NJM','ACA','ACB','JQI','DQI','FQI','HQI','WQI','MQI','BQI','LQI','KQI'}
new={};polys=defaultdict(list);meta={};sources=[]
def simp(points,eps=.006):
 if len(points)<=8:return points
 pts=points[:-1] if points[0]==points[-1] else points
 # Split the closed ring at the farthest vertex, avoiding a degenerate baseline.
 k=max(range(1,len(pts)),key=lambda i:(pts[i][0]-pts[0][0])**2+(pts[i][1]-pts[0][1])**2)
 def rdp(q):
  keep={0,len(q)-1};stack=[(0,len(q)-1)]
  while stack:
   l,h=stack.pop();ax,ay=q[l];bx,by=q[h];dx=bx-ax;dy=by-ay;den=dx*dx+dy*dy
   far=-1;best=eps*eps
   for i in range(l+1,h):
    x,y=q[i];t=max(0,min(1,((x-ax)*dx+(y-ay)*dy)/den)) if den else 0
    d=(x-ax-t*dx)**2+(y-ay-t*dy)**2
    if d>best:best=d;far=i
   if far>=0:keep.add(far);stack.extend([(l,far),(far,h)])
  return [q[i] for i in sorted(keep)]
 out=rdp(pts[:k+1])+rdp(pts[k:]+[pts[0]])[1:]
 if len(out)<4:return points
 return out
for f in w['features']:
 p=f['properties'];adm=alias.get(p['ADM0_A3'],p['ADM0_A3']);su=p['SU_A3'];gu=alias.get(p['GU_A3'],p['GU_A3']);iso=p.get('ISO_A3')
 code=adm
 if iso in c and iso!=adm:code=iso
 if gu in c and gu!=adm:code=gu
 if su in c and su!=adm:code=su
 if (p.get('SU_DIF') and su not in main) or su in island_units:code=su
 if su=='NSV':code='SJM'
 code=alias.get(code,code)
 if code not in c:
  # Unrelated disputed/continental map units stay with the existing administrative entity.
  if not ((p.get('SU_DIF') and su not in main) or su in island_units):
   if adm not in c:continue
   code=adm
  else:
   parent=sovs.get(p['SOV_A3'],p['SOV_A3']);parent=parent if parent in c else adm
   name=p.get('NAME_FR') or p['NAME']
   c[code]={'code':code,'iso2':c.get(parent,{}).get('iso2',''),'name':name,'en':p['NAME'],'official':name,'capital':'Non renseignée','area':0,'languages':[],'currency':'Non renseignée','region':c.get(adm,{}).get('region',''),'borders':[],'lat':p['LABEL_Y'],'lon':p['LABEL_X'],'label':[p['LABEL_X'],p['LABEL_Y']],'population':p['POP_EST'] if p['POP_EST']>=0 else None,'pop_year':p['POP_YEAR'] if p['POP_EST']>=0 else None,'pop_source':'Natural Earth · sous-unité cartographique','gdp':0,'gdp_year':0,'un':False,'independent':False,'cities':[],'wiki':name,'parent_code':parent,'territory':True,'disputed':bool(p.get('BRK_DIFF'))}
   new[code]={'title':name,'qid':p.get('WIKIDATAID'),'parent':parent}
 if code!=adm or (not c[code].get('independent') and code not in ['ATA','PSE','UNK','TWN','ESH','CYN','SOL','KAS']):
  parent=sovs.get(p['SOV_A3'],p['SOV_A3'])
  if parent==code:parent=adm
  if parent in c and parent!=code:
   c[code]['parent_code']=parent;c[code]['territory']=True
   meta[code]={'parent_code':parent,'territory':True}
 if code in ['GUF','GLP','MTQ','REU','MYT'] and c[code]['population'] is None:
  c[code].update(population=p['POP_EST'],pop_year=p['POP_YEAR'],pop_source='Natural Earth · unité cartographique')
 geom=f['geometry'];rings=geom['coordinates'] if geom['type']=='MultiPolygon' else [geom['coordinates']]
 for poly in rings:polys[code].append([[[round(x,5),round(y,5)] for x,y,*_ in simp(ring)] for ring in poly])
 sources.append({'code':code,'su':su,'qid':p.get('WIKIDATAID'),'admin':adm,'name':p['NAME']})
# Preserve old aggregate IDs and old saved bookmarks; no records are deleted.
c['ALD']['alias_of']='ALA';c['ALA']['name']='Åland';c['ALA']['parent_code']='FIN';c['ALA']['territory']=True
c['VAT']['un']=False
c['PMD']['capital']='Funchal'
# Resolve each city against its territory polygons, rather than inheriting the state.
def inside(pt,ring):
 x,y=pt;hit=False
 for i in range(len(ring)):
  a=ring[i-1];b=ring[i]
  if (a[1]>y)!=(b[1]>y) and x<(b[0]-a[0])*(y-a[1])/(b[1]-a[1])+a[0]:hit=not hit
 return hit
bounds={k:[(min(p[0] for p in poly[0]),min(p[1] for p in poly[0]),max(p[0] for p in poly[0]),max(p[1] for p in poly[0]),poly) for poly in v] for k,v in polys.items() if c[k].get('territory')}
citymap={}
for city in cities:
 x,y=city['lon'],city['lat']
 for code,parts in bounds.items():
  if any(l<=x<=rr and b<=y<=t and inside((x,y),poly[0]) and not any(inside((x,y),hole) for hole in poly[1:]) for l,b,rr,t,poly in parts):
   city['code']=code;citymap[str(city['id'])]=code;break
for code in c:c[code]['cities']=[str(v['id']) for v in cities if v['code']==code]
# Existing entities whose label falls in a remote component use their metropolitan centre.
for code in ['FRA','PRT','ESP','NLD','NOR','FIN','USA','AUS','JPN','NZL']:
 c[code]['label']=[c[code]['lon'],c[code]['lat']]
for name,data in [('countries',c),('polygons',[{'code':k,'rings':v} for k,v in polys.items()]),('cities',cities),('territories',{'meta':meta,'city_codes':citymap,'new':new,'source':'https://www.naturalearthdata.com/downloads/10m-cultural-vectors/10m-admin-0-details/','units':sources})]:
 (D/(name+'.json')).write_text(json.dumps(data,ensure_ascii=False,separators=(',',':')))
print('Countries',len(c),'new islands',len(new),'polygon entities',len(polys),'territory metadata',len(meta),'city remaps',len(citymap),flush=True)
print('New',new,flush=True)
