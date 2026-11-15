import struct,zipfile,sys
from pathlib import Path
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

path=Path(sys.argv[1]);dex=Path(sys.argv[2])
with zipfile.ZipFile(path) as z:items=[(i,z.read(i.filename)) for i in z.infolist() if not i.filename.startswith('META-INF/')]
result=[]
for info,b in items:
 if info.filename=='AndroidManifest.xml':
  chunks=[];pos=8
  while pos<len(b):
   typ,h,n=struct.unpack_from('<HHI',b,pos);c=b[pos:pos+n];chunks.append((typ,c));pos+=n
   if typ==1:strings,flags,header=read_pool(c)
   if typ==0x180:resources=list(struct.unpack_from('<'+'I'*((n-h)//4),c,h))
  def string(s):
   if s in strings:return strings.index(s)
   strings.append(s);return len(strings)-1
  ns=string('http://schemas.android.com/apk/res/android')
  def attribute(name,value,kind=3):
   ids={'name':0x01010003,'exported':0x01010010,'excludeFromRecents':0x01010017}
   i=string(name)
   while len(resources)<=i:resources.append(0)
   resources[i]=ids[name]
   v=string(value) if kind==3 else value
   return struct.pack('<IIIHBBI',ns,i,v if kind==3 else 0xffffffff,8,0,kind,v)
  def start(name,attrs=[]):
   return struct.pack('<HHIIIIIHHHHHH',0x102,16,36+20*len(attrs),0,0xffffffff,0xffffffff,string(name),20,20,len(attrs),0,0,0)+b''.join(attrs)
  def end(name):return struct.pack('<HHIIIII',0x103,16,24,0,0xffffffff,0xffffffff,string(name))
  permissions=b''
  for perm in ['android.permission.POST_NOTIFICATIONS','android.permission.RECEIVE_BOOT_COMPLETED']:
   permissions+=start('uses-permission',[attribute('name',perm)])+end('uses-permission')
  receiver=start('receiver',[attribute('name','fr.alexisuguz.meridien.discovery.DiscoveryNotifications'),attribute('exported',0,18)])+start('intent-filter')
  for action in ['android.intent.action.BOOT_COMPLETED','android.intent.action.TIME_SET','android.intent.action.TIMEZONE_CHANGED','android.intent.action.MY_PACKAGE_REPLACED']:
   receiver+=start('action',[attribute('name',action)])+end('action')
  receiver+=end('intent-filter')+end('receiver')
  activity=start('activity',[attribute('name','fr.alexisuguz.meridien.discovery.DiscoveryLinkActivity'),attribute('exported',0,18),attribute('excludeFromRecents',1,18)])+end('activity')
  parts=[]
  for typ,c in chunks:
   if typ==1:parts.append(write_pool(strings,flags,header));continue
   if typ==0x180:parts.append(struct.pack('<HHI',0x180,8,8+4*len(resources))+struct.pack('<'+'I'*len(resources),*resources));continue
   application=typ==0x102 and strings[struct.unpack_from('<I',c,20)[0]]=='application'
   if application:parts.append(permissions)
   parts.append(c)
   if application:parts.extend([receiver,activity])
  b=struct.pack('<HHI',3,8,8+sum(map(len,parts)))+b''.join(parts)
 result.append((info,b))
existing={i.filename for i,b in result};index=2
while 'classes%d.dex'%index in existing:index+=1
with zipfile.ZipFile(path.with_suffix('.native'),'w') as z:
 for info,b in result:z.writestr(info,b)
 z.writestr('classes%d.dex'%index,dex.read_bytes())
path.with_suffix('.native').replace(path)
print('Native notifications and Android manifest integrated')
