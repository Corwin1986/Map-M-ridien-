"""Final identity checks and content coverage; no approximate city homonym matching."""
import json,zipfile
from pathlib import Path
D=Path(__file__).resolve().parents[1]/'data';C=D/'source_v12/cache'
arts=json.load(open(D/'articles.json'));cities=json.load(open(D/'cities.json'));people=json.load(open(D/'people.json'));entities={}
for p in C.glob('entities_*.json'):entities.update(json.load(open(p)).get('entities',{}))
# The pre-update corpus is kept separately for identity-safe retention.
original=json.load(open(D/'source_v12/original_article_keys.json'))
removed=[]
for city in cities:
 key='city_'+city['id']
 if key in original:continue
 e=entities.get(city.get('qid',''),{})
 if not e.get('sitelinks',{}).get('frwiki'):
  removed.append(city['name']);arts[key]={'title':city['name'],'retrieved':'2026-11-14','scope':'missing','url':'https://www.wikidata.org/wiki/'+city['qid'] if str(city.get('qid') or '').startswith('Q') else 'https://fr.wikipedia.org/w/index.php?search='+city['name'].replace(' ','%20')}
for p in C.glob('fullfood_*.json'):arts['food_'+p.stem.split('_',1)[1]]=json.load(open(p))
# Reuse full context already included for contemporary conflicts when it is the same article.
full={a.get('url'):a for a in arts.values() if a.get('scope')!='intro' and a.get('text')}
for key,a in list(arts.items()):
 if a.get('scope')=='intro' and a.get('url') in full:arts[key]=full[a['url']]
cs=json.load(open(D/'countries.json'));wars=json.load(open(D/'conflict_history.json'));foods=json.load(open(D/'cuisines.json'))
for city in cities:
 assert city['code'] in cs and -90<=city['lat']<=90 and -180<=city['lon']<=180
for p in people:assert p['code'] in cs and p['qid'].startswith('Q')
for war in wars:assert set(war['codes'])<=set(cs) and (war['end'] is None or war['end']>=war['start'])
report={'cities':len(cities),'cities_with_text':sum(bool(arts.get('city_'+c['id'],{}).get('text')) for c in cities),'people':len(people),'people_with_text':sum(bool(arts.get(p.get('article',''),{}).get('text')) for p in people),'conflicts':len(wars),'conflicts_with_text':sum(bool(arts.get(w['article'],{}).get('text')) for w in wars),'cuisine_catalogues':len(foods),'cuisines_with_text':sum(bool(arts.get(f['article'],{}).get('text')) for f in foods.values()),'articles_with_text':sum(bool(a.get('text')) for a in arts.values()),'ambiguous_city_titles_excluded':removed,'missing_wars':[(w['id'],w['wiki']) for w in wars if not arts.get(w['article'],{}).get('text')],'missing_cuisines':[(c,f['wiki']) for c,f in foods.items() if not arts.get(f['article'],{}).get('text')]}
(D/'articles.json').write_text(json.dumps(arts,ensure_ascii=False,separators=(',',':')))
(D/'coverage.json').write_text(json.dumps(report,ensure_ascii=False,indent=2))
print(json.dumps(report,ensure_ascii=False,indent=2))
