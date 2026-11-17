"""Build robust fill triangles offline. Requires numpy, shapely, mapbox-earcut.
No dependency or triangulation service is needed on the device.
"""
from pathlib import Path
import json
import numpy as np
import shapely
from shapely.geometry import Polygon, LineString
import mapbox_earcut as earcut
ROOT=Path(__file__).resolve().parents[2]
source=json.loads((ROOT/'data/polygons.json').read_text())
meshes={}; lines={}; report={'countries':len(source),'rings':0,'repaired':0,'max_relative_area_error':0.0}
def polygons(g):
 if g.geom_type=='Polygon':return [g]
 return [p for x in getattr(g,'geoms',[]) for p in polygons(x)]
for entry in source:
 code=entry['code']; out={}; lod=[[],[],[]]
 for kind in ['outer','holes']:
  vertices=[];indices=[]
  for poly in entry['rings']:
   for ring in ([poly[0]] if kind=='outer' else poly[1:]):
    report['rings']+=1
    geom=Polygon(ring)
    if not geom.is_valid:
     report['repaired']+=1; geom=shapely.make_valid(geom)
    for piece in polygons(geom):
     if piece.area<1e-14:continue
     rs=[np.asarray(piece.exterior.coords)[:-1]]+[np.asarray(r.coords)[:-1] for r in piece.interiors]
     points=np.concatenate(rs); ends=np.cumsum([len(r) for r in rs]).astype(np.uint32)
     tri=earcut.triangulate_float64(points,ends)
     assert len(tri)>0,(code,kind)
     triangles=points[tri.reshape(-1,3)]
     a=triangles[:,1]-triangles[:,0]; b=triangles[:,2]-triangles[:,0]
     area=np.abs(a[:,0]*b[:,1]-a[:,1]*b[:,0]).sum()/2
     error=abs(area-piece.area)/piece.area
     assert error<1e-7,(code,error)
     report['max_relative_area_error']=max(report['max_relative_area_error'],error)
     offset=len(vertices)
     vertices.extend([[float(x),float(-y)] for x,y in points]); indices.extend((tri+offset).tolist())
  out[kind]={'vertices':vertices,'indices':indices}
 for poly in entry['rings']:
  for level,tolerance in enumerate([0.004,0.02,0.06]):
   coords=list(LineString(poly[0]).simplify(tolerance,preserve_topology=True).coords)
   for a,b in zip(coords,coords[1:]):lod[level].extend([[a[0],-a[1]],[b[0],-b[1]]])
 meshes[code]=out;lines[code]=lod
(ROOT/'tools/map23/meshes.json').write_text(json.dumps(meshes,separators=(',',':')))
(ROOT/'data/map_lines.json').write_text(json.dumps(lines,separators=(',',':')))
(ROOT/'tools/map23/validation.json').write_text(json.dumps(report,indent=2))
print(report)
