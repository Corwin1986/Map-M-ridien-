import json
from pathlib import Path
D=Path(__file__).resolve().parents[1]/'data';wars=json.load(open(D/'conflict_history.json'))
raw='''1964||Conflit armé colombien|Conflit armé colombien|COL|4.71|-74.07
2006||Guerre de la drogue au Mexique|Guerre de la drogue au Mexique|MEX|23|-102
1991||Guerre civile somalienne|Guerre civile somalienne|SOM|2.05|45.32
2003||Guerre du Sahel|Guerre du Sahel|MLI NER BFA MRT TCD FRA|17|1
2009||Insurrection de Boko Haram|Insurrection de Boko Haram|NGA NER TCD CMR|11.83|13.15
2004||Insurrection islamiste au Pakistan|Insurrection islamiste au Pakistan|PAK|34|71.5
1984||Conflit kurde en Turquie|Conflit kurde en Turquie|TUR IRQ SYR|37.91|40.24
2017||Crise haïtienne|Crise haïtienne depuis 2017|HTI|18.54|-72.34
2017||Crise anglophone au Cameroun|Crise anglophone au Cameroun|CMR|5.96|10.15
2017||Insurrection de Cabo Delgado|Insurrection de Cabo Delgado|MOZ| -12.97|40.52
2004||Guerre du Kivu|Guerre du Kivu|COD RWA UGA| -1.68|29.23
1990|1994|Guerre civile rwandaise|Guerre civile rwandaise|RWA| -1.94|30.06
1993|2005|Guerre civile burundaise|Guerre civile burundaise|BDI| -3.38|29.36
2013||Troisième guerre civile centrafricaine|Troisième guerre civile centrafricaine|CAF|4.36|18.56
1961|1991|Guerre d’indépendance de l’Érythrée|Guerre d'indépendance de l'Érythrée|ERI ETH|15.34|38.93
1966|1990|Guerre de la frontière sud-africaine|Guerre de la frontière sud-africaine|NAM AGO ZAF CUB| -17|16
1964|1979|Guerre du Bush de Rhodésie du Sud|Guerre du Bush de Rhodésie du Sud|ZWE| -17.83|31.05
1979|1992|Guerre civile du Salvador|Guerre civile du Salvador|SLV|13.69|-89.19
1960|1996|Guerre civile du Guatemala|Guerre civile du Guatemala|GTM|14.63|-90.5
1980||Conflit armé péruvien|Conflit armé péruvien|PER| -13.16|-74.22
1979|1979|Guerre sino-vietnamienne|Guerre sino-vietnamienne|CHN VNM|22.67|106.26
1996|2006|Guerre civile népalaise|Guerre civile népalaise|NPL|27.72|85.32
1992|1997|Guerre civile du Tadjikistan|Guerre civile du Tadjikistan|TJK|38.56|68.79
1982||Conflit en Casamance|Conflit en Casamance|SEN|12.56|-16.27
2002|2007|Première guerre civile ivoirienne|Première guerre civile ivoirienne|CIV|7.69|-5.03
2010|2011|Crise ivoirienne de 2010-2011|Crise ivoirienne de 2010-2011|CIV|5.35|-4.02'''
for i,line in enumerate(raw.splitlines()):
 start,end,name,wiki,codes,lat,lon=line.split('|');start=int(start);end=int(end) if end else None
 if any(w['wiki']==wiki for w in wars):continue
 key='war_extra_'+str(i)
 wars.append({'id':key,'article':key,'name':name,'wiki':wiki,'start':start,'end':end,'codes':codes.split(),'lat':float(lat),'lon':float(lon),'date_checked':'2026-11-14','kind':'Conflit ou violence de masse','period':str(start)+'–'+str(end) if end and end!=start else str(start) if end else 'Depuis '+str(start)+' · fin non renseignée'})
wars.sort(key=lambda w:(w['start'],w['name']))
(D/'conflict_history.json').write_text(json.dumps(wars,ensure_ascii=False,separators=(',',':')))
print('Wars',len(wars))
