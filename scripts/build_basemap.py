import json,math
from pathlib import Path
from PIL import Image,ImageDraw
root=Path(__file__).resolve().parents[1]
polys=json.load(open(root/'data/polygons.json'));countries=json.load(open(root/'data/countries.json'))
size=(4096,2048)
def coord(p):return ((p[0]+180)*size[0]/360,(90-p[1])*size[1]/180)
for heat,name in [(False,'basemap'),(True,'population')]:
    im=Image.new('RGBA',size,(0,0,0,0));draw=ImageDraw.Draw(im)
    for entity in polys:
        col=(53,89,99,255)
        if heat:
            pop=countries[entity['code']].get('population') or 0
            t=max(0,min(1,math.log(max(pop,1))/20-.2))
            col=tuple(round(a+(b-a)*t) for a,b in zip((36,60,70),(198,171,116)))+(255,)
        for poly in entity['rings']:
            outer=[coord(p) for p in poly[0]]
            draw.polygon(outer,fill=col)
            draw.line(outer,fill=((94,120,123,255) if not heat else (77,99,101,255)),width=1,joint='curve')
            for hole in poly[1:]:draw.polygon([coord(p) for p in hole],fill=(0,0,0,0))
    im.save(root/('assets/'+name+'.png'),optimize=True)
print('Basemap textures generated')
