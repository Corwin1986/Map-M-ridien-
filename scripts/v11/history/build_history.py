"""Build sourced chronological accordions without inferring eras from arbitrary numbers.
Each body is a verbatim contiguous slice of its source, stripped only at its edges.
Headings stay in source order; nested subheadings remain inside the parent period.
Dedicated histories are preferred only when the country history lacks period headings.
"""
import json,re,hashlib
from manual_periods import PERIODS
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
OUT=Path(__file__).parent
DATA=ROOT/'data'
C=json.loads((DATA/'countries.json').read_text())
A=json.loads((DATA/'articles.json').read_text())
corrected=json.loads((OUT/'corrected_articles.json').read_text())
A.update(corrected)
dedicated=json.loads((OUT/'dedicated_articles.json').read_text()) if (OUT/'dedicated_articles.json').exists() else {}
LEVEL2=re.compile(r'(?m)^== ([^=\n]+) ==[ \t]*$')
LEVEL3=re.compile(r'(?m)^=== ([^=\n]+) ===[ \t]*$')
BACKMATTER={'notes et références','notes','références','sources','bibliographie','annexes','voir aussi','liens externes','compléments'}
result={};overrides=dict(corrected);audit={}
def sections(text,regex):
 hs=list(regex.finditer(text))
 return [(h[1].strip(),h.end(),hs[i+1].start() if i+1<len(hs) else len(text)) for i,h in enumerate(hs)]
def split_history(text,start,end):
 block=text[start:end];hs=sections(block,LEVEL3)
 if not hs:return '',[{'title':'Repères historiques','text':block.strip(),'source_start':start,'source_end':end}]
 first=LEVEL3.search(block).start()
 intro=block[:first].strip()
 return intro,[{'title':title,'text':block[s:e].strip(),'source_start':start+s,'source_end':start+e} for title,s,e in hs]
for code,c in C.items():
 article=A.get(code,{})
 text=article.get('text','')
 top=sections(text,LEVEL2)
 matched=[(title,s,e) for title,s,e in top if 'histoire' in title.lower()]
 article_key=code;basis='country_history';intro='';periods=[]
 if code=='ATA':
  selected=[x for x in top if x[0] in ['Conjecture liée à la forme de la Terre',"Découverte de l'Antarctique",'Exploration du continent','Vers un continent consacré à la science, à la paix et à la préservation']]
  periods=[{'title':title,'text':text[s:e].strip(),'source_start':s,'source_end':e} for title,s,e in selected]
  basis='country_historical_sections'
 else:
  for title,s,e in matched:
   pre,ps=split_history(text,s,e)
   if pre:intro+=('\n\n' if intro else '')+pre
   periods.extend(ps)
 # Dedicated articles are added only when they improve genuine historical structure.
 candidate=dedicated.get(code,{})
 ct=candidate.get('text','')
 ch=[x for x in sections(ct,LEVEL2) if x[0].lower() not in BACKMATTER]
 use_dedicated=candidate.get('title','').startswith('Histoire ') and len(ch)>1 and (not periods or all(p['title']=='Repères historiques' for p in periods))
 if use_dedicated:
  article=candidate;text=ct;article_key='history_'+code;basis='dedicated_history'
  top=sections(text,LEVEL2)
  periods=[]
  for title,s,e in top:
   if title.lower() in BACKMATTER:break
   periods.append({'title':title,'text':text[s:e].strip(),'source_start':s,'source_end':e})
  first=LEVEL2.search(text)
  intro=text[:first.start()].strip() if first else ''
  overrides[article_key]=article
 # For flat sources, reviewed paragraph anchors offer country-specific period titles.
 if code in PERIODS and len(periods)==1 and periods[0]['title']=='Repères historiques':
  start=periods[0]['source_start'];end=periods[0]['source_end'];block=text[start:end]
  spec=PERIODS[code];positions=[]
  for title,anchor in spec:
   pos=block.find(anchor) if anchor else 0
   assert pos>=0,(code,anchor)
   positions.append((title,start+pos))
  assert [p[1] for p in positions]==sorted(p[1] for p in positions),code
  periods=[{'title':title,'text':text[s:positions[i+1][1] if i+1<len(positions) else end].strip(),'source_start':s,'source_end':positions[i+1][1] if i+1<len(positions) else end} for i,(title,s) in enumerate(positions)]
  basis='reviewed_paragraph_periods'
 # Do not invent an era for empty source headings; retain their nested text if present.
 periods=[p for p in periods if p['text']]
 coverage='periods' if len(periods)>1 or (periods and periods[0]['title']!='Repères historiques') else 'overview' if periods else 'unavailable'
 note='Les périodes suivent le découpage de la source et varient selon les pays. Les frontières et les États ont changé au fil du temps.'
 if basis=='reviewed_paragraph_periods':note='Les titres de périodes ont été ajoutés pour faciliter la lecture. Le texte et son ordre sont conservés à partir de la source ; certains passages rappellent des événements antérieurs.'
 if coverage=='overview':note='La source présente ici une synthèse sans découpage en périodes. Le texte historique disponible est conservé intégralement.'
 if coverage=='unavailable':note='La copie disponible ne contient pas de rubrique historique distincte. Consultez la source pour poursuivre la recherche.'
 meta={k:v for k,v in article.items() if k!='text'}
 result[code]={'article_key':article_key,'source':meta,'text_sha256':hashlib.sha256(text.encode()).hexdigest(),'basis':basis,'intro':intro,'periods':periods,'coverage':coverage,'note':note}
 for p in periods:
  assert p['text']==text[p['source_start']:p['source_end']].strip(),(code,p['title'])
 audit[code]={'name':c['name'],'coverage':coverage,'basis':basis,'article_key':article_key,'titles':[p['title'] for p in periods],'characters':len(intro)+sum(len(p['text']) for p in periods)}
(DATA/'history_periods.json').write_text(json.dumps(result,ensure_ascii=False,separators=(',',':')))
(OUT/'history_articles.json').write_text(json.dumps(overrides,ensure_ascii=False,separators=(',',':')))
(OUT/'audit.json').write_text(json.dumps(audit,ensure_ascii=False,indent=2))
print('countries',len(result),'periods',sum(x['coverage']=='periods' for x in result.values()),'overview',sum(x['coverage']=='overview' for x in result.values()),'unavailable',sum(x['coverage']=='unavailable' for x in result.values()))
print('dedicated',sum(x['basis']=='dedicated_history' for x in result.values()),'source overrides',len(overrides),'period count',sum(len(x['periods']) for x in result.values()))
print('missing',[(k,C[k]['name']) for k,x in result.items() if x['coverage']=='unavailable'])
