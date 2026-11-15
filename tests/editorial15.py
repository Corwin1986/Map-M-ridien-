import json,collections,pathlib
r=pathlib.Path(__file__).resolve().parents[1]
read=lambda n:json.loads((r/'data'/n).read_text())
d,q,j=map(read,['discoveries.json','quiz.json','journeys.json']);countries=read('countries.json')
topics={'Géographie','Histoire','Gastronomie','Personnalités marquantes','Sport','Population','Religion','Langue','Économie','Militaire','Institutions','Conflits','Villes'}
assert len(d)==426 and len(q)==300 and len(j)>=6
assert len({x['id'] for x in d})==len(d) and len({x['id'] for x in q})==len(q)
for x in d+q+[s for route in j for s in route['steps']]:
 assert x['code'] in countries,(x.get('id'),x['code'])
 assert x['topic'] in topics,x['topic']
 assert x['sources'] and all(s['url'].startswith('https://') for s in x['sources'])
for x in q:assert len(set(x['options']))==4 and 0<=x['correct']<4
assert len([x for x in d if x.get('date')])==366
assert len({x['date'] for x in d if x.get('date')})==366
for x in d:assert x['body'].strip()
for route in j:
 assert 3<=len(route['steps'])<=5
 for step in route['steps']:
  linked=next(x for x in d if x['id']==step['discovery_id'])
  assert linked['code']==step['code'] and linked['topic']==step['topic']
print('EDITORIAL V15 PASS:',len(d),'discoveries,',len(q),'questions,',len(j),'routes,',sum(len(x['steps']) for x in j),'steps')
print('Question themes:',dict(collections.Counter(x['theme'] for x in q)))
