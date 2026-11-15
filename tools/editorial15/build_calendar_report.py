from pathlib import Path
import json,calendar,html,datetime,collections,csv
root=Path(__file__).parent
rows=[];missing=[]
for n in range(1,5):
 p=root/f'calendar_q{n}.json'
 if p.exists():
  data=json.loads(p.read_text());rows+=data if isinstance(data,list) else data.get('events',data.get('rows',[]))
 p=root/f'calendar_q{n}_missing.json'
 if p.exists():
  data=json.loads(p.read_text());missing+=data if isinstance(data,list) else data.get('missing',[])
overrides={r['date']:r for r in json.loads((root/'review_overrides.json').read_text())} if (root/'review_overrides.json').exists() else {}
rows=[overrides.get(r['date'],r) for r in rows]
rows.sort(key=lambda x:x['date']);assert len({x['date'] for x in rows})==len(rows),'Duplicate dates'
countries=json.loads(Path('v14_work/Meridien/data/countries.json').read_text())
all_dates=[f'{m:02}-{d:02}' for m in range(1,13) for d in range(1,calendar.monthrange(2024,m)[1]+1)]
for r in rows:
 assert r['date'] in all_dates,r
 assert r['code'] in countries,r
 assert r.get('url','').startswith('https://'),r
missing_dates=[d for d in all_dates if d not in {r['date'] for r in rows}]
months=['Janvier','Février','Mars','Avril','Mai','Juin','Juillet','Août','Septembre','Octobre','Novembre','Décembre']
esc=html.escape
cards=[]
for r in rows:
 m,d=map(int,r['date'].split('-'));country=countries[r['code']]['name'];summary=r.get('summary','')
 cards.append(f'<article data-month="{m}"><div class="date">{d} {months[m-1].lower()} · {esc(country)} · {esc(str(r["year"]))}</div><h3>{esc(r["title"])}</h3><p>{esc(summary)}</p><a target="_blank" rel="noopener" href="{esc(r["url"],quote=True)}">{esc(r.get("source_title","Source"))} ↗</a></article>')
gaps=[]
for m in range(1,13):
 ds=[str(int(x[3:])) for x in missing_dates if int(x[:2])==m]
 gaps.append(f'<tr><th>{months[m-1]}</th><td>{", ".join(ds) if ds else "Aucune date sans proposition"}</td></tr>')
page='''<!doctype html><html lang="fr"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Méridien · calendrier historique proposé</title><style>*{box-sizing:border-box}body{margin:0;background:#0b202a;color:#f3f0e7;font:17px/1.65 system-ui,sans-serif}main{max-width:950px;margin:auto;padding:24px}h1,h2,h3{font-family:Georgia,serif;font-weight:400}h1{font-size:34px}h3{margin:6px 0;font-size:23px}.muted{color:#b6c8ca}.count{color:#dcc187}article{background:#f3f0e7;color:#16303a;border-radius:16px;padding:24px;margin:16px 0}.date{font-size:14px;color:#5b7176}a{color:#78591c}select,input{padding:14px;font:inherit;max-width:100%;border-radius:10px;border:0;margin:5px 0}table{width:100%;border-collapse:collapse}th,td{text-align:left;padding:10px;border-bottom:1px solid #3c535c}th{width:140px}.filters{position:sticky;top:0;background:#0b202a;padding:10px 0}button{padding:10px;border:0;border-radius:8px}</style><main><p class="count">MÉRIDIEN · PROPOSITION ÉDITORIALE</p><h1>Un jour, un événement, un pays</h1><p>Calendrier examiné sur 366 dates, y compris le 29 février. Chaque proposition relie une date précise à un événement historique et à un pays directement concerné. Ce document prépare une évolution de l’application ; il ne constitue pas une nouvelle version installable.</p><p class="muted">Recherche du 15 novembre 2026. Une date laissée vide signifie qu’aucune proposition suffisamment pertinente et vérifiée n’a été retenue dans cette recherche, pas qu’aucun événement n’a jamais eu lieu ce jour-là.</p>'''
page+=f'<p class="count">{len(rows)} dates proposées · {len(missing_dates)} dates laissées sans suggestion · {len(set(r["code"] for r in rows))} pays ou territoires</p>'
page+='<h2>Dates sans suggestion retenue</h2><table>'+''.join(gaps)+'</table><h2>Les propositions sourcées</h2><div class="filters"><select id="month"><option value="">Toute l’année</option>'+''.join(f'<option value="{i+1}">{m}</option>' for i,m in enumerate(months))+'</select> <input id="search" type="search" placeholder="Pays, événement…" aria-label="Rechercher"></div>'+''.join(cards)
page+='''<script>const month=document.getElementById('month'),search=document.getElementById('search');function filter(){const q=search.value.toLocaleLowerCase('fr');document.querySelectorAll('article').forEach(a=>a.hidden=(month.value&&a.dataset.month!==month.value)||!a.textContent.toLocaleLowerCase('fr').includes(q));}month.onchange=filter;search.oninput=filter;</script></main></html>'''
out=Path('dist');out.mkdir(exist_ok=True)
(out/'Meridien_Calendrier_Historique_Propose.html').write_text(page)
(root/'calendar_all.json').write_text(json.dumps(rows,ensure_ascii=False,indent=2))
(root/'calendar_missing_dates.json').write_text(json.dumps(missing_dates))
print(len(rows),'retained',len(missing_dates),'missing',collections.Counter(r['code'] for r in rows).most_common(10))
