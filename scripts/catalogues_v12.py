import json
from pathlib import Path
D=Path(__file__).resolve().parents[1]/'data';cs=json.load(open(D/'countries.json'))
# Non-exhaustive documentary selection. Codes describe involved states or present-day territories.
raw='''1821|1829|Guerre d’indépendance grecque|Guerre d'indépendance grecque|GRC TUR GBR FRA RUS|37.98|23.72
1826|1828|Guerre russo-persane|Guerre russo-persane de 1826-1828|RUS IRN ARM AZE|40.18|44.51
1828|1829|Guerre russo-turque|Guerre russo-turque de 1828-1829|RUS TUR BGR ROU|43.2|27.9
1830|1902|Conquête française de l’Algérie|Conquête de l'Algérie par la France|DZA FRA|36.75|3.06
1830|1831|Révolution belge|Révolution belge|BEL NLD|50.85|4.35
1830|1831|Insurrection de Novembre|Insurrection de Novembre|POL RUS|52.23|21.01
1835|1836|Révolution texane|Révolution texane|USA MEX|29.42|-98.49
1835|1842|Deuxième guerre séminole|Deuxième guerre séminole|USA|28|-82
1838|1842|Première guerre anglo-afghane|Première guerre anglo-afghane|AFG GBR IND|34.55|69.2
1839|1842|Première guerre de l’opium|Première guerre de l'opium|CHN GBR|23.13|113.26
1846|1848|Guerre américano-mexicaine|Guerre américano-mexicaine|USA MEX|19.43|-99.13
1848|1851|Première guerre de Schleswig|Première guerre de Schleswig|DNK DEU|54.52|9.57
1848|1849|Première guerre d’indépendance italienne|Première guerre d'indépendance italienne|ITA AUT|45.46|9.19
1850|1864|Révolte des Taiping|Révolte des Taiping|CHN|32.06|118.8
1853|1856|Guerre de Crimée|Guerre de Crimée|RUS UKR TUR FRA GBR ITA|44.6|33.52
1856|1860|Seconde guerre de l’opium|Seconde guerre de l'opium|CHN GBR FRA|39.9|116.4
1857|1858|Révolte des cipayes|Révolte des cipayes|IND GBR|28.61|77.2
1859|1859|Deuxième guerre d’indépendance italienne|Deuxième guerre d'indépendance italienne|ITA AUT FRA|45.37|10.57
1861|1865|Guerre de Sécession|Guerre de Sécession|USA|38.9|-77.04
1861|1867|Expédition française au Mexique|Expédition du Mexique|MEX FRA|19.04|-98.2
1864|1864|Guerre des Duchés|Guerre des Duchés|DNK DEU AUT|54.91|9.79
1864|1870|Guerre de la Triple-Alliance|Guerre de la Triple-Alliance|PRY BRA ARG URY|-25.26|-57.58
1866|1866|Guerre austro-prussienne|Guerre austro-prussienne|AUT DEU ITA CZE|50.21|15.83
1868|1869|Guerre de Boshin|Guerre de Boshin|JPN|35.68|139.69
1868|1878|Guerre des Dix Ans|Guerre des Dix Ans|CUB ESP|20.37|-76.64
1870|1871|Guerre franco-allemande|Guerre franco-allemande de 1870|FRA DEU|49.7|4.94
1871|1871|Commune de Paris|Commune de Paris|FRA|48.86|2.35
1876|1877|Guerre des Black Hills|Guerre des Black Hills|USA|45.57|-107.43
1877|1878|Guerre russo-turque|Guerre russo-turque de 1877-1878|RUS TUR BGR ROU SRB MNE|42.7|23.32
1878|1880|Seconde guerre anglo-afghane|Seconde guerre anglo-afghane|AFG GBR IND|34.55|69.2
1879|1879|Guerre anglo-zouloue|Guerre anglo-zouloue|ZAF GBR|-28.36|30.65
1879|1884|Guerre du Pacifique|Guerre du Pacifique (1879-1884)|CHL PER BOL|-23.65|-70.4
1881|1899|Guerre des Mahdistes|Guerre des Mahdistes|SDN EGY GBR|15.6|32.5
1884|1885|Guerre franco-chinoise|Guerre franco-chinoise|CHN VNM FRA|21.03|105.85
1894|1895|Première guerre sino-japonaise|Première guerre sino-japonaise|CHN JPN KOR PRK|38|127
1895|1896|Première guerre italo-éthiopienne|Première guerre italo-éthiopienne|ETH ITA ERI|14.16|38.9
1898|1898|Guerre hispano-américaine|Guerre hispano-américaine|USA ESP CUB PHL PRI|23.11|-82.37
1899|1902|Seconde guerre des Boers|Seconde guerre des Boers|ZAF GBR|-25.75|28.19
1899|1902|Guerre américano-philippine|Guerre américano-philippine|PHL USA|14.6|120.98
1899|1901|Révolte des Boxers|Révolte des Boxers|CHN JPN RUS GBR FRA DEU USA ITA AUT|39.9|116.4
1904|1905|Guerre russo-japonaise|Guerre russo-japonaise|RUS JPN CHN|38.8|121.3
1910|1920|Révolution mexicaine|Révolution mexicaine|MEX|19.43|-99.13
1911|1912|Guerre italo-turque|Guerre italo-turque|ITA TUR LBY|32.89|13.19
1912|1913|Guerres balkaniques|Guerres balkaniques|BGR GRC SRB MNE TUR ALB ROU MKD|42|22
1914|1918|Première Guerre mondiale|Première Guerre mondiale|FRA GBR DEU AUT HUN RUS TUR ITA USA BEL SRB BGR ROU GRC PRT JPN CAN AUS NZL IND ZAF POL UKR CZE SVK HRV BIH SVN|49.16|5.38
1917|1923|Guerre civile russe|Guerre civile russe|RUS UKR BLR EST LVA LTU GEO ARM AZE|55.75|37.62
1918|1918|Guerre civile finlandaise|Guerre civile finlandaise|FIN RUS DEU|60.17|24.94
1919|1921|Guerre d’indépendance irlandaise|Guerre d'indépendance irlandaise|IRL GBR|53.35|-6.26
1919|1923|Guerre d’indépendance turque|Guerre d'indépendance turque|TUR GRC ARM FRA GBR ITA|39.93|32.86
1919|1921|Guerre soviéto-polonaise|Guerre soviéto-polonaise|POL RUS UKR BLR|52.23|21.01
1921|1926|Guerre du Rif|Guerre du Rif|MAR ESP FRA|35.17|-3.85
1922|1923|Guerre civile irlandaise|Guerre civile irlandaise|IRL|53.35|-6.26
1927|1949|Guerre civile chinoise|Guerre civile chinoise|CHN TWN|34|108
1932|1935|Guerre du Chaco|Guerre du Chaco|BOL PRY|-22|-60
1935|1936|Seconde guerre italo-éthiopienne|Seconde guerre italo-éthiopienne|ETH ITA ERI|9.03|38.75
1936|1939|Guerre d’Espagne|Guerre d'Espagne|ESP DEU ITA RUS|40.42|-3.7
1937|1945|Seconde guerre sino-japonaise|Seconde guerre sino-japonaise|CHN JPN|32.06|118.8
1939|1945|Seconde Guerre mondiale|Seconde Guerre mondiale|DEU POL FRA GBR RUS UKR BLR USA JPN CHN ITA CAN AUS NZL IND BEL NLD NOR DNK GRC SRB HRV BIH SVN MKD MNE CZE SVK AUT HUN ROU BGR FIN EST LVA LTU PHL IDN MYS SGP MMR THA VNM LAO KHM MAR DZA TUN LBY EGY ETH ERI ZAF BRA|52.52|13.4
1939|1940|Guerre d’Hiver|Guerre d'Hiver|FIN RUS|60.17|24.94
1945|1949|Révolution nationale indonésienne|Révolution nationale indonésienne|IDN NLD| -6.17|106.83
1946|1949|Guerre civile grecque|Guerre civile grecque|GRC|37.98|23.72
1946|1954|Guerre d’Indochine|Guerre d'Indochine|VNM LAO KHM FRA|21.4|103.02
1947|1948|Première guerre indo-pakistanaise|Première guerre indo-pakistanaise|IND PAK|34.08|74.8
1948|1949|Guerre israélo-arabe de 1948|Guerre israélo-arabe de 1948-1949|ISR PSE EGY JOR SYR LBN IRQ|31.77|35.21
1950|1953|Guerre de Corée|Guerre de Corée|KOR PRK USA CHN GBR FRA TUR CAN AUS|38|127
1952|1960|Révolte des Mau Mau|Révolte des Mau Mau|KEN GBR|-1.29|36.82
1954|1962|Guerre d’Algérie|Guerre d'Algérie|DZA FRA|36.75|3.06
1955|1975|Guerre du Viêt Nam|Guerre du Viêt Nam|VNM USA LAO KHM KOR AUS|16.07|108.22
1956|1956|Crise du canal de Suez|Crise du canal de Suez|EGY GBR FRA ISR|30.58|32.27
1956|1956|Insurrection de Budapest|Insurrection de Budapest|HUN RUS|47.5|19.04
1959|1962|Guerre du Tibet|Soulèvement tibétain de 1959|CHN|29.65|91.17
1960|1965|Crise congolaise|Crise congolaise|COD BEL| -4.32|15.31
1961|1974|Guerres coloniales portugaises|Guerres coloniales portugaises|PRT AGO MOZ GNB| -8.84|13.23
1962|1962|Guerre sino-indienne|Guerre sino-indienne|CHN IND|28|94
1963|1963|Guerre des Sables|Guerre des Sables|DZA MAR|31|-3
1965|1965|Deuxième guerre indo-pakistanaise|Deuxième guerre indo-pakistanaise|IND PAK|31.55|74.34
1967|1967|Guerre des Six Jours|Guerre des Six Jours|ISR PSE EGY JOR SYR|31.77|35.21
1967|1970|Guerre du Biafra|Guerre du Biafra|NGA|6.45|7.51
1968|1998|Conflit nord-irlandais|Conflit nord-irlandais|GBR IRL|54.6|-5.93
1971|1971|Guerre de libération du Bangladesh|Guerre de libération du Bangladesh|BGD PAK IND|23.81|90.41
1973|1973|Guerre du Kippour|Guerre du Kippour|ISR EGY SYR|30.58|32.27
1974|1974|Invasion turque de Chypre|Invasion turque de Chypre|CYP CYN TUR GRC|35.18|33.38
1975|1990|Guerre du Liban|Guerre du Liban|LBN ISR SYR PSE|33.89|35.5
1975|2002|Guerre civile angolaise|Guerre civile angolaise|AGO ZAF CUB COD| -12.5|18.5
1975|1999|Occupation indonésienne du Timor oriental|Occupation indonésienne du Timor oriental|TLS IDN| -8.56|125.58
1975||Conflit du Sahara occidental|Conflit du Sahara occidental|ESH MAR DZA MRT|27.15|-13.2
1977|1992|Guerre civile du Mozambique|Guerre civile du Mozambique|MOZ| -25.97|32.57
1977|1978|Guerre de l’Ogaden|Guerre de l'Ogaden|ETH SOM CUB|9|43
1978|1979|Guerre ougando-tanzanienne|Guerre ougando-tanzanienne|UGA TZA|0.35|32.58
1978|1991|Conflit cambodgien|Conflit cambodgien (1978-1999)|KHM VNM CHN|11.56|104.93
1979|1989|Guerre d’Afghanistan|Guerre d'Afghanistan (1979-1989)|AFG RUS|34.55|69.2
1980|1988|Guerre Iran-Irak|Guerre Iran-Irak|IRN IRQ|30.51|47.81
1982|1982|Guerre des Malouines|Guerre des Malouines|ARG GBR FLK| -51.7|-57.85
1983|2009|Guerre civile du Sri Lanka|Guerre civile du Sri Lanka|LKA|9.66|80.03
1983|2005|Seconde guerre civile soudanaise|Seconde guerre civile soudanaise|SDN SSD|4.85|31.58
1988|1994|Première guerre du Haut-Karabagh|Première guerre du Haut-Karabagh|ARM AZE|39.82|46.75
1989|2003|Guerres civiles du Liberia|Guerres civiles du Liberia|LBR|6.32|-10.8
1990|1991|Guerre du Golfe|Guerre du Golfe|IRQ KWT USA GBR FRA SAU|29.38|47.99
1991|2002|Guerre civile algérienne|Guerre civile algérienne|DZA|36.75|3.06
1991|2001|Guerres de Yougoslavie|Guerres de Yougoslavie|SVN HRV BIH SRB MNE UNK MKD|44.8|20.46
1991|2002|Guerre civile sierra-léonaise|Guerre civile sierra-léonaise|SLE|8.48|-13.23
1992|1995|Guerre de Bosnie-Herzégovine|Guerre de Bosnie-Herzégovine|BIH SRB HRV|43.86|18.41
1994|1994|Génocide des Tutsi au Rwanda|Génocide des Tutsi au Rwanda|RWA| -1.94|30.06
1994|1996|Première guerre de Tchétchénie|Première guerre de Tchétchénie|RUS|43.32|45.69
1996|1997|Première guerre du Congo|Première guerre du Congo|COD RWA UGA AGO| -4.32|15.31
1998|2003|Deuxième guerre du Congo|Deuxième guerre du Congo|COD RWA UGA AGO ZWE NAM| -2.51|28.86
1998|2000|Guerre entre l’Éthiopie et l’Érythrée|Guerre entre l'Éthiopie et l'Érythrée|ETH ERI|14.13|38.72
1998|1999|Guerre du Kosovo|Guerre du Kosovo|UNK SRB USA GBR FRA DEU ITA|42.66|21.16
1999|2009|Seconde guerre de Tchétchénie|Seconde guerre de Tchétchénie|RUS|43.32|45.69
2001|2021|Guerre d’Afghanistan|Guerre d'Afghanistan (2001-2021)|AFG USA GBR FRA CAN DEU ITA AUS|34.55|69.2
2003|2011|Guerre d’Irak|Guerre d'Irak|IRQ USA GBR|33.31|44.37
2003||Guerre du Darfour|Guerre du Darfour|SDN TCD|13.63|25.35
2006|2006|Guerre du Liban de 2006|Conflit israélo-libanais de 2006|LBN ISR|33.89|35.5
2008|2008|Guerre russo-géorgienne|Guerre russo-géorgienne|GEO RUS|42.23|43.97
2011|2011|Première guerre civile libyenne|Première guerre civile libyenne|LBY FRA GBR USA|32.89|13.19
2011||Guerre civile syrienne|Guerre civile syrienne|SYR|33.51|36.29
2012||Guerre du Mali|Guerre du Mali|MLI FRA|16.77|-3.01
2013|2020|Guerre civile sud-soudanaise|Guerre civile sud-soudanaise|SSD|4.85|31.58
2014||Guerre russo-ukrainienne|Guerre russo-ukrainienne|UKR RUS|50.45|30.52
2014|2020|Deuxième guerre civile libyenne|Deuxième guerre civile libyenne|LBY|32.1|20.07
2014||Guerre civile yéménite|Guerre civile yéménite|YEM SAU ARE|15.35|44.2
2020|2020|Guerre du Haut-Karabagh de 2020|Guerre de 2020 au Haut-Karabagh|ARM AZE|39.82|46.75
2020|2022|Guerre du Tigré|Guerre du Tigré|ETH ERI|13.5|39.47
2021||Guerre civile birmane|Guerre civile birmane (depuis 2021)|MMR|19.76|96.08
2023||Guerre civile soudanaise|Guerre civile soudanaise (depuis 2023)|SDN|15.6|32.5
2023||Guerre de Gaza|Guerre de Gaza depuis 2023|ISR PSE|31.5|34.47'''
wars=[]
for i,line in enumerate(raw.splitlines()):
 start,end,name,wiki,codes,lat,lon=line.split('|');start=int(start);end=int(end) if end else None
 if end is not None and end<1826:continue
 wars.append({'id':'war_'+str(i),'article':'war_'+str(i),'name':name,'wiki':wiki,'start':start,'end':end,'codes':codes.split(),'lat':float(lat),'lon':float(lon),'date_checked':'2026-11-14','kind':'Conflit ou violence de masse','period':str(start)+'–'+str(end) if end and end!=start else str(start) if end else 'Depuis '+str(start)+' · fin non renseignée'})
# Two chronology corrections: the entries refer to the events, not a broader regional war.
for w in wars:
 if w['wiki']=='Soulèvement tibétain de 1959':w.update(name='Soulèvement tibétain de 1959',end=1959,period='1959')
 if w['wiki']=='Conflit cambodgien (1978-1999)':w.update(end=1999,period='1978–1999')
(D/'conflict_history.json').write_text(json.dumps(wars,ensure_ascii=False,separators=(',',':')))
# Titles are resolved and checked against the encyclopedia; missing pages fall back transparently to the country article.
food='''FRA française
DZA algérienne
MAR marocaine
TUN tunisienne
TUR turque
USA américaine
IND indienne
CHN chinoise
JPN japonaise
KOR coréenne
PRK nord-coréenne
GBR britannique
IRL irlandaise
ITA italienne
ESP espagnole
PRT portugaise
DEU allemande
BEL belge
NLD néerlandaise
CHE suisse
AUT autrichienne
POL polonaise
CZE tchèque
SVK slovaque
HUN hongroise
ROU roumaine
BGR bulgare
GRC grecque
CYP chypriote
ALB albanaise
SRB serbe
BIH bosnienne
HRV croate
SVN slovène
MNE monténégrine
MKD macédonienne
UNK kosovare
UKR ukrainienne
BLR biélorusse
RUS russe
EST estonienne
LVA lettone
LTU lituanienne
FIN finlandaise
SWE suédoise
NOR norvégienne
DNK danoise
ISL islandaise
GEO géorgienne
ARM arménienne
AZE azerbaïdjanaise
IRN iranienne
IRQ irakienne
SYR syrienne
LBN libanaise
ISR israélienne
PSE palestinienne
JOR jordanienne
SAU saoudienne
YEM yéménite
OMN omanaise
ARE émiratie
QAT qatarienne
KWT koweïtienne
BHR bahreïnienne
AFG afghane
PAK pakistanaise
BGD bangladaise
LKA srilankaise
NPL népalaise
BTN bhoutanaise
MDV maldivienne
MMR birmane
THA thaïlandaise
LAO laotienne
KHM cambodgienne
VNM vietnamienne
MYS malaisienne
IDN indonésienne
PHL philippine
SGP singapourienne
BRN brunéienne
TLS est-timoraise
MNG mongole
KAZ kazakhe
KGZ kirghize
UZB ouzbèke
TJK tadjike
TKM turkmène
TWN taïwanaise
HKG hongkongaise
MAC macanaise
EGY égyptienne
LBY libyenne
SDN soudanaise
SSD sud-soudanaise
ETH éthiopienne
ERI érythréenne
DJI djiboutienne
SOM somalienne
KEN kényane
UGA ougandaise
TZA tanzanienne
RWA rwandaise
BDI burundaise
COD congolaise
COG congolaise
GAB gabonaise
CMR camerounaise
CAF centrafricaine
TCD tchadienne
NGA nigériane
NER nigérienne
BEN béninoise
TGO togolaise
GHA ghanéenne
CIV ivoirienne
LBR libérienne
SLE sierraléonaise
GIN guinéenne
GNB bissau-guinéenne
SEN sénégalaise
GMB gambienne
MLI malienne
BFA burkinabè
MRT mauritanienne
CPV cap-verdienne
STP santoméenne
GNQ équatoguinéenne
AGO angolaise
ZMB zambienne
ZWE zimbabwéenne
MWI malawite
MOZ mozambicaine
BWA botswanaise
NAM namibienne
ZAF sud-africaine
LSO lésothienne
SWZ eswatinienne
MDG malgache
COM comorienne
MUS mauricienne
SYC seychelloise
CAN canadienne
MEX mexicaine
GTM guatémaltèque
BLZ bélizienne
HND hondurienne
SLV salvadorienne
NIC nicaraguayenne
CRI costaricienne
PAN panaméenne
CUB cubaine
HTI haïtienne
DOM dominicaine
JAM jamaïcaine
TTO trinidadienne
BRB barbadienne
BHS bahaméenne
COL colombienne
VEN vénézuélienne
GUY guyanienne
SUR surinamaise
ECU équatorienne
PER péruvienne
BOL bolivienne
BRA brésilienne
PRY paraguayenne
URY uruguayenne
ARG argentine
CHL chilienne
AUS australienne
NZL néo-zélandaise
PNG papouasienne
FJI fidjienne
WSM samoane
TON tongienne
VUT vanuataise
SLB salomonaise
LUX luxembourgeoise
MLT maltaise
MDA moldave
AND andorrane
SMR saint-marinaise
MCO monégasque
LIE liechtensteinoise'''
cuisines={}
for line in food.splitlines():
 code,adj=line.split(' ',1);cuisines[code]={'code':code,'wiki':'Cuisine '+adj,'article':'food_'+code}
(D/'cuisines.json').write_text(json.dumps(cuisines,ensure_ascii=False,separators=(',',':')))
print('WARS',len(wars),'CUISINES',len(cuisines))
