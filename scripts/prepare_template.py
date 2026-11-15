"""Restore a reusable Godot Android template and install Meridien launcher assets."""
import zipfile,struct,io
from pathlib import Path
from PIL import Image,ImageDraw
root=Path(__file__).resolve().parents[1]
path=root/'tools/android_debug_template.apk'
im=Image.new('RGBA',(768,768),'#0b202a');d=ImageDraw.Draw(im)
d.ellipse((136,136,632,632),outline='#d8bd82',width=18)
d.ellipse((272,136,496,632),outline='#d8bd82',width=16)
for y in [240,384,528]:
    x=184 if y!=384 else 136
    d.line((x,y,768-x,y),fill='#d8bd82',width=16)
d.ellipse((460,228,532,300),fill='#f1e8d6')
im.resize((192,192),Image.Resampling.LANCZOS).save(root/'assets/launcher.png')
with zipfile.ZipFile(path) as z:items=[(i,z.read(i.filename)) for i in z.infolist()]
out=[]
for info,b in items:
    if info.filename.startswith('META-INF/'):continue
    if info.filename=='resources.arsc':
        pos=12;t,h,n=struct.unpack_from('<HHI',b,pos);count,styles,flags,start,ss=struct.unpack_from('<IIIII',b,pos+8)
        assert t==1 and flags==0 and styles==0
        pool=b[pos:pos+n];data=bytearray();offsets=[];changed=0
        for i in range(count):
            off=struct.unpack_from('<I',pool,h+4*i)[0];at=start+off;length=struct.unpack_from('<H',pool,at)[0];assert length<32768
            s=pool[at+2:at+2+length*2].decode('utf-16le')
            if s in ['Village vs Chenapan','Méridien'] or s.startswith('Turbulence 1.'):
                s='godot-project-name';changed+=1
            raw=s.encode('utf-16le');offsets.append(len(data));data+=struct.pack('<H',len(raw)//2)+raw+b'\0\0'
        data+=b'\0'*((-len(data))%4)
        new=bytearray(pool[:start])+data;struct.pack_into('<I',new,4,len(new))
        for i,off in enumerate(offsets):struct.pack_into('<I',new,h+4*i,off)
        result=bytearray(b[:pos])+new+b[pos+n:];struct.pack_into('<I',result,4,len(result));b=bytes(result)
        print(changed,'labels restored')
    if info.filename.startswith('res/mipmap-') and info.filename.endswith('.webp'):
        original=Image.open(io.BytesIO(b));size=original.size
        if 'background' in info.filename:icon=Image.new('RGBA',size,'#0b202a')
        elif 'foreground' in info.filename:
            icon=Image.new('RGBA',size,(0,0,0,0));small=im.resize((int(size[0]*.68),int(size[1]*.68)),Image.Resampling.LANCZOS);icon.alpha_composite(small,((size[0]-small.width)//2,(size[1]-small.height)//2))
        else:icon=im.resize(size,Image.Resampling.LANCZOS)
        buf=io.BytesIO();icon.save(buf,'WEBP',lossless=True);b=buf.getvalue()
    out.append((info,b))
tmp=path.with_suffix('.tmp')
with zipfile.ZipFile(tmp,'w') as z:
    for info,b in out:z.writestr(info,b)
tmp.replace(path)
