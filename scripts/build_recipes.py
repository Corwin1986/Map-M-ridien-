"""Curated home adaptations. Cultural sources are resolved separately; not verbatim recipes."""
import json
from pathlib import Path
D=Path(__file__).resolve().parents[1]/'data'
R={}
def add(id,name,wiki,ingredients,steps,minutes=45,servings='4 personnes',note='Version familiale simplifiée ; les ingrédients et les gestes varient selon les régions et les foyers.'):
 R[id]=dict(id=id,name=name,wiki=wiki,ingredients=ingredients.split('|'),steps=steps.split('|'),minutes=minutes,servings=servings,note=note)
# Each method is specified per dish, not inferred from an unrelated recipe.
add('couscous','Couscous aux légumes','Couscous','300 g de semoule de couscous|2 carottes|2 courgettes|2 navets|240 g de pois chiches cuits|1 oignon|2 tomates|2 c. à soupe d’huile|1 c. à café de ras-el-hanout|700 ml de bouillon de légumes|Sel','Faire revenir l’oignon émincé dans l’huile 5 minutes. Ajouter les tomates, les épices, les carottes et les navets coupés.|Verser le bouillon ; cuire 20 minutes. Ajouter les courgettes et les pois chiches ; poursuivre 15 minutes.|Hydrater la semoule selon son emballage, puis l’égrener. Servir avec les légumes et le bouillon.',50)
add('chorba','Chorba frik','Chorba frik','250 g d’agneau en petits cubes|80 g de frik (blé vert concassé)|1 oignon|2 tomates|1 branche de céleri|120 g de pois chiches cuits|1 c. à soupe de concentré de tomate|1 c. à café de paprika|1 c. à soupe d’huile|1,2 l d’eau|Coriandre, sel','Dorer l’oignon et la viande dans l’huile. Ajouter tomates, concentré, céleri et paprika.|Couvrir d’eau et mijoter 35 minutes. Rincer le frik, l’ajouter avec les pois chiches et cuire encore 25 à 30 minutes, jusqu’à tendreté.|Ajuster la consistance avec de l’eau chaude. Parsemer de coriandre.',75)
add('chakchouka','Chakchouka','Shakshouka','4 œufs|3 poivrons|4 tomates|1 oignon|2 gousses d’ail|2 c. à soupe d’huile d’olive|1 c. à café de cumin|Sel','Faire revenir oignon et poivrons émincés 10 minutes dans l’huile.|Ajouter ail, tomates coupées et cumin. Mijoter 20 minutes.|Former quatre creux, casser les œufs dedans et couvrir jusqu’à cuisson des blancs.',40)
add('bourek','Bourek à la viande','Bourek','8 feuilles de brick|300 g de bœuf haché|1 oignon|1 bouquet de persil|1 œuf|2 c. à soupe d’huile|Sel, poivre','Faire revenir l’oignon puis la viande jusqu’à cuisson complète. Saler, poivrer, ajouter le persil et laisser tiédir.|Incorporer l’œuf à la farce. Répartir sur les feuilles, replier les côtés et rouler.|Badigeonner d’huile et cuire 15 à 20 minutes à 190 °C, en retournant à mi-cuisson.',40)
add('rechta','Rechta au poulet','Rechta','400 g de nouilles rechta|4 morceaux de poulet|2 navets|240 g de pois chiches cuits|1 oignon|2 c. à soupe d’huile|1/2 c. à café de cannelle|800 ml d’eau|Sel','Faire revenir poulet et oignon dans l’huile. Ajouter cannelle, sel et eau ; mijoter 30 minutes.|Ajouter les navets et les pois chiches ; cuire encore 20 minutes, jusqu’à cuisson du poulet.|Cuire la rechta à la vapeur selon le fabricant. L’humecter de bouillon et servir avec la garniture.',65)
add('tajine','Tajine de poulet au citron confit','Tajine','4 morceaux de poulet|2 oignons|1 citron confit|100 g d’olives|2 gousses d’ail|1 c. à café de gingembre|1/2 c. à café de curcuma|2 c. à soupe d’huile|300 ml d’eau|Persil','Faire revenir les oignons dans l’huile. Ajouter poulet, ail et épices ; dorer légèrement.|Verser l’eau, couvrir et mijoter 40 à 50 minutes, jusqu’à cuisson du poulet.|Ajouter les olives et l’écorce de citron confit rincée, en lanières. Cuire 10 minutes puis parsemer de persil.',70)
add('harira','Harira','Harira','100 g de lentilles sèches|240 g de pois chiches cuits|400 g de tomates concassées|1 oignon|1 branche de céleri|40 g de vermicelles|1 c. à soupe de farine|1 c. à café de gingembre|1 c. à soupe d’huile|1,2 l d’eau|Coriandre, sel','Faire revenir oignon et céleri. Ajouter tomates, lentilles, épices et eau ; cuire 30 minutes.|Ajouter les pois chiches et les vermicelles. Délayer la farine dans un peu d’eau froide, incorporer en remuant.|Mijoter encore 10 minutes ; ajuster la consistance et ajouter la coriandre.',50)
add('brik','Brik à l’œuf','Brik','4 feuilles de brick|4 œufs|120 g de thon égoutté|1 petite pomme de terre cuite|2 c. à soupe de persil haché|Huile de friture|1 citron','Écraser la pomme de terre et mélanger au thon et au persil.|Poser une feuille dans une assiette, placer la farce sur une moitié, casser un œuf dessus et replier.|Faire frire prudemment dans une poêle d’huile chaude, sur les deux faces, jusqu’à cuisson de l’œuf. Égoutter et servir avec du citron.',25)
add('lablabi','Lablabi','Lablabi','600 g de pois chiches cuits|4 tranches de pain de la veille|2 gousses d’ail|1 c. à café de cumin|800 ml de bouillon de légumes|2 c. à soupe d’huile d’olive|1 citron|Harissa selon le goût','Chauffer les pois chiches avec le bouillon, l’ail et le cumin pendant 20 minutes.|Déposer le pain en morceaux dans quatre bols. Verser dessus les pois chiches et leur bouillon.|Ajouter huile, citron et harissa selon le goût.',30)
add('koshari','Koshari','Koshary','150 g de riz|150 g de lentilles|150 g de petites pâtes|240 g de pois chiches cuits|400 g de tomates concassées|2 oignons|2 gousses d’ail|3 c. à soupe d’huile|1 c. à soupe de vinaigre|Cumin, sel','Cuire séparément riz, lentilles et pâtes ; égoutter.|Faire dorer les oignons émincés dans l’huile. Réserver. Mijoter tomates, ail, vinaigre et cumin 15 minutes.|Assembler les féculents et les pois chiches chauds. Ajouter la sauce puis les oignons.',50)
add('ful','Foul medames','Ful medames','600 g de fèves cuites|2 gousses d’ail|1 citron|3 c. à soupe d’huile d’olive|1 c. à café de cumin|Persil, sel|Pain pour accompagner','Réchauffer les fèves avec 150 ml d’eau pendant 10 minutes.|Écraser grossièrement une partie des fèves. Ajouter ail pilé, cumin, jus de citron et huile.|Parsemer de persil et servir chaud avec du pain.',20)
add('shorba','Soupe de lentilles','Lentil soup','250 g de lentilles corail|1 oignon|1 carotte|1 c. à café de cumin|1 c. à soupe d’huile|1 l de bouillon de légumes|1 citron','Faire revenir oignon et carotte coupés dans l’huile.|Ajouter lentilles rincées, cumin et bouillon. Cuire 25 minutes en remuant de temps en temps.|Mixer ou garder la texture rustique. Servir avec du citron.',35)
add('mafe','Mafé aux légumes','Maafe','150 g de pâte d’arachide non sucrée|2 patates douces|2 carottes|1 oignon|2 tomates|1 c. à soupe de concentré de tomate|1 c. à soupe d’huile|700 ml d’eau|300 g de riz|Sel','Faire revenir l’oignon, puis tomates et concentré. Ajouter les légumes en cubes et l’eau.|Délayer la pâte d’arachide dans une louche de bouillon et reverser. Mijoter 30 à 40 minutes en remuant pour éviter que la sauce attache.|Cuire le riz séparément. Servir avec la sauce et les légumes.',50)
add('yassa','Poulet yassa','Yassa','600 g de poulet désossé|4 oignons|2 citrons|2 c. à soupe de moutarde|2 c. à soupe d’huile|200 ml d’eau|300 g de riz|Sel, poivre','Mélanger poulet, oignons émincés, jus des citrons et moutarde. Laisser mariner 1 heure au réfrigérateur.|Égoutter le poulet et le dorer. Le réserver. Faire fondre les oignons dans la même casserole.|Ajouter marinade, eau et poulet ; mijoter 25 à 30 minutes jusqu’à cuisson complète. Servir avec le riz.',110)
add('thieb','Thiéboudiène','Thieboudienne','600 g de poisson blanc|300 g de riz brisé|2 carottes|1 aubergine|1/4 de chou|1 oignon|2 c. à soupe de concentré de tomate|2 gousses d’ail|Persil|3 c. à soupe d’huile|1 l d’eau|Sel','Hacher ail et persil, en frotter le poisson puis le faire dorer dans l’huile. Réserver.|Faire revenir l’oignon et le concentré. Ajouter eau et légumes coupés ; cuire 25 minutes. Ajouter le poisson et poursuivre jusqu’à cuisson, puis réserver la garniture.|Cuire le riz dans une quantité de bouillon adaptée à son emballage. Servir avec poisson et légumes.',65)
add('jollof','Riz jollof','Jollof rice','300 g de riz long|400 g de tomates concassées|1 poivron rouge|1 oignon|2 c. à soupe de concentré de tomate|3 c. à soupe d’huile|500 ml de bouillon|Thym, curry, sel','Mixer tomates, poivron et la moitié de l’oignon. Faire revenir le reste de l’oignon dans l’huile.|Ajouter concentré puis légumes mixés, thym et curry. Réduire 15 minutes.|Ajouter riz rincé et bouillon. Couvrir et cuire à feu doux 20 à 25 minutes, en ajustant le liquide au riz utilisé.',50)
add('alloco','Alloco','Alloco','4 bananes plantains bien mûres|Huile de friture|Sel|1 oignon|2 tomates|Piment facultatif','Éplucher les plantains et les couper en dés ou en rondelles.|Les faire dorer par petites fournées dans l’huile chaude ; égoutter et saler légèrement.|Faire compoter à part oignon, tomates et piment avec une cuillère d’huile. Servir en accompagnement.',30)
add('akara','Beignets de niébé','Akara','250 g de niébé sec décortiqué|1 petit oignon|1 petit piment facultatif|Sel|Huile de friture','Faire tremper le niébé 6 heures, puis égoutter. Mixer avec l’oignon, le piment et juste assez d’eau pour former une pâte épaisse.|Saler et fouetter la pâte pour l’aérer.|Déposer de petites cuillerées dans l’huile chaude. Cuire 4 à 6 minutes en retournant, jusqu’à cuisson du centre.',390)
add('egusi','Soupe egusi','Egusi soup','150 g de graines d’egusi moulues|300 g d’épinards|2 tomates|1 oignon|300 g de bœuf en petits cubes|2 c. à soupe d’huile de palme alimentaire|800 ml d’eau|Sel, piment facultatif','Cuire le bœuf dans l’eau salée jusqu’à tendreté, environ 1 heure, en gardant le bouillon.|Faire revenir oignon et tomates dans l’huile. Ajouter l’egusi délayé avec du bouillon et mijoter 15 minutes.|Ajouter la viande et les épinards ; cuire encore 10 minutes. Ajuster l’épaisseur avec le bouillon.',95)
add('pouletmoambe','Poulet moambé','Moambe chicken','4 morceaux de poulet|400 g de sauce de noix de palme alimentaire en conserve|1 oignon|2 gousses d’ail|300 ml d’eau|Sel, piment facultatif','Faire dorer le poulet dans une casserole antiadhésive. Ajouter l’oignon et l’ail émincés.|Incorporer la sauce de noix de palme et l’eau. Couvrir et mijoter 45 à 55 minutes jusqu’à cuisson complète.|Remuer régulièrement et ajuster l’eau pour obtenir une sauce nappante.',65)
add('saka','Saka-saka','Saka saka','500 g de feuilles de manioc déjà préparées et précuites du commerce|1 oignon|2 c. à soupe de pâte d’arachide|2 c. à soupe d’huile de palme alimentaire|400 ml d’eau|Sel','Utiliser exclusivement des feuilles de manioc préparées pour l’alimentation et suivre leur notice de cuisson ; ne pas utiliser de feuilles crues.|Faire revenir l’oignon, ajouter feuilles, eau et pâte d’arachide délayée.|Mijoter à couvert au moins le temps indiqué sur le produit, en remuant et en ajoutant de l’eau si nécessaire.',60,note='Cette adaptation utilise des feuilles déjà préparées. Leur traitement préalable ne doit pas être improvisé.')
add('ugali','Ugali / sadza / nsima','Ugali','300 g de farine de maïs blanc fine|900 ml d’eau','Porter l’eau à ébullition. Verser progressivement la farine en remuant avec une cuillère solide.|Cuire à feu doux 10 à 15 minutes en travaillant la pâte jusqu’à ce qu’elle soit épaisse, homogène et cuite.|Former un dôme et servir avec des légumes ou une sauce.',25,note='Préparation partagée dans plusieurs pays ; noms, finesse de farine et consistance changent selon les régions.')
add('ricebeans','Riz aux haricots','Rice and beans','250 g de riz|400 g de haricots rouges cuits|1 oignon|2 gousses d’ail|1 c. à soupe d’huile|500 ml de bouillon|Thym, sel','Faire revenir oignon et ail dans l’huile. Ajouter le riz rincé et remuer 1 minute.|Ajouter bouillon, haricots et thym. Couvrir et cuire à feu doux selon le riz, environ 20 minutes.|Laisser reposer 5 minutes puis égrener.',35)
add('isombe','Isombe','Isombe','500 g de feuilles de manioc préparées et précuites du commerce|1 aubergine|1 poireau|2 c. à soupe de pâte d’arachide|2 c. à soupe d’huile|400 ml d’eau|Sel','Employer des feuilles de manioc déjà préparées pour l’alimentation ; respecter leur notice.|Faire revenir poireau et aubergine coupés. Ajouter les feuilles, l’eau et la pâte d’arachide délayée.|Mijoter à couvert en respectant au minimum le temps de cuisson du produit. Remuer et ajuster l’eau.',60)
add('matoke','Matoke','Matoke','8 bananes à cuire vertes|1 oignon|2 tomates|1 c. à soupe d’huile|250 ml d’eau|Sel','Éplucher les bananes à cuire et les couper en morceaux.|Faire revenir l’oignon, ajouter tomates, bananes, eau et sel.|Couvrir et cuire à feu doux 30 minutes, jusqu’à tendreté. Écraser légèrement si souhaité.',45)
add('pilau','Pilau aux épices','Pilaf','300 g de riz|400 g de bœuf en petits cubes|1 oignon|2 gousses d’ail|1 c. à café de cumin|4 gousses de cardamome|1 bâton de cannelle|2 c. à soupe d’huile|750 ml de bouillon','Dorer la viande avec l’oignon dans l’huile. Ajouter ail et épices.|Verser 300 ml de bouillon et mijoter 40 minutes jusqu’à tendreté.|Ajouter le riz et le reste du bouillon ; couvrir et cuire environ 20 minutes, en ajustant le liquide au riz.',75)
add('misir','Misir wot','Wat (food)','250 g de lentilles corail|2 oignons|2 gousses d’ail|1 c. à soupe de concentré de tomate|1 à 2 c. à café de berbéré|2 c. à soupe d’huile|700 ml d’eau|Sel','Faire fondre les oignons très finement hachés dans l’huile 10 minutes.|Ajouter ail, berbéré et concentré. Remuer, puis ajouter lentilles rincées et eau.|Mijoter 25 minutes en remuant. Ajouter de l’eau si nécessaire ; servir avec de l’injera ou du pain.',40)
add('sambusa','Sambusas aux lentilles','Samosa','8 feuilles de brick|200 g de lentilles cuites|1 oignon|1 c. à café de cumin|Coriandre|2 c. à soupe d’huile|Sel','Faire revenir l’oignon avec le cumin. Ajouter les lentilles égouttées et la coriandre ; laisser refroidir.|Couper les feuilles en bandes, garnir et plier en triangles en enfermant la farce.|Badigeonner d’huile et cuire 15 à 20 minutes à 190 °C en retournant.',35)
add('bobotie','Bobotie','Bobotie','500 g de bœuf haché|1 oignon|1 tranche de pain|250 ml de lait|2 œufs|2 c. à soupe de raisins secs|1 c. à soupe de curry doux|1 c. à soupe de chutney|1 c. à soupe d’huile|Sel','Tremper le pain dans le lait. Faire revenir oignon, curry puis viande jusqu’à cuisson.|Mélanger viande, pain essoré, raisins et chutney. Étaler dans un plat.|Battre les œufs avec le lait réservé, verser dessus et cuire 30 à 35 minutes à 180 °C jusqu’à prise de la garniture.',55)
add('chakalaka','Chakalaka','Chakalaka','1 oignon|2 carottes|1 poivron|400 g de tomates concassées|400 g de haricots blancs cuits|1 c. à soupe de curry|2 c. à soupe d’huile|Sel','Faire revenir l’oignon et le poivron émincés dans l’huile.|Ajouter carottes râpées, curry et tomates ; cuire 15 minutes.|Ajouter les haricots égouttés et mijoter 10 minutes.',35)
add('seswaa','Seswaa','Seswaa','800 g de bœuf à mijoter|1 oignon|800 ml d’eau|Sel','Placer la viande, l’oignon et l’eau dans une cocotte. Saler légèrement.|Couvrir et mijoter environ 3 heures, jusqu’à ce que la viande s’effiloche facilement ; ajouter de l’eau au besoin.|Retirer les os éventuels, effilocher la viande et réduire le jus pour l’enrober.',190)
add('romazava','Romazava','Romazava','500 g de bœuf à mijoter|300 g de brèdes alimentaires ou de cresson|2 tomates|1 oignon|2 gousses d’ail|2 cm de gingembre|1 c. à soupe d’huile|800 ml d’eau|Sel','Faire revenir viande et oignon. Ajouter tomates, ail et gingembre.|Verser l’eau et mijoter 1 h 15, jusqu’à tendreté.|Ajouter les feuilles lavées et cuire encore 15 minutes. Servir avec du riz.',105,note='Le cresson est une substitution domestique ; les brèdes locales donnent au plat son caractère régional.')
add('rougail','Rougail saucisses','Rougail saucisse','4 saucisses à cuire|4 tomates|2 oignons|2 gousses d’ail|1 c. à soupe d’huile|Piment facultatif','Cuire les saucisses dans l’eau selon leur emballage, puis les couper.|Faire revenir oignons et saucisses. Ajouter ail et tomates coupées.|Mijoter 25 minutes jusqu’à réduction de la sauce. Ajouter le piment à convenance.',45)
add('cachupa','Cachupa','Cachupa','200 g de maïs sec à cachupa|150 g de haricots secs|300 g de porc à mijoter|1 patate douce|1/4 de chou|1 oignon|2 tomates|2 c. à soupe d’huile|Eau, sel','Faire tremper séparément maïs et haricots une nuit. Jeter l’eau de trempage.|Cuire les haricots dans de l’eau neuve, à franche ébullition 10 minutes puis jusqu’à tendreté. Cuire le maïs séparément jusqu’à ce qu’il s’attendrisse.|Faire revenir porc, oignon et tomates. Ajouter maïs, haricots et eau à hauteur ; mijoter 1 heure. Ajouter patate douce et chou pour les 30 dernières minutes.',180)
add('calulu','Calulu de poisson','Calulu','600 g de poisson en morceaux|200 g de gombos|200 g d’épinards|2 tomates|1 aubergine|1 oignon|2 c. à soupe d’huile de palme alimentaire|300 ml d’eau|Sel','Faire revenir l’oignon ; ajouter tomates, aubergine et eau. Cuire 15 minutes.|Ajouter poisson et gombos ; mijoter 15 minutes ou jusqu’à cuisson du poisson.|Ajouter les épinards pour les 5 dernières minutes ; servir avec du riz ou une pâte de maïs.',45)
add('coconutfish','Poisson au lait de coco','Fish curry','600 g de poisson blanc|400 ml de lait de coco|1 oignon|2 tomates|1 citron vert|1 c. à café de curcuma|1 c. à soupe d’huile|Sel','Faire revenir l’oignon dans l’huile ; ajouter tomates et curcuma, puis cuire 5 minutes.|Verser le lait de coco et mijoter 10 minutes.|Ajouter le poisson en morceaux ; cuire doucement 8 à 12 minutes selon son épaisseur, jusqu’à cuisson complète. Ajouter le citron.',35,note='Version domestique d’une préparation présente dans plusieurs cuisines insulaires ; les épices locales diffèrent.')
add('gombo','Sauce gombo','Okra soup','400 g de gombos|300 g de poisson|2 tomates|1 oignon|2 c. à soupe d’huile|500 ml d’eau|Sel','Faire revenir oignon et tomates dans l’huile.|Ajouter les gombos coupés et l’eau. Cuire 15 minutes.|Ajouter le poisson ; mijoter jusqu’à cuisson complète, environ 10 minutes. Servir avec du riz ou une pâte de céréales.',35)
# Europe and the eastern Mediterranean.
add('ratatouille','Ratatouille','Ratatouille','2 courgettes|1 aubergine|2 poivrons|4 tomates|1 oignon|2 gousses d’ail|3 c. à soupe d’huile d’olive|Thym, sel','Couper les légumes. Faire revenir oignon, aubergine et poivrons dans l’huile 10 minutes.|Ajouter courgettes, tomates, ail et thym.|Mijoter à découvert 35 minutes en remuant, jusqu’à tendreté et réduction du jus.',55)
add('quiche','Quiche lorraine','Quiche lorraine','1 pâte brisée|150 g de lardons|3 œufs|200 ml de crème|100 ml de lait|Poivre, muscade','Étaler la pâte dans un moule et piquer le fond. Faire revenir les lardons et les égoutter.|Battre œufs, crème, lait, poivre et muscade ; répartir les lardons sur le fond.|Verser l’appareil et cuire 35 à 40 minutes à 180 °C, jusqu’à prise du centre.',50)
add('bourguignon','Bœuf bourguignon','Beef bourguignon','800 g de bœuf à braiser|2 carottes|1 oignon|250 g de champignons|500 ml de vin rouge|300 ml de bouillon|1 c. à soupe de farine|2 c. à soupe d’huile|Thym, laurier, sel','Dorer la viande dans l’huile. Ajouter oignon et carottes, puis la farine.|Verser vin et bouillon en remuant. Ajouter les herbes et mijoter à couvert 2 h 30 à 3 heures, jusqu’à tendreté.|Faire sauter les champignons et les ajouter pour les 20 dernières minutes.',200)
add('crepes','Crêpes','Crêpe','250 g de farine|3 œufs|500 ml de lait|30 g de beurre fondu|1 pincée de sel','Mélanger farine et sel. Incorporer les œufs puis le lait progressivement en fouettant.|Ajouter le beurre fondu et laisser reposer 30 minutes.|Verser une petite louche dans une poêle chaude légèrement graissée. Cuire les deux faces et recommencer.',50)
add('gratin','Gratin dauphinois','Gratin dauphinois','1 kg de pommes de terre|400 ml de crème|300 ml de lait|1 gousse d’ail|20 g de beurre|Sel, poivre, muscade','Éplucher et trancher finement les pommes de terre. Frotter un plat avec l’ail et le beurrer.|Disposer les pommes de terre assaisonnées. Verser lait et crème.|Cuire 75 à 90 minutes à 160 °C, jusqu’à ce qu’un couteau traverse les pommes de terre sans résistance.',105)
add('menemen','Menemen','Menemen','4 œufs|4 tomates|2 poivrons verts doux|2 c. à soupe d’huile d’olive|Sel, piment doux','Faire revenir les poivrons coupés dans l’huile 8 minutes.|Ajouter tomates coupées, sel et piment. Cuire 15 minutes.|Incorporer les œufs légèrement battus et remuer doucement jusqu’à la consistance souhaitée.',30)
add('mercimek','Mercimek çorbası','Mercimek çorbası','250 g de lentilles corail|1 carotte|1 oignon|1 petite pomme de terre|1 c. à soupe de concentré de tomate|2 c. à soupe d’huile|1,2 l d’eau|Cumin, sel|1 citron','Faire revenir l’oignon dans l’huile, ajouter le concentré et remuer.|Ajouter les légumes coupés, les lentilles rincées et l’eau. Cuire 25 à 30 minutes.|Mixer, ajuster l’eau et l’assaisonnement. Servir avec du citron.',40)
add('kofte','Köfte','Kofta','500 g de bœuf haché|1 oignon râpé et égoutté|40 g de chapelure|1 œuf|1 c. à café de cumin|Persil, sel, poivre|1 c. à soupe d’huile','Mélanger la viande, l’oignon, la chapelure, l’œuf et les aromates.|Former de petites boulettes aplaties. Réfrigérer 20 minutes.|Cuire dans une poêle huilée en retournant, jusqu’à cuisson complète à cœur, environ 12 minutes selon l’épaisseur.',40)
add('borek','Börek au fromage','Börek','8 feuilles de pâte filo|250 g de feta|150 g d’épinards cuits et essorés|1 œuf|150 ml de lait|3 c. à soupe d’huile','Mélanger feta et épinards. Battre séparément œuf, lait et huile.|Disposer la moitié des feuilles dans un plat, en les badigeonnant de ce mélange. Répartir la farce puis couvrir des autres feuilles badigeonnées.|Cuire 30 à 35 minutes à 180 °C, jusqu’à coloration.',50)
add('imam','İmam bayıldı','İmam bayıldı','2 grosses aubergines|2 oignons|3 tomates|3 gousses d’ail|5 c. à soupe d’huile d’olive|Persil, sel|100 ml d’eau','Couper les aubergines en deux, huiler et cuire 25 minutes à 190 °C.|Faire fondre les oignons et l’ail avec le reste d’huile. Ajouter tomates et persil ; compoter 15 minutes.|Creuser légèrement les aubergines, les garnir, ajouter l’eau au fond du plat et cuire 25 minutes à 180 °C.',75)
add('dolma','Feuilles de vigne farcies au riz','Dolma','30 feuilles de vigne en saumure|180 g de riz|1 oignon|2 c. à soupe de raisins secs|2 c. à soupe de pignons|3 c. à soupe d’huile d’olive|1 citron|Menthe, sel|400 ml d’eau','Rincer les feuilles. Faire revenir l’oignon ; ajouter riz, raisins, pignons et menthe. Mouiller avec 100 ml d’eau et cuire 5 minutes.|Déposer peu de farce sur chaque feuille, replier les bords et rouler sans serrer.|Ranger dans une casserole, ajouter le reste d’eau, l’huile restante et du citron. Maintenir avec une petite assiette et cuire à feu doux 35 à 45 minutes.',70)
add('hummus','Houmous','Hummus','400 g de pois chiches cuits|3 c. à soupe de tahini|1 citron|1 gousse d’ail|2 c. à soupe d’huile d’olive|4 c. à soupe d’eau froide|Sel','Mixer les pois chiches avec tahini, jus du citron, ail et sel.|Ajouter progressivement l’eau froide pour obtenir une crème lisse.|Verser dans un bol et arroser d’huile d’olive.',15)
add('tabbouleh','Taboulé au persil','Tabbouleh','2 gros bouquets de persil|1 petit bouquet de menthe|3 tomates|2 oignons nouveaux|60 g de boulgour fin|2 citrons|3 c. à soupe d’huile d’olive|Sel','Hydrater le boulgour selon son emballage puis bien égoutter.|Hacher finement les herbes lavées et séchées. Couper tomates et oignons en petits dés.|Mélanger avec boulgour, jus de citron, huile et sel. Laisser reposer 15 minutes au frais.',30)
add('falafel','Falafels','Falafel','250 g de pois chiches secs|1 petit oignon|2 gousses d’ail|1 bouquet de persil|1 c. à café de cumin|1/2 c. à café de bicarbonate alimentaire|Sel|Huile de friture','Faire tremper les pois chiches 12 heures au réfrigérateur ; égoutter soigneusement sans les cuire.|Mixer avec oignon, ail, persil, cumin et sel en gardant une texture granuleuse. Ajouter le bicarbonate et former de petites boulettes.|Frire par petites fournées 5 à 6 minutes, jusqu’à cuisson du centre et coloration. Égoutter.',760)
add('musakhan','Musakhan','Musakhan','4 morceaux de poulet|4 oignons|4 pains plats|2 c. à soupe de sumac|4 c. à soupe d’huile d’olive|30 g de pignons|Sel','Cuire le poulet salé au four à 190 °C pendant 45 à 55 minutes, jusqu’à cuisson complète.|Faire fondre les oignons émincés dans l’huile 25 minutes. Ajouter le sumac.|Garnir les pains d’oignons et de poulet. Passer 5 minutes au four et parsemer de pignons dorés.',65)
add('mansaf','Mansaf, adaptation au yaourt','Mansaf','700 g d’agneau à mijoter|500 g de yaourt nature entier|1 c. à soupe de fécule|1 oignon|300 g de riz|30 g d’amandes|Sel, cardamome|Eau','Cuire l’agneau et l’oignon dans l’eau avec la cardamome environ 1 h 30, jusqu’à tendreté. Garder le bouillon.|Délayer la fécule dans un peu de bouillon froid, mélanger au yaourt puis chauffer doucement en remuant. Ajouter la viande et un peu de bouillon.|Cuire le riz séparément. Servir la viande en sauce dessus, avec les amandes dorées.',115,note='Le mansaf traditionnel utilise du jameed. Cette version remplace le jameed par du yaourt et n’en reproduit pas exactement le goût.')
add('kabsa','Kabsa au poulet','Kabsa','4 morceaux de poulet|300 g de riz basmati|1 oignon|2 tomates|2 c. à soupe d’huile|1 bâton de cannelle|4 gousses de cardamome|1 citron séché facultatif|800 ml d’eau|Sel','Dorer poulet et oignon. Ajouter tomates, épices et eau ; mijoter 35 à 45 minutes jusqu’à cuisson du poulet.|Retirer le poulet et mesurer le bouillon selon la quantité requise par le riz.|Cuire le riz rincé dans ce bouillon à couvert. Servir avec le poulet.',70)
add('shortrice','Riz aux vermicelles','Rice vermicelli','250 g de riz|60 g de vermicelles|30 g de beurre|550 ml d’eau|Sel','Faire dorer les vermicelles dans le beurre en remuant.|Ajouter le riz rincé, l’eau et le sel. Couvrir et cuire à feu doux selon le riz, environ 15 à 20 minutes.|Laisser reposer 5 minutes hors du feu avant d’égrener.',30)
add('pizza','Pizza margherita','Pizza Margherita','400 g de pâte à pizza|200 g de tomates concassées|200 g de mozzarella|Basilic|1 c. à soupe d’huile d’olive|Sel','Chauffer le four à 240 °C avec une plaque à l’intérieur.|Étaler la pâte. Répartir tomates légèrement salées et mozzarella égouttée.|Cuire sur la plaque chaude 12 à 18 minutes. Ajouter basilic et huile.',30)
add('risotto','Risotto aux champignons','Risotto','300 g de riz arborio|300 g de champignons|1 oignon|1 l de bouillon chaud|40 g de beurre|60 g de parmesan','Faire revenir oignon et champignons avec la moitié du beurre.|Ajouter le riz et remuer 2 minutes. Verser le bouillon chaud louche par louche, en remuant, pendant 18 à 22 minutes.|Hors du feu, incorporer le reste du beurre et le parmesan. Servir aussitôt.',35)
add('pasta','Pâtes à la sauce tomate','Pasta al pomodoro','400 g de pâtes|600 g de tomates concassées|2 gousses d’ail|3 c. à soupe d’huile d’olive|Basilic, sel','Faire revenir doucement l’ail dans l’huile. Ajouter les tomates et mijoter 20 minutes.|Cuire les pâtes dans l’eau bouillante salée selon leur emballage.|Égoutter et mélanger à la sauce avec une petite louche d’eau de cuisson. Ajouter le basilic.',30)
add('tortilla','Tortilla de pommes de terre','Spanish omelette','600 g de pommes de terre|6 œufs|1 oignon|100 ml d’huile d’olive|Sel','Émincer pommes de terre et oignon. Les cuire doucement dans l’huile jusqu’à tendreté ; égoutter en gardant un peu d’huile.|Mélanger avec les œufs battus et salés.|Verser dans une poêle huilée, cuire à feu doux puis retourner avec une assiette et cuire l’autre face.',45)
add('gazpacho','Gaspacho','Gazpacho','800 g de tomates mûres|1 concombre|1 poivron|1 gousse d’ail|50 g de pain|3 c. à soupe d’huile d’olive|1 c. à soupe de vinaigre|Sel, eau froide','Couper les légumes et humidifier le pain.|Mixer le tout avec ail, huile, vinaigre et sel. Ajuster avec un peu d’eau froide.|Réfrigérer au moins 1 heure avant de servir.',75)
add('paella','Paella au poulet, version maison','Paella','300 g de riz rond|500 g de poulet en morceaux|200 g de haricots verts|150 g de haricots blancs cuits|2 tomates|900 ml de bouillon|3 c. à soupe d’huile|Safran ou curcuma, sel','Dorer le poulet dans une large poêle. Ajouter haricots verts et tomates ; cuire 10 minutes.|Ajouter riz, épice et bouillon. Répartir puis cuire sans remuer 18 à 25 minutes, jusqu’à cuisson du riz et du poulet.|Ajouter les haricots cuits en cours de cuisson. Laisser reposer 5 minutes.',50)
add('bacalhau','Bacalhau à Brás','Bacalhau à Brás','400 g de morue dessalée|400 g de pommes de terre|1 oignon|4 œufs|3 c. à soupe d’huile|Olives, persil|Huile pour les pommes de terre','Dessaler la morue selon les indications du vendeur. La pocher puis l’effeuiller en retirant les arêtes.|Couper les pommes de terre en fines allumettes, les frire et les égoutter. Faire fondre l’oignon dans l’huile.|Ajouter morue et pommes de terre, puis œufs battus. Remuer à feu doux jusqu’à cuisson. Ajouter olives et persil.',50)
add('caldo','Caldo verde','Caldo verde','500 g de pommes de terre|200 g de chou vert finement émincé|1 oignon|2 gousses d’ail|100 g de chouriço|2 c. à soupe d’huile|1,2 l d’eau|Sel','Cuire pommes de terre, oignon et ail dans l’eau salée 25 minutes. Mixer.|Ajouter le chou en très fines lanières, l’huile et le chouriço en rondelles.|Mijoter 10 à 15 minutes, jusqu’à tendreté du chou.',45)
add('stoemp','Stoemp','Stoemp','800 g de pommes de terre|400 g de carottes|1 poireau|40 g de beurre|100 ml de lait|Sel, poivre','Cuire pommes de terre et carottes en morceaux dans l’eau salée.|Faire fondre le poireau émincé avec la moitié du beurre.|Égoutter les légumes, les écraser avec lait et beurre restant puis incorporer le poireau.',40)
add('stamppot','Stamppot au chou frisé','Stamppot','1 kg de pommes de terre|400 g de chou frisé|150 ml de lait|40 g de beurre|Sel, poivre','Cuire les pommes de terre dans l’eau salée. Ajouter le chou émincé pour les 10 dernières minutes.|Égoutter soigneusement, puis écraser ensemble avec le lait chaud et le beurre.|Assaisonner et servir chaud.',35)
add('rosti','Rösti','Rösti','800 g de pommes de terre à chair ferme|50 g de beurre|Sel, poivre','Précuire les pommes de terre entières 10 minutes ; refroidir, peler et râper grossièrement.|Chauffer la moitié du beurre dans une poêle. Former une galette et cuire à feu moyen-doux 12 minutes.|Retourner à l’aide d’une assiette, ajouter le reste du beurre et dorer l’autre face.',45)
add('spaetzle','Spätzle / Käsknöpfle au fromage','Käsespätzle','300 g de farine|3 œufs|120 ml d’eau|200 g de fromage râpé|2 oignons|30 g de beurre|Sel','Battre farine, œufs, eau et sel pour obtenir une pâte collante. La pousser à travers une râpe à spätzle au-dessus d’eau frémissante salée.|Récupérer les pâtes quand elles remontent et les égoutter.|Dorer les oignons dans le beurre. Mélanger pâtes et fromage à feu doux puis garnir d’oignons.',40)
add('schnitzel','Escalope panée','Schnitzel','4 fines escalopes de veau ou de porc|60 g de farine|2 œufs|150 g de chapelure|Huile de cuisson|1 citron|Sel','Aplatir les escalopes et les saler légèrement.|Passer successivement dans farine, œufs battus et chapelure sans trop tasser.|Cuire dans une poêle avec suffisamment d’huile chaude, des deux côtés jusqu’à cuisson complète. Égoutter et servir avec le citron.',30)
add('goulash','Goulash','Goulash','700 g de bœuf à mijoter|2 oignons|2 pommes de terre|2 carottes|2 c. à soupe de paprika doux|2 tomates|2 c. à soupe d’huile|1 l d’eau|Carvi, sel','Faire fondre les oignons dans l’huile. Retirer brièvement du feu pour ajouter le paprika, puis ajouter viande et tomates.|Verser l’eau, ajouter carvi et sel ; mijoter 1 h 30.|Ajouter carottes et pommes de terre en cubes. Cuire encore 30 minutes jusqu’à tendreté.',140)
add('pierogi','Pierogi aux pommes de terre','Pierogi','300 g de farine|150 ml d’eau tiède|1 c. à soupe d’huile|400 g de pommes de terre cuites|150 g de fromage frais ferme|1 oignon|30 g de beurre|Sel','Pétrir farine, eau, huile et sel ; laisser reposer 20 minutes.|Écraser les pommes de terre avec fromage et la moitié de l’oignon revenu au beurre. Étaler la pâte, découper des disques, garnir et souder.|Pocher dans l’eau frémissante salée 3 minutes après remontée. Servir avec le reste d’oignon doré.',65)
add('borscht','Bortsch','Borscht','3 betteraves crues|2 pommes de terre|1 carotte|1 oignon|200 g de chou|2 c. à soupe de concentré de tomate|1,5 l de bouillon|1 c. à soupe de vinaigre|2 c. à soupe d’huile|Aneth, sel','Faire revenir oignon, carotte et betteraves râpées. Ajouter concentré et vinaigre.|Verser le bouillon ; ajouter pommes de terre en cubes et chou émincé. Mijoter 35 à 45 minutes.|Assaisonner et ajouter l’aneth.',60)
add('draniki','Draniki','Draniki','800 g de pommes de terre|1 oignon|1 œuf|2 c. à soupe de farine|3 c. à soupe d’huile|Sel','Râper finement pommes de terre et oignon. Presser légèrement pour retirer l’excès de liquide.|Mélanger avec œuf, farine et sel.|Former de petites galettes dans une poêle huilée. Cuire 4 à 5 minutes par face à feu moyen, jusqu’à cuisson du centre.',30)
add('blini','Blinis','Blini','200 g de farine|1 œuf|250 ml de lait tiède|5 g de levure boulangère sèche|20 g de beurre fondu|1 pincée de sel','Mélanger levure et lait, puis incorporer farine, œuf, beurre et sel.|Couvrir et laisser lever environ 1 heure.|Cuire de petites louches de pâte dans une poêle légèrement graissée, 1 à 2 minutes par face.',85)
add('mamaliga','Mămăligă','Mămăligă','250 g de semoule de maïs|1 l d’eau|30 g de beurre|150 g de fromage de brebis|Sel','Porter l’eau salée à ébullition. Verser la semoule en pluie en fouettant.|Cuire à feu doux en remuant selon l’emballage, généralement 20 à 30 minutes.|Ajouter le beurre et servir avec le fromage émietté.',35)
add('sarma','Sarma au chou','Sarma (food)','12 feuilles de chou blanchies|350 g de viande hachée|100 g de riz cru|1 oignon|400 g de tomates concassées|500 ml de bouillon|1 c. à soupe d’huile|Paprika, sel','Mélanger viande, riz rincé, oignon finement haché, paprika et sel.|Répartir dans les feuilles de chou et rouler en rentrant les bords.|Disposer dans une cocotte avec tomates, bouillon et huile. Couvrir et mijoter 60 à 75 minutes, jusqu’à cuisson du riz et de la viande.',100)
add('shopska','Salade shopska','Shopska salad','3 tomates|1 concombre|1 poivron|1 petit oignon|150 g de fromage blanc en saumure|2 c. à soupe d’huile|1 c. à soupe de vinaigre|Persil','Couper tomates, concombre, poivron et oignon.|Mélanger avec huile, vinaigre et persil.|Râper ou émietter le fromage par-dessus juste avant de servir.',15)
add('cevapi','Ćevapi','Ćevapi','500 g de bœuf haché|200 g d’agneau haché|2 gousses d’ail|1 c. à café de paprika|Sel, poivre|1 oignon pour servir','Mélanger les viandes avec ail écrasé, paprika, sel et poivre. Pétrir puis réfrigérer 1 heure.|Former de petits cylindres.|Griller en retournant régulièrement jusqu’à cuisson complète à cœur. Servir avec oignon cru et pain plat.',85)
add('tavce','Tavče gravče','Tavče gravče','600 g de haricots blancs cuits|2 oignons|1 poivron|1 c. à soupe de paprika|3 c. à soupe d’huile|250 ml d’eau|Menthe séchée, sel','Faire fondre oignons et poivron dans l’huile. Ajouter le paprika hors du feu.|Mélanger avec haricots, eau et menthe dans un plat.|Cuire 35 à 45 minutes à 180 °C, jusqu’à épaississement et légère coloration.',60)
add('byrek','Byrek aux épinards','Byrek','8 feuilles de pâte filo|400 g d’épinards cuits et essorés|200 g de feta|1 œuf|4 c. à soupe d’huile','Mélanger épinards, feta et œuf.|Huiler la moitié des feuilles et les superposer dans un plat. Étaler la farce, couvrir du reste des feuilles huilées.|Cuire 35 minutes à 180 °C.',50)
add('souvlaki','Souvlaki','Souvlaki','600 g de poulet ou de porc en cubes|1 citron|3 c. à soupe d’huile d’olive|2 gousses d’ail|1 c. à café d’origan|Sel','Mélanger viande, citron, huile, ail et origan. Mariner 1 heure au réfrigérateur.|Enfiler sur des brochettes.|Griller en retournant jusqu’à cuisson complète à cœur. Servir avec pain et salade.',80)
add('tzatziki','Tzatziki','Tzatziki','400 g de yaourt épais|1 concombre|1 gousse d’ail|1 c. à soupe d’huile d’olive|1 c. à soupe de jus de citron|Aneth, sel','Râper le concombre, le saler légèrement puis le presser pour retirer l’eau.|Mélanger avec le yaourt, l’ail écrasé, l’huile et le citron.|Ajouter l’aneth et garder au frais jusqu’au service.',20)
add('stew','Ragoût d’agneau et pommes de terre','Irish stew','700 g d’agneau à mijoter|800 g de pommes de terre|2 oignons|3 carottes|800 ml de bouillon|Thym, sel','Placer viande et oignons dans une cocotte avec le bouillon et le thym.|Mijoter à couvert 1 heure. Ajouter pommes de terre et carottes en morceaux.|Poursuivre 45 à 60 minutes jusqu’à tendreté ; ajuster le liquide.',135)
add('shepherd','Shepherd’s pie','Shepherd’s pie','500 g d’agneau haché|800 g de pommes de terre|1 oignon|2 carottes|150 g de petits pois|1 c. à soupe de concentré de tomate|250 ml de bouillon|40 g de beurre|100 ml de lait|Sel','Cuire les pommes de terre puis les écraser avec beurre et lait.|Faire revenir oignon, carottes et viande. Ajouter concentré, bouillon et petits pois ; mijoter 15 minutes.|Verser dans un plat, couvrir de purée et cuire 25 minutes à 190 °C.',65)
add('fishchips','Fish and chips','Fish and chips','4 filets de poisson blanc|800 g de pommes de terre|150 g de farine|200 ml d’eau gazeuse très froide|1 c. à café de levure chimique|Sel|Huile de friture','Couper les pommes de terre en bâtonnets, bien sécher et frire jusqu’à cuisson. Égoutter.|Mélanger farine, levure, sel et eau gazeuse pour une pâte épaisse.|Enrober le poisson et frire par petites fournées jusqu’à cuisson complète et croûte dorée, environ 6 à 8 minutes selon l’épaisseur.',45)
add('meatballs','Boulettes suédoises','Swedish meatballs','500 g de viande hachée|1 oignon|50 g de chapelure|100 ml de lait|1 œuf|30 g de beurre|150 ml de crème|200 ml de bouillon|1 c. à soupe de farine|Sel, poivre','Tremper la chapelure dans le lait. Mélanger avec viande, oignon haché, œuf et assaisonnement.|Former de petites boulettes et les cuire dans le beurre jusqu’à cuisson complète ; réserver.|Dans la poêle, ajouter la farine, puis bouillon et crème en fouettant. Mijoter 5 minutes et remettre les boulettes.',45)
add('salmonSoup','Soupe de saumon','Lohikeitto','400 g de saumon|500 g de pommes de terre|1 poireau|800 ml de bouillon de poisson|200 ml de crème|20 g de beurre|Aneth, sel','Faire fondre le poireau dans le beurre. Ajouter pommes de terre et bouillon ; cuire 20 minutes.|Ajouter le saumon en cubes et la crème ; frémir doucement 5 à 8 minutes, jusqu’à cuisson du poisson.|Ajouter l’aneth et servir.',35)
add('fishstew','Ragoût de poisson et pommes de terre','Fish stew','600 g de poisson blanc|600 g de pommes de terre|1 oignon|500 ml de bouillon de poisson|30 g de beurre|100 ml de lait|Sel, poivre','Cuire les pommes de terre en cubes dans le bouillon jusqu’à tendreté.|Faire fondre l’oignon dans le beurre et l’ajouter avec le poisson en morceaux.|Cuire doucement jusqu’à cuisson du poisson, puis ajouter le lait et remuer délicatement.',40)
add('smorrebrod','Smørrebrød aux œufs','Smørrebrød','8 petites tranches de pain de seigle|4 œufs|1 concombre|4 radis|30 g de beurre|Aneth, sel, poivre','Cuire les œufs durs, les refroidir et les écaler.|Beurrer le pain. Garnir de concombre et d’œufs en tranches.|Ajouter radis, aneth et assaisonnement. Servir aussitôt.',20)
add('kama','Kama au yaourt','Kama (food)','80 g de farine de kama grillée prête à consommer|600 g de yaourt ou de kéfir|2 c. à soupe de miel|150 g de fruits rouges','Mélanger le kama avec le yaourt ou le kéfir.|Sucrer légèrement avec le miel.|Répartir dans des bols et ajouter les fruits. Servir frais.',10)
add('greyPeas','Pois gris aux oignons','Grey peas','300 g de pois gris secs|2 oignons|150 g de lardons|Sel','Faire tremper les pois une nuit puis jeter l’eau. Les cuire dans de l’eau neuve jusqu’à tendreté, selon le produit.|Faire dorer les lardons et les oignons émincés.|Égoutter les pois, mélanger avec la garniture et servir chaud.',90)
add('potatoPancake','Galettes de pommes de terre','Potato pancake','800 g de pommes de terre|1 oignon|1 œuf|40 g de farine|3 c. à soupe d’huile|Sel, poivre','Râper pommes de terre et oignon puis presser pour retirer l’excès d’eau.|Mélanger avec œuf, farine et assaisonnement.|Former de petites galettes et les cuire dans l’huile 4 à 5 minutes par face, jusqu’à cuisson du centre.',30)
add('khachapuri','Khachapuri au fromage','Khachapuri','400 g de pâte à pain|250 g de mozzarella|150 g de feta|1 œuf|20 g de beurre','Mélanger les fromages râpés avec l’œuf.|Étaler la pâte en deux disques. Garnir chacun de fromage, refermer les bords vers le centre et aplatir délicatement.|Cuire à 220 °C pendant 20 à 25 minutes ; badigeonner de beurre.',40,note='Version domestique fermée, inspirée du khachapuri imérétien ; les fromages géorgiens sont remplacés ici par mozzarella et feta.')
add('lobio','Lobio','Lobio','600 g de haricots rouges cuits|2 oignons|2 gousses d’ail|50 g de noix|2 c. à soupe d’huile|1 c. à café de coriandre moulue|1 c. à soupe de vinaigre|Coriandre fraîche, sel','Faire revenir les oignons dans l’huile. Ajouter ail et coriandre moulue.|Ajouter les haricots avec 150 ml d’eau. Écraser une partie et mijoter 15 minutes.|Ajouter noix hachées, vinaigre et coriandre fraîche.',30)
# Asia.
add('plov','Plov / palov','Pilaf','300 g de riz|500 g d’agneau en cubes|3 carottes|2 oignons|1 tête d’ail|3 c. à soupe d’huile|1 c. à café de cumin|650 ml d’eau|Sel','Dorer viande et oignons dans l’huile. Ajouter carottes en bâtonnets et cumin.|Verser 250 ml d’eau et mijoter 40 minutes. Étaler le riz rincé dessus, placer l’ail entier et ajouter le reste d’eau.|Couvrir et cuire à feu doux environ 25 minutes, jusqu’à cuisson du riz ; ajuster l’eau au besoin.',85)
add('kabuli','Kabuli palaw','Kabuli palaw','300 g de riz basmati|500 g d’agneau|2 carottes|80 g de raisins secs|1 oignon|3 c. à soupe d’huile|Cardamome, cumin, sel|700 ml d’eau','Faire dorer l’agneau et l’oignon ; ajouter épices et eau. Mijoter 1 heure jusqu’à tendreté.|Faire revenir séparément carottes en fins bâtonnets et raisins.|Cuire le riz dans la quantité de bouillon requise, avec la viande. Garnir de carottes et de raisins.',95)
add('manti','Manti','Manti (food)','300 g de farine|150 ml d’eau|350 g de viande hachée|1 oignon|Sel, poivre|Yaourt nature pour servir','Pétrir farine, eau et sel puis laisser reposer 20 minutes. Mélanger viande, oignon haché et poivre.|Étaler finement la pâte, couper en carrés, garnir légèrement et souder les bords.|Cuire à la vapeur 30 à 40 minutes, jusqu’à cuisson complète de la farce. Servir avec du yaourt.',75,note='Version de grands raviolis à la vapeur ; les manti existent sous des tailles et des formes différentes de la Turquie à l’Asie centrale.')
add('besh','Beshbarmak','Beshbarmak','700 g de bœuf ou d’agneau à mijoter|300 g de pâtes plates larges|2 oignons|1,5 l d’eau|Laurier, sel, poivre','Cuire la viande dans l’eau avec le laurier 2 à 3 heures, jusqu’à tendreté. Écumer si nécessaire.|Retirer la viande et la détailler. Cuire les pâtes dans une partie du bouillon.|Pocher les oignons émincés 5 minutes dans du bouillon. Dresser pâtes, viande et oignons avec un peu de jus.',190)
add('buuz','Buuz','Buuz','300 g de farine|150 ml d’eau|400 g de bœuf ou d’agneau haché|1 oignon|1 gousse d’ail|Sel, poivre','Pétrir farine, eau et sel ; reposer 20 minutes.|Mélanger viande, oignon, ail et 3 cuillerées d’eau. Étaler des disques de pâte, garnir et plisser en laissant une petite ouverture.|Cuire à la vapeur 25 à 30 minutes, jusqu’à cuisson de la farce.',65)
add('dal','Dal de lentilles','Dal','250 g de lentilles corail|1 oignon|2 tomates|2 gousses d’ail|2 cm de gingembre|1 c. à café de curcuma|1 c. à café de cumin|2 c. à soupe d’huile|800 ml d’eau|Sel','Cuire les lentilles rincées dans l’eau avec le curcuma 20 minutes.|Faire revenir oignon, ail, gingembre et cumin. Ajouter les tomates et compoter 10 minutes.|Mélanger aux lentilles, saler et mijoter 5 minutes.',35)
add('chana','Chana masala','Chana masala','600 g de pois chiches cuits|400 g de tomates concassées|1 oignon|2 gousses d’ail|2 cm de gingembre|1 c. à café de garam masala|1 c. à café de cumin|2 c. à soupe d’huile|Sel','Faire revenir oignon, ail et gingembre. Ajouter cumin et garam masala.|Ajouter tomates et cuire 10 minutes.|Ajouter pois chiches et 150 ml d’eau ; mijoter 20 minutes.',40)
add('biryani','Biryani au poulet','Biryani','300 g de riz basmati|600 g de poulet désossé|200 g de yaourt|2 oignons|2 gousses d’ail|2 cm de gingembre|2 c. à café de garam masala|3 c. à soupe d’huile|Coriandre, sel','Mariner le poulet dans yaourt, ail, gingembre et épices 1 heure au frais.|Dorer les oignons puis ajouter le poulet et sa marinade. Cuire à couvert 20 minutes. Précuire le riz 6 minutes dans de l’eau bouillante puis égoutter.|Couvrir le poulet de riz, ajouter 100 ml d’eau, fermer hermétiquement et cuire à feu très doux 20 minutes. Vérifier la cuisson du poulet et du riz.',115)
add('aloo','Aloo gobi','Aloo gobi','500 g de pommes de terre|1 petit chou-fleur|1 oignon|2 tomates|1 c. à café de cumin|1 c. à café de curcuma|2 c. à soupe d’huile|100 ml d’eau|Sel','Faire revenir oignon et épices. Ajouter tomates et cuire 5 minutes.|Ajouter pommes de terre en petits cubes, chou-fleur en fleurettes et eau.|Couvrir et cuire 25 à 30 minutes en remuant délicatement, jusqu’à tendreté.',45)
add('roti','Roti / chapati','Chapati','300 g de farine de blé complète fine|200 ml d’eau tiède environ|1/2 c. à café de sel|1 c. à soupe d’huile facultative','Pétrir farine, sel et eau jusqu’à une pâte souple ; ajuster légèrement l’eau. Reposer 20 minutes.|Diviser en 8 boules et étaler en disques fins.|Cuire dans une poêle sèche très chaude, environ 1 minute par face, en retournant jusqu’à l’apparition de taches dorées.',40)
add('momo','Momos aux légumes','Momo (food)','300 g de farine|150 ml d’eau|300 g de chou|1 carotte|1 oignon|2 cm de gingembre|1 c. à soupe d’huile|Sel','Pétrir farine, eau et sel, puis reposer 20 minutes.|Hacher finement les légumes, les faire revenir 8 minutes avec huile et gingembre ; refroidir.|Étaler de petits disques de pâte, garnir et fermer en plissant. Cuire à la vapeur 15 à 20 minutes.',60)
add('ema','Ema datshi, version douce','Ema datshi','4 piments doux ou poivrons longs|1 oignon|200 g de fromage frais salé|20 g de beurre|200 ml d’eau','Couper les piments doux et l’oignon en lanières.|Cuire avec l’eau et le beurre à couvert 15 minutes.|Ajouter le fromage émietté et chauffer doucement en remuant jusqu’à liaison de la sauce.',25,note='Les piments doux et le fromage disponible remplacent ici les ingrédients bhoutanais ; la version traditionnelle est souvent très pimentée.')
add('khichuri','Khichuri','Khichdi','180 g de riz|150 g de lentilles corail|1 oignon|1 carotte|100 g de petits pois|1 c. à café de curcuma|1 c. à café de cumin|2 c. à soupe d’huile|1 l d’eau|Sel','Faire revenir oignon et épices. Ajouter riz et lentilles rincés.|Verser l’eau, ajouter carotte coupée et sel. Cuire doucement 25 minutes en remuant.|Ajouter les petits pois pour les 5 dernières minutes ; ajuster l’eau pour une texture souple.',40)
add('polsambol','Pol sambol','Pol sambol','200 g de noix de coco fraîche râpée|1 petit oignon rouge|1 citron vert|1 c. à café de piment doux ou fort|Sel','Hacher très finement l’oignon.|Mélanger à la noix de coco avec le piment et le sel.|Ajouter le jus de citron vert et travailler à la cuillère. Servir frais en accompagnement.',15)
add('mashuni','Mas huni','Mas huni','200 g de thon cuit émietté|150 g de noix de coco fraîche râpée|1 petit oignon|1 citron vert|Piment facultatif|Sel','Émincer très finement l’oignon et le piment.|Mélanger au thon et à la noix de coco.|Ajouter citron et sel ; servir avec des pains plats.',15)
add('nasi','Nasi goreng','Nasi goreng','600 g de riz cuit refroidi rapidement puis réfrigéré|2 œufs|1 carotte|2 oignons nouveaux|2 gousses d’ail|2 c. à soupe de kecap manis|2 c. à soupe d’huile','Préparer tous les ingrédients avant de chauffer le wok. Faire revenir ail, carotte et oignons.|Ajouter le riz et le kecap manis. Sauter jusqu’à ce que l’ensemble soit bien chaud.|Cuire les œufs au plat à part et les déposer dessus. Servir immédiatement.',20)
add('gado','Gado-gado','Gado-gado','300 g de pommes de terre|200 g de haricots verts|200 g de chou|200 g de tofu|100 g de pâte d’arachide|1 c. à soupe de sauce soja|1 citron vert|150 ml d’eau chaude','Cuire pommes de terre, haricots et chou à la vapeur jusqu’à tendreté. Faire dorer le tofu en cubes dans une poêle.|Délayer la pâte d’arachide avec eau chaude, soja et citron.|Disposer légumes et tofu, puis napper de sauce.',40)
add('satay','Satay de poulet','Satay','600 g de poulet en cubes|2 c. à soupe de sauce soja|1 c. à café de curcuma|1 c. à soupe d’huile|100 g de pâte d’arachide|150 ml de lait de coco|1 citron vert','Mariner le poulet avec soja, curcuma et huile 30 minutes au réfrigérateur.|Enfiler sur des brochettes et griller en retournant jusqu’à cuisson complète.|Chauffer doucement pâte d’arachide et lait de coco ; ajouter citron et servir avec les brochettes.',55)
add('nasikuning','Nasi lemak','Nasi lemak','300 g de riz|250 ml de lait de coco|250 ml d’eau|1 feuille de pandan facultative|4 œufs|1 concombre|60 g de cacahuètes grillées|Sambal selon le goût|Sel','Cuire le riz rincé avec lait de coco, eau, sel et pandan selon les indications du riz ; ajuster le liquide au besoin.|Cuire les œufs durs et couper le concombre.|Servir le riz avec œufs, concombre, cacahuètes et sambal.',35)
add('padthai','Pad thaï','Pad thai','250 g de nouilles de riz|200 g de tofu|2 œufs|150 g de pousses de soja|2 oignons nouveaux|2 c. à soupe de pâte de tamarin|2 c. à soupe de sauce de poisson|1 c. à soupe de sucre|30 g de cacahuètes|2 c. à soupe d’huile','Réhydrater les nouilles selon leur emballage. Mélanger tamarin, sauce de poisson, sucre et 3 cuillerées d’eau.|Dorer le tofu dans l’huile, ajouter les œufs et les brouiller.|Ajouter nouilles et sauce ; sauter jusqu’à cuisson. Ajouter pousses et oignons pour 2 minutes puis les cacahuètes.',30)
add('amok','Amok de poisson','Fish amok','600 g de poisson blanc|300 ml de lait de coco|2 œufs|1 tige de citronnelle tendre|2 gousses d’ail|2 cm de gingembre|1 c. à café de curcuma|1 c. à soupe de sauce de poisson','Mixer citronnelle, ail, gingembre et curcuma avec un peu de lait de coco.|Mélanger au reste de lait, aux œufs et à la sauce de poisson. Ajouter les morceaux de poisson.|Répartir dans des ramequins et cuire à la vapeur 25 à 30 minutes, jusqu’à prise de l’appareil et cuisson du poisson.',45,note='Adaptation domestique au gingembre ; le kroeung cambodgien traditionnel utilise notamment du galanga et d’autres aromates.')
add('laap','Laap au poulet','Larb','500 g de poulet haché|2 citrons verts|2 c. à soupe de sauce de poisson|2 échalotes|Menthe, coriandre|2 c. à soupe de riz cru|Piment facultatif','Griller le riz à sec puis le réduire en poudre grossière.|Cuire le poulet avec 3 cuillerées d’eau jusqu’à cuisson complète ; laisser tiédir.|Mélanger avec échalotes émincées, citron, sauce de poisson, herbes et riz grillé.',25)
add('pho','Phở au poulet','Pho','500 g de poulet|250 g de nouilles de riz|1 oignon|4 cm de gingembre|2 étoiles de badiane|1 bâton de cannelle|1,5 l de bouillon|2 c. à soupe de sauce de poisson|Herbes, citron vert','Faire griller légèrement oignon et gingembre à sec. Les mettre dans le bouillon avec les épices.|Pocher le poulet 25 à 35 minutes jusqu’à cuisson complète. Retirer et effilocher ; filtrer le bouillon et ajouter la sauce de poisson.|Cuire les nouilles séparément puis assembler avec poulet, bouillon brûlant, herbes et citron.',50)
add('adobo','Adobo de poulet','Philippine adobo','700 g de poulet en morceaux|60 ml de sauce soja|60 ml de vinaigre|6 gousses d’ail|2 feuilles de laurier|200 ml d’eau|1 c. à soupe d’huile|Poivre','Dorer le poulet dans l’huile.|Ajouter soja, vinaigre, ail écrasé, laurier, eau et poivre. Porter à frémissement puis couvrir.|Mijoter 35 à 45 minutes jusqu’à cuisson. Découvrir et réduire la sauce 10 minutes.',60)
add('mohinga','Mohinga, version maison','Mohinga','400 g de poisson blanc|250 g de vermicelles de riz|1 oignon|2 gousses d’ail|2 cm de gingembre|1 tige de citronnelle|1 c. à café de curcuma|2 c. à soupe de farine de pois chiches|1,2 l d’eau|2 c. à soupe de sauce de poisson|1 c. à soupe d’huile','Pocher le poisson dans l’eau 10 minutes puis l’effeuiller en retirant les arêtes.|Faire revenir oignon, ail, gingembre, citronnelle et curcuma. Ajouter le bouillon, la farine délayée à froid et le poisson ; mijoter 15 minutes.|Cuire les vermicelles à part. Verser la soupe dessus et assaisonner avec la sauce de poisson.',45)
add('friedrice','Riz sauté aux œufs','Fried rice','600 g de riz cuit refroidi rapidement puis réfrigéré|3 œufs|150 g de petits pois|1 carotte|2 oignons nouveaux|2 c. à soupe de sauce soja|2 c. à soupe d’huile','Brouiller les œufs dans une cuillère d’huile puis réserver.|Sauter carotte coupée finement, petits pois et oignons dans le reste d’huile.|Ajouter riz, soja et œufs. Remuer sur feu vif jusqu’à ce que l’ensemble soit bien chaud. Servir immédiatement.',20)
add('jiaozi','Jiaozi aux légumes','Jiaozi','24 feuilles à raviolis chinois|300 g de chou|150 g de champignons|1 carotte|2 cm de gingembre|2 c. à soupe de sauce soja|1 c. à soupe d’huile','Hacher les légumes et les cuire dans l’huile avec gingembre et soja jusqu’à évaporation de l’eau ; refroidir.|Garnir les feuilles, humidifier les bords et fermer.|Pocher dans l’eau frémissante 5 à 7 minutes, ou selon la pâte utilisée.',40)
add('mapotofu','Mapo tofu, version douce','Mapo tofu','400 g de tofu ferme|150 g de porc haché|1 c. à soupe de doubanjiang|2 gousses d’ail|2 cm de gingembre|200 ml de bouillon|1 c. à café de fécule|1 c. à soupe d’huile|Poivre de Sichuan facultatif','Faire revenir le porc jusqu’à cuisson, puis ajouter ail, gingembre et doubanjiang.|Ajouter tofu en cubes et bouillon. Mijoter 10 minutes.|Délayer la fécule dans 2 cuillerées d’eau froide et incorporer. Cuire 2 minutes ; relever de poivre de Sichuan selon le goût.',30)
add('oyakodon','Oyakodon','Oyakodon','500 g de poulet désossé|4 œufs|1 oignon|300 ml de dashi|3 c. à soupe de sauce soja|2 c. à soupe de mirin|600 g de riz cuit','Faire frémir dashi, soja et mirin. Ajouter oignon émincé et poulet en petits morceaux.|Cuire 10 à 15 minutes, jusqu’à cuisson complète du poulet.|Verser les œufs battus, couvrir et cuire jusqu’à ce qu’ils soient pris. Servir sur le riz chaud.',30)
add('okonomiyaki','Okonomiyaki aux légumes','Okonomiyaki','300 g de chou|150 g de farine|2 œufs|150 ml de dashi ou d’eau|2 oignons nouveaux|2 c. à soupe d’huile|Sauce okonomiyaki pour servir','Mélanger farine, liquide et œufs, puis ajouter chou et oignons finement émincés.|Former quatre galettes dans une poêle huilée.|Cuire à feu moyen-doux environ 5 minutes par face, à couvert si nécessaire, jusqu’à cuisson de la pâte. Ajouter la sauce.',30)
add('bibimbap','Bibimbap','Bibimbap','600 g de riz cuit|4 œufs|2 carottes|200 g d’épinards|200 g de champignons|2 c. à soupe d’huile de sésame|Gochujang, sauce soja','Faire sauter séparément les légumes émincés avec un peu d’huile et de sauce soja.|Cuire les œufs au plat jusqu’à cuisson des blancs.|Répartir le riz chaud dans des bols, ajouter les légumes et les œufs. Servir le gochujang à part et mélanger avant de manger.',35)
add('japchae','Japchae','Japchae','250 g de vermicelles de patate douce|1 carotte|1 poivron|200 g de champignons|150 g d’épinards|3 c. à soupe de sauce soja|1 c. à soupe de sucre|2 c. à soupe d’huile de sésame','Cuire les vermicelles selon leur emballage, égoutter et couper aux ciseaux.|Sauter les légumes émincés jusqu’à tendreté.|Mélanger nouilles et légumes avec soja, sucre et huile de sésame. Réchauffer 2 minutes.',30)
add('mandu','Mandu aux légumes','Mandu (food)','24 feuilles à raviolis|200 g de tofu|200 g de chou|150 g de champignons|2 oignons nouveaux|2 c. à soupe de sauce soja|1 c. à soupe d’huile de sésame','Presser et émietter le tofu. Hacher les légumes et les cuire à la poêle jusqu’à évaporation de l’eau.|Mélanger avec tofu, soja et huile ; laisser refroidir.|Garnir et fermer les raviolis. Cuire à la vapeur 12 à 15 minutes selon leur taille.',45)
add('danbing','Dàn bǐng','Dan bing','120 g de farine|30 g de fécule|250 ml d’eau|4 œufs|2 oignons nouveaux|2 c. à soupe d’huile|Sauce soja','Mélanger farine, fécule et eau. Cuire quatre fines crêpes dans une poêle huilée.|Battre un œuf avec de l’oignon, verser dans la poêle puis poser une crêpe dessus.|Cuire jusqu’à prise de l’œuf. Rouler et couper ; servir avec un peu de sauce soja.',25)
add('ghormeh','Ghormeh sabzi','Ghormeh sabzi','500 g de bœuf à mijoter|240 g de haricots rouges cuits|2 bouquets de persil|1 bouquet de coriandre|1 poireau|1 oignon|1 c. à café de fenugrec séché|2 citrons séchés percés|3 c. à soupe d’huile|700 ml d’eau|Curcuma, sel','Hacher les herbes et le poireau ; les faire revenir doucement dans la moitié de l’huile.|Dorer oignon et viande dans le reste d’huile avec le curcuma. Ajouter eau, herbes, fenugrec et citrons séchés.|Mijoter 1 h 30. Ajouter les haricots pour les 20 dernières minutes ; poursuivre jusqu’à tendreté.',120)
add('kuku','Kuku sabzi','Kuku (food)','6 œufs|1 gros bouquet de persil|1 bouquet de coriandre|1 bouquet d’aneth|2 oignons nouveaux|2 c. à soupe de farine|2 c. à soupe d’huile|Sel, curcuma','Hacher très finement les herbes et les oignons.|Mélanger aux œufs, à la farine et à l’assaisonnement.|Verser dans un petit plat huilé ; cuire 20 à 25 minutes à 180 °C, jusqu’à prise du centre.',35)
add('shakriya','Ragoût au yaourt','Shakriyeh','600 g d’agneau à mijoter|500 g de yaourt entier|1 oignon|1 c. à soupe de fécule|600 ml d’eau|Sel, poivre','Cuire l’agneau et l’oignon dans l’eau 1 h 30, jusqu’à tendreté.|Délayer la fécule dans 100 ml de bouillon refroidi, mélanger au yaourt puis chauffer doucement en remuant.|Ajouter viande et un peu de bouillon pour obtenir une sauce nappante. Servir avec du riz.',110)
# Americas.
add('chili','Chili con carne','Chili con carne','400 g de bœuf haché|400 g de haricots rouges cuits|400 g de tomates concassées|1 oignon|1 poivron|2 c. à café de cumin|1 c. à café de paprika|2 c. à soupe d’huile|Sel','Faire revenir oignon et poivron. Ajouter la viande et cuire en l’émiettant.|Ajouter épices, tomates et 150 ml d’eau ; mijoter 20 minutes.|Ajouter les haricots et poursuivre 10 minutes.',45)
add('maccheese','Macaroni au fromage','Macaroni and cheese','350 g de macaroni|40 g de beurre|40 g de farine|500 ml de lait|200 g de cheddar râpé|Sel, poivre','Cuire les pâtes puis égoutter.|Faire fondre le beurre, ajouter la farine et remuer 1 minute. Verser le lait progressivement en fouettant, cuire jusqu’à épaississement.|Ajouter le fromage puis les pâtes. Servir ou gratiner 10 minutes à 200 °C.',30)
add('pancakes','Pancakes','Pancake','200 g de farine|2 œufs|250 ml de lait|30 g de beurre fondu|1 c. à soupe de sucre|1 sachet de levure chimique|1 pincée de sel','Mélanger les ingrédients secs. Incorporer œufs, lait et beurre sans trop travailler la pâte.|Laisser reposer 10 minutes.|Cuire de petites louches dans une poêle légèrement graissée ; retourner lorsque des bulles apparaissent.',25)
add('tourtiere','Tourtière, version à la viande hachée','Tourtière','2 pâtes brisées|500 g de porc haché|250 g de bœuf haché|1 oignon|1 pomme de terre râpée|150 ml d’eau|Cannelle, girofle, sel, poivre','Cuire viandes, oignon, pomme de terre, eau et une pincée d’épices 25 minutes en remuant. Laisser tiédir.|Garnir un moule avec une pâte, ajouter la farce, couvrir de la seconde pâte et souder. Faire une cheminée.|Cuire 40 à 45 minutes à 190 °C, jusqu’à coloration.',90)
add('poutine','Poutine','Poutine','800 g de pommes de terre|250 g de fromage en grains|400 ml de bouillon de bœuf|20 g de beurre|20 g de farine|Huile de friture|Sel','Préparer des frites avec les pommes de terre, puis les égoutter.|Faire fondre le beurre, ajouter farine puis bouillon en fouettant. Mijoter 8 minutes.|Répartir le fromage sur les frites chaudes et verser la sauce brûlante.',40)
add('tacos','Tacos au poulet','Taco','8 petites tortillas de maïs|500 g de poulet en lanières|1 oignon|2 tomates|1 citron vert|1 c. à café de cumin|1 c. à soupe d’huile|Coriandre, sel','Cuire le poulet dans l’huile avec le cumin jusqu’à cuisson complète.|Couper oignon et tomates ; mélanger avec coriandre, citron et sel.|Réchauffer les tortillas et garnir de poulet puis de salsa.',25)
add('guacamole','Guacamole','Guacamole','3 avocats mûrs|1 citron vert|1 petite tomate|1/2 oignon|Coriandre, sel|Piment facultatif','Écraser grossièrement la chair des avocats avec le jus de citron.|Incorporer tomate et oignon finement coupés.|Ajouter coriandre et sel ; servir rapidement.',15)
add('gallopinto','Gallo pinto','Gallo pinto','500 g de riz cuit|400 g de haricots noirs ou rouges cuits|1 oignon|1 poivron|2 c. à soupe d’huile|Coriandre|Sauce Lizano facultative|Sel','Faire revenir oignon et poivron émincés.|Ajouter haricots et 100 ml de leur liquide, puis le riz.|Faire sauter jusqu’à ce que l’ensemble soit bien chaud ; ajouter coriandre et sauce selon le goût.',20)
add('pupusas','Pupusas au fromage','Pupusa','300 g de masa harina|350 ml d’eau tiède environ|200 g de mozzarella râpée|1 pincée de sel|1 c. à soupe d’huile','Mélanger masa harina, sel et eau jusqu’à obtenir une pâte souple qui ne craque pas.|Former 8 boules, creuser, garnir de fromage et refermer. Aplatir délicatement en galettes.|Cuire dans une poêle légèrement huilée environ 4 minutes par face, jusqu’à cuisson de la pâte.',35)
add('baleadas','Baleadas','Baleada','4 grandes tortillas de blé|400 g de haricots rouges cuits|1 oignon|150 g de fromage émietté|100 g de crème épaisse|1 c. à soupe d’huile','Faire revenir l’oignon, ajouter les haricots et les écraser en chauffant ; détendre avec un peu d’eau.|Réchauffer les tortillas.|Garnir de purée de haricots, de fromage et de crème puis replier.',25)
add('pepián','Pepián de poulet','Pepián','600 g de poulet|3 tomates|1 oignon|1 poivron|40 g de graines de courge|30 g de sésame|1 tortilla de maïs|600 ml de bouillon|Sel, piment selon le goût','Griller à sec tomates, oignon et poivron, puis graines, sésame et tortilla séparément.|Mixer avec un peu de bouillon pour obtenir une sauce.|Faire mijoter le poulet dans cette sauce avec le reste de bouillon 35 à 45 minutes, jusqu’à cuisson complète.',60)
add('sancocho','Sancocho au poulet','Sancocho','600 g de poulet|2 pommes de terre|1 banane plantain verte|2 épis de maïs|1 oignon|2 gousses d’ail|1,5 l d’eau|Coriandre, sel','Mettre poulet, oignon, ail et eau dans une cocotte. Mijoter 20 minutes.|Ajouter les légumes et le plantain pelé en morceaux.|Cuire encore 30 minutes jusqu’à tendreté et cuisson du poulet. Ajouter la coriandre.',60)
add('ropa','Ropa vieja','Ropa vieja','700 g de bœuf à mijoter|2 poivrons|2 oignons|400 g de tomates concassées|2 gousses d’ail|1 c. à café de cumin|2 c. à soupe d’huile|Eau, sel','Cuire le bœuf dans de l’eau environ 2 heures jusqu’à tendreté ; l’effilocher et garder du bouillon.|Faire revenir oignons, poivrons et ail dans l’huile.|Ajouter tomates, cumin, viande et une louche de bouillon. Mijoter 25 minutes.',160)
add('moros','Moros y cristianos','Moros y Cristianos (food)','250 g de riz|400 g de haricots noirs cuits|1 oignon|1 poivron|2 gousses d’ail|500 ml de bouillon|2 c. à soupe d’huile|Cumin, origan, sel','Faire revenir oignon, poivron et ail. Ajouter cumin et origan.|Ajouter riz rincé, haricots et bouillon.|Couvrir et cuire à feu doux environ 20 minutes, selon le riz. Reposer 5 minutes.',35)
add('mangu','Mangú','Mangú','4 bananes plantains vertes|1 oignon rouge|30 g de beurre|1 c. à soupe de vinaigre|1 c. à soupe d’huile|Sel','Peler et couper les plantains. Cuire dans de l’eau salée jusqu’à tendreté, environ 25 minutes.|Faire revenir l’oignon émincé dans l’huile puis ajouter le vinaigre.|Écraser les plantains avec beurre et un peu d’eau de cuisson ; servir avec l’oignon.',35)
add('joumou','Soupe joumou','Soup joumou','500 g de courge|400 g de bœuf en petits cubes|2 carottes|2 pommes de terre|100 g de petites pâtes|1 oignon|1 citron vert|1,5 l d’eau|Thym, sel|1 c. à soupe d’huile','Faire dorer viande et oignon puis couvrir d’eau et mijoter 1 heure.|Cuire la courge séparément dans de l’eau puis mixer. Ajouter cette purée à la viande avec les légumes.|Cuire 25 minutes puis ajouter les pâtes pour le temps indiqué sur leur emballage. Assaisonner au citron.',110)
add('jerk','Poulet jerk','Jerk (cooking)','600 g de poulet|3 oignons nouveaux|2 gousses d’ail|1 citron vert|1 c. à café de quatre-épices|1 c. à café de thym|1 c. à soupe de sauce soja|2 c. à soupe d’huile|Piment selon le goût','Mixer les aromates avec citron, soja et huile.|Enrober le poulet et laisser mariner au réfrigérateur 2 heures.|Cuire au four à 190 °C pendant 40 à 50 minutes selon les morceaux, jusqu’à cuisson complète.',180)
add('ricepeas','Rice and peas','Rice and peas','300 g de riz|400 g de haricots rouges cuits|250 ml de lait de coco|250 ml d’eau|2 oignons nouveaux|1 gousse d’ail|Thym, sel','Mettre eau, lait de coco, aromates et haricots dans une casserole ; frémir 5 minutes.|Ajouter le riz rincé, couvrir et cuire à feu doux selon l’emballage, environ 20 minutes.|Retirer du feu et laisser reposer 5 minutes.',35)
add('callaloo','Callaloo, adaptation aux épinards','Callaloo','500 g d’épinards|200 g de gombos|1 oignon|250 ml de lait de coco|200 ml d’eau|1 gousse d’ail|1 c. à soupe d’huile|Thym, sel','Faire revenir oignon et ail dans l’huile.|Ajouter gombos coupés, feuilles, lait de coco, eau et thym. Mijoter 25 minutes.|Écraser ou mixer légèrement et assaisonner.',35,note='Les feuilles locales varient selon les îles ; cette version utilise des épinards et ne nécessite pas de préparer des feuilles de taro.')
add('couCou','Cou-cou','Cou-cou','250 g de semoule de maïs|200 g de gombos|900 ml d’eau|20 g de beurre|Sel','Couper les gombos et les cuire dans l’eau salée 10 minutes.|Verser progressivement la semoule en remuant.|Cuire à feu doux selon l’emballage, jusqu’à épaississement et cuisson de la semoule. Ajouter le beurre et servir avec une sauce.',35)
add('arepa','Arepas au fromage','Arepa','300 g de farine de maïs précuite pour arepas|400 ml d’eau tiède environ|150 g de fromage râpé|1/2 c. à café de sel|1 c. à soupe d’huile','Mélanger eau, sel et farine ; laisser gonfler 5 minutes. Ajouter le fromage et ajuster l’eau pour une pâte souple.|Former 8 galettes épaisses.|Cuire dans une poêle légèrement huilée à feu moyen-doux 6 à 8 minutes par face, jusqu’à cuisson du centre.',35)
add('feijoada','Feijoada, version simplifiée','Feijoada','600 g de haricots noirs cuits|400 g de porc en cubes|150 g de saucisse fumée|1 oignon|2 gousses d’ail|2 feuilles de laurier|2 c. à soupe d’huile|500 ml d’eau|Sel','Faire dorer le porc avec l’oignon et l’ail.|Ajouter eau et laurier ; mijoter 45 minutes jusqu’à tendreté.|Ajouter haricots et saucisse en rondelles ; cuire encore 25 minutes. Écraser quelques haricots pour lier la sauce.',85)
add('moqueca','Moqueca de poisson','Moqueca','600 g de poisson blanc|2 tomates|1 poivron|1 oignon|250 ml de lait de coco|1 citron vert|2 c. à soupe d’huile de palme alimentaire ou d’olive|Coriandre, sel','Couper les légumes en rondelles et les faire fondre doucement dans l’huile.|Ajouter le poisson, le lait de coco et le sel. Couvrir et mijoter 12 à 18 minutes, jusqu’à cuisson du poisson.|Ajouter citron et coriandre.',35)
add('empanada','Empanadas au bœuf','Empanada','2 pâtes brisées|350 g de bœuf haché|1 oignon|1 poivron|1 œuf dur|1 c. à café de cumin|1 c. à soupe d’huile|Sel','Faire revenir oignon, poivron et viande avec cumin et sel jusqu’à cuisson. Refroidir et ajouter l’œuf dur haché.|Découper des disques de pâte, garnir, replier et bien souder.|Cuire 25 à 30 minutes à 190 °C.',55)
add('locro','Locro, version au maïs et à la courge','Locro','400 g de maïs blanc précuit|400 g de haricots blancs cuits|500 g de courge|300 g de porc en cubes|1 oignon|1 c. à café de paprika|1 c. à soupe d’huile|800 ml d’eau|Sel','Dorer oignon et porc. Ajouter paprika et eau ; mijoter 45 minutes.|Ajouter maïs, haricots et courge en cubes.|Mijoter 35 minutes jusqu’à tendreté ; écraser une partie de la courge pour lier.',95)
add('chipa','Chipa','Chipa','250 g de fécule de manioc alimentaire|150 g de fromage ferme râpé|1 œuf|50 g de beurre|80 ml de lait environ|1 pincée de sel','Mélanger fécule, fromage et sel. Incorporer beurre, œuf et lait peu à peu pour obtenir une pâte souple.|Former de petites boules ou des anneaux.|Cuire 20 à 25 minutes à 190 °C, jusqu’à légère coloration.',35)
add('sopaParaguaya','Sopa paraguaya','Sopa paraguaya','250 g de farine de maïs fine|2 oignons|3 œufs|300 ml de lait|200 g de fromage frais ferme|40 g de beurre|Sel','Faire fondre les oignons émincés dans le beurre.|Mélanger farine, lait et œufs, puis incorporer fromage émietté et oignons.|Verser dans un plat graissé et cuire 35 à 45 minutes à 180 °C, jusqu’à prise du centre.',55)
add('lomo','Lomo saltado','Lomo saltado','500 g de bœuf tendre en lanières|2 tomates|1 oignon rouge|2 c. à soupe de sauce soja|1 c. à soupe de vinaigre|2 c. à soupe d’huile|Coriandre|Frites et riz cuits pour servir','Saisir le bœuf par petites fournées dans une poêle très chaude.|Ajouter oignon en quartiers et tomates ; sauter brièvement.|Ajouter soja et vinaigre, mélanger puis servir avec frites, riz et coriandre.',25)
add('papahuancaina','Papas a la huancaína','Papa a la huancaína','800 g de pommes de terre|200 g de fromage frais salé|150 ml de lait concentré non sucré|1 à 2 c. à café de pâte d’ají amarillo|4 crackers nature|2 c. à soupe d’huile|2 œufs durs|Olives','Cuire les pommes de terre, les refroidir et les trancher.|Mixer fromage, lait, ají, crackers et huile en sauce lisse ; ajuster l’épaisseur avec un peu de lait.|Napper les pommes de terre et garnir d’œufs durs et d’olives.',40)
add('humita','Humitas, version en ramequins','Humita','600 g de grains de maïs|1 oignon|100 ml de lait|150 g de fromage frais|30 g de beurre|Basilic, sel','Faire fondre l’oignon dans le beurre. Mixer grossièrement le maïs avec le lait.|Mélanger maïs, oignon, fromage émietté et basilic.|Répartir dans des ramequins et cuire à la vapeur 35 à 45 minutes, jusqu’à prise.',60,note='Adaptation domestique sans enveloppe ; les humitas traditionnelles sont souvent cuites dans les feuilles de maïs.')
add('saltena','Salteñas, chaussons simplifiés','Salteña','2 pâtes brisées|350 g de poulet cuit effiloché|1 pomme de terre cuite|100 g de petits pois|1 oignon|150 ml de bouillon|1 c. à café de paprika|1 c. à soupe d’huile|Sel','Faire revenir l’oignon et le paprika. Ajouter poulet, pomme de terre en dés, petits pois et bouillon ; réduire puis refroidir complètement.|Garnir des disques de pâte sans trop de liquide, replier et souder soigneusement.|Cuire 25 à 30 minutes à 190 °C.',55,note='Version simplifiée sans bouillon gélifié ; la salteña bolivienne classique est plus juteuse et utilise une pâte spécifique.')
add('pom','Pom, adaptation au taro','Pom (dish)','800 g de taro alimentaire épluché|400 g de poulet désossé|1 oignon|2 tomates|1 orange|1 citron|40 g de beurre|Sel','Cuire le taro dans l’eau jusqu’à tendreté complète puis l’écraser ; ne pas le goûter cru.|Faire revenir le poulet en petits morceaux avec oignon et tomates jusqu’à cuisson complète.|Mélanger la purée de taro avec beurre et jus d’agrumes. Alterner purée et poulet dans un plat puis cuire 35 minutes à 180 °C.',75,note='Le pom surinamais emploie normalement du pomtayer. Le taro est ici une substitution domestique explicitement différente.')
add('cookup','Cook-up rice','Cook-up rice','250 g de riz|400 g de niébés cuits|300 g de poulet désossé|250 ml de lait de coco|300 ml d’eau|1 oignon|1 gousse d’ail|Thym, sel|1 c. à soupe d’huile','Faire revenir oignon, ail et poulet en petits morceaux.|Ajouter eau, lait de coco, thym et sel. Frémir 10 minutes.|Ajouter riz et niébés. Couvrir et cuire selon le riz, jusqu’à cuisson complète du poulet et absorption du liquide.',45)
# Pacific and island preparations.
add('damper','Damper','Damper (food)','400 g de farine|1 sachet de levure chimique|250 ml de lait|40 g de beurre|1/2 c. à café de sel','Mélanger farine, levure et sel. Sabler avec le beurre puis incorporer le lait sans trop pétrir.|Former un pain rond et inciser le dessus.|Cuire 30 à 40 minutes à 200 °C ; vérifier que le centre est cuit.',50)
add('anzac','Biscuits Anzac','Anzac biscuit','100 g de flocons d’avoine|100 g de farine|70 g de noix de coco râpée|100 g de sucre|100 g de beurre|2 c. à soupe de golden syrup|1/2 c. à café de bicarbonate|2 c. à soupe d’eau','Mélanger avoine, farine, coco et sucre. Faire fondre beurre et sirop.|Dissoudre le bicarbonate dans l’eau chaude, l’ajouter au beurre puis mélanger aux ingrédients secs.|Former de petits tas espacés et cuire 12 à 15 minutes à 170 °C. Refroidir sur la plaque.',30)
add('kumara','Kūmara rôties','Kūmara','800 g de patates douces|2 c. à soupe d’huile|1 c. à café de romarin|Sel','Laver les patates douces et les couper en quartiers.|Mélanger avec huile, romarin et sel.|Cuire 35 à 45 minutes à 200 °C en retournant, jusqu’à tendreté.',50)
add('palusami','Palusami, adaptation aux épinards','Palusami','600 g d’épinards|400 ml de lait de coco|1 oignon|1 pincée de sel','Faire tomber les épinards à la poêle puis bien les égoutter.|Mélanger avec oignon très finement émincé, lait de coco et sel.|Répartir dans des ramequins couverts et cuire 30 à 40 minutes à 180 °C.',50,note='Les feuilles de taro traditionnelles sont remplacées par des épinards. Le résultat est une adaptation, pas la préparation traditionnelle en feuilles.')
add('laplap','Laplap, adaptation au four','Laplap','800 g de patate douce|250 ml de lait de coco|200 g d’épinards|1 pincée de sel','Râper finement la patate douce épluchée. Mélanger avec 150 ml de lait de coco et le sel.|Déposer sur les épinards dans un plat peu profond ; couvrir et cuire 50 à 60 minutes à 180 °C, jusqu’à cuisson complète.|Verser le reste du lait de coco et remettre 10 minutes au four.',80,note='Version au four à la patate douce ; la préparation vanuataise emploie divers tubercules et des feuilles, souvent dans un four de pierres.')
add('poe','Po’e à la banane','Poʻe','600 g de bananes mûres épluchées|120 g de fécule de tapioca alimentaire|200 ml de lait de coco|1 gousse de vanille|1 c. à soupe d’huile','Écraser les bananes puis mélanger à la fécule et aux graines de vanille.|Étaler dans un plat huilé sur environ 3 cm d’épaisseur.|Cuire 35 à 45 minutes à 180 °C, jusqu’à prise. Couper et servir avec le lait de coco.',55)
add('coconutrice','Riz au lait de coco','Coconut rice','300 g de riz|250 ml de lait de coco|300 ml d’eau|1 pincée de sel','Rincer le riz. Le mettre dans une casserole avec lait de coco, eau et sel.|Porter à frémissement puis couvrir et cuire à feu doux selon le riz, généralement 15 à 20 minutes ; ajuster le liquide.|Laisser reposer 5 minutes avant d’égrener.',30)
add('breadfruit','Fruit à pain rôti','Breadfruit','1 fruit à pain mûr mais ferme|3 c. à soupe d’huile|Sel','Éplucher le fruit à pain, retirer le cœur fibreux et couper la chair en quartiers.|Précuire dans l’eau frémissante 15 minutes, puis égoutter.|Huiler, saler et rôtir 25 à 35 minutes à 200 °C, jusqu’à tendreté complète.',60)
add('grilledfish','Poisson grillé au citron','Grilled fish','4 filets épais de poisson|2 citrons verts|2 c. à soupe d’huile|1 gousse d’ail|Sel','Essuyer le poisson et l’enduire d’huile, d’ail et d’un peu de jus de citron.|Cuire au gril ou à la poêle, sur les deux faces, jusqu’à cuisson complète et chair se détachant facilement ; adapter le temps à l’épaisseur.|Servir avec le reste de citron et un accompagnement.',25,note='Préparation simple partagée par de nombreuses cuisines côtières ; elle n’est pas présentée comme une invention exclusive d’un pays.')
add('kesra','Kesra','Kesra','400 g de semoule fine de blé dur|60 ml d’huile|180 à 220 ml d’eau|1 c. à café de sel','Sabler la semoule avec l’huile et le sel. Ajouter l’eau progressivement pour former une pâte homogène.|Diviser en deux galettes de 1 cm d’épaisseur et piquer à la fourchette.|Cuire dans une poêle épaisse à feu moyen-doux environ 8 minutes par face, en tournant pour une cuisson régulière.',35)
add('oignons','Soupe à l’oignon','French onion soup','600 g d’oignons|40 g de beurre|1 c. à soupe de farine|1 l de bouillon|4 tranches de pain|120 g de fromage râpé|Sel, poivre','Faire fondre les oignons émincés dans le beurre 30 minutes, en remuant jusqu’à coloration.|Ajouter la farine, puis le bouillon ; mijoter 20 minutes.|Verser dans des bols allant au four, couvrir de pain et de fromage puis gratiner.',65)
add('rizgras','Riz gras','Riz gras','300 g de riz|400 g de poulet en petits morceaux|1 oignon|2 tomates|2 carottes|1/4 de chou|2 c. à soupe de concentré de tomate|3 c. à soupe d’huile|700 ml d’eau|Ail, sel','Dorer le poulet avec l’oignon et l’ail. Ajouter tomates et concentré ; cuire 5 minutes.|Ajouter eau et légumes, mijoter 20 minutes.|Ajouter le riz rincé et cuire à couvert selon le riz, jusqu’à cuisson complète du poulet. Ajuster le liquide.',55)
add('machboos','Machbous au poulet','Kabsa','4 morceaux de poulet|300 g de riz basmati|2 tomates|1 oignon|1 citron séché percé|1 c. à café de baharat|4 gousses de cardamome|2 c. à soupe d’huile|800 ml d’eau|Sel','Dorer poulet et oignon dans l’huile. Ajouter tomates, épices, citron séché et eau.|Mijoter jusqu’à cuisson du poulet, environ 40 minutes. Le réserver.|Mesurer le bouillon selon le riz et y cuire celui-ci à couvert. Servir avec le poulet.',70,note='Préparation partagée dans le Golfe ; mélanges d’épices, appellations et garnitures changent d’un pays à l’autre.')
add('saltah','Saltah, adaptation au bœuf','Saltah','400 g de bœuf en petits cubes|2 pommes de terre|2 tomates|1 oignon|2 gousses d’ail|2 c. à soupe de fenugrec moulu|1 bouquet de coriandre|1 citron|1 c. à soupe d’huile|700 ml d’eau|Sel','Faire tremper le fenugrec dans de l’eau 2 heures ; jeter doucement l’eau surnageante.|Faire revenir viande, oignon et ail. Ajouter tomates, eau et sel ; mijoter 1 heure. Ajouter pommes de terre et cuire 25 minutes.|Fouetter le fenugrec égoutté avec citron et coriandre hachée. Déposer une cuillerée de cette mousse sur le ragoût très chaud.',150)
add('zigni','Zigni','Zigni','600 g de bœuf en petits cubes|2 oignons|400 g de tomates concassées|2 gousses d’ail|1 à 2 c. à café de berbéré|2 c. à soupe d’huile|300 ml d’eau|Sel','Faire fondre les oignons dans l’huile 15 minutes. Ajouter ail et berbéré.|Ajouter viande et tomates puis l’eau.|Mijoter à couvert 1 h 15 à 1 h 30, jusqu’à tendreté ; servir avec de l’injera ou du pain.',115)
add('efo','Efo riro','Ẹ̀fọ́ riro','500 g d’épinards|300 g de bœuf en petits cubes|1 poivron rouge|2 tomates|1 oignon|2 c. à soupe d’huile de palme alimentaire|Sel, piment facultatif|Eau','Cuire le bœuf dans de l’eau jusqu’à tendreté et conserver une louche de bouillon.|Mixer poivron, tomates et moitié de l’oignon. Faire revenir le reste d’oignon dans l’huile ; ajouter le mélange et réduire 15 minutes.|Ajouter viande, bouillon et épinards. Mijoter 10 minutes.',95)
add('banku','Banku, avec pâte prête à cuire','Banku','600 g de pâte fermentée à banku prête à cuire|500 ml d’eau environ|Sel','Délayer la pâte fermentée alimentaire achetée prête à cuire dans l’eau et saler légèrement.|Chauffer en remuant sans arrêt avec une spatule solide, puis cuire selon la notice du produit jusqu’à pâte homogène et complètement cuite.|Former des portions à la cuillère humide et servir avec une sauce.',30,note='Cette recette utilise une pâte fermentée préparée ; elle ne décrit pas de fermentation domestique.')
add('waakye','Waakye','Waakye','250 g de riz|400 g de niébés cuits|500 ml de liquide de cuisson des niébés|Sel','Mettre les niébés et leur liquide dans une casserole. Porter à frémissement.|Ajouter le riz rincé et le sel. Couvrir et cuire à feu doux selon le riz, environ 20 minutes.|Laisser reposer 5 minutes. Servir avec une sauce ou des légumes.',30,note='Version simple sans feuilles de sorgho, qui donnent habituellement au waakye sa coloration caractéristique.')
add('katogo','Katogo aux haricots','Katogo','6 bananes à cuire vertes|400 g de haricots cuits|2 tomates|1 oignon|1 c. à soupe d’huile|400 ml d’eau|Sel','Éplucher et couper les bananes à cuire.|Faire revenir oignon et tomates. Ajouter les bananes, l’eau et le sel ; couvrir et cuire 25 minutes.|Ajouter les haricots et cuire encore 10 minutes, jusqu’à tendreté.',45)
add('bunny','Bunny chow aux pois chiches','Bunny chow','2 petits pains de mie non tranchés|600 g de pois chiches cuits|400 g de tomates concassées|1 oignon|2 pommes de terre|1 c. à soupe de curry|2 c. à soupe d’huile|300 ml d’eau|Sel','Faire revenir oignon et curry. Ajouter tomates, pommes de terre en cubes et eau ; cuire 20 minutes.|Ajouter les pois chiches et mijoter 10 minutes.|Couper les pains en deux, creuser chaque moitié en gardant un fond et garnir de curry.',45)
add('bouneschlupp','Bouneschlupp','Bouneschlupp','500 g de haricots verts|400 g de pommes de terre|1 oignon|100 g de lardons|1 l de bouillon|100 ml de crème|Sel, poivre','Faire revenir les lardons et l’oignon.|Ajouter haricots verts coupés, pommes de terre et bouillon. Mijoter 30 minutes.|Ajouter la crème, réchauffer doucement et assaisonner.',40)
add('stocafi','Stocafi','Stocafi','600 g de morue dessalée|500 g de tomates concassées|1 oignon|2 gousses d’ail|100 g d’olives noires|3 c. à soupe d’huile|Thym','Dessaler la morue selon le vendeur. Faire revenir oignon et ail dans l’huile.|Ajouter tomates, thym et olives ; mijoter 20 minutes.|Ajouter la morue en morceaux et cuire doucement 15 à 20 minutes, jusqu’à cuisson du poisson.',50)
add('trinxat','Trinxat','Trinxat','600 g de pommes de terre|400 g de chou vert|150 g de lardons|2 gousses d’ail|1 c. à soupe d’huile|Sel','Cuire pommes de terre et chou dans l’eau salée jusqu’à tendreté puis bien égoutter.|Faire dorer lardons et ail dans l’huile.|Écraser les légumes, les mélanger aux lardons et faire dorer cette préparation en galette, sur les deux faces.',45)
add('pastizzi','Pastizzi au fromage','Pastizz','2 pâtes feuilletées|300 g de ricotta égouttée|1 œuf|Sel, poivre','Mélanger la ricotta avec l’œuf et l’assaisonnement.|Découper des disques de pâte, déposer la farce et pincer les bords en laissant une petite ouverture.|Cuire 20 à 25 minutes à 200 °C, jusqu’à coloration et cuisson de la farce.',40,note='Version domestique à pâte feuilletée prête à l’emploi ; le feuilletage maltais traditionnel est différent.')
# Country selections: deliberately capped at six. Shared traditions remain explicit.
SELECTIONS='''
DZA:couscous,chorba,chakchouka,bourek,rechta,kesra
MAR:couscous,tajine,harira,chakchouka
TUN:couscous,brik,lablabi,chakchouka
LBY:couscous,shorba,chakchouka
EGY:koshari,ful,falafel,shorba
SDN:ful,shorba,sambusa
SSD:ugali,gombo
ETH:misir,sambusa,zigni
ERI:zigni,misir,shorba
DJI:lahoh,pilau,sambusa
SOM:pilau,sambusa
SOL:pilau,sambusa
SEN:thieb,yassa,mafe
GMB:mafe,yassa,jollof
MLI:mafe,rizgras
MRT:thieb,couscous
ESH:couscous,grilledfish
GIN:mafe,jollof
GNB:jollof,grilledfish
SLE:jollof,gombo
LBR:jollof,gombo
CIV:alloco,gombo,mafe
GHA:jollof,waakye,banku
TGO:akara,gombo
BEN:akara,gombo,alloco
BFA:rizgras,mafe
NER:rizgras,couscous
NGA:jollof,egusi,akara,efo
TCD:gombo,ugali
CMR:pouletmoambe,gombo,alloco
CAF:pouletmoambe,gombo
COG:pouletmoambe,saka
COD:pouletmoambe,saka,ugali
GAB:pouletmoambe,alloco
GNQ:grilledfish,alloco
STP:calulu,coconutfish
AGO:pouletmoambe,calulu
ZMB:ugali,gombo
ZWE:ugali,peanutgreens
MWI:ugali,grilledfish
MOZ:coconutfish,pouletmoambe
NAM:ugali,grilledfish
BWA:seswaa,ugali
ZAF:bobotie,chakalaka,bunny
LSO:ugali,peanutgreens
SWZ:ugali,peanutgreens
RWA:isombe,ugali
BDI:ugali,ricebeans
UGA:matoke,katogo,ugali
KEN:ugali,pilau,chapati
TZA:ugali,pilau,coconutfish
MDG:romazava,coconutfish
COM:coconutfish,coconutrice
MYT:coconutfish,coconutrice
MUS:rougail,dal,roti
SYC:coconutfish,grilledfish
REU:rougail,coconutfish
CPV:cachupa,grilledfish
FRA:ratatouille,quiche,bourguignon,crepes,gratin,oignons
TUR:menemen,mercimek,kofte,borek,imam,dolma
ITA:pizza,risotto,pasta
ESP:tortilla,gazpacho,paella
PRT:bacalhau,caldo
BEL:stoemp,crepes
NLD:stamppot,pancakes
DEU:schnitzel,potatoPancake,spaetzle
AUT:schnitzel,spaetzle
CHE:rosti,spaetzle
LIE:spaetzle,rosti
LUX:bouneschlupp,potatoPancake
MCO:stocafi,ratatouille
AND:trinxat,stew
SMR:pasta,roti
VAT:pasta,pizza
MLT:pastizzi,fishstew
GRC:souvlaki,tzatziki,dolma
CYP:souvlaki,dolma,tzatziki
CYN:kofte,dolma,borek
ALB:byrek,kofte
UNK:byrek,cevapi
MKD:tavce,shopska
BGR:shopska,byrek
SRB:cevapi,sarma
BIH:cevapi,borek
MNE:cevapi,sarma
HRV:sarma,risotto
SVN:spaetzle,sarma
HUN:goulash
SVK:potatoPancake,goulash
CZE:goulash,potatoPancake
POL:pierogi,potatoPancake
UKR:borscht,pierogi
BLR:draniki,borscht
RUS:blini,borscht
MDA:mamaliga,sarma
ROU:mamaliga,sarma
LTU:potatoPancake
LVA:greyPeas,potatoPancake
EST:kama,potatoPancake
FIN:salmonSoup
SWE:meatballs,pancakes
NOR:fishstew,potatoPancake
DNK:smorrebrod,meatballs
ISL:fishstew,stew
FRO:fishstew,stew
GRL:fishstew
GBR:fishchips,shepherd,pancakes
IRL:stew,shepherd
IMN:fishchips
JEY:fishstew,crepes
GGY:fishstew,crepes
GIB:fishchips,tortilla
ALA:pancakes,salmonSoup
ALD:pancakes,salmonSoup
GEO:khachapuri,lobio
ARM:dolma,kofte
AZE:plov,dolma
IRN:ghormeh,kuku
IRQ:dolma,kofte,shortrice
SYR:shakriya,hummus,kofte
LBN:hummus,tabbouleh,falafel
PSE:musakhan,hummus,falafel
ISR:chakchouka,falafel,hummus
JOR:mansaf,hummus
SAU:kabsa,shorba
ARE:machboos,shorba
BHR:machboos
QAT:machboos
KWT:machboos
OMN:machboos,grilledfish
YEM:saltah,shorba
AFG:kabuli,manti
PAK:biryani,dal,chana,roti
IND:dal,chana,biryani,aloo,roti,khichuri
BGD:khichuri,biryani,dal
NPL:dal,momo,roti
BTN:ema,momo
LKA:dal,polsambol
MDV:mashuni,coconutfish
KAZ:besh,manti
KGZ:besh,manti
UZB:plov,manti
TJK:plov,manti
TKM:plov,manti
MNG:buuz
CHN:jiaozi,mapotofu,friedrice
HKG:jiaozi,friedrice
MAC:friedrice,pastel
TWN:danbing,friedrice
JPN:oyakodon,okonomiyaki
KOR:bibimbap,japchae,mandu
PRK:mandu,japchae
MMR:mohinga
THA:padthai,coconutfish
LAO:laap,coconutrice
KHM:amok
VNM:pho,friedrice
MYS:nasikuning,satay
SGP:satay,friedrice
IDN:nasi,gado,satay
BRN:nasikuning,satay
PHL:adobo,friedrice
TLS:coconutfish,coconutrice
USA:chili,maccheese,pancakes
CAN:tourtiere,poutine,pancakes
MEX:tacos,guacamole
GTM:pepián
BLZ:ricepeas,sancocho
HND:baleadas
SLV:pupusas
NIC:gallopinto
CRI:gallopinto
PAN:sancocho
CUB:ropa,moros
DOM:mangu,sancocho
HTI:joumou,ricebeans
JAM:jerk,ricepeas
BHS:grilledfish,ricepeas
BRB:couCou,grilledfish
ATG:couCou,grilledfish
DMA:callaloo,grilledfish
GRD:callaloo,breadfruit
KNA:grilledfish,breadfruit
LCA:grilledfish,breadfruit
VCT:breadfruit,grilledfish
TTO:callaloo,roti
PRI:ricebeans,plantain
VEN:arepa,empanada
COL:arepa,sancocho
ECU:locro,humita
PER:lomo,papahuancaina
BOL:saltena,humita
CHL:empanada,humita
ARG:empanada,locro
URY:empanada
PRY:chipa,sopaParaguaya
BRA:feijoada,moqueca
SUR:pom,roti
GUY:cookup,roti
GUF:grilledfish,coconutrice
MTQ:callaloo,grilledfish
GLP:callaloo,grilledfish
BLM:grilledfish,crepes
MAF:grilledfish,ricepeas
SXM:grilledfish,ricepeas
ABW:panbati,grilledfish
CUW:couCou,grilledfish
BES:couCou,grilledfish
AIA:grilledfish,ricepeas
BMU:fishstew
CYM:grilledfish,coconutrice
TCA:grilledfish,ricepeas
VGB:grilledfish,couCou
VIR:grilledfish,couCou
MSR:stew
SPM:fishstew,crepes
FLK:fishchips,stew
SHN:fishstew
AUS:damper,anzac
NZL:kumara,anzac
PNG:coconutfish,kumara
VUT:laplap,coconutfish
SLB:coconutfish,coconutrice
FJI:coconutfish,roti
TON:palusami,coconutfish
WSM:palusami,poe
ASM:palusami,coconutfish
TUV:coconutfish,coconutrice
KIR:coconutfish,breadfruit
FSM:breadfruit,coconutfish
MHL:breadfruit,coconutfish
PLW:coconutfish,breadfruit
NRU:coconutfish,coconutrice
COK:poe,coconutfish
NIU:coconutfish,poe
TKL:coconutfish,coconutrice
WLF:palusami,coconutfish
PYF:poe,coconutfish
NCL:coconutfish,kumara
NFK:fishchips,anzac
PCN:coconutfish,poe
GUM:kelaguen,friedrice
MNP:kelaguen,friedrice
CXR:nasi,coconutfish
CCK:coconutrice,coconutfish
'''
add('peanutgreens','Légumes-feuilles à l’arachide','Peanut stew','500 g d’épinards ou de chou vert alimentaire|100 g de pâte d’arachide non sucrée|1 oignon|2 tomates|250 ml d’eau|1 c. à soupe d’huile|Sel','Faire revenir oignon et tomates dans l’huile.|Ajouter les feuilles coupées et l’eau ; cuire jusqu’à tendreté.|Incorporer la pâte d’arachide délayée dans un peu d’eau chaude et mijoter 10 minutes en remuant.',35,note='Préparation régionale partagée ; les feuilles et l’appellation changent selon les communautés.')
add('lahoh','Lahoh','Lahoh','200 g de farine de blé|100 g de semoule fine|450 ml d’eau tiède|5 g de levure boulangère sèche|1/2 c. à café de sel','Mélanger les ingrédients pour obtenir une pâte fluide. Couvrir et laisser lever 1 heure.|Verser une louche dans une poêle antiadhésive tiède.|Cuire sur une seule face jusqu’à ce que les bulles se figent et que la surface soit cuite. Refroidir légèrement la poêle entre les galettes.',85)
add('chapati','Chapati d’Afrique de l’Est','Chapati','300 g de farine de blé|180 ml d’eau tiède|3 c. à soupe d’huile|1/2 c. à café de sel','Pétrir farine, eau, sel et une cuillère d’huile. Reposer 20 minutes.|Diviser en 6 boules, étaler, badigeonner d’un peu d’huile puis rouler en spirales. Reposer 10 minutes et réétaler.|Cuire à la poêle sur les deux faces jusqu’à apparition de taches dorées.',50)
add('pastel','Pastéis de nata, version maison','Pastel de nata','1 pâte feuilletée|300 ml de lait|3 jaunes d’œufs|70 g de sucre|25 g de fécule|1 zeste de citron|Cannelle facultative','Chauffer 250 ml de lait avec le zeste. Mélanger le reste de lait avec fécule, sucre et jaunes.|Retirer le zeste, verser le lait chaud sur le mélange puis faire épaissir à feu doux en remuant.|Garnir des moules à muffins de pâte, remplir de crème et cuire 18 à 22 minutes à 230 °C.',40)
add('plantain','Tostones','Tostones','3 bananes plantains vertes|Huile de friture|Sel','Peler les plantains et couper en rondelles épaisses.|Frire une première fois jusqu’à attendrissement, puis égoutter et aplatir les rondelles avec le fond d’un verre.|Frire de nouveau jusqu’à coloration, égoutter et saler.',30)
add('panbati','Pan bati','Pan bati','150 g de farine de maïs fine|150 g de farine de blé|1 œuf|350 ml de lait|1 c. à café de levure chimique|1 c. à soupe de sucre|1 pincée de sel|Huile pour la poêle','Mélanger farines, levure, sucre et sel. Incorporer œuf et lait.|Laisser reposer 10 minutes.|Cuire de petites galettes dans une poêle huilée, quelques minutes par face jusqu’à cuisson du centre.',25)
add('kelaguen','Kelaguen au poulet cuit','Kelaguen','500 g de poulet désossé|150 g de noix de coco fraîche râpée|2 citrons|3 oignons nouveaux|Piment facultatif|Sel','Griller le poulet jusqu’à cuisson complète, puis le laisser tiédir et le hacher finement.|Mélanger avec noix de coco, oignons émincés, citron, sel et piment.|Servir rapidement ou conserver au réfrigérateur jusqu’au repas.',35,note='La version proposée emploie du poulet entièrement cuit ; le citron ne remplace pas la cuisson.')
C={}
for row in SELECTIONS.strip().splitlines():
 code,ids=row.split(':');C[code]=ids.split(',')
# San Marino's piadina is a distinct local bread, not an Indian roti.
add('piadina','Piadina','Piadina','300 g de farine|140 ml d’eau|40 g d’huile d’olive|1/2 c. à café de bicarbonate alimentaire|1/2 c. à café de sel','Pétrir tous les ingrédients pour obtenir une pâte souple. Reposer 20 minutes.|Diviser en 4 boules et étaler en disques fins.|Cuire à sec dans une poêle chaude environ 2 minutes par face. Garnir selon le goût.',35)
C['SMR']=['piadina','pasta']
# No invented national cuisine for uninhabited or research-only territories.
NO_LOCAL={k:'Pas de cuisine locale permanente documentée pour ce territoire. Les repas des bases et des visiteurs ne constituent pas une gastronomie nationale.' for k in ['ATA','ATF','BVT','HMD','SGS','UMI','ATC','KAS']}
NO_LOCAL['IOT']='Pas de recette attribuée ici à ce territoire : les traditions chagossiennes demandent une documentation spécifique.'
NO_LOCAL['IOA']='Regroupement cartographique : consulter les fiches des îles Christmas et Cocos pour les préparations sélectionnées.'
C['SJM']=['fishstew']
# Notes distinguish broad everyday foods from distinctive named dishes.
GENERIC={'grilledfish','coconutfish','coconutrice','ricebeans','fishstew','peanutgreens','kumara','breadfruit','roti','pasta','pancakes','stew'}
countries=json.load(open(D/'countries.json'))
for code in countries:
 assert code in C or code in NO_LOCAL, ('Missing country',code)
for code,ids in C.items():
 assert code in countries and 1<=len(ids)<=6 and len(set(ids))==len(ids),code
 for id in ids:assert id in R,(code,id)
add('frikadeller','Frikadeller','Frikadeller','500 g de porc haché|1 oignon râpé|1 œuf|50 g de farine|100 ml de lait|30 g de beurre|Sel, poivre','Mélanger viande, oignon, œuf, farine et lait pour obtenir une farce souple. Assaisonner et réfrigérer 20 minutes.|Former des boulettes légèrement aplaties à la cuillère.|Cuire dans le beurre à feu moyen, sur les deux faces, jusqu’à cuisson complète au centre.',40)
add('goatwater','Goat water','Goat water','800 g de chèvre à mijoter|2 oignons|2 gousses d’ail|2 tomates|1 c. à soupe de farine|2 c. à soupe d’huile|1,2 l d’eau|Thym, girofle, sel, poivre','Faire revenir les oignons et l’ail, puis la viande en morceaux dans l’huile.|Ajouter tomates, eau, thym et une pincée de girofle. Mijoter à couvert 2 à 3 heures, jusqu’à tendreté.|Délayer la farine dans un peu d’eau froide. Incorporer et cuire encore 10 minutes pour lier légèrement le bouillon.',200)
C['DNK']=['smorrebrod','frikadeller']
C['MSR']=['goatwater']
SOURCE_TITLES={'bourek': 'Bourek (Algerian cuisine)', 'rougail': 'Cuisine of Réunion', 'coconutfish': 'Seychellois cuisine', 'mercimek': 'Lentil soup', 'shepherd': "Shepherd's pie", 'cookup': 'Guyanese cuisine', 'grilledfish': 'Fish as food', 'banku': 'Banku (dish)', 'stocafi': 'Monégasque cuisine'}
for rid,title in SOURCE_TITLES.items():R[rid]["wiki"]=title
used={x for ids in C.values() for x in ids};R={k:v for k,v in R.items() if k in used}
for r in R.values():r['editorial']='Recette rédigée pour Méridien : adaptation domestique, non testée en cuisine. La source documentaire décrit le plat ; elle n’est pas nécessairement la recette exacte.'
obj={'revision':1,'date':'2026-11-14','recipes':R,'countries':{code:{'dishes':ids,'note':('Sélection de préparations consommées dans cette aire culturelle, dont certaines sont partagées avec les pays voisins ; ce ne sont pas des origines exclusives.' if any(i in GENERIC for i in ids) else 'Les variantes régionales et familiales sont nombreuses ; un même plat peut appartenir à plusieurs cuisines.')} for code,ids in C.items()},'unavailable':NO_LOCAL}
(D/'recipes.json').write_text(json.dumps(obj,ensure_ascii=False,separators=(',',':')))
print(len(R),'recipes;',len(C),'country/territory selections;',sum(map(len,C.values())),'dish entries;',len(NO_LOCAL),'explicit exceptions')
