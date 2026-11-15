"""Conservative V11 domain audit. Never infer acting from generic CELEBRITY.
Uses retained Wikidata P106 snapshots for entertainment roles, editorial grouping.
Run from project workspace after audit.py. Preserves all entries and country links.
"""
import json,pathlib,collections
base=pathlib.Path(__file__).resolve().parents[3]/'data';out=pathlib.Path(__file__).parent
people=json.load(open(base/'people.json'))
scene_ids={'Q33999','Q4610556','Q18581305','Q10800557','Q131524','Q2259451','Q3282637','Q2405480','Q28389','Q947873','Q17307272','Q7358','Q47928','Q1371925','Q60723847','Q2045208','Q44508716'}
overrides={
'Q285563':('Exploration et société','Affaire historique et identité revendiquée','https://www.wikidata.org/wiki/Q285563'),
'Q482615':('Sciences et inventions','Ingénierie','https://www.wikidata.org/wiki/Q482615'),
'Q63477':('Sciences et inventions','Médecine dentaire','https://www.wikidata.org/wiki/Q63477'),
'Q171291':('Exploration et société','Témoin de la préhistoire','https://www.iceman.it/en/oetzi/the-iceman'),
'Q960901':('Musique','Clarinette','https://www.wikidata.org/wiki/Q960901'),
'Q28481203':('Exploration et société','Récitation coranique','https://www.wikidata.org/wiki/Q28481203'),
'Q447227':('Sport','Plongée en apnée','https://www.wikidata.org/wiki/Q447227'),
'Q87610':('Histoire et politique','Famille impériale japonaise','https://www.wikidata.org/wiki/Q87610'),
'Q328744':('Cinéma et scène','Production cinématographique','https://www.wikidata.org/wiki/Q328744'),
'Q438450':('Cinéma et scène','Création de costumes','https://www.wikidata.org/wiki/Q438450'),
'Q200817':('Arts et littérature','Peinture et commerce d’art','https://www.wikidata.org/wiki/Q200817'),
'Q215852':('Exploration et société','Témoin de l’âge du fer','https://www.wikidata.org/wiki/Q215852'),
'Q234125':('Exploration et société','Aristocratie et histoire de l’art','https://www.wikidata.org/wiki/Q234125'),
}
changes=[]
for p in people:
 old=p['group'];q=p['qid'];new=old;label=p['occupation_label'];source=''
 if p.get('occupation') in ('MAFIOSO','PIRATE'):
  new='Exploration et société';source=p['source_url']
 if p.get('occupation')=='CELEBRITY':
  f=out/'wikidata'/(q+'.json')
  if not f.exists():raise RuntimeError('Missing verification '+q)
  e=json.load(open(f))['entities'][q]
  roles={r['mainsnak'].get('datavalue',{}).get('value',{}).get('id') for r in e.get('claims',{}).get('P106',[])}
  new='Cinéma et scène' if roles & scene_ids else 'Exploration et société'
  source='https://www.wikidata.org/wiki/'+q
  if roles & {'Q33999','Q131524','Q10800557'}:label='Cinéma et télévision'
  elif roles & {'Q4610556','Q18581305'}:label='Mannequinat et concours de beauté'
  if q in overrides:new,label,source=overrides[q]
  desc=e.get('descriptions',{}).get('fr',{}).get('value','')
  if desc and not p.get('description'):p['description']=desc
  if not p.get('wiki'):p['wiki']=e.get('sitelinks',{}).get('frwiki',{}).get('title','')
  # Date/association are deliberately not rewritten from unreviewed claims.
  p['classification_source_url']=source
  p['classification_note']='Regroupement éditorial selon le parcours documenté ; la catégorie générique de notoriété ne désigne pas un métier.'
  p['occupation_label']=label
 if new!=old:
  p['group']=new
  changes.append({'qid':q,'name':p['name'],'code':p['code'],'before':old,'after':new,'source':source})
assert len({(p['code'],p['qid']) for p in people})==len(people)
(base/'people.json').write_text(json.dumps(people,ensure_ascii=False,separators=(',',':')))
countries=json.load(open(base/'countries.json'));groups=sorted(set(x['group'] for x in people));coverage={}
for code,c in countries.items():
 counts=collections.Counter(x['group'] for x in people if x['code']==code)
 coverage[code]={'name':c['name'],'profiles':sum(counts.values()),'groups':{g:counts[g] for g in groups}}
report={'profiles':len(people),'countries_with_profiles':sum(v['profiles']>0 for v in coverage.values()),'un_states_with_profiles':sum(countries[k].get('un',False) and v['profiles']>0 for k,v in coverage.items()),'corrections':changes,'coverage':coverage,'limitations':'Catalogue documentaire non exhaustif. Les catégories sans personnalité documentée restent vides; aucun nom inventé. L’appartenance à une catégorie est éditoriale et n’est pas une appréciation morale. Classement Pantheon ne signifie pas classement absolu d’importance.'}
(out/'audit_report.json').write_text(json.dumps(report,ensure_ascii=False,indent=2))
print('profiles',len(people),'corrections',len(changes),'countries',report['countries_with_profiles'])
