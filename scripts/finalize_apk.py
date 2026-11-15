"""Fix AndroidX authority in an APK exported from the reused Gradle template.
Run before zipalign and apksigner. Does not modify the app's own FileProvider.
"""
import struct,zipfile,sys
from pathlib import Path
path=Path(sys.argv[1])
def read_pool(chunk):
    typ,h,size=struct.unpack_from('<HHI',chunk);count,styles,flags,start,ss=struct.unpack_from('<IIIII',chunk,8)
    assert typ==1 and styles==0
    strings=[]
    def ulen(at):
        a=chunk[at]
        return (((a&127)<<8)|chunk[at+1],at+2) if a&128 else (a,at+1)
    for i in range(count):
        off=struct.unpack_from('<I',chunk,h+4*i)[0];at=start+off
        if flags&256:
            _,at=ulen(at);length,at=ulen(at);s=chunk[at:at+length].decode('utf8')
        else:
            length=struct.unpack_from('<H',chunk,at)[0];assert length<32768;s=chunk[at+2:at+2+length*2].decode('utf-16le')
        strings.append(s)
    return strings,flags,h
def write_pool(strings,flags,h):
    data=bytearray();offsets=[]
    def enc_len(n):return bytes([n]) if n<128 else bytes([(n>>8)|128,n&255])
    for s in strings:
        offsets.append(len(data))
        if flags&256:
            raw=s.encode('utf8');data+=enc_len(len(s.encode('utf-16le'))//2)+enc_len(len(raw))+raw+b'\0'
        else:
            raw=s.encode('utf-16le');data+=struct.pack('<H',len(raw)//2)+raw+b'\0\0'
    data+=b'\0'*((-len(data))%4);start=h+len(strings)*4
    return struct.pack('<HHIIIIII',1,h,start+len(data),len(strings),0,flags,start,0)+b''.join(struct.pack('<I',v) for v in offsets)+data
with zipfile.ZipFile(path) as z:items=[(i,z.read(i.filename)) for i in z.infolist()]
out=[];patched=0
for info,b in items:
    if info.filename.startswith('META-INF/'):continue
    if info.filename=='AndroidManifest.xml':
        p=8;chunks=[];strings=[];flags=0;header=28
        while p<len(b):
            typ,h,n=struct.unpack_from('<HHI',b,p);chunk=bytearray(b[p:p+n])
            if typ==1:strings,flags,header=read_pool(chunk)
            chunks.append((typ,chunk));p+=n
        for typ,chunk in chunks:
            if typ!=0x102:continue
            name_idx=struct.unpack_from('<I',chunk,20)[0]
            if strings[name_idx]!='provider':continue
            attr_start,attr_size,attr_count=struct.unpack_from('<HHH',chunk,24)
            attrs=[16+attr_start+i*attr_size for i in range(attr_count)]
            is_androidx=any(strings[struct.unpack_from('<I',chunk,a+4)[0]]=='name' and chunk[a+15]==3 and strings[struct.unpack_from('<I',chunk,a+16)[0]]=='androidx.startup.InitializationProvider' for a in attrs)
            if not is_androidx:continue
            for a in attrs:
                if strings[struct.unpack_from('<I',chunk,a+4)[0]]=='authorities':
                    idx=len(strings);strings.append('fr.alexisuguz.meridien.androidx-startup')
                    struct.pack_into('<I',chunk,a+8,idx);struct.pack_into('<I',chunk,a+16,idx);patched+=1
        all_chunks=[write_pool(strings,flags,header) if t==1 else bytes(c) for t,c in chunks]
        b=struct.pack('<HHI',3,8,8+sum(map(len,all_chunks)))+b''.join(all_chunks)
    out.append((info,b))
assert patched==1,patched
tmp=path.with_suffix('.tmp')
with zipfile.ZipFile(tmp,'w') as z:
    for info,b in out:z.writestr(info,b)
tmp.replace(path)
print('AndroidX provider fixed; sign APK after this step.')
