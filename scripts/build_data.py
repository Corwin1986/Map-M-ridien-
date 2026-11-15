import json, urllib.request, urllib.parse, concurrent.futures, os, time, re, csv, collections, threading
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
DATA=ROOT/'data'; CACHE=ROOT.parent/'wiki_cache'; CACHE.mkdir(exist_ok=True)
UA={'User-Agent':'MeridienAtlas/1.0 (educational offline atlas; Wikimedia content with attribution)'}
rate_lock=threading.Lock()
next_request=0.0
def fetch(url):
    global next_request
    with rate_lock:
        delay=next_request-time.monotonic()
        if delay>0:time.sleep(delay)
        next_request=time.monotonic()+2.5
    return urllib.request.urlopen(urllib.request.Request(url,headers=UA),timeout=25).read()
facts=json.load(open(DATA/'facts_raw.json'))
world=json.load(open(DATA/'world.json'))
cities_raw=json.load(open(DATA/'cities_raw.json'))
wb=json.load(open(DATA/'wb_raw.json'))[1]
wb={x['countryiso3code']:x for x in wb if x['value'] is not None}
lang={'English':'anglais','French':'français','Arabic':'arabe','Spanish':'espagnol','Portuguese':'portugais','German':'allemand','Chinese':'chinois','Mandarin Chinese':'mandarin','Japanese':'japonais','Korean':'coréen','Turkish':'turc','Russian':'russe','Italian':'italien','Dutch':'néerlandais','Greek':'grec','Hindi':'hindi','Bengali':'bengali','Urdu':'ourdou','Persian (Farsi)':'persan','Persian':'persan','Swahili':'swahili','Indonesian':'indonésien','Malay':'malais','Vietnamese':'vietnamien','Thai':'thaï','Burmese':'birman','Polish':'polonais','Ukrainian':'ukrainien','Hebrew':'hébreu','Amharic':'amharique','Somali':'somali','Pashto':'pachto','Dari':'dari','Danish':'danois','Swedish':'suédois','Norwegian':'norvégien','Finnish':'finnois','Icelandic':'islandais','Romanian':'roumain','Hungarian':'hongrois','Czech':'tchèque','Slovak':'slovaque','Serbian':'serbe','Croatian':'croate','Albanian':'albanais','Bulgarian':'bulgare','Armenian':'arménien','Georgian':'géorgien'}
regions={'Africa':'Afrique','Europe':'Europe','Asia':'Asie','Americas':'Amériques','Oceania':'Océanie','Antarctic':'Antarctique','Antarctica':'Antarctique','North America':'Amérique du Nord','South America':'Amérique du Sud','Seven seas (open ocean)':'Océans'}
countries={}
for f in facts:
    code=f['cca3']; name=f.get('translations',{}).get('fra',{}).get('common',f['name']['common'])
    countries[code]={'code':code,'iso2':f['cca2'].lower(),'name':name,'en':f['name']['common'],'official':f.get('translations',{}).get('fra',{}).get('official',name),'capital':', '.join(f['capital']) or 'Sans capitale permanente','area':f['area'],'languages':[lang.get(x,x) for x in f['languages'].values()],'currency':', '.join(f['currencies'].keys()),'region':regions.get(f['region'],f['region']),'borders':f['borders'],'lat':f['latlng'][0] if f['latlng'] else 0,'lon':f['latlng'][1] if f['latlng'] else 0,'population':None,'pop_year':None,'pop_source':'Non disponible','un':f.get('unMember',False),'independent':f.get('independent',False),'cities':[]}
aliases={'SDS':'SSD','KOS':'UNK','SAH':'ESH','PSX':'PSE'}
polygons=[]
for feat in world['features']:
    p=feat['properties']; code=p['ADM0_A3'];code=aliases.get(code,code)
    if code not in countries:
        countries[code]={'code':code,'iso2':p.get('ISO_A2','').lower(),'name':p.get('NAME_FR') or p['NAME'],'en':p['ADMIN'],'official':p.get('FORMAL_FR') or p['ADMIN'],'capital':'Non renseignée','area':0,'languages':[],'currency':'Non renseignée','region':regions.get(p['CONTINENT'],p['CONTINENT']),'borders':[],'lat':p['LABEL_Y'],'lon':p['LABEL_X'],'un':False,'independent':False,'cities':[]}
    c=countries[code]; c['label']=[p['LABEL_X'],p['LABEL_Y']];c['population']=p['POP_EST'] if p['POP_EST']>0 else None;c['pop_year']=p['POP_YEAR'];c['pop_source']='Natural Earth';c['gdp']=p.get('GDP_MD',0);c['gdp_year']=p.get('GDP_YEAR',0);c['disputed']=bool(p['BRK_DIFF']) or code in ['PSE','ISR','ESH','TWN','UNK','CYN','SOL']
    geom=feat['geometry'];rings=geom['coordinates'] if geom['type']=='MultiPolygon' else [geom['coordinates']]
    polygons.append({'code':code,'rings':[[[[round(v,4) for v in pt] for pt in ring] for ring in poly] for poly in rings]})
for code,c in countries.items():
    if code in wb:c['population']=wb[code]['value'];c['pop_year']=int(wb[code]['date']);c['pop_source']='Banque mondiale · SP.POP.TOTL'
cities=[]
for feat in cities_raw['features']:
    p=feat['properties']; code=aliases.get(p['ADM0_A3'],p['ADM0_A3'])
    if code not in countries:continue
    city={'id':str(p['NE_ID']),'name':p.get('NAME_FR') or p['NAME'],'en':p['NAME'],'code':code,'capital':p['NAME'] in next((f['capital'] for f in facts if f['cca3']==code),[]),'lat':p['LATITUDE'],'lon':p['LONGITUDE']}
    cities.append(city);countries[code]['cities'].append(city['id'])
for c in countries.values():
    if 'label' not in c:c['label']=[c['lon'],c['lat']]
    c.setdefault('population',None);c.setdefault('pop_year',None);c.setdefault('pop_source','Non disponible');c.setdefault('gdp',0);c.setdefault('gdp_year',0)
    # French capital labels from the cartographic dataset.
    original_caps=next((f['capital'] for f in facts if f['cca3']==c['code']),[])
    caps=[next((x['name'] for x in cities if x['code']==c['code'] and x['en']==cap),cap) for cap in original_caps]
    if caps:c['capital']=', '.join(caps)
countries['SOL']['capital']='Hargeisa'
countries['PSE']['capital']='Jérusalem-Est (revendiquée) ; administration à Ramallah'
countries['ISR']['capital']='Jérusalem (statut international contesté)'
countries['UKR']['capital']='Kyiv'
countries['KAZ']['capital']='Astana'
countries['LKA']['capital']='Sri Jayawardenapura Kotte ; Colombo'
countries['BOL']['capital']='Sucre ; siège du gouvernement à La Paz'
for city in cities:
    if city['code']=='SOL' and city['en']=='Hargeisa':city['capital']=True
    if city['name']=='Noursoultan':city['name']='Astana';city['capital']=True
    if city['name']=='Kiev':city['name']='Kyiv';city['capital']=True
wiki_overrides={'SXM':'Saint-Martin (royaume des Pays-Bas)','IOA':"Territoires australiens de l'océan Indien",'DMA':'Dominique (pays)','IRL':'Irlande (pays)','MAF':'Saint-Martin (Antilles françaises)','GEO':'Géorgie (pays)','COM':'Comores (pays)','GRD':'Grenade (pays)','CXR':'Île Christmas (Australie)','PLW':'Palaos','USA':'États-Unis','GBR':'Royaume-Uni','COD':'République démocratique du Congo','COG':'République du Congo','CIV':"Côte d’Ivoire",'TUR':'Turquie','VAT':'Vatican','PSE':'Palestine (État)','MMR':'Birmanie','KOR':'Corée du Sud','PRK':'Corée du Nord','FSM':'États fédérés de Micronésie','CPV':'Cap-Vert','TLS':'Timor oriental','SWZ':'Eswatini','CYN':'Chypre du Nord','UNK':'Kosovo'}
city_overrides={'Valence':'Valence (Espagne)','Canton':'Canton (Chine)','Salvador':'Salvador (Bahia)','Hyderabad':'Hyderabad','Dubaï':'Dubaï (ville)','Saint-Marin':'Saint-Marin (ville)','Abou Dabi':'Abou Dabi (ville)','Guatemala-Ville':'Guatemala (ville)','Roseau':'Roseau (ville)','Luxembourg':'Luxembourg (ville)','Djibouti':'Djibouti (ville)','Panama':'Panama (ville)','Koweït':'Koweït (ville)','Tripoli':'Tripoli (Libye)','Sucre':'Sucre (Bolivie)',"Saint John's":"Saint John's",'Port-Louis':'Port-Louis (Maurice)','Nassau':'Nassau (Bahamas)','São Tomé':'São Tomé (ville)','Moroni':'Moroni (Comores)','San Salvador':'San Salvador (Salvador)','Victoria':'Victoria (Seychelles)','San José':'San José (Costa Rica)','San Juan':'San Juan (Porto Rico)','Saint-Georges':'Saint-Georges (Grenade)','Kingston':'Kingston (Jamaïque)','Georgetown':'Georgetown (Guyana)','Santiago':'Santiago','La Paz':'La Paz','Washington':'Washington (district de Columbia)','Saint-Domingue':'Saint-Domingue (ville)'}
requests=[]
for c in countries.values():
    c['wiki']=wiki_overrides.get(c['code'],c['name']);requests.append((c['code'],c['wiki']))
for c in cities:
    c['wiki']=city_overrides.get(c['name'],c['name']);requests.append(('city_'+c['id'],c['wiki']))
conflict_titles=['Guerre russo-ukrainienne','Guerre civile soudanaise (depuis 2023)','Conflit israélo-palestinien','Guerre civile birmane (depuis 2021)','Guerre du Sahel','Guerre du Kivu','Guerre civile yéménite','Guerre civile syrienne','Guerre civile somalienne','Conflit armé colombien','Insurrection de Boko Haram','Conflit du Cachemire','Conflit kurde en Turquie','Insurrection islamiste au Pakistan','Crise haïtienne depuis 2017','Crise anglophone au Cameroun','Insurrection de Cabo Delgado']
for i,t in enumerate(conflict_titles):requests.append(('conflict_'+str(i),t))
landmark_titles=['Canal de Suez','Détroit d’Ormuz','Détroit de Malacca','Canal de Panama','Détroit du Bosphore','Détroit de Bab-el-Mandeb','Détroit de Gibraltar','Nil','Amazone (fleuve)','Himalaya','Sahara','Andes']
for i,t in enumerate(landmark_titles):requests.append(('place_'+str(i),t))
def wiki(item):
    key,title=item; path=CACHE/(key+'.json')
    if path.exists():return key,json.load(open(path))
    url='https://fr.wikipedia.org/w/api.php?action=query&prop=extracts&explaintext=1&titles='+urllib.parse.quote(title)+'&format=json&redirects=1'
    if os.environ.get('CACHE_ONLY')=='1':return key,{'title':title,'url':'https://fr.wikipedia.org/wiki/'+urllib.parse.quote(title)}
    for attempt in range(3):
        try:
            raw=json.loads(fetch(url));page=next(iter(raw['query']['pages'].values()));txt=page.get('extract','')
            if len(txt)<80:raise ValueError('missing or short article')
            record={'title':page['title'],'pageid':page['pageid'],'text':txt,'url':'https://fr.wikipedia.org/?curid='+str(page['pageid']),'history':'https://fr.wikipedia.org/w/index.php?title='+urllib.parse.quote(page['title'])+'&action=history','retrieved':'2026-11-13','license':'CC BY-SA 4.0'}
            path.write_text(json.dumps(record,ensure_ascii=False));return key,record
        except Exception as e:
            if getattr(e,'code',0)==429 and attempt<2:
                pause=int(e.headers.get('Retry-After','30'))+2
                with rate_lock:
                    globals()['next_request']=max(next_request,time.monotonic()+pause)
                print('Rate limit: respecting retry-after',pause,'seconds',key,flush=True)
                time.sleep(min(pause,60))
                continue
            print('Missing',key,title,str(e),flush=True)
            return key,{'title':title,'error':str(e),'url':'https://fr.wikipedia.org/wiki/'+urllib.parse.quote(title)}
    return key,{}
articles={}
requests.sort(key=lambda item: 0 if item[0].startswith("conflict") else 1 if item[0].startswith("place") else 2 if len(item[0])==3 else 3)
with concurrent.futures.ThreadPoolExecutor(max_workers=3) as ex:
    for n,(key,result) in enumerate(ex.map(wiki,requests)):
        articles[key]=result
        if n%30==0:print('Encyclopedia',n,'/',len(requests),flush=True)
DATA.joinpath('articles.json').write_text(json.dumps(articles,ensure_ascii=False,separators=(',',':')))
DATA.joinpath('countries.json').write_text(json.dumps(countries,ensure_ascii=False,separators=(',',':')))
DATA.joinpath('polygons.json').write_text(json.dumps(polygons,separators=(',',':')))
DATA.joinpath('cities.json').write_text(json.dumps(cities,ensure_ascii=False,separators=(',',':')))
DATA.joinpath('article_titles.json').write_text(json.dumps({'conflicts':conflict_titles,'places':landmark_titles},ensure_ascii=False))
print('DONE',len(countries),len(cities),'articles',sum(bool(a.get('text')) for a in articles.values()),'/',len(articles),flush=True)
