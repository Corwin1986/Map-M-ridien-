"""Reproducible educational relief atlas. GEBCO 2025/GMT 2 arc-minute tiles.
Run download.py first. Images are derived data, not precision navigation maps.
"""
import json,math,re,glob
from pathlib import Path
import numpy as np
from scipy.ndimage import map_coordinates
from PIL import Image,ImageDraw,ImageFont
import rasterio
from pyproj import Transformer
APP=Path(__file__).resolve().parents[2]
OUT=APP/'assets/relief';OUT.mkdir(parents=True,exist_ok=True)
COUNTRIES=json.loads((APP/'data/countries.json').read_text())
POLYS=json.loads((APP/'data/polygons.json').read_text())
POLY={p['code']:p['rings'] for p in POLYS}
W,H=720,480
FONT=ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',16)
SMALL=ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',13)
DEM=np.zeros((5401,10801),dtype=np.int16)
for p in Path(__file__).parent.glob('*gebco*.jp2'):
 with rasterio.open(p) as d:
  lon=d.transform.c+1/60;lat=d.transform.f-1/60
  col=round((lon+180)*30);row=round((90-lat)*30)
  a=d.read(1);DEM[row:row+1801,col:col+1801]=a
# Exact selected-source terrestrial polygons separate sub-sea-level land from ocean.
LAND=np.zeros((5401,10801),dtype=np.uint8)
for poly in POLYS:
 land=Image.new('1',(10801,5401));draw=ImageDraw.Draw(land)
 for part in poly['rings']:
  for i,ring in enumerate(part):
   pts=[((x+180)*30,(90-y)*30) for x,y in ring]
   if len(pts)>2: draw.polygon(pts,fill=1 if i==0 else 0)
 LAND |= np.asarray(land,dtype=np.uint8)
COLORS=['#669b91','#8caf79','#b4c58a','#d5cc99','#d4b381','#bd906e','#a57866','#e8e5db']
BINS=[0,200,500,1000,2000,4000,6000]
PALETTE=np.array([tuple(bytes.fromhex(s[1:])) for s in COLORS],dtype=np.float32)
WATER=np.array([177,209,219],dtype=np.float32)
BORDER='#193b48'

def unwrap(x,center):return (np.asarray(x)-center+180)%360-180+center

def selected_parts(code):return POLY.get(code,[])

def intervals(code,parts,c):
 # Separate distant regions rather than stretching tiny mainland across oceans.
 if code=='USA':return [('États-Unis continentaux',lambda p: np.mean(np.array(p[0])[:,1])<50 and np.mean(np.array(p[0])[:,0])>-130),('Alaska',lambda p: np.mean(np.array(p[0])[:,1])>50),('Hawaï',lambda p: np.mean(np.array(p[0])[:,1])<30 and np.mean(np.array(p[0])[:,0])<-130)]
 if code=='FRA':return [('France métropolitaine',lambda p: np.mean(np.array(p[0])[:,1])>35),('Guyane',lambda p: np.mean(np.array(p[0])[:,1])<10)]
 if code=='CHL':return [('Chili continental',lambda p:np.mean(np.array(p[0])[:,0])>-80),('Île de Pâques',lambda p:np.mean(np.array(p[0])[:,0])<-100),('Archipel Juan Fernández',lambda p:-85<np.mean(np.array(p[0])[:,0])<-75 and np.mean(np.array(p[0])[:,1])>-36)]
 if code=='PRT':return [('Portugal continental',lambda p:np.mean(np.array(p[0])[:,0])>-12),('Açores',lambda p:np.mean(np.array(p[0])[:,0])<-20),('Madère',lambda p:-20<np.mean(np.array(p[0])[:,0])<-12)]
 if code=='ESP':return [('Espagne et Baléares',lambda p:np.mean(np.array(p[0])[:,1])>30),('Îles Canaries',lambda p:np.mean(np.array(p[0])[:,1])<30)]
 if code=='ECU':return [('Équateur continental',lambda p:np.mean(np.array(p[0])[:,0])>-85),('Galápagos',lambda p:np.mean(np.array(p[0])[:,0])<-85)]
 return [(c['name'],lambda p:True)]

def render(code,title,parts,index,c):
 coords=np.concatenate([np.array(p[0]) for p in parts]) if parts else np.array([[float(c['lon']),float(c['lat'])]])
 if code=='ATA':
  forward=Transformer.from_crs(4326,3031,always_xy=True);inverse=Transformer.from_crs(3031,4326,always_xy=True)
  xx,yy=forward.transform(coords[:,0],coords[:,1]);cx=cy=0.
  span=max(np.max(np.abs(xx)),np.max(np.abs(yy)))*2.2
  xmin,xmax=-span*W/H/2,span*W/H/2;ymin,ymax=-span/2,span/2
  X,Y=np.meshgrid(np.linspace(xmin,xmax,W),np.linspace(ymax,ymin,H));LON,LAT=inverse.transform(X,Y)
  def transform(ring):
   a=np.array(ring);x,y=forward.transform(a[:,0],a[:,1]);return np.column_stack(((x-xmin)/(xmax-xmin)*(W-1),(ymax-y)/(ymax-ymin)*(H-1)))
  mpp=(xmax-xmin)/W
  bounds=[-180,-90,180,-60]
 else:
  # Find circular longitude extent avoiding the antimeridian seam.
  lons=np.sort(coords[:,0]%360);gaps=np.diff(np.r_[lons,lons[0]+360]);cut=int(np.argmax(gaps));west=lons[(cut+1)%len(lons)];east=lons[cut]
  if east<west:east+=360
  center=(east+west)/2
  lons=unwrap(coords[:,0],center);south,north=float(coords[:,1].min()),float(coords[:,1].max())
  midlat=(south+north)/2;factor=max(.15,math.cos(math.radians(midlat)))
  width=max((east-west)*factor,1.2);height=max(north-south,.8)
  width*=1.17;height*=1.17
  if width/height<W/H:width=height*W/H
  else:height=width*H/W
  # Avoid going beyond poles; changes centre, preserves displayed scale.
  cy=min(90-height/2,max(-90+height/2,midlat))
  xmin,xmax=center-width/(2*factor),center+width/(2*factor);ymin,ymax=cy-height/2,cy+height/2
  LON,LAT=np.meshgrid(np.linspace(xmin,xmax,W),np.linspace(ymax,ymin,H))
  def transform(ring):
   a=np.asarray(ring);x=unwrap(a[:,0],center);return np.column_stack(((x-xmin)/(xmax-xmin)*(W-1),(ymax-a[:,1])/(ymax-ymin)*(H-1)))
  mpp=width*111195/W;bounds=[xmin,ymin,xmax,ymax]
 row=np.clip((90-LAT)*30,0,5400);col=((LON+180)%360)*30
 z=map_coordinates(DEM,[row,col],order=1,mode='nearest')
 is_land=map_coordinates(LAND,[row,col],order=0,mode='nearest').astype(bool)
 rgb=PALETTE[np.digitize(z,BINS)]
 rgb[~is_land]=WATER
 # Keep surroundings lighter so the selected territory remains legible.
 mask=Image.new('L',(W,H));md=ImageDraw.Draw(mask)
 for part in parts:
  for n,ring in enumerate(part):
   pts=transform(ring)
   if len(pts)>2 and np.max(np.abs(np.diff(pts[:,0])))<W*2:md.polygon([tuple(p) for p in pts],fill=255 if n==0 else 0)
 selected=np.asarray(mask)>0
 rgb[~selected]=rgb[~selected]*.60+np.array([239,239,226])*.40
 img=Image.fromarray(np.uint8(rgb));d=ImageDraw.Draw(img)
 # Country borders from same Natural Earth geometry as the app.
 for p in POLYS:
  if p['code']==code:continue
  for part in p['rings']:
   pts=transform(part[0]);
   if pts[:,0].max()<0 or pts[:,0].min()>W or pts[:,1].max()<0 or pts[:,1].min()>H:continue
   if np.max(np.abs(np.diff(pts[:,0])))<W: d.line([tuple(p) for p in pts],fill='#b7bdb1',width=1)
 for part in parts:
  for ring in part:
   pts=transform(ring)
   if len(pts)>1:
    segments=[pts]
    if code=='ATA':
     segments=[pts[i:i+2] for i in range(len(pts)-1) if min(ring[i][1],ring[i+1][1])>-89.9 and not (abs(ring[i][0])>179.99 and abs(ring[i+1][0])>179.99)]
    for segment in segments:
     d.line([tuple(p) for p in segment],fill='#fffaf0',width=4)
     d.line([tuple(p) for p in segment],fill=BORDER,width=2)
 tiny=np.count_nonzero(selected)<150
 if tiny:
  # Explicit locator only, not an invented outline or terrain measurement.
  p=transform([[float(c['lon']),float(c['lat'])]])[0];x,y=p
  if not (0<=x<W and 0<=y<H):x,y=W/2,H/2
  d.ellipse((x-7,y-7,x+7,y+7),outline=BORDER,width=2)
  d.line((x-11,y,x+11,y),fill=BORDER,width=1);d.line((x,y-11,x,y+11),fill=BORDER,width=1)
  note='Vue régionale : territoire repéré par un cercle. Le relief local est trop fin pour cette grille généralisée.'
 else:note=''
 # Legible north indicator and approximate centre-latitude scale.
 if code!='ATA':
  d.rounded_rectangle((W-45,12,W-12,69),radius=6,fill='#f4f2e8');d.text((W-34,15),'N',font=FONT,fill=BORDER);d.line((W-29,57,W-29,38),fill=BORDER,width=2);d.polygon([(W-34,44),(W-29,34),(W-24,44)],fill=BORDER)
 else:
  d.text((W//2-32,H//2),'Pôle Sud',font=SMALL,fill=BORDER,stroke_width=2,stroke_fill='#ffffff')
 target=mpp*130/1000
 magnitude=10**math.floor(math.log10(target))
 km=max([s*magnitude for s in [.1,.2,.5,1,2,5,10] if s*magnitude<=target])
 bar=round(km*1000/mpp);label=f'{km:g} km'
 d.rounded_rectangle((12,H-48,max(120,bar+36),H-9),radius=5,fill='#f4f2e8')
 d.line((24,H-21,24+bar,H-21),fill=BORDER,width=3);d.line((24,H-25,24,H-17),fill=BORDER,width=2);d.line((24+bar,H-25,24+bar,H-17),fill=BORDER,width=2)
 d.text((24,H-43),label,font=SMALL,fill=BORDER)
 fname=f'{code}'+(f'_{index}' if index else '')+'.webp';img.save(OUT/fname,'WEBP',quality=78,method=6)
 return {'title':title,'file':'res://assets/relief/'+fname,'bounds':[round(v,4) for v in bounds],'width':W,'height':H,'note':note,'projection':'Stéréographique polaire sud' if code=='ATA' else 'Équirectangulaire, parallèle local','scale_note':'Échelle indicative au centre de la carte'}

meta={'source':'GEBCO Compilation Group (2025), GEBCO 2025 Grid ; dérivé GMT earth_gebco_02m_g. Frontières : Natural Earth.','source_url':'https://www.generic-mapping-tools.org/remote-datasets/earth-gebco.html','license_url':'https://www.gebco.net/data-products/gridded-bathymetry/terms-of-use','data_url':'https://doi.org/10.5285/37c52e96-24ea-67ce-e063-7086abc05f29','license':'GEBCO : domaine public, réutilisation commerciale autorisée avec attribution. Natural Earth : domaine public.','description':'Altitude en mètres. Grille au pas de 2 minutes (~3,7 km à l’équateur), lissée sur environ 11 km. Carte pédagogique, non destinée à la navigation ; détails locaux et petits îlots non résolus. Les teintes sont atténuées hors du territoire sélectionné.','legend':[{'label':label,'color':col} for label,col in zip(['Sous 0 m (terres)','0 à 200 m','200 à 500 m','500 à 1 000 m','1 000 à 2 000 m','2 000 à 4 000 m','4 000 à 6 000 m','Plus de 6 000 m'],COLORS)]+[{'label':'Eaux (océans, lacs de la carte)','color':'#b1d1db'}],'outline_color':BORDER,'outline_label':'Contour du territoire sélectionné · frontières indicatives','year':2025}
result={'meta':meta,'countries':{}}
for n,(code,c) in enumerate(COUNTRIES.items()):
 parts=selected_parts(code);maps=[]
 for title,filter_fn in intervals(code,parts,c):
  chosen=[p for p in parts if filter_fn(p)]
  if parts and not chosen:continue
  maps.append(render(code,title,chosen,len(maps),c))
 note=''
 if code=='FRA':note='Métropole et Guyane dans ce découpage Natural Earth ; les autres territoires ultramarins disposent de leur propre fiche sur la carte.'
 if not parts:note='Localisation régionale : aucun contour détaillé disponible dans le fond de carte embarqué.'
 result['countries'][code]={'maps':maps,'note':note}
 if n%25==0:print(n,code,flush=True)
(APP/'data/relief_maps.json').write_text(json.dumps(result,ensure_ascii=False,separators=(',',':')))
print('COUNTRIES',len(result['countries']),'MAPS',sum(len(v['maps']) for v in result['countries'].values()),'BYTES',sum(p.stat().st_size for p in OUT.glob('*.webp')))
