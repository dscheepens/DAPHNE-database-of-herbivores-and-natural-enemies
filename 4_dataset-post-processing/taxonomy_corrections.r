
binomial_corrections <- tribble(
  ~clean_name, ~corrected_name, ~corrected_genus, ~corrected_species, ~is_synonym, 
  "A. amygdali", "Apodiphus amygdali", "Apodiphus", "amygdali", FALSE,
  "A. terebrans", "Apate terebrans", "Apate", "terebrans", FALSE,
  "D. trifasciata", "Diastocera trifasciata", "Diastocera", "trifasciata", FALSE,
  "A. zoegana", "Agapeta zoegana", "Agapeta", "zoegana", FALSE,
  "P. inspersa", "Pelochrista inspersa", "Pelochrista", "inspersa", FALSE,
  "A. avenae", "Sitobion avenae", "Sitobion", "avenae", FALSE,
  "M. avena", "Sitobion avenae", "Sitobion", "avenae", FALSE,
  "S. graminum", "Schizaphis graminum", "Schizaphis", "graminum", FALSE,
  "A. kuehniella", "Ephestia kuehniella", "Ephestia", "kuehniella", FALSE,
  "A. kuenhiella", "Ephestia kuehniella", "Ephestia", "kuehniella", FALSE,
  "Acrobasis nuxvoreüa", "Acrobasis nuxvorella", "Acrobasis", "nuxvorella", FALSE,
  "A. modicella", "Aproaerema modicella", "Aproaerema", "modicella", FALSE,
  "B. kolae", "Balanogastris kolae", "Balanogastris", "kolae", FALSE,
  "C. acuta", "Chrysodeixis acuta", "Chrysodeixis", "acuta", FALSE,
  "C. lichenaria", "Cleorodes lichenaria", "Cleorodes", "lichenaria", FALSE,
  "C. varipes", "Carea varipes", "Carea", "varipes", FALSE,
  "D. decempuncta", "Dialeuropora decempuncta", "Dialeuropora", "decempuncta", FALSE,
  "Myzaphis v. d. G.", "Myzaphis", "Myzaphis", "", FALSE,
  "E. monohammi", "Euthera monohammi", "Euthera", "monohammi", FALSE,
  "G. gema", "Gesonia gema", "Gesonia", "gema", FALSE,
  "H. truncatulus", "Hypolytrus truncatulus", "Hypolytrus", "truncatulus", FALSE,
  "M. obtusa", "Melanagromyza obtusa", "Melanagromyza", "obtusa", FALSE,
  "M. separate", "Mythimna separata", "Mythimna", "separata", FALSE,
  "N. vastator", "Nipaecoccus vastator", "Nipaecoccus", "vastator", FALSE,
  "O. brevis", "Obereopsis brevis", "Obereopsis", "brevis", FALSE,
  "P. japonica", "Popillia japonica", "Popillia", "japonica", FALSE,
  "P. nemorum", "Phyllotreta nemorum", "Phyllotreta", "nemorum", FALSE,
  "P. reichei", "Plesispa reichei", "Plesispa", "reichei", FALSE,
  "P. rugicollis", "Plesiocoris rugicollis", "Plesiocoris", "rugicollis", FALSE,
  "S. globosum", "Synema globosum", "Synema", "globosum", FALSE,
  "S. obliqua", "Spilosoma obliqua", "Spilosoma", "obliqua", FALSE,
  "S. patrulis", "Sternuchopsis patrulis", "Sternuchopsis", "patrulis", FALSE,
  "T. gyraloura", "Tripius gyraloura", "Tripius", "gyraloura", FALSE,
  "T. variabilis", "Tricliona variabilis", "Tricliona", "variabilis", FALSE,
  "Tetrastichus sp. near T. dubius", "Tetrastichus sp. nr. dubius", "Tetrastichus", "dubius", FALSE,
  "A. sp. nr. hemixantha", "Archips sp. nr. hemixantha", "Archips", "hemixantha", FALSE,
  "Archips sp. nr. hemixantha", "Chirapsina sp. nr. hemixantha", "Chirapsina", "hemixantha", TRUE,
  "Archips hemixantha", "Chirapsina hemixantha", "Chirapsina", "hemixantha", TRUE,
  "Acanthococcus ioronsidei", "Acanthococcus ironsidei", "Acanthococcus", "ironsidei", FALSE,
  "Acarus hyacinthi", "Rhizoglyphus hyacinthi", "Rhizoglyphus", "hyacinthi", TRUE,
  "Acathodelta janata", "Achaea janata", "Achaea", "janata", TRUE,
  "Acharia fusca", "Sibine fusca", "Sibine", "fusca", TRUE,
  "Achea catocaloides", "Achaea catocaloides", "Achaea", "catocaloides", FALSE,
  "Acigona ignefusalis", "Coniesta ignefusalis", "Coniesta", "ignefusalis", TRUE,
  "Acistrotermes latinotus", "Ancistrotermes latinotus", "Ancistrotermes", "latinotus", FALSE,
  "Aclees sp. cf. foveatus", "Aclees taiwanensis", "Aclees", "taiwanensis", TRUE,
  "Acnulliopliis syciscri", "Acanthoplus speiseri", "Acanthoplus", "speiseri", FALSE,
  "Acrantus vestitus", "Chaetoptelius vestitus", "Chaetoptelius", "vestitus", TRUE,
  "Acrea acerata", "Acraea acerata", "Acraea", "acerata", FALSE,
  "Acritochaeta yorki", "Atherigona yorki", "Atherigona", "yorki", FALSE,
  "Acrocercops globulifera", "Conopobathra gravissima", "Conopobathra", "gravissima", TRUE,
  "Acromyrmex molestans", "Acromyrmex subterraneus molestans", "Acromyrmex", "subterraneus molestans", FALSE,
  "Acrosternum aseadum", "Chinavia aseada", "Chinavia", "aseada", TRUE,
  "Aculops ailanthi", "Aculops ailanthii", "Aculops", "ailanthii", FALSE,
  "Adalia fasciatopunctata", "Adalia bipunctata var. fasciatopunctata", "Adalia", "bipunctata var. fasciatopunctata", FALSE,
  "Adelencyrtus miyarai", "Adelencyrtus mayurai", "Adelencyrtus", "mayurai", FALSE,
  "Aegeria tibialis", "Sesia tibiale", "Sesia", "tibiale", TRUE,
  "Aegorhinus nodipennis", "Lophotus nodipennis", "Lophotus", "nodipennis", TRUE,
  "Aerobacter aerogenes", "Klebsiella aerogenes", "Klebsiella", "aerogenes", TRUE,
  "Agelena difficilis", "Allagelena difficilis", "Allagelena", "difficilis", TRUE,
  "Agonopterix umbellana", "Agonopterix ulicetella", "Agonopterix", "ulicetella", TRUE,
  "Agrilus aurichalceus", "Agrilus cuprescens", "Agrilus", "cuprescens", TRUE,
  "Alans sordidns", "Alaus sordidus", "Alaus", "sordidus", FALSE,
  "Alaus sordidus", "Cryptalaus sordidus", "Cryptalaus", "sordidus", TRUE,
  "Alerodicus dispersus", "Aleurodicus dispersus", "Aleurodicus", "dispersus", FALSE,
  "Aleurodiscus dispersus", "Aleurodicus dispersus", "Aleurodicus", "dispersus", FALSE,
  "Amara octopunctatum", "Agonum octopunctatum", "Agonum", "octopunctatum", FALSE,
  "Amblydromella caudiglans", "Typhlodromus caudiglans", "Typhlodromus", "caudiglans", TRUE,
  "Amblysieus longispinoses", "Amblyseius longispinosus", "Amblyseius", "longispinosus", FALSE,
  "Amischa amicula", "Atheta amicula", "Atheta", "amicula", FALSE,
  "Amphorophora idae", "Amphorophora idaei", "Amphorophora", "idaei", FALSE,
  "Amrasca devastans", "Amrasca biguttula", "Amrasca", "biguttula", TRUE,
  "Amsacta albistriga", "Aloa albistriga", "Aloa", "albistriga", TRUE,
  "Amyotea hamatus", "Amyotea hamata", "Amyotea", "hamata", FALSE,
  "Anabena oryzae", "Anabaena oryzae", "Anabaena", "oryzae", FALSE,
  "Anagaspis daci", "Aganaspis daci", "Aganaspis", "daci", FALSE,
  "Anagyms sp.", "Anagyrus sp.", "Anagyrus", "", FALSE,
  "Anas platyrynchos", "Anas platyrhynchos", "Anas", "platyrhynchos", FALSE,
  "Anas tatus", "Anastatus", "Anastatus", "", FALSE,
  "Anastatus redivii", "Anastatus reduvii", "Anastatus", "reduvii", FALSE,
  "Anastatus reducvii", "Anastatus reduvii", "Anastatus", "reduvii", FALSE,
  "Anastrophe longirnacula", "Anastrophe longimacula", "Anastrophe", "longimacula", FALSE,
  "Aneglei scardoni", "Anegleis cardoni", "Anegleis", "cardoni", FALSE,
  "Angitia cerophaga", "Diadegma semiclausum", "Diadegma", "semiclausum", TRUE,
  "Anisolemnia dilatata", "Megalocaria dilatata", "Megalocaria", "dilatata", TRUE,
  "Anophococcus abaii", "Eriococcus abaii", "Eriococcus", "abaii", TRUE,
  "Anthocoris tonwntosm", "Anthocoris tomentosus", "Anthocoris", "tomentosus", FALSE,
  "Antigastra cataulinalis", "Antigastra catalaunalis", "Antigastra", "catalaunalis", FALSE,
  "Antilochus conqueberti", "Antilochus coqueberti", "Antilochus", "coqueberti", FALSE,
  "Antiteuches kerzhneri", "Antiteuchus kerzhneri", "Antiteuchus", "kerzhneri", FALSE,
  "Apanteles aciculatus", "Rhygoplitis aciculatus", "Rhygoplitis", "aciculatus", TRUE,
  "Apantesis blakei", "Grammia blakei", "Grammia", "blakei", TRUE,
  "Aphis biguttula", "Amrasca biguttula", "Amrasca", "biguttula", FALSE,
  "Aphlonobia histricina", "Aplonobia histricina", "Aplonobia", "histricina", FALSE,
  "Archips cerrrsivormus", "Archips cerasivoranus", "Archips", "cerasivoranus", FALSE,
  "Argyroploce schistaceana", "Tetramoera schistaceana", "Tetramoera", "schistaceana", TRUE,
  "Arimania comaroffi", "Arimania komaroffi", "Arimania", "komaroffi", FALSE,
  "Asolcus mitsukurii", "Trissolcus mitsukurii", "Trissolcus", "mitsukurii", TRUE,
  "Aspidomorpha miliaris", "Aspidimorpha miliaris", "Aspidimorpha", "miliaris", FALSE,
  "Aspidoproctus zimmermanni", "Perissopneumon zimmermanni", "Perissopneumon", "zimmermanni", TRUE,
  "Aspodoptera mauritia", "Spodoptera mauritia", "Spodoptera", "mauritia", FALSE,
  "Aspongopus viduatus", "Coridius viduatus", "Coridius", "viduatus", TRUE,
  "Asterochiton sonchi", "Trialeurodes vaporariorum", "Trialeurodes", "vaporariorum", TRUE,
  "Atalodera andina", "Mesodolichodera andina", "Mesodolichodera", "andina", TRUE,
  "Atractamorphpha crenulata", "Atractomorpha crenulata", "Atractomorpha", "crenulata", FALSE,
  "Auleroglyphus ovatus", "Aleuroglyphus ovatus", "Aleuroglyphus", "ovatus", FALSE,
  "Autographa circumflexa", "Cornutiplusia circumflexa", "Cornutiplusia", "circumflexa", TRUE,
  "Azia luteipes", "Azya luteipes", "Azya", "luteipes", FALSE,
  "B. icolae", "Balanogastris kolae", "Balanogastris", "kolae", FALSE,
  "Bacchisa sp. near pallidiventris", "Bacchisa sp. nr. pallidiventris", "Bacchisa", "pallidiventris", FALSE,
  "Bactericera melaleucae", "Boreioglycaspis melaleucae", "Boreioglycaspis", "melaleucae", FALSE,
  "Banacuniculus hunteri", "Eucoila hunteri", "Eucoila", "hunteri", TRUE,
  "Bassaris gonerilla", "Vanessa gonerilla", "Vanessa", "gonerilla", TRUE,
  "Bathycoelia natalicola", "Bathycoelia distincta", "Bathycoelia", "distincta", TRUE,
  "Batocera rufus", "Batocera rubus", "Batocera", "rubus", FALSE,
  "Beddingia siricidicola", "Deladenus siricidicola", "Deladenus", "siricidicola", TRUE,
  "Bembecia marginata", "Pennisetia marginata", "Pennisetia", "marginata", TRUE,
  "Bephratelloides ablus", "Bephratelloides ablusus", "Bephratelloides", "ablusus", FALSE,
  "Bhyzopertha dominica", "Rhyzopertha dominica",  "Rhyzopertha", "dominica",  FALSE,
  "Biguttula biguttula", "Amrasca biguttula", "Amrasca", "biguttula", TRUE,
  "Biorrhys pallida", "Biorhiza pallida", "Biorhiza", "pallida", FALSE,
  "Biosteres arisanus", "Fopius arisanus", "Fopius", "arisanus", TRUE,
  "Borassia borassis", "Mackiella borasis", "Mackiella", "borasis", TRUE,
  "Bothriomyrmex dalyi", "Chronoxenus dalyi", "Chronoxenus", "dalyi", TRUE,
  "Branta bernicla hrota", "Branta bernicla", "Branta", "bernicla", FALSE,
  "Brochymena dimidiata", "Brochymena dilata", "Brochymena", "dilata", FALSE,
  "Bruchidis albizziae", "Bruchidius albizziae", "Bruchidius", "albizziae", FALSE,
  "Bruchus theobromae", "Callosobruchus theobromae", "Callosobruchus", "theobromae", TRUE,
  "Burkseus elongatus", "Cirrospilus elongatus", "Cirrospilus", "elongatus", TRUE,
  "Buzura suppressaria", "Biston suppressarius", "Biston", "suppressarius", TRUE,
  "Cacoecia crataegana", "Archips crataegana", "Archips", "crataegana", TRUE,
  "Cadra castellan", "Cadra cautella", "Cadra", "cautella", FALSE,
  "Cadra caustella", "Cadra cautella", "Cadra", "cautella", FALSE,
  "Caligula japonica", "Saturnia japonica", "Saturnia", "japonica", TRUE,
  "Callasobruchus maculates", "Callasobruchus maculatus", "Callasobruchus", "maculatus", FALSE,
  "Calligrapha signatipennis", "Zygogramma signatipennis", "Zygogramma", "signatipennis", TRUE,
  "Callimorpha jacobaeae", "Tyria jacobaeae", "Tyria", "jacobaeae", TRUE,
  "Callosobruchus dimidatus", "Carpophilus dimidiatus", "Carpophilus", "dimidiatus", FALSE,
  "Calpe gruësa", "Calyptra gruesa", "Calyptra", "gruesa", FALSE,
  "Cameraria ochridella", "Cameraria ohridella", "Cameraria", "ohridella", FALSE,
  "Campylochaeta plathypenae", "Campylocheta plathypenae", "Campylocheta", "plathypenae", FALSE,
  "Canthecona furcellata", "Eocanthecona furcellata", "Eocanthecona", "furcellata", FALSE,
  "Cantheconidea furcellata", "Eocanthecona furcellata", "Eocanthecona", "furcellata", FALSE,
  "Capitophorus hippophae", "Capitophorus hippophaes", "Capitophorus", "hippophaes", FALSE,
  "Capitophorus hippophaeus", "Capitophorus hippophaes", "Capitophorus", "hippophaes", FALSE,
  "Capra bircus", "Capra hircus", "Capra", "hircus", FALSE,
  "Capsodes infuscatus", "Horistus infuscatus", "Horistus", "infuscatus", TRUE,
  "Carpomya liat", "Goniglossum liat", "Goniglossum", "liat", TRUE,
  "Carystrus pallipes", "Caystrus pallipes", "Caystrus", "pallipes", FALSE,
  "Castnia dedalus", "Eupalamides cyparissias", "Eupalamides", "cyparissias", TRUE,
  "Catopsila ponoma", "Catopsilia pomona", "Catopsilia", "pomona", FALSE,
  "Catorama herbarium", "Lasioderma serricorne", "Lasioderma", "serricorne", TRUE,
  "Cazira bhoutanica", "Cazira frivaldskyi", "Cazira", "frivaldskyi", TRUE,
  "Celama parvitis", "Nola parvitis", "Nola", "parvitis", TRUE,
  "Celosterna scrabrator", "Cerosterna scabrator", "Cerosterna", "scabrator", FALSE,
  "Ceocoris pollens", "Geocoris pallens", "Geocoris", "pallens", FALSE,
  "Cephus ductus", "Cephus cinctus", "Cephus", "cinctus", TRUE,
  "Ceratagallia agricola", "Aceratagallia agricola", "Aceratagallia", "agricola", TRUE,
  "Cerotrioza umalii", "Trioza umalii", "Trioza", "umalii", TRUE,
  "Ceutorhynchus portulacae", "Hypurus bertrandi", "Hypurus", "bertrandi", TRUE,
  "Chaetogena obliquata", "Tachina obliquata", "Tachina", "obliquata", TRUE,
  "Chaetorellia hexachaeta", "Chaetorellia australis", "Chaetorellia", "australis", TRUE,
  "Chamaesphecia doryliformis", "Pyropteron doryliformis", "Pyropteron", "doryliformis", TRUE,
  "Charidotella bicolor", "Charidotella sexpunctata bicolor", "Charidotella", "sexpunctata bicolor", FALSE,
  "Chauliognathus flavipes", "Chauliognathus basalis", "Chauliognathus", "basalis", TRUE,
  "Cheilomenes septumpunctata", "Coccinella septempunctata", "Coccinella", "septempunctata", FALSE,
  "Chelytus sp. near C. fortis", "Cheyletus sp. nr. fortis", "Cheyletus", "fortis", FALSE,
  "Chilesia rudis", "Paracles rudis", "Paracles", "rudis", TRUE,
  "Chilomenes sexmaculata", "Cheilomenes sexmaculata", "Cheilomenes", "sexmaculata", FALSE,
  "Chilotraea polychrysa", "Chilo polychrysa", "Chilo", "polychrysa", TRUE,
  "Chiracanthium inclusum", "Cheiracanthium inclusum", "Cheiracanthium", "inclusum", FALSE,
  "Chlamisus cribripennis", "Neochlamisus cribripennis", "Neochlamisus", "cribripennis", TRUE,
  "Chloethrips oryzae", "Stenchaetothrips biformis", "Stenchaetothrips", "biformis", TRUE,
  "Chortodes rufostrigata", "Hypocoena rufostrigata", "Hypocoena", "rufostrigata", TRUE,
  "Chrysophtharta agricola", "Paropsisterna agricola", "Paropsisterna", "agricola", TRUE,
  "Chrysso clementinae", "Meotipa pulcherrima", "Meotipa", "pulcherrima", TRUE,
  "Cicadatra alagheos", "Cicadatra alhageos", "Cicadatra", "alhageos", FALSE,
  "Cicadulina ambila", "Cicadulina mbila", "Cicadulina", "mbila", FALSE,
  "Cicindela circumpicta", "Eunota circumpicta", "Eunota", "circumpicta", TRUE,
  "Cicloneda sanguinea", "Cycloneda sanguinea", "Cycloneda", "sanguinea", FALSE,
  "Cinnamopteryx castaneofuscus", "Ploceus castaneofuscus", "Ploceus", "castaneofuscus", TRUE,
  "Cirrospilus near lyncus", "Cirrospilus nr. lyncus", "Cirrospilus", "lyncus", FALSE,
  "Cissa erythrorhyncha", "Urocissa erythroryncha", "Urocissa", "erythroryncha", TRUE,
  "Clavaspis perseae", "Abgrallaspis perseae",  "Abgrallaspis", "perseae", TRUE,
  "Cleothera notata", "Tenuisvalvae notata", "Tenuisvalvae", "notata", TRUE,
  "Cnaphalocrocis edinalis", "Cnaphalocrocis medinalis", "Cnaphalocrocis", "medinalis", FALSE,
  "Coccygomimus disparis", "Pimpla disparis", "Pimpla", "disparis", TRUE,
  "Cocyra cephalonica", "Corcyra cephalonica", "Corcyra", "cephalonica", FALSE,
  "Coelaenomenodera minuta", "Coelaenomenodera elaeidis", "Coelaenomenodera", "elaeidis", TRUE,
  "Coelophora inequalis", "Coelophora inaequalis", "Coelophora", "inaequalis", FALSE,
  "Cofana uiiinmciilata", "Cofana unimaculata", "Cofana", "unimaculata", FALSE,
  "Cossidophaga coffea", "Cossidophaga coffeae", "Cossidophaga", "coffeae", FALSE,
  "Cothonaspis rapae", "Trybliographa rapae", "Trybliographa", "rapae", TRUE,
  "Creatonotus gangis", "Creatonotos gangis", "Creatonotos", "gangis", FALSE,
  "Crisicoccus hirsutus", "Pseudococcus hirsutus", "Pseudococcus", "hirsutus", TRUE,
  "Cryptophlebia batrachopa", "Thaumatotibia batrachopa", "Thaumatotibia", "batrachopa", TRUE,
  "Crysamphalus dictyospermi", "Chrysomphalus dictyospermi", "Chrysomphalus", "dictyospermi", FALSE,
  "Ctenicera destructor", "Selatosomus aeripennis destructor", "Selatosomus", "aeripennis destructor", TRUE,
  "Cuphocera sp. nr pilosa", "Cuphocera sp. nr. pilosa", "Cuphocera", "pilosa", TRUE,
  "Cyaneodinodes faciger", "Chlaenius fasciger", "Chlaenius", "fasciger", TRUE,
  "Cyaneolylta coerculea", "Cyaneolytta coerculea", "Cyaneolytta", "coerculea", FALSE,
  "Cydnodromus picanus", "Neoseiulus picanus", "Neoseiulus", "picanus", TRUE,
  "Cydonia vicina", "Cheilomenes propinqua vicina", "Cheilomenes", "propinqua vicina", TRUE,
  "Cythorhinus lividipennis", "Cyrtorhinus lividipennis", "Cyrtorhinus", "lividipennis", FALSE,
  "Dactylozodes okea", "Lasionota okea", "Lasionota", "okea", TRUE,
  "Darna jasea", "Ploneta jasea", "Ploneta", "jasea", TRUE,
  "Dasyhippus harbipes", "Dasyhippus barbipes", "Dasyhippus", "barbipes", FALSE,
  "Dasyneura lini", "Dasineura lini", "Dasineura", "lini", FALSE,
  "Degeeria collaris", "Medina collaris", "Medina", "collaris", TRUE,
  "Delias aglaia", "Delias pasithoe", "Delias", "pasithoe", TRUE,
  "Denticera near-divisella", "Denticera nr. divisella", "Denticera", "divisella", FALSE,
  "Dentichasmias bitsseolae", "Dentichasmias busseolae", "Dentichasmias", "busseolae", FALSE,
  "Diabrotica vigifera zeae", "Diabrotica virgifera zeae", "Diabrotica", "virgifera zeae", FALSE,
  "Dialeurodes abbreviatus", "Diaprepes abbreviatus", "Diaprepes", "abbreviatus", FALSE,
  "Diaspidiotus fraxini", "Abgrallaspis fraxini", "Abgrallaspis", "fraxini", TRUE,
  "Dichocrocis punctiferalis", "Conogethes punctiferalis", "Conogethes", "punctiferalis", TRUE,
  "Dichromia orosia", "Noctua sagitta", "Noctua", "sagitta", TRUE,
  "Dictyoploca japonica", "Caligula japonica", "Caligula", "japonica", TRUE,
  "Didacus ciliatus", "Dacus ciliatus", "Dacus", "ciliatus", TRUE,
  "Diomorus orientalis", "Torymus indicus", "Torymus", "indicus", TRUE,
  "Dione junio", "Dione juno", "Dione", "juno", FALSE,
  "Dioryctria splendidella", "Dioryctria sylvestrella", "Dioryctria", "sylvestrella", TRUE,
  "Diphornia citri", "Diaphorina citri", "Diaphorina", "citri", FALSE,
  "Diphylleia rotans", "Aulacomonas submarina", "Aulacomonas", "submarina", TRUE,
  "Diplocystis oxycan i", "Diplocystis oxycani", "Diplocystis", "oxycani", TRUE,
  "Diuncus quadrispinulosus", "Diuncus quadrispinosulus", "Diuncus", "quadrispinosulus", TRUE,
  "Dolichogenidea aethiopica", "Apanteles aethiopicus", "Apanteles", "aethiopicus", TRUE,
  "Dorymyrmex reginicula", "Conomyrma reginicula", "Conomyrma", "reginicula", TRUE,
  "Doryphorophaga doryphorae", "Myiopharus doryphorae", "Myiopharus", "doryphorae", TRUE,
  "Dryoxylon onoharaensum", "Dryoxylon onoharaense", "Dryoxylon", "onoharaense", FALSE,
  "Dysaphis carategi", "Dysaphis crataegi", "Dysaphis", "crataegi", FALSE,
  "Ecdytolopha aurantiana", "Gymnandrosoma aurantianum", "Gymnandrosoma", "aurantianum", TRUE,
  "Eilema gayneri", "Eublemma gayneri", "Eublemma", "gayneri", FALSE,
  "Elasmolomus sordidus", "Elasmolomus pallens", "Elasmolomus", "pallens", TRUE,
  "Elasmus hyblaeae", "Elasmus hyblaea", "Elasmus", "hyblaea", FALSE,
  "Elbella luteizona", "Elbella carriae", "Elbella", "carriae", TRUE,
  "Elliptio coinpianata", "Elliptio complanata", "Elliptio", "complanata", FALSE,
  "Empoasca discipiens", "Empoasca decipiens", "Empoasca", "decipiens", FALSE,
  "Endoxyla änereus", "Endoxyla cinereus", "Endoxyla", "cinereus", FALSE,
  "Ephedius sp.", "Ephedrus sp.", "Ephedrus", "", FALSE,
  "Epiblema tedella", "Epinotia tedella", "Epinotia", "tedella", TRUE,
  "Epicauta atomaria", "Epicauta punctata", "Epicauta", "punctata", TRUE,
  "Epinotia aceriella", "Catastega aceriella", "Catastega", "aceriella", TRUE,
  "Epuraea domina", "Epuraea terminalis", "Epuraea", "terminalis", TRUE,
  "Eremophilia alperestis", "Eremophila alpestris", "Eremophila", "alpestris", FALSE,
  "Eriocaenus equiseti", "Eriophyes equiseti", "Eriophyes", "equiseti", FALSE,
  "Eriogyna pyretorum", "Saturnia pyretorum", "Saturnia", "pyretorum", TRUE,
  "Eriops connexa", "Eriopis connexa", "Eriopis", "connexa", FALSE,
  "Eris marginata", "Eris militaris", "Eris", "militaris", TRUE,
  "Erthymelus helopeltidis", "Erythmelus helopeltidis", "Erythmelus", "helopeltidis", FALSE,
  "Erynia erinacea", "Zoophthora erinacea", "Zoophthora", "erinacea", TRUE,
  "Eryphanis greeneyi", "Eryphanis zolvizora greeneyi", "Eryphanis", "zolvizora greeneyi", TRUE,
  "Erythroneura sudra", "Watara sudra", "Watara", "sudra", TRUE,
  "Eublemma anguilifera", "Autoba anguilifera", "Autoba", "anguilifera", TRUE,
  "Eucarcelia illota", "Carcelia illota", "Carcelia", "illota", TRUE,
  "Euchrysops pandava", "Luthrodes pandava", "Luthrodes", "pandava", TRUE,
  "Eucoenogenes aestuosa", "Fibuloides aestuosa", "Fibuloides", "aestuosa", TRUE,
  "Eucosma critica", "Cydia critica", "Cydia", "critica", TRUE,
  "Eucosmocydia monitrix", "Eucosma monitrix", "Eucosma", "monitrix", TRUE,
  "Euderus near arenarius", "Euderus nr. arenarius", "Euderus", "arenarius", FALSE,
  "Eudonia atomosa", "Exelastis atomosa", "Exelastis", "atomosa", FALSE,
  "Eulecanium cerasorium", "Eulecanium cerasorum", "Eulecanium", "cerasorum", FALSE,
  "Eupeodes nuda", "Eupeodes nuba", "Eupeodes", "nuba", FALSE,
  "Euphorus pallipes", "Peristenus pallipes", "Peristenus", "pallipes", TRUE,
  "Euproctis machaeralis", "Paliga machoeralis", "Paliga", "machoeralis", TRUE,
  "Eurydema kraemeri", "Empoasca kraemeri", "Empoasca", "kraemeri", FALSE,
  "Euxoa seliginis", "Agrotis segnilis", "Agrotis", "segnilis", TRUE,
  "Eversia resinella", "Retinia resinella", "Retinia", "resinella", FALSE,
  "Funambulus palamaram", "Funambulus palmarum", "Funambulus", "palmarum", FALSE,
  "Gaeolaelaps americana", "Glyptholaspis americana", "Glyptholaspis", "americana", FALSE,
  "Galerucella assimilis", "Ceutorhynchus assimilis", "Ceutorhynchus", "assimilis", FALSE,
  "Gelechia fibesella", "Gelechia ribesella", "Gelechia", "ribesella", FALSE,
  "Glyphodes negatalis", "Dysallacta negatalis", "Dysallacta", "negatalis", TRUE,
  "Gonatocerus sp. near tuberculifemur Clade 1", "Gonatocerus sp. nr. tuberculifemur", "Gonatocerus", "tuberculifemur", FALSE,
  "Gracillaria theivora", "Caloptilia theivora", "Caloptilia", "theivora", TRUE,
  "Gynaephora alpherakii", "Lachana alpherakii", "Lachana", "alpherakii", TRUE,
  "Habrobracon lineatellae", "Habrobracon lineatella", "Habrobracon", "lineatella", FALSE,
  "Hamonia axyridis", "Harmonia axyridis", "Harmonia", "axyridis", FALSE,
  "Harposporium aungulilae", "Harposporium anguillulae", "Harposporium", "anguillulae", FALSE,
  "Hartigia trimaculata", "Phylloecus trimaculatus", "Phylloecus", "trimaculatus", TRUE,
  "Hedwigiella jureceki", "Hylaeogena jureceki", "Hylaeogena", "jureceki", TRUE,
  "Heliothrips angustior", "Heliothrips haemorrhoidalis", "Heliothrips", "haemorrhoidalis", TRUE,
  "Hemerocampa pseudotsugata", "Orgyia pseudotsugata", "Orgyia", "pseudotsugata", TRUE,
  "Hemiasphondylia prosopidis", "Asphondylia prosopidis", "Asphondylia", "prosopidis", TRUE,
  "Hemiberlesia ithacae", "Abgrallaspis ithacae", "Abgrallaspis", "ithacae", TRUE,
  "Hemilecanium bursera", "Etiennea bursera", "Etiennea", "bursera", TRUE,
  "Hepialus californicus", "Phymatopus californicus", "Phymatopus", "californicus", TRUE,
  "Herpetogramma sp. near licarsisalis", "Herpetogramma sp. nr. licarsisalis", "Herpetogramma", "licarsisalis", FALSE,
  "Heteropsylla vitripennis", "Homalodisca vitripennis", "Homalodisca", "vitripennis", FALSE,
  "Hieroxestis subcervinella", "Opogona sacchari", "Opogona", "sacchari", TRUE,
  "Hippocampus coccinellae", "Dinocampus coccinellae", "Dinocampus", "coccinellae", FALSE,
  "Hippota dorsalis", "Hippotiscus dorsalis", "Hippotiscus", "dorsalis", TRUE,
  "Holcocerus hippophaecolus", "Eogystia hippophaecolus", "Eogystia", "hippophaecolus", TRUE,
  "Homeosoma nebulella", "Homoeosoma nebulella", "Homoeosoma", "nebulella", FALSE,
  "Homona coffeae", "Homona coffearia", "Homona", "coffearia", TRUE,
  "Hydatothrips aldolfifriderici", "Hydatothrips adolfifriderici", "Hydatothrips", "adolfifriderici", FALSE,
  "Hylemya antiqua", "Delia antiqua", "Delia", "antiqua", TRUE,
  "Hylemyia brassicae", "Delia radicum", "Delia", "radicum", TRUE,
  "Hyles galli", "Hyles gallii", "Hyles", "gallii", FALSE,
  "Hypocampsis contorticornis", "Platygaster contorticornis", "Platygaster", "contorticornis", TRUE,
  "Hypocryphalus discretus", "Cryphalus discretus", "Cryphalus", "discretus", TRUE,
  "Hyposidra lalaca", "Hyposidra talaca", "Hyposidra", "talaca", FALSE,
  "Hypsipyla puera", "Hyblaea puera", "Hyblaea", "puera", FALSE,
  "Hyseleotris galii", "Hypseleotris galii", "Hypseleotris", "galii", FALSE,
  "Icerya personas", "Icerya purchasi", "Icerya", "purchasi", FALSE,
  "Ichneumonoptera chrysophanes", "Paranthrenella chrysophanes", "Paranthrenella", "chrysophanes", TRUE,
  "Idiomorpha rapae", "Trybliographa rapae", "Trybliographa", "rapae", TRUE,
  "Imbrasia belina", "Gonimbrasia belina", "Gonimbrasia", "belina", TRUE,
  "Isaria cateni", "Isaria cateniannulata", "Isaria", "cateniannulata", FALSE,
  "Isauria aphidovora", "Isauria aphidivora", "Isauria", "aphidivora", FALSE,
  "Isauria aphidivora", "Dipha aphidivora", "Dipha", "aphidivora", TRUE,
  "Isoceras sibirica", "Eogystia sibirica", "Eogystia", "sibirica", TRUE,
  "Isocolus concolor", "Pachyneuron muscarum", "Pachyneuron", "muscarum", FALSE,
  "Ixeuticus martius", "Badumna longinqua", "Badumna", "longinqua", TRUE,
  "Kanaima vittata", "Kanaima dubia", "Kanaima", "dubia", TRUE,
  "Khadira aurantia", "Eudocima aurantia", "Eudocima", "aurantia", TRUE,
  "Kytorhinus sharpianus", "Mylabris tenebrosa", "Mylabris", "tenebrosa", TRUE,
  "Labrorychus delarvatus", "Agrypon delarvatum", "Agrypon", "delarvatum", TRUE,
  "Lachnosterna consanguinea", "Holotrichia consanguinea", "Holotrichia", "consanguinea", TRUE,
  "Laetheticus oryzae", "Latheticus oryzae", "Latheticus", "oryzae", FALSE,
  "Lagynotomus elongatus", "Niphe elongata", "Niphe", "elongata", TRUE,
  "Lamprosema diemenalis", "Hedylepta diemenalis", "Hedylepta", "diemenalis", TRUE,
  "Lasiomma artthracinum", "Strobilomyia anthracina", "Strobilomyia", "anthracina", TRUE,
  "Laspeyresia funebrana", "Grapholita funebrana", "Grapholita", "funebrana", TRUE,
  "Latoia consocia", "Parasa consocia", "Parasa", "consocia", TRUE,
  "Leiocopis gaimarii", "Leucopis gaimarii", "Leucopis", "gaimarii", FALSE,
  "Leis axyridis", "Harmonia axyridis", "Harmonia", "axyridis", TRUE,
  "Leluthia asgtigma", "Leluthia astigma", "Leluthia", "astigma", FALSE,
  "Leptococcus eugeniae", "Plotococcus eugeniae", "Plotococcus", "eugeniae", TRUE,
  "Leucinodes arbonalis", "Leucinodes orbonalis", "Leucinodes", "orbonalis", FALSE,
  "Leucopomyia palliditarsis", "Leucopis alticeps", "Leucopis", "alticeps", TRUE,
  "Leuronota corniger", "Cerotrioza corniger", "Cerotrioza", "corniger", TRUE,
  "Listronotus elongatus", "Pseudhyperodes elongatus", "Pseudhyperodes", "elongatus", TRUE,
  "Lithocolletis ringoniella", "Phyllonorycter ringoniella", "Phyllonorycter", "ringoniella", TRUE,
  "Locris ritbens", "Locris rubens", "Locris", "rubens", FALSE,
  "Lupotarsonemus talpae", "Tarsonemus talpae", "Tarsonemus", "talpae", TRUE,
  "Lyclene dharma dharma", "Miltochrista dharma dharma", "Miltochrista", "dharma dharma", TRUE,
  "Lygropia obrinusalis", "Notarcha obrinusalis", "Notarcha", "obrinusalis", TRUE,
  "Lysiphlebus abnormis", "Leptomastidae abnormis", "Leptomastidae", "abnormis", TRUE,
  "M. nitida", "Medetera nitida", "Medetera", "nitida", FALSE,
  "M. sp. nr spangbergii", "Machaerota sp. nr. spangbergii", "Machaerota", "spangbergii", FALSE,
  "Macaronesia fortunata", "Calliteara fortunata", "Calliteara", "fortunata", TRUE,
  "Maconellicoccus hirturus", "Maconellicoccus hirsutus", "Maconellicoccus", "hirsutus", FALSE,
  "Macrosiphum solanifolii", "Macrosiphum euphorbiae", "Macrosiphum", "euphorbiae", TRUE,
  "Maladera nathani", "Neoserica nathani", "Neoserica", "nathani", TRUE,
  "Malameba locustae", "Malamoeba locustae", "Malamoeba", "locustae", FALSE,
  "Mallodon dasystomus", "Mallodon dasystomum", "Mallodon", "dasystomum", FALSE,
  "Mambarilla rotunda", "Contheyla rotunda", "Contheyla", "rotunda", TRUE,
  "Marasmia obtusa", "Melanagromyza obtusa", "Melanagromyza", "obtusa", FALSE,
  "Marpissa magister", "Mendoza canestrini", "Mendoza", "canestrini", TRUE,
  "Mayetiola mimeuri", "Mayetiola destructor", "Mayetiola", "destructor", TRUE,
  "Medythia nigrobilineata", "Paraluperodes suturalis nigrobilineatus", "Paraluperodes", "suturalis nigrobilineatus", TRUE,
  "Megalurothrips sjosdetji", "Megalurothrips sjostedti", "Megalurothrips", "sjostedti", FALSE,
  "Melanis leda", "Melanitis leda", "Melanitis", "leda", FALSE,
  "Melanoplus bilituratus", "Melanoplus sanguinipes", "Melanoplus", "sanguinipes", TRUE,
  "Melissopus latiferreanus", "Cydia latiferreana", "Cydia", "latiferreana", TRUE,
  "Melitara cf. nephelepasa", "Zophodia cf. nephelepasa", "Zophodia", "nephelepasa", TRUE,
  "Melittia cucurbitae", "Eichlinia cucurbitae", "Eichlinia", "cucurbitae", TRUE,
  "Merocnemus binotatus", "Merocnemus horni", "Merocnemus", "horni", TRUE,
  "Mesobuthus tamulus", "Hottentotta tamulus", "Hottentotta", "tamulus", TRUE,
  "Mesoneura rufonota", "Nematus papillosus", "Nematus", "papillosus", TRUE,
  "Metadelphax muiri", "Matsumuramata muiri", "Matsumuramata", "muiri", FALSE,
  "Metaphidippus aeneolus", "Pelegrina aeneola", "Pelegrina", "aeneola", TRUE,
  "Metaphycus affinis stanleyi", "Metaphycus aff. stanleyi", "Metaphycus", "stanleyi", FALSE,
  "Metarhizium anisopliae var. acridum", "Metarhizium anisopliae", "Metarhizium", "anisopliae", TRUE,
  "Metarhizium anisopliae var. anisopliae", "Metarhizium anisopliae", "Metarhizium", "anisopliae", TRUE,
  "Meterana exquisita", "Melanchra exquisita", "Melanchra", "exquisita", TRUE,
  "Microbracon hebetor", "Habrobracon hebetor", "Habrobracon", "hebetor", FALSE,
  "Micromerus erivanicus", "Muzimes erivanicus", "Muzimes", "erivanicus", TRUE,
  "Microthrix inconspicuella", "Elegia inconspicuella", "Elegia", "inconspicuella", TRUE,
  "Millardia booduga", "Mus booduga", "Mus", "booduga", FALSE,
  "Mimodromites cyaneus", "Dromius cyaneus", "Dromius", "cyaneus", TRUE,
  "Mimorista pulchellalis", "Loxomorpha pulchellalis", "Loxomorpha", "pulchellalis", TRUE,
  "Misumenops lepidus", "Mecaphesa lepida", "Mecaphesa", "lepida", TRUE,
  "Mohunia biguttata", "Ommatocyba biguttata", "Ommatocyba", "biguttata", TRUE,
  "Monecphora saccharina", "Aeneolamia varia saccharina", "Aeneolamia", "varia saccharina", TRUE,
  "Monellia costalis", "Monellia caryella", "Monellia", "caryella", TRUE,
  "Monema favescens", "Monema flavescens", "Monema", "flavescens", FALSE,
  "Monopetalotaxis candescens", "Trochilina candescens", "Trochilina", "candescens", TRUE,
  "Mops plicatus", "Vespertilio plicatus", "Vespertilio", "plicatus", TRUE,
  "Mulsantina stigmatipennis", "Micantulina stigmatipennis", "Micantulina", "stigmatipennis", TRUE,
  "Mylabris afzelli", "Hycleus terminatus", "Hycleus", "terminatus", TRUE,
  "Myosoma chinensis", "Amyosoma chinensis", "Amyosoma", "chinensis", TRUE,
  "Myospalax cansus", "Eospalax fontanierii cansus", "Eospalax", "fontanierii cansus", TRUE,
  "Myzocallis leclanti", "Myzocallis castanicola leclanti", "Myzocallis", "castanicola leclanti", TRUE,
  "Naranga anescens", "Naranga aenescens", "Naranga", "aenescens", FALSE,
  "Nematoclonus concurrens", "Hohenbuehelia concurrens", "Hohenbuehelia", "concurrens", TRUE,
  "Nematoctonus georgenious", "Hohenbuehelia petaloides", "Hohenbuehelia", "petaloides", TRUE,
  "Neochetina conspurcatalis", "Neomusotima conspurcatalis", "Neomusotima", "conspurcatalis", FALSE,
  "Neostauropus alternus", "Stauropus alternus", "Stauropus", "alternus", TRUE,
  "Nephopteryx divisella", "Nephopterix divisella", "Nephopterix", "divisella", FALSE,
  "Nephotettix migropictus", "Nephotettix nigropictus", "Nephotettix", "nigropictus", FALSE,
  "Nesidiocoris cnieniatus", "Nesidiocoris cruentatus", "Nesidiocoris", "cruentatus", FALSE,
  "Nipaecoccus masakensis", "Pseudococcus masakensis", "Pseudococcus", "masakensis", TRUE,
  "Niphadoses gilbiverbis", "Niphadoses gilviberbis", "Niphadoses", "gilviberbis", FALSE,
  "Niphadoses gilviberbis", "Scirpophaga gilviberbis", "Scirpophaga", "gilviberbis", TRUE,
  "Noctua lutescens", "Feltia subterranea", "Feltia", "subterranea", TRUE,
  "Noorda albizonalis", "Deanolis sublimbalis", "Deanolis", "sublimbalis", TRUE,
  "Notolophus antiqua", "Orgyia antiqua", "Orgyia", "antiqua", TRUE,
  "Nupserha sp. near vexator", "Nupserha sp. nr. vexator", "Nupserha", "vexator", FALSE,
  "Nuzonia pallidula", "Gratiana pallidula", "Gratiana", "pallidula", TRUE,
  "Nymphula depenctalia", "Parapoynx stagnalis", "Parapoynx", "stagnalis", TRUE,
  "Nyssia graecarius", "Biston graecarius", "Biston", "graecarius", TRUE,
  "Oberia brevis", "Oberea brevis", "Oberea", "brevis", FALSE,
  "Ochrilidia affinis", "Ochrilidia gracilis", "Ochrilidia", "gracilis", TRUE,
  "Ocinara lida", "Ernolatia lida", "Ernolatia", "lida", TRUE,
  "Ocyptamus stenogaster", "Fragosa stenogaster", "Fragosa", "stenogaster", TRUE,
  "Odontopus varicornis", "Probergrothius varicornis", "Probergrothius", "varicornis", TRUE,
  "Oedophrys hilleri", "Pseudoedophrys hilleri", "Pseudoedophrys", "hilleri", TRUE,
  "Oeobia vevbascalis", "Anania verbascalis", "Anania", "verbascalis", TRUE,
  "Oidaematophorus balanotes", "Hellinsia balanotes", "Hellinsia", "balanotes", TRUE,
  "Olios diana", "Neosparassus diana", "Neosparassus", "diana", TRUE,
  "Omphisa plagialis", "Sinomphisa plagialis", "Sinomphisa", "plagialis", TRUE,
  "Onychiurus armatus", "Protaphorura armata", "Protaphorura", "armata", TRUE,
  "Ophyiulus cf. rargionii", "Ophyiulus cf. targionii", "Ophyiulus", "targionii", FALSE,
  "Orthaga eudrusalis", "Orthaga euadrusalis", "Orthaga", "euadrusalis", FALSE,
  "Orthezia preelonga", "Orthezia praelonga", "Orthezia", "praelonga", FALSE,
  "Osphilia tenuipes", "Osphiliades tenuipes", "Osphiliades", "tenuipes", TRUE,
  "Othreis jordani", "Eudocima jordani", "Eudocima", "jordani", TRUE,
  "Otitis tristicolor", "Orius tristicolor", "Orius", "tristicolor", FALSE,
  "Otospermophilus douglasii", "Otospermophilus beecheyi douglasii", "Otospermophilus", "beecheyi douglasii", TRUE,
  "Ovomermis albicans", "Hexamermis albicans", "Hexamermis", "albicans", TRUE,
  "Oxycanus rufobrunnea", "Oncopera rufobrunnea", "Oncopera", "rufobrunnea", FALSE,
  "Oxycarenus latus", "Oxycarenus laetus", "Oxycarenus", "laetus", FALSE,
  "Ozodendron fijianus", "Coccotrypes nitidus", "Coccotrypes", "nitidus", TRUE,
  "P silochalcis sp.", "Psilochalcis sp.", "Psilochalcis", "", FALSE,
  "PMlophylla heraclei", "Phytomyza heraclei", "Phytomyza", "heraclei", FALSE,
  "Pachydiplosis oryzae", "Orseolia oryzae", "Orseolia", "oryzae", TRUE,
  "Pachytrichospora transvaalensis", "Pachytichospora transvaalensis", "Pachytichospora", "transvaalensis", FALSE,
  "Pachytichospora transvaalensis", "Grigorovia transvaalensis", "Grigorovia", "transvaalensis", TRUE,
  "Pammene critica", "Pammenopsis critica", "Pammenopsis", "critica", TRUE,
  "Panonychus oleivora", "Phyllocoptruta oleivora", "Phyllocoptruta", "oleivora", FALSE,
  "Panotima sp. near angularis", "Panotima sp. nr. angularis", "Panotima", "angularis", FALSE,
  "Panthose bmaculatus", "Panthous bimaculatus", "Panthous", "bimaculatus", FALSE,
  "Pantomorus cinerosus", "Naupactus cinerosus", "Naupactus", "cinerosus", TRUE,
  "Papio itrsinus", "Papio ursinus", "Papio", "ursinus", FALSE,
  "Paracalais berus", "Cryptalaus berus", "Cryptalaus", "berus", TRUE,
  "Paracoccus commiphorae", "Spilococcus commiphorae", "Spilococcus", "commiphorae", TRUE,
  "Paragus hemorrhous", "Paragus haemorrhous", "Paragus", "haemorrhous", FALSE,
  "Paramyelois transitella", "Amyelois transitella", "Amyelois", "transitella", TRUE,
  "Paraponyx stagnalis", "Parapoynx stagnalis", "Parapoynx", "stagnalis", FALSE,
  "Paraqus guadifasciatus", "Paragus quadrifasciatus", "Paragus", "quadrifasciatus", FALSE,
  "Parastethorus nigripes", "Stethorus nigripes", "Stethorus", "nigripes", TRUE,
  "Parastethynium maxwelli", "Stethynium maxwelli", "Stethynium", "maxwelli", TRUE,
  "Parastrongylus costaricensis", "Angiostrongylus costaricensis", "Angiostrongylus", "costaricensis", TRUE,
  "Paratachardina lobata", "Paratachardina silvestrii", "Paratachardina", "silvestrii", TRUE,
  "Paratelenomus minor", "Paratelenomus saccharalis", "Paratelenomus", "saccharalis", TRUE,
  "Pegomya huscami", "Pegomya hyoscyami", "Pegomya", "hyoscyami", FALSE,
  "Pegomyia mixta", "Pegomya mixta", "Pegomya", "mixta", FALSE,
  "Pegomya mixta", "Pegomya cunicularia", "Pegomya", "cunicularia", TRUE,
  "Pegylis sommeri", "Pegylis sommeri", "Pegylis", "sommeri", FALSE,
  "Penthocrates meyrick", "Penthocrates", "Penthocrates", "", FALSE,
  "Phaedon striolata", "Phyllotreta striolata", "Phyllotreta", "striolata", FALSE,
  "Pharoscymnus anchorago", "Pharoscymnus setulosus anchorago", "Pharoscymnus", "setulosus anchorago", TRUE,
  "Philosamia cynthia", "Samia cynthia", "Samia", "cynthia", TRUE,
  "Phissama transiens", "Creatonotos transiens", "Creatonotos", "transiens", TRUE,
  "Phorbia brassicae", "Delia radicum", "Delia", "radicum", TRUE,
  "Phyllonorycter isskii", "Phyllonorycter issikii", "Phyllonorycter", "issikii", FALSE,
  "Phyrohk lantanae", "Phytobia lantanae", "Phytobia", "lantanae", FALSE,
  "Phytophaga thujae", "Mayetiola thujae", "Mayetiola", "thujae", TRUE,
  "Pityophthorus curvidens", "Pityokteines curvidens", "Pityokteines", "curvidens", FALSE,
  "Plagiolepis smitzii", "Plagiolepis schmitzii", "Plagiolepis", "schmitzii", FALSE,
  "Plagiprospherysa trinitatis", "Chetogena trinitatis", "Chetogena", "trinitatis", TRUE,
  "Platymopsis humeralis", "Rhytiphora piperitia", "Rhytiphora", "piperitia", TRUE,
  "Platynaspidius saundersi", "Platynaspis saundersii", "Platynaspis", "saundersii", TRUE,
  "Platystethynium triclavatum", "Pseudocleruchus triclavatus", "Pseudocleruchus", "triclavatus", TRUE,
  "Platytelenomus busseolae", "Telenomus busseolae", "Telenomus", "busseolae", TRUE,
  "Plotococcus capixaba", "Leptococcus capixaba", "Leptococcus", "capixaba", TRUE,
  "Pnigalio circumscriptus", "Pholetesor circumscriptus", "Pholetesor", "circumscriptus", TRUE,
  "Pochonia clamydosporia", "Pochonia chlamydospora", "Pochonia", "chlamydospora", FALSE,
  "Podagrica bowringi", "Nisotra gemella", "Nisotra", "gemella", TRUE,
  "Podontia 14-punctata", "Podontia quatuordecimpunctata", "Podontia", "quatuordecimpunctata", TRUE,
  "Poecilips cardamomi", "Coccotrypes cardamomi", "Coccotrypes", "cardamomi", TRUE,
  "Polybia fastidiosula", "Polybia fastidiosuscula", "Polybia", "fastidiosuscula", FALSE,
  "Polylopha ditissima", "Lopharcha ditissima", "Lopharcha", "ditissima", TRUE,
  "Polypedilum sp. near reei", "Polypedilum sp. nr. reei", "Polypedilum", "reei", FALSE,
  "Popillia japónica", "Popillia japonica", "Popillia", "japonica", FALSE,
  "Poterioochromonas malhamensis", "Poteriochromonas malhamensis", "Poteriochromonas", "malhamensis", TRUE,
  "Potosia brevitarsis", "Protaetia brevitarsis", "Protaetia", "brevitarsis", TRUE,
  "Praina temperata", "Anicla temperata", "Anicla", "temperata", TRUE,
  "Premnotrypes percei", "Premnotrypes piercei", "Premnotrypes", "piercei", TRUE,
  "Pristophora conjugata", "Pristiphora conjugata", "Pristiphora", "conjugata", FALSE,
  "Proceras indicus", "Chilo sacchariphagus indicus", "Chilo", "sacchariphagus indicus", TRUE,
  "Prodenia eridania", "Spodoptera eridania", "Spodoptera", "eridania", TRUE,
  "Prodenia litura", "Spodoptera litura", "Spodoptera", "litura", TRUE,
  "Propylaea japonica", "Propylea japonica", "Propylea", "japonica", FALSE,
  "Prosapia inferens", "Prosapia simulans inferens", "Prosapia", "simulans inferens", TRUE,
  "Protagrotis obscura", "Apamea niveivenosa obscuroides", "Apamea", "niveivenosa obscuroides", TRUE,
  "Protocryptis sibiricella", "Coleophora sibiricella", "Coleophora", "sibiricella", TRUE,
  "Psammodes scrobicollis", "Ocnodes scrobicollis", "Ocnodes", "scrobicollis", TRUE,
  "Pseudaletia adultera", "Mythimna adultera", "Mythimna", "adultera", TRUE,
  "Pseudaphycus flavidulus", "Acerophagus flavidulus", "Acerophagus", "flavidulus", TRUE,
  "Pseudaspidimerus flaviceps", "Coccinella flaviceps", "Coccinella", "flaviceps", TRUE,
  "Pseudocribrolecanium andersoni", "Cribrolecanium andersoni", "Cribrolecanium", "andersoni", TRUE,
  "Pseudodendrothrips mon", "Pseudodendrothrips mori", "Pseudodendrothrips", "mori", FALSE,
  "Pseudodorus clavatus", "Pseudodoros clavatus", "Pseudodoros", "clavatus", FALSE,
  "Pseudoferrisia floridana", "Ferrisia floridana", "Ferrisia", "floridana", TRUE,
  "Pseudometopius apiophaga", "Perilitus apiophaga", "Perilitus", "apiophaga", FALSE,
  "Pseudoplusia indudens", "Pseudoplusia includens", "Pseudoplusia", "includens", FALSE,
  "Pseudosarcophaga affinis", "Agria affinis", "Agria", "affinis", TRUE,
  "Pseudoscymnus tsugae", "Sasajiscymnus tsugae", "Sasajiscymnus", "tsugae", TRUE,
  "Psigida walkeri", "Psilopygida walkeri", "Psilopygida", "walkeri", TRUE,
  "Psila rosea", "Psila rosae", "Psila", "rosae", FALSE,
  "Psiloptera fastuosa", "Lampetis fastuosa", "Lampetis", "fastuosa", TRUE,
  "Pterocormus lotatorius", "Ichneumon lotatorius", "Ichneumon", "lotatorius", TRUE,
  "Pulvinaria innumerabilis", "Neopulvinaria innumerabilis", "Neopulvinaria", "innumerabilis", TRUE,
  "Pysandisia archon", "Paysandisia archon", "Paysandisia", "archon", FALSE,
  "Rachispunctatus sp.", "Rachis punctatus", "Rachis", "punctatus", FALSE,
  "Raghuva albipunctella", "Heliocheilus albipunctella", "Heliocheilus", "albipunctella", TRUE,
  "Rana nigromaculata", "Pelophylax nigromaculatus", "Pelophylax", "nigromaculatus", TRUE,
  "Raphidopalpa foveicollis", "Aulacophora foveicollis", "Aulacophora", "foveicollis", TRUE,
  "Rattus gleadowi", "Millardia gleadowi", "Millardia", "gleadowi", TRUE,
  "Rhinotorus congruens", "Otlophorus congruens", "Otlophorus", "congruens", TRUE,
  "Rhipibruchus picturatus", "Bruchus picturatus", "Bruchus", "picturatus", TRUE,
  "Rhizotrogus majalis", "Amphimallon majale", "Amphimallon", "majale", TRUE,
  "Rhopalicus pukhripennis", "Rhopalicus pulchripennis", "Rhopalicus", "pulchripennis", FALSE,
  "Rhynchocoris poseidon", "Rhynchocoris humeralis", "Rhynchocoris", "humeralis", TRUE,
  "Rhytia cocalus", "Eudocima cocalus", "Eudocima", "cocalus", TRUE,
  "Ribeiroia guadeloupensis", "Ribeiroia marini guadeloupensis", "Ribeiroia", "marini guadeloupensis", TRUE,
  "Ricania fertestrata", "Ricania fenestrata", "Ricania", "fenestrata", FALSE,
  "Rodolia limbata", "Novius koebelei", "Novius", "koebelei", TRUE,
  "Roseala tessellatus", "Phassus agrionides", "Phassus", "agrionides", TRUE,
  "Ruguloscolytus amygdali", "Scolytus amygdali", "Scolytus", "amygdali", TRUE,
  "Rynchophorus ferrugineus", "Rhynchophorus ferrugineus", "Rhynchophorus", "ferrugineus", FALSE,
  "Sahyadrassus malabaricus", "Endoclita malabaricus", "Endoclita", "malabaricus", TRUE,
  "Saisettia oleae", "Saissetia oleae", "Saissetia", "oleae", FALSE,
  "Sameodes albiguttalis", "Niphograpta albiguttalis", "Niphograpta", "albiguttalis", TRUE,
  "Sancassania chelone", "Sancassania mycophagus", "Sancassania", "mycophagus", TRUE,
  "Sathrobota simplex", "Anatrachyntis simplex", "Anatrachyntis", "simplex", TRUE,
  "Schizaphis granarium", "Schizaphis graminum", "Schizaphis", "graminum", TRUE,
  "Schoenobius incertulas", "Scirpophaga incertulas", "Scirpophaga", "incertulas", TRUE,
  "Scleroderma guani", "Sclerodermus guani", "Sclerodermus", "guani", FALSE,
  "Scolecocampa mochisa", "Saccharophagos mochisa", "Saccharophagos", "mochisa", TRUE,
  "Scotinophara coaractata", "Scotinophara coarctata", "Scotinophara", "coarctata", FALSE,
  "Scrobipalpula absoluta", "Tuta absoluta", "Tuta", "absoluta", TRUE,
  "Scrobipalpuloides absoluta", "Tuta absoluta", "Tuta", "absoluta", TRUE,
  "Scutopalus momentosus", "Scutopalus tomentosus", "Scutopalus", "tomentosus", FALSE,
  "Scymnobius flavifrons", "Nephus flavifrons", "Nephus", "flavifrons", TRUE,
  "Scyphophorus incurrens", "Sphenophorus incurrens", "Sphenophorus", "incurrens", FALSE,
  "Sebaethe fulvipennis", "Podagricomela nigripes", "Podagricomela", "nigripes", TRUE,
  "Secusio extensa", "Galtara extensa", "Galtara", "extensa", TRUE,
  "Semasia diniana", "Zeiraphera diniana", "Zeiraphera", "diniana", TRUE,
  "Semiadalia undecimpunctata", "Ceratomegilla undecimnotata", "Ceratomegilla", "undecimnotata", TRUE,
  "Sericothrips adolfifriderici", "Hydatothrips adolfifriderici", "Hydatothrips", "adolfifriderici", TRUE,
  "Sesselia pnsilla", "Sesselia pusilla", "Sesselia", "pusilla", FALSE,
  "Sidemia depravata", "Spodoptera depravata", "Spodoptera", "depravata", TRUE,
  "Sigelgaita nr. chilensis", "Zophodia nr. chilensis", "Zophodia", "chilensis", TRUE,
  "Siraton internatus", "Tranes internatus", "Tranes", "internatus", TRUE,
  "Sitotroga serealella", "Sitotroga cerealella", "Sitotroga", "cerealella", FALSE,
  "Smaragdina oblongum", "Exomis oblongum", "Exomis", "oblongum", TRUE,
  "Sminthums viridis", "Sminthurus viridis", "Sminthurus", "viridis", FALSE,
  "Sogatella dorsalis", "Scirtothrips dorsalis", "Scirtothrips", "dorsalis", FALSE,
  "Spectrobates ceratoniae", "Apomyelois ceratoniae", "Apomyelois", "ceratoniae", TRUE,
  "Sphaerophoria Indiana", "Sphaerophoria indiana", "Sphaerophoria", "indiana", FALSE,
  "Spilosoma maculosa", "Alpenus maculosa", "Alpenus", "maculosa", TRUE,
  "Spondylis alternans", "Sybra alternans", "Sybra", "alternans", FALSE,
  "Steatococcus sp. new species", "Steatococcus sp. nov.", "Steatococcus", "", FALSE,
  "Steneotarsonemus concavus", "Steneotarsonemus concavuscutum", "Steneotarsonemus", "concavuscutum", FALSE,
  "Stenomesius sp. near japonicus", "Stenomesius sp. nr. japonicus", "Stenomesius", "japonicus", FALSE,
  "Stenophysa columella", "Pseudosuccinea columella", "Pseudosuccinea", "columella", TRUE,
  "Steriphus variabilis", "Dryopais variabilis", "Dryopais", "variabilis", TRUE,
  "Sternochaetus mangiferae", "Sternochetus mangiferae", "Sternochetus", "mangiferae", FALSE,
  "Stethorus japonicus", "Stethorus siphonulus", "Stethorus", "siphonulus", TRUE,
  "Stomatomyia littoralis", "Chetogena littoralis", "Chetogena", "littoralis", TRUE,
  "Strobliomyia orbata", "Peribaea orbata", "Peribaea", "orbata", TRUE,
  "Strongyllodes variegatus", "Xenostrongylus variegatus", "Xenostrongylus", "variegatus", TRUE,
  "Sturmia sericariae", "Blepharipa sericariae", "Blepharipa", "sericariae", TRUE,
  "Stylocephatus janovyi", "Stylocephalus janovyi", "Stylocephalus", "janovyi", FALSE,
  "Stylosomus prob. tamaricis", "Stylosomus tamarisci", "Stylosomus", "tamarisci", TRUE,
  "Sukunahikona japonica", "Scymnomorphus japonicus", "Scymnomorphus", "japonicus", TRUE,
  "Synergus davisi", "Synergus lignicola", "Synergus", "lignicola", TRUE,
  "Syntomis passalis", "Amata passalis", "Amata", "passalis", TRUE,
  "Syphrea bibiana", "Nesaecrepida infuscata", "Nesaecrepida", "infuscata", TRUE,
  "Tachina larvarum", "Tachina hispida", "Tachina", "hispida", TRUE,
  "Tachinus pennipes", "Trichopoda pennipes", "Trichopoda", "pennipes", FALSE,
  "Tadarida plicata", "Chaerephon plicatus", "Chaerephon", "plicatus", TRUE,
  "Takecallis nigroantennatus", "Takecallis nigroantennata", "Takecallis", "nigroantennata", TRUE,
  "Tamarixia atamiensis", "Tetrastichus atamiensis", "Tetrastichus", "atamiensis", TRUE,
  "Taplirorychus betuiae", "Taphrorychus betulae", "Taphrorychus", "betulae", FALSE,
  "Tarache nitidula", "Acontia nitidula", "Acontia", "nitidula", TRUE,
  "Tarachidia candefacta", "Ponometia candefacta", "Ponometia", "candefacta", TRUE,
  "Taragama siva", "Streblote siva", "Streblote", "siva", TRUE,
  "Taumetopoea solitaria", "Thaumetopoea solitaria", "Thaumetopoea", "solitaria", FALSE,
  "Teda solanivora", "Tecia solanivora", "Tecia", "solanivora", FALSE,
  "Telamonia bifurcilinea", "Phintella bifurcilinea", "Phintella", "bifurcilinea", TRUE,
  "Telenotmis spp.", "Telenomus spp.", "Telenomus", "", FALSE,
  "Temnochila chlorodia", "Temnoscheila chlorodia", "Temnoscheila", "chlorodia", TRUE,
  "Temnochila virescens", "Temnoscheila virescens", "Temnoscheila", "virescens", TRUE,
  "Tetradacus citri", "Bactrocera minax", "Bactrocera", "minax", TRUE,
  "Tetralopha scortealis", "Pococera scortealis", "Pococera", "scortealis", TRUE,
  "Teuchothrips fuscus", "Liothrips fuscus", "Liothrips", "fuscus", TRUE,
  "Thaeniothrips simplex", "Taeniothrips simplex", "Taeniothrips", "simplex", FALSE,
  "Taeniothrips simplex", "Thrips simplex", "Thrips", "simplex", TRUE,
  "Thecabius qffinis", "Thecabius affinis", "Thecabius", "affinis", FALSE,
  "Theridium octomaculatum", "Coleosoma octomaculatum", "Coleosoma", "octomaculatum", TRUE,
  "Thomasiniana oleisuga", "Resseliella oleisuga", "Resseliella", "oleisuga", TRUE,
  "Thrips abaci", "Thrips tabaci", "Thrips", "tabaci", FALSE,
  "Thrips babaci", "Thrips tabaci", "Thrips", "tabaci", FALSE,
  "Thyphedanus undulatus", "Typhedanus undulatus", "Typhedanus", "undulatus", FALSE,
  "Thyraeella collaris", "Diadromus collaris", "Diadromus", "collaris", TRUE,
  "Thyreocephalus cyanopterus", "Achmonia cyanoptera", "Achmonia", "cyanoptera", TRUE,
  "Tijphaea stercorea", "Typhaea stercorea", "Typhaea", "stercorea", FALSE,
  "Tipulia tipuliformis", "Synanthedon tipuliformis", "Synanthedon", "tipuliformis", TRUE,
  "Tmetocera lariciana", "Spilonota laricana", "Spilonota", "laricana", TRUE,
  "Tmetolophota atristriga", "Graphania atristriga", "Graphania", "atristriga", TRUE,
  "Topiris salva", "Athrypsiastis salva", "Athrypsiastis", "salva", TRUE,
  "Tortrix capensana", "Lozotaenia capensana", "Lozotaenia", "capensana", TRUE,
  "Trachyaphthona nigrita", "Aphthona nigrita", "Aphthona", "nigrita", TRUE,
  "Traumatocampa ispartaensis", "Thaumetopoea ispartaensis", "Thaumetopoea", "ispartaensis", TRUE,
  "Trichogramma acha*eae", "Trichogramma acchaeae", "Trichogramma", "acchaeae", FALSE,
  "Trichophysetis cretacea", "Hendecasis cretacea", "Hendecasis", "cretacea", TRUE,
  "Trichopoda giacomellii", "Trichopoda pictipennis", "Trichopoda", "pictipennis", TRUE,
  "Trichospilus albiflagellatus", "Trichospilus vorax", "Trichospilus", "vorax", TRUE,
  "Tricliona nr nigra", "Bathseba nr. nigra", "Bathseba", "nigra", TRUE,
  "Trionymus glomerulus", "Eurycoccus glomerulus", "Eurycoccus", "glomerulus", TRUE,
  "Tropiconabis capsiformis", "Nabis capsiformis", "Nabis", "capsiformis", TRUE,
  "Tropoderma variabile", "Trogoderma variabile", "Trogoderma", "variabile", FALSE,
  "Troxys cirsii", "Trioxys cirsii", "Trioxys", "cirsii", FALSE,
  "Tryporyza nivella", "Scirpophaga nivella", "Scirpophaga", "nivella", TRUE,
  "Utethesia pulchella", "Utetheisa pulchella", "Utetheisa", "pulchella", FALSE,
  "Vairimorpha necatrix", "Vairimorpha ephestiae", "Vairimorpha", "ephestiae", TRUE,
  "Virachola isocrates", "Deudorix isocrates", "Deudorix", "isocrates", TRUE,
  "Volkeliopsis arecae", "Mircarvalhoia arecae", "Mircarvalhoia", "arecae", TRUE,
  "Xanthodes graellsi", "Microcassiope minor", "Microcassiope", "minor", TRUE,
  "Xyleborus californiens", "Xyleborus californicus", "Xyleborus", "californicus", TRUE,
  "Yagra oiticica", "Yagra", "Yagra", "", TRUE,
  "Zinckenia fascialis", "Spoladea recurvalis", "Spoladea", "recurvalis", TRUE,
  "albipes", "Stenocephalemys albipes", "Stenocephalemys", "albipes", FALSE,
  "alces", "Alces alces", "Alces", "alces", FALSE,
  "bison", "Bison bison", "Bison", "bison", FALSE,
  "buteo", "Buteo buteo", "Buteo", "buteo", FALSE,
  "caracal", "Caracal caracal", "Caracal", "caracal", FALSE,
  "chitala", "Chitala chitala", "Chitala", "chitala", FALSE,
  "cinnabarinus", "Tetranychus cinnabarinus", "Tetranychus", "cinnabarinus", FALSE,
  "cossus", "Cossus cossus", "Cossus", "cossus", FALSE,
  "crocuta", "Crocuta crocuta", "Crocuta", "crocuta", FALSE,
  "gema", "Gesonia gema", "Gesonia", "gema", FALSE,
  "gryllotalpa", "Gryllotalpa gryllotalpa", "Gryllotalpa", "gryllotalpa", FALSE,
  "harringtoni", "Pelomys harringtoni", "Pelomys", "harringtoni", FALSE,
  "lutra", "Lutra lutra", "Lutra", "lutra", FALSE,
  "martes", "Martes martes", "Martes", "martes", FALSE,
  "musculus", "Mus musculus", "Mus", "musculus", FALSE,
  "ocellana", "Spilonota ocellana", "Spilonota", "ocellana", FALSE,
  "perdix", "Perdix perdix", "Perdix", "perdix", FALSE,
  "polygraphus", "Polygraphus poligraphus", "Polygraphus", "poligraphus", FALSE,
  "ponentina", "Ponentina ponentina", "Ponentina", "ponentina", FALSE,
  "rattus", "Rattus rattus", "Rattus", "rattus", FALSE,
  "Bossus sp.", "Bassus sp.", "Bassus", "", FALSE,
  "Chelomis sp.", "Chelonus sp.", "Chelonus", "", FALSE,
  "Syzenclus riiberrimns", "Syzeuctus ruberrimus", "Syzeuctus", "ruberrimus", FALSE,
  "Dentichasmias bnsseolae", "Dentichasmias busseolae", "Dentichasmias", "busseolae", FALSE,
  "Cotesia nificrits", "Cotesia ruficrus", "Cotesia", "ruficrus", FALSE,
  "Pediobius firrus", "Pediobius furvus", "Pediobius", "furvus", FALSE,
  "argillacea", "Alabama argillacea", "Alabama", "argillacea", FALSE,
  "A. argillacea", "Alabama argillacea", "Alabama", "argillacea", FALSE,
  "?Paraphylax sp.", "Paraphylax", "Paraphylax", "", FALSE,
  "Abalone (unspecified species)", "Haliotis", "Haliotis", "", TRUE,
  "D. abbreviatus", "Dialeurodes abbreviatus", "Dialeurodes", "abbreviatus", FALSE,
  "D. inedulis", "Dasiops inedulis", "Dasiops", "inedulis", FALSE,
  "E. kuhniella", "Ephestia kuhniella", "Ephestia", "kuhniella", FALSE,
  "H. vitripennis", "Heteropsylla vitripennis", "Heteropsylla", "vitripennis", FALSE,
  "Heteroperreyia n.? sp.", "Heteroperreyia", "Heteroperreyia", "", FALSE,
  "Anagyrus ?nr aurantifrons", "Anagyrus aurantifrons", "Anagyrus", "aurantifrons", TRUE,
  "Steinernema NR01", "Steinernema", "Steinernema", "", FALSE,
  "Rivula atimeta (nr.)", "Rivula atimeta", "Rivula", "atimeta", TRUE,
  "Gonipterus species no. 2", "Gonipterus", "Gonipterus", "", TRUE,
  "Sclerodermus sp. (No. 5)", "Sclerodermus", "Sclerodermus", "", TRUE,
  "Agnippe sp. #1", "Agnippe", "Agnippe", "", TRUE,
  "Trichogramma foersterisp. nov.", "Trichogramma foersteri", "Trichogramma", "foersteri", FALSE,
  "Callosobruchus sp. (Indet.)", "Callosobruchus", "Callosobruchus", "", TRUE,
  "T. citricidus", "Trioza citricidus", "Trioza", "citricidus", FALSE,
  "Thrips spp. (e.g., spider mites)", "Thrips spp.", "Thrips", "", FALSE,
  "Whitefly spp. (e.g., spider mites)", "Whitefly spp.", "", "", FALSE,
  "Acharia gemmatalis", "Anticarsia gemmatalis", "Anticarsia", "gemmatalis", FALSE,
  "Antheraea pernyi (unspecified)", "Antheraea pernyi", "Antheraea", "pernyi", FALSE,
  "Aondiniella aurantii", "Aonidiella aurantii", "Aonidiella", "aurantii", FALSE,
  "Aph i s g ossypii", "Aphis gossypii", "Aphis", "gossypii", FALSE,
  "Aphidae", "Aphididae", "", "", FALSE,
  "Aphodidae", "Aphodiinae", "", "", FALSE,
  "Asian citrus psyllid", "Diaphorina citri", "Diaphorina", "citri", TRUE,
  "Asian citrus psyllid (ACP)", "Diaphorina citri", "Diaphorina", "citri", TRUE,
  "Bacterocea oleae", "Bactrocera oleae", "Bactrocera", "oleae", FALSE,
  "Calleria mellonella", "Galleria mellonella", "Galleria", "mellonella", FALSE,
  "Corcyra cephalonica (unspecified)", "Corcyra cephalonica", "Corcyra", "cephalonica", FALSE,
  "Fergusonia sp.", "Fergusonina", "Fergusonina", "", FALSE,
  "Foxglove aphid", "Aulacorthum solani", "Aulacorthum", "solani", TRUE,
  "Fuller rose beetle", "Naupactus cervinus", "Naupactus", "cervinus", TRUE,
  "Gracilaria sp.", "Gracillaria sp.", "Gracillaria", "", FALSE,
  "Gracilaria syringella", "Gracillaria syringella", "Gracillaria", "syringella", FALSE,
  "Melonworm moth (Crambidae)", "Diaphania hyalinata", "Diaphania", "hyalinata", TRUE,
  "Nelanitis leda ismene", "Melanitis leda ismene", "Melanitis", "leda ismene", FALSE,
  "Nomura earileyi", "Nomuraea rileyi", "Nomuraea", "rileyi", FALSE,
  "Pseudococcus solenopsis", "Phenacoccus solenopsis", "Phenacoccus", "solenopsis", FALSE,
  "Pltenacoccus solenopsis", "Phenacoccus solenopsis", "Phenacoccus", "solenopsis", FALSE,
  "Porina", "Wiseana", "Wiseana", "", TRUE,
  "Potato cyst nematode", "Globodera spp.", "Globodera", "", TRUE,
  "potato cyst nematodes (PCN)", "Globodera spp.", "Globodera", "", TRUE,
  "Rhynocophorus ferrugineus", "Rhynchophorus ferrugineus", "Rhynchophorus", "ferrugineus", FALSE,
  "Rlinbdepyris sp.", "Rhabdepyris sp.", "Rhabdepyris", "", FALSE,
  "Schirphopaga incertulas", "Scirpophaga incertulas", "Scirpophaga", "incertulas", FALSE,
  "Spodtera exigua", "Spodoptera exigua", "Spodoptera", "exigua", FALSE,
  "TaeccaiHs arnddinariae", "Takecallis arundinariae", "Takecallis", "arundinariae", FALSE,
  "T taiwana", "Takecallis taiwana", "Takecallis", "taiwana", FALSE,
  "Two-banded Japanese weevil", "Pseudocneorhinus bifasciatus", "Pseudocneorhinus", "bifasciatus", TRUE,
  "Two‑spotted spider mite", "Tetranychus urticae", "Tetranychus", "urticae", TRUE,
  "Western flower thrips", "Frankliniella occidentalis", "Frankliniella", "occidentalis", TRUE,
  "Wheat stem sawfly", "Cephus cinctus", "Cephus", "cinctus", TRUE,
  "adzuki bean borer", "Ostrinia scapulalis", "Ostrinia", "scapulalis", TRUE,
  "apple and nut borer (ANB)", "Citripestis eutraphera", "Citripestis", "eutraphera", TRUE,
  "apple leaf-curling aphid", "Dysaphis", "Dysaphis", "", TRUE,
  "apple sawfly", "Hoplocampa testudinea", "Hoplocampa", "testudinea", TRUE,
  "banana aphid", "Pentalonia nigronervosa", "Pentalonia", "nigronervosa", TRUE,
  "banana borer", "Cosmopolites sordidus", "Cosmopolites", "sordidus", TRUE,
  "black-margined pecan aphid", "Monellia caryella", "Monellia", "caryella", TRUE,
  "brinjal fruit borer", "Leucinodes orbonalis", "Leucinodes", "orbonalis", TRUE,
  "brinjal shoot borer", "Leucinodes orbonalis", "Leucinodes", "orbonalis", TRUE,
  "cabbage root maggot", "Delia radicum", "Delia", "radicum", TRUE,
  "cabbage root maggots", "Delia radicum", "Delia", "radicum", TRUE,
  "cabbage seedpod weevil", "Ceutorhynchus obstrictus", "Ceutorhynchus", "obstrictus", TRUE,
  "cabbage stem flea beetle", "Psylliodes chrysocephala", "Psylliodes", "chrysocephala", TRUE,
  "cabbage webworm", "Hellula undalis", "Hellula", "undalis", TRUE,
  "carrot aphid", "Cavariella aegopodii", "Cavariella", "aegopodii", TRUE,
  "carrot root weevil", "Listronotus oregonensis", "Listronotus", "oregonensis", TRUE,
  "cassava green mite", "Mononychellus tanajoa", "Mononychellus", "tanajoa", TRUE,
  "cockchafer beetles (Melolontha melolontha)", "Melolontha melolontha", "Melolontha", "melolontha", TRUE,
  "codling moth", "Cydia pomonella", "Cydia", "pomonella", TRUE,
  "coffee berry borer", "Hypothenemus hampei", "Hypothenemus", "hampei", TRUE,
  "corn borer", "Ostrinia furnacalis", "Ostrinia", "furnacalis", TRUE,
  "cotton aphid", "Aphis gossypii", "Aphis", "gossypii", TRUE,
  "cotton bollworm", "Helicoverpa armigera", "Helicoverpa", "armigera", TRUE,
  "cotton fleahopper (Pseudatomoscelis seriatus)", "Pseudatomoscelis seriatus", "Pseudatomoscelis", "seriatus", TRUE,
  "cowpea aphid", "Aphis craccivora", "Aphis", "craccivora", TRUE,
  "early shoot borer", "Chilo infuscatellus", "Chilo", "infuscatellus", TRUE,
  "eastern spruce budworm", "Choristoneura fumiferana", "Choristoneura", "fumiferana", TRUE,
  "elongate hemlock scale", "Fiorinia externa", "Fiorinia", "externa", TRUE,
  "furniture beetle", "Anobium punctatum", "Anobium", "punctatum", TRUE,
  "gram pod borer larvae", "Helicoverpa armigera", "Helicoverpa", "armigera", TRUE,
  "green leafhopper", "Cicadella viridis", "Cicadella", "viridis", TRUE,
  "greenhouse whitefly", "Trialeurodes vaporariorum", "Trialeurodes", "vaporariorum", TRUE,
  "hadda beetle", "Henosepilachna vigintioctopunctata", "Henosepilachna", "vigintioctopunctata", TRUE,
  "hemlock looper", "Lambdina fiscellaria", "Lambdina", "fiscellaria", TRUE,
  "internode borer", "Chilo sacchariphagus indicus", "Chilo", "sacchariphagus indicus", TRUE,
  "Sugarcane internode borer", "Chilo sacchariphagus indicus", "Chilo", "sacchariphagus indicus", TRUE,
  "Sugarcane internode borer (eggs)", "Chilo sacchariphagus indicus", "Chilo", "sacchariphagus indicus", TRUE,
  "leopard frog tadpoles", "Lithobates", "Lithobates", "", TRUE,
  "maize aphid", "Rhopalosiphum maidis", "Rhopalosiphum", "maidis", TRUE,
  "mango leaf webber", "Orthaga euadrusalis", "Orthaga", "euadrusalis", TRUE,
  "melonworm (pupa)", "Diaphania hyalinata", "Diaphania", "hyalinata", TRUE,
  "millet head miner", "Heliocheilus albipunctella", "Heliocheilus", "albipunctella", TRUE,
  "olive moth", "Prays oleae", "Prays", "oleae", TRUE,
  "onion flies (Diptera)", "Delia antiqua", "Delia", "antiqua", TRUE,
  "pea aphid", "Acyrthosiphon pisum", "Acyrthosiphon", "pisum", TRUE,
  "pea aphids", "Acyrthosiphon pisum", "Acyrthosiphon", "pisum", TRUE,
  "pear psyllid", "Cacopsylla sp.", "Cacopsylla", "", TRUE,
  "pearl millet head miner", "Heliocheilus albipunctella", "Heliocheilus", "albipunctella", TRUE,
  "pear‑psylla nymphs (Cacopsylla pyri nymphs)", "Cacopsylla pyri", "Cacopsylla", "pyri", TRUE,
  "pink bollworm", "Pectinophora gossypiella", "Pectinophora", "gossypiella", TRUE,
  "pistachio psyllid", "Agonoscena sp.", "Agonoscena", "", TRUE,
  "red scale", "Aonidiella aurantii", "Aonidiella", "aurantii", TRUE,
  "red spider mite", "Tetranychus urticae", "Tetranychus", "urticae", TRUE,
  "rice black bug", "Scotinophara spp.", "Scotinophara", "", TRUE,
  "rice blue beetle", "Leptispa pygmaea", "Leptispa", "pygmaea", TRUE,
  "rice ear bugs", "Leptocorisa oratoria", "Leptocorisa", "oratoria", TRUE,
  "rice gall midge", "Orseolia oryzae", "Orseolia", "oryzae", TRUE,
  "rice leaf folder", "Cnaphalocrocis medinalis", "Cnaphalocrocis", "medinalis", TRUE,
  "rugose spiraling whitefly", "Aleurodicus rugioperculatus", "Aleurodicus", "rugioperculatus", TRUE,
  "southern green stink bug", "Nezara viridula", "Nezara", "viridula", TRUE,
  "spotted bollworm", "Earias spp.", "Earias", "", TRUE,
  "spotted bollworm of okra", "Earias spp.", "Earias", "", TRUE,
  "squash bug", "Anasa tristis", "Anasa", "tristis", TRUE,
  "striped flea beetle", "Phyllotreta striolata", "Phyllotreta", "striolata", TRUE,
  "sugarcane weevil", "Rhabdoscelus obscurus", "Rhabdoscelus", "obscurus", TRUE,
  "summer fruit tortrix moth", "Adoxophyes orana", "Adoxophyes", "orana", TRUE,
  "tasar silkworm", "Antheraea paphia", "Antheraea", "paphia", TRUE,
  "tomato borer", "Tuta absoluta", "Tuta", "absoluta", TRUE,
  "top borer", "Scirpophaga nivella", "Scirpophaga", "nivella", TRUE,
  "Top borer (eggs)", "Scirpophaga nivella", "Scirpophaga", "nivella", TRUE,
  "twig borer", "Xylosandrus compactus", "Xylosandrus", "compactus", TRUE,
  "two-spotted spider mite", "Tetranychus urticae", "Tetranychus", "urticae", TRUE,
  "two-spotted spider mite (Tetranychidae)", "Tetranychus urticae", "Tetranychus", "urticae", TRUE,
  "uzi fly", "Exorista sorbillans", "Exorista", "sorbillans", TRUE,
  "western flower thrips", "Frankliniella occidentalis", "Frankliniella", "occidentalis", TRUE,
  "western spruce budworm", "Choristoneura freemani", "Choristoneura", "freemani", TRUE,
  "wheat aphid", "Sitobion miscanthi", "Sitobion", "miscanthi", TRUE,
  "white apple leafhopper", "Typhlocyba pomaria", "Typhlocyba", "pomaria", TRUE,
  "white-backed planthopper", "Sogatella furcifera", "Sogatella", "furcifera", TRUE,
  "white‑apple leafhopper", "Typhlocyba pomaria", "Typhlocyba", "pomaria", TRUE,
  "yellow stem borer", "Scirpophaga incertulas", "Scirpophaga", "incertulas", TRUE,
  "Anagyrus sp. nearpseudococci", "Anagyrus nr. pseudococci", "Anagyrus", "pseudococci", FALSE,
  "Chelonus near-curvimaculatus", "Chelonus nr. curvimaculatus", "Chelonus", "curvimaculatus", FALSE,
  "Hypena sp. (near abyssinialis)", "Hypena nr. abyssinialis", "Hypena", "abyssinialis", FALSE,
  "Macrosteles near-severini", "Macrosteles nr. severini", "Macrosteles", "severini", FALSE,
  "Paracentrobia sp. (near subflava)", "Paracentrobia nr. subflava", "Paracentrobia", "subflava", FALSE,
  "Pseudoligosita sp. (near longifrangiata)", "Pseudoligosita nr. longifrangiata", "Pseudoligosita", "longifrangiata", FALSE,
  "Acromyrmex landolti fracticornis", "Acromyrmex fracticornis", "Acromyrmex", "fracticornis", FALSE,
  "Acyrthosiphon kondoi (pecan aphids)", "Acyrthosiphon kondoi", "Acyrthosiphon", "kondoi", FALSE,
  "Acyrthosiphon pisum (pecan aphids)", "Acyrthosiphon pisum", "Acyrthosiphon", "pisum", FALSE,
  "Adalia fasciatopunctata revelieri", "Adalia fasciatopunctata revelierei", "Adalia", "fasciatopunctata revelierei", FALSE,
  "Adelges (An.) lepsimon", "Adelges lepsimon", "Adelges", "lepsimon", FALSE,
  "Ageniaspis citr icola", "Ageniaspis citricola", "Ageniaspis", "citricola", FALSE,
  "Aleuroglyphus ovatus (eggs)", "Aleuroglyphus ovatus", "Aleuroglyphus", "ovatus", FALSE,
  "Aleyrodicus rugioper-culatus", "Aleyrodicus rugioperculatus", "Aleyrodicus", "rugioperculatus", FALSE,
  "Allurus litu-ratus", "Allurus lituratus", "Allurus", "lituratus", FALSE,
  "Amrasca biguttulla biguttulla", "Amrasca biguttula biguttula", "Amrasca", "biguttula biguttula", FALSE,
  "Amrasca bigutulla bigutulla", "Amrasca biguttula biguttula", "Amrasca", "biguttula biguttula", FALSE,
  "Amrasea biguttula biguttula", "Amrasca biguttula biguttula", "Amrasca", "biguttula biguttula", FALSE,
  "Amrasca bigutella bigutella", "Amrasca biguttula biguttula", "Amrasca", "biguttula biguttula", FALSE,
  "Amrasca biguttula biguttila", "Amrasca biguttula biguttula", "Amrasca", "biguttula biguttula", FALSE,
  "Anagyrus sp. ?nr aurantifrons", "Anagyrus sp. nr. aurantifrons", "Anagyrus", "aurantifrons", FALSE,
  "Anagyrus sp. nov near sinope", "Anagyrus sp. nr. sinope", "Anagyrus", "sinope", FALSE,
  "Anoecia corni group", "Anoecia corni", "Anoecia", "corni", FALSE,
  "Anthaxia (Haplanthaxia) caseyi caseyi", "Anthaxia caseyi caseyi", "Anthaxia", "caseyi caseyi", FALSE,
  "Anthocoris gallarum-ulmi", "Anthocoris gallarumulmi", "Anthocoris", "gallarumulmi", FALSE,
  "Apanteles sp. (glomeratus group)", "Cotesia glomerata", "Cotesia", "glomerata", FALSE,
  "Aphis (Bursaphis) nr. oenotherae", "Aphis nr. oenotherae", "Aphis", "oenotherae", FALSE,
  "Aphis fabae cirsiacanthoides", "Aphis fabae cirsiiacanthoidis", "Aphis", "fabae cirsiiacanthoidis", FALSE,
  "Aphis viticis (non-leaf-curling)", "Aphis viticis", "Aphis", "viticis", FALSE,
  "Arion ater agg.", "Arion ater", "Arion", "ater", FALSE,
  "Arion hortensis agg.", "Arion hortensis", "Arion", "hortensis", FALSE,
  "Aspilanta am-pelopsifoliella", "Aspilanta ampelopsifoliella", "Aspilanta", "ampelopsifoliella", FALSE,
  "Bacillus thuringiensis subsp. galleriae", "Bacillus thuringiensis galleriae", "Bacillus", "thuringiensis galleriae", FALSE,
  "Bacillus thuringiensis subsp. israelensis", "Bacillus thuringiensis israelensis", "Bacillus", "thuringiensis israelensis", FALSE,
  "Bacillus thuringiensis subsp. kurstaki", "Bacillus thuringiensis kurstaki", "Bacillus", "thuringiensis kurstaki", FALSE,
  "Bacillus thuringiensis subsp. tenebrionis", "Bacillus thuringiensis tenebrionis", "Bacillus", "thuringiensis tenebrionis", FALSE,
  "Bacillus thuringiensis subsp. thuringiensis", "Bacillus thuringiensis thuringiensis", "Bacillus", "thuringiensis thuringiensis", FALSE,
  "Bactrocera (Zeugodacus) tau", "Zeugodacus tau", "Zeugodacus", "tau", FALSE,
  "Bemisia (tabaci complex)", "Bemisia tabaci", "Bemisia", "tabaci", FALSE,
  "Bemisia tabaci (biotype Q)", "Bemisia tabaci", "Bemisia", "tabaci", FALSE,
  "Bemisia tabaci AsiaII7", "Bemisia tabaci", "Bemisia", "tabaci", FALSE,
  "Bemisia tabaci MEAM1", "Bemisia tabaci", "Bemisia", "tabaci", FALSE,
  "Bemisia tabaci MED", "Bemisia tabaci", "Bemisia", "tabaci", FALSE,
  "Bemisia tabaci biotype B", "Bemisia tabaci", "Bemisia", "tabaci", FALSE,
  "Bemisia tabaci group", "Bemisia tabaci", "Bemisia", "tabaci", FALSE,
  "Billbug (Coleoptera: Dryophthoridae)", "Sphenophorus venatus", "Sphenophorus", "venatus", FALSE,
  "Blissus leucopterous leucopterous", "Blissus leucopterus leucopterus", "Blissus", "leucopterus leucopterus", FALSE,
  "Boerias cryptic third species", "Boerias sp.", "Boerias", "", FALSE,
  "Brachycaudus klugkisti (non-leaf-curling)", "Brachycaudus klugkisti", "Brachycaudus", "klugkisti", FALSE,
  "Bradysia sp. nr. coprophila (fungus‑gnat larvae)", "Bradysia sp. nr. coprophila", "Bradysia", "coprophila", FALSE,
  "Budapest keeled slug", "Tandonia budapestensis", "Tandonia", "budapestensis", FALSE,
  "Cacopsylla pyri (pear psylla)", "Cacopsylla pyri", "Cacopsylla", "pyri", FALSE,
  "California red scale", "Aonidiella aurantii", "Aonidiella", "aurantii", FALSE,
  "Carpoglyphus lactis (eggs)", "Carpoglyphus lactis", "Carpoglyphus", "lactis", FALSE,
  "Cecidomyiidae (gall midges) on Rosaceae (including Filipendula ulmaria)", "Filipendula ulmaria", "Filipendula", "ulmaria", FALSE,
  "Cephalonomia tar-salis", "Cephalonomia tarsalis", "Cephalonomia", "tarsalis", FALSE,
  "Ceratitis (Ceratalaspis) spp. cosyra group", "Ceratitis cosyra", "Ceratitis", "cosyra", FALSE,
  "Ceratitis (Pardalaspis) sp. punctata group", "Ceratitis punctata", "Ceratitis", "punctata", FALSE,
  "Ceroplastes floridensis (biotype Q)", "Ceroplastes floridensis", "Ceroplastes", "floridensis", FALSE,
  "Chartocerus sp. A (Signiphoridae)", "Chartocerus sp.", "Chartocerus", "", FALSE,
  "Chestnut gall wasp", "Dryocosmus kuriphilus", "Dryocosmus", "kuriphilus", FALSE,
  "Choristoneura rosaceana (egg masses)", "Choristoneura rosaceana", "Choristoneura", "rosaceana", FALSE,
  "Choristoneura rosaceana (larvae)", "Choristoneura rosaceana", "Choristoneura", "rosaceana", FALSE,
  "Choristoneura rosaceana (obliquebanded leafroller)", "Choristoneura rosaceana", "Choristoneura", "rosaceana", FALSE,
  "Chrysoperla zastrowi silleni", "Chrysoperla zastrowi sillemi", "Chrysoperla", "zastrowi sillemi", FALSE,
  "Coccinella septem-punctata", "Coccinella septempunctata", "Coccinella", "septempunctata", FALSE,
  "Coccinella setempunctata bruckii", "Coccinella septempunctata bruckii", "Coccinella", "septempunctata bruckii", FALSE,
  "Coccinella undecimpunctata aegyptica", "Coccinella undecimpunctata aegyptiaca", "Coccinella", "undecimpunctata aegyptiaca", FALSE,
  "Coccophagus lycimnia (Walker)", "Coccophagus lycimnia", "Coccophagus", "lycimnia", FALSE,
  "Coleoptera: Curculionidae (alfalfa weevil)", "Hypera postica", "Hypera", "postica", FALSE,
  "Common white snail", "Cernuella virgata", "Cernuella", "virgata", FALSE,
  "Condylostylus caudatus group", "Condylostylus caudatus", "Condylostylus", "caudatus", FALSE,
  "Corcyra cephalonica (egg)", "Corcyra cephalonica", "Corcyra", "cephalonica", FALSE,
  "Corcyra cephalonica (various lepidopteran hosts)", "Corcyra cephalonica", "Corcyra", "cephalonica", FALSE,
  "Cryphalomorphus grosse-punctatus", "Cryphalomorphus grossepunctatus", "Cryphalomorphus", "grossepunctatus", FALSE,
  "Cryptolestes pusillus (eggs)", "Cryptolestes pusillus", "Cryptolestes", "pusillus", FALSE,
  "Cybocephalus fodori-minor", "Cybocephalus fodori minor","Cybocephalus", "fodori minor",  FALSE,
  "Cybocephalus jodori minor", "Cybocephalus fodori minor", "Cybocephalus", "fodori minor", FALSE,
  "Cylas formicarius elengantulus", "Cylas formicarius elegantulus", "Cylas", "formicarius elegantulus", FALSE,
  "Cyrtomenus bergi (Hemiptera: Cydnidae)", "Cyrtomenus bergi", "Cyrtomenus", "bergi", FALSE,
  "Dasineura ulmaria (Cecidomyiidae)", "Dasineura ulmaria", "Dasineura", "ulmaria", FALSE,
  "Dasineura urticae (Cecidomyiidae)", "Dasineura urticae", "Dasineura", "urticae", FALSE,
  "Demyrsus meleoid es", "Demyrsus meleoides", "Demyrsus", "meleoides", FALSE,
  "Deroceras reticulatum (egg)", "Deroceras reticulatum", "Deroceras", "reticulatum", FALSE,
  "Diabrotica undecimpunctata Howardi", "Diabrotica undecimpunctata howardi", "Diabrotica", "undecimpunctata howardi", FALSE,
  "Diabrotica undecimpunctata howardii", "Diabrotica undecimpunctata howardi", "Diabrotica", "undecimpunctata howardi", FALSE,
  "Diabrotica virginifera virginifera", "Diabrotica virgifera virgifera", "Diabrotica", "virgifera virgifera", FALSE,
  "Diadegma semi-clausum", "Diadegma semiclausum", "Diadegma", "semiclausum", FALSE,
  "Diaphania undecimpunctata howardi", "Diabrotica undecimpunctata howardi", "Diabrotica", "undecimpunctata howardi", FALSE,
  "Diaprepes abbreviatus (Diaprepes root weevil)", "Diaprepes abbreviatus", "Diaprepes", "abbreviatus", FALSE,
  "Drosophila melanogaster group", "Drosophila melanogaster", "Drosophila", "melanogaster", FALSE,
  "Dysaphis spp. (leaf-curling)", "Dysaphis spp.", "Dysaphis", "", FALSE,
  "Earias vitella (neonate)", "Earias vittella", "Earias", "vittella", FALSE,
  "Ephestia kuehniella (Tortricidae, Noctuidae, Plutellidae, Pyralidae, Crambidae)", "Ephestia kuehniella", "Ephestia", "kuehniella", FALSE,
  "Epilachna 26-punctata 26-punctata", "Henosepilachna vigintisexpunctata vigintisexpunctata", "Henosepilachna", "vigintisexpunctata vigintisexpunctata", FALSE,
  "Epilachna 26‑punctata", "Henosepilachna vigintisexpunctata", "Henosepilachna", "vigintisexpunctata", FALSE,
  "Epilachna 28-punctata pardalis", "Henosepilachna vigintioctopunctata pardalis", "Henosepilachna", "vigintioctopunctata pardalis", FALSE,
  "Epilachna 28‑punctata pardalis", "Henosepilachna vigintioctopunctata pardalis", "Henosepilachna", "vigintioctopunctata pardalis", FALSE,
  "Epilachna dodeca-stigma", "Epilachna dodecastigma", "Epilachna", "dodecastigma", FALSE,
  "Epilachna vigintiocto-punctata", "Henosepilachna vigintioctopunctata", "Henosepilachna", "vigintioctopunctata", FALSE,
  "Epilachna vigintisexpunctata vigintisexpunctata", "Henosepilachna vigintisexpunctata", "Henosepilachna", "vigintisexpunctata", FALSE,
  "Eretmocerus sp. gr. serius", "Eretmocerus serius", "Eretmocerus", "serius", FALSE,
  "Erio‑phyes eremus", "Eriophyes eremus", "Eriophyes", "eremus", FALSE,
  "European red mite", "Panonychus ulmi", "Panonychus", "ulmi", FALSE,
  "Fruit‑fly larvae (e.g., Drosophila spp.)", "Drosophila spp.", "Drosophila", "", FALSE,
  "Graminella stelliger-viridescens", "Graminella stelliger viridescens", "Graminella", "stelliger viridescens", FALSE,
  "Gray field slug", "Deroceras agreste", "Deroceras", "agreste", FALSE,
  "Green peach aphid", "Myzus persicae", "Myzus", "persicae", FALSE,
  "Gynæphora Gynaephora jiuzhiensis", "Gynaephora jiuzhiensis", "Gynaephora", "jiuzhiensis", FALSE,
  "Gynæphora Gynaephora menyuanensis", "Gynaephora menyuanensis", "Gynaephora", "menyuanensis", FALSE,
  "Gynæphora Gynaephora qinghaiensis", "Gynaephora qinghaiensis", "Gynaephora", "qinghaiensis", FALSE,
  "Gynæphora Gynaephora qumalaiensis", "Gynaephora qumalaiensis", "Gynaephora", "qumalaiensis", FALSE,
  "Habrocytus sp. near dispar group", "Habrocytus sp. nr. dispar", "Habrocytus", "dispar", FALSE,
  "Hartigiola annulipes (Cecidomyiidae)", "Hartigiola annulipes", "Hartigiola", "annulipes", FALSE,
  "Helicoverpa armigera (neonate)", "Helicoverpa armigera", "Helicoverpa", "armigera", FALSE,
  "Heliozelidae Aspilanta viticordifoliella", "Aspilanta viticordifoliella", "Aspilanta", "viticordifoliella", FALSE,
  "Heliozelidae Heliozela eugeniella", "Heliozela eugeniella", "Heliozela", "eugeniella", FALSE,
  "Hemiptera: Adelgidae (hemlock woolly adelgid)", "Adelges tsugae", "Adelges", "tsugae", FALSE,
  "Herpisticus betan‑curiae", "Herpisticus betancuriae", "Herpisticus", "betancuriae", FALSE,
  "Heterodera trifolii f. sp. beta", "Heterodera betae", "Heterodera", "betae", FALSE,
  "Heteronychus sanctae-helenae", "Heteronychus sanctaehelenae", "Heteronychus", "sanctaehelenae", FALSE,
  "Hyadaphis foeniculi (non-leaf-curling)", "Hyadaphis foeniculi", "Hyadaphis", "foeniculi", FALSE,
  "Hyper a postica", "Hypera postica", "Hypera", "postica", FALSE,
  "Lasioderma serricorne (eggs)", "Lasioderma serricorne", "Lasioderma", "serricorne", FALSE,
  "Leptocorisa (Leptocorisa bugs)", "Leptocorisa spp.", "Leptocorisa", "", FALSE,
  "Leucoptera sparti-foliella", "Leucoptera spartifoliella", "Leucoptera", "spartifoliella", FALSE,
  "Lipaphis pseudo-brassicae", "Lipaphis pseudobrassicae", "Lipaphis", "pseudobrassicae", FALSE,
  "Litylenchus crenatae ssp. mccannii", "Litylenchus crenatae mccannii", "Litylenchus", "crenatae mccannii", FALSE,
  "Locusta migratoria manilemsis", "Locusta migratoria manilensis", "Locusta", "migratoria manilensis", FALSE,
  "Locusta migratoria migratoriodes", "Locusta migratoria migratorioides", "Locusta", "migratoria migratorioides", FALSE,
  "Locusta migratoria subsp. migratorioides", "Locusta migratoria migratorioides", "Locusta", "migratoria migratorioides", FALSE,
  "Lycosa t‑insignata", "Trochosa insignis", "Trochosa", "insignis", FALSE,
  "Marietta leopardina (Aphelinidae)", "Marietta leopardina", "Marietta", "leopardina", FALSE,
  "Megacopda Megacopta cribrarla", "Megacopta cribraria", "Megacopta", "cribraria", FALSE,
  "Meloidogyne sp. (isolate 93-13a)", "Meloidogyne sp.", "Meloidogyne", "", FALSE,
  "Metopolophium festucae cerealiurn", "Metopolophium festucae cerealium", "Metopolophium", "festucae cerealium", FALSE,
  "Myzus persicae subsp. nicotianae", "Myzus persicae nicotianae", "Myzus", "persicae nicotianae", FALSE,
  "Myzus persicae var. nicotianae", "Myzus persicae nicotianae", "Myzus", "persicae nicotianae", FALSE,
  "Nasonovia ribis-nigri", "Nasonovia ribisnigri", "Nasonovia", "ribisnigri", FALSE,
  "Odontotermes vaishno-bose", "Odontotermes vaishno", "Odontotermes", "vaishno", FALSE,
  "Oligosita collina group", "Oligosita collina", "Oligosita", "collina", FALSE,
  "Ophraella commun a", "Ophraella communa", "Ophraella", "communa", FALSE,
  "Opius concolor var. siculus", "Opius concolor siculus", "Opius", "concolor siculus", FALSE,
  "Otiorhynchus sulcatus (black vine weevil)", "Otiorhynchus sulcatus", "Otiorhynchus", "sulcatus", FALSE,
  "Pandemis pyrusana (larvae)", "Pandemis pyrusana", "Pandemis", "pyrusana", FALSE,
  "Pandemis spp. (pandemis leafroller)", "Pandemis spp.", "Pandemis", "", FALSE,
  "Photorhabdus luminescens subsp. kayaii", "Photorhabdus luminescens kayaii", "Photorhabdus", "luminescens kayaii", FALSE,
  "Pineus (P.) wallichianae", "Pineus wallichianae", "Pineus", "wallichianae", FALSE,
  "Plas-tanoxus westwoodi", "Plastanoxus westwoodi", "Plastanoxus", "westwoodi", FALSE,
  "Pochonia chlamydosporia var. catenulata", "Pochonia chlamydosporia catenulata", "Pochonia", "chlamydosporia catenulata", FALSE,
  "Polyphagotarsonemus latus (broad mite)", "Polyphagotarsonemus latus", "Polyphagotarsonemus", "latus", FALSE,
  "Procambarus fallax f. virginalis", "Procambarus fallax virginalis", "Procambarus", "fallax virginalis", FALSE,
  "Prochiloneurus aegyptiacus (Encyrtidae)", "Prochiloneurus aegyptiacus", "Prochiloneurus", "aegyptiacus", FALSE,
  "Prochiloneurus insolitus (Encyrtidae)", "Prochiloneurus insolitus", "Prochiloneurus", "insolitus", FALSE,
  "Pseudospidimerus circumflexa var. testaceus", "Pseudospidimerus circumflexa testaceus", "Pseudospidimerus", "circumflexa testaceus", FALSE,
  "Rhopalosiphum padi (pecan aphids)", "Rhopalosiphum padi", "Rhopalosiphum", "padi", FALSE,
  "Rhyacionia buoliana var. thurificana", "Rhyacionia buoliana thurificana", "Rhyacionia", "buoliana thurificana", FALSE,
  "Rhyzopertha dominica (eggs)", "Rhyzopertha dominica", "Rhyzopertha", "dominica", FALSE,
  "Saissetia oleae (biotype Q)", "Saissetia oleae", "Saissetia", "oleae", FALSE,
  "Schistocerca piceifrons ssp. piceifrons", "Schistocerca piceifrons piceifrons", "Schistocerca", "piceifrons piceifrons", FALSE,
  "Schistocerca spp. (plague locusts)", "Schistocerca spp.", "Schistocerca", "", FALSE,
  "Sitophilus Sitophila oryzae", "Sitophilus oryzae", "Sitophilus", "oryzae", FALSE,
  "Spilonota ocellana (eyespot bud moth)", "Spilonota ocellana", "Spilonota", "ocellana", FALSE,
  "Spodoptera litura (neonate)", "Spodoptera litura", "Spodoptera", "litura", FALSE,
  "Spodoptera litura (tobacco cutworm)", "Spodoptera litura", "Spodoptera", "litura", FALSE,
  "Subcoccinella vigintiquattuor-punctata", "Subcoccinella vigintiquatuorpunctata", "Subcoccinella", "vigintiquatuorpunctata", FALSE,
  "Tetranychus urticae (Coccoidea spp.)", "Tetranychus urticae", "Tetranychus", "urticae", FALSE,
  "Tetranychus urticae (combined with Eotetranychus sp.)", "Tetranychus urticae", "Tetranychus", "urticae", FALSE,
  "Tetrastichus sp. (second species)", "Tetrastichus sp.", "Tetrastichus", "", FALSE,
  "Therioaphis trifolii f. maculata", "Therioaphis trifolii maculata", "Therioaphis", "trifolii maculata", FALSE,
  "Thyanta custator accera", "Thyanta custator accerra", "Thyanta", "custator accerra", FALSE,
  "Thyanta custator acerra", "Thyanta custator accerra", "Thyanta", "custator accerra", FALSE,
  "Trathala flavo-orbitalis", "Trathala flavoorbitalis", "Trathala", "flavoorbitalis", FALSE,
  "Trichogramma ostr iniae", "Trichogramma ostriniae", "Trichogramma", "ostriniae", FALSE,
  "Trichogrammatoidea bactrae-bactrae", "Trichogrammatoidea bactrae bactrae", "Trichogrammatoidea", "bactrae bactrae", FALSE,
  "Trichosurus vulpecula (common brushtail possum)", "Trichosurus vulpecula", "Trichosurus", "vulpecula", FALSE,
  "Trichosurus Trichosaurus vulpecula", "Trichosurus vulpecula", "Trichosurus", "vulpecula", FALSE,
  "Trioza erytreae (gall‑forming species related to Trioza montanetana)", "Trioza erytreae", "Trioza", "erytreae", FALSE,
  "Trioza sp. (gall‑forming species related to Trioza montanetana)", "Trioza sp.", "Trioza", "", FALSE,
  "Tuberocephalus momonis (non-leaf-curling)", "Tuberocephalus momonis", "Tuberocephalus", "momonis", FALSE,
  "Woolly apple aphid", "Eriosoma lanigerum", "Eriosoma", "lanigerum", FALSE,
  "Zygina zeal‑andica", "Zygina zealandica", "Zygina", "zealandica", FALSE,
  "Ñetonia aureate", "Cetonia aurata", "Cetonia", "aurata", FALSE,
  "Cleothera onerata", "Hyperaspis onerata", "Hyperaspis", "onerata", TRUE,
  "Agrotis ípsilon", "Agrotis ipsilon", "Agrotis", "ipsilon", FALSE
)






higher_taxonomy_correction <- function(df){
  df$Phylum[df$binomial_corrected == "Adelina sp."] <- "Apicomplexa"
  df$Class[df$binomial_corrected == "Adelina sp."] <- "Conoidasida"
  df$Order[df$binomial_corrected == "Adelina sp."] <- "Eucoccidiorida"
  df$Family[df$binomial_corrected == "Adelina sp."] <- "Adeleidae"
  
  df$Phylum[df$binomial_corrected == "Adelina castana"] <- "Apicomplexa"
  df$Class[df$binomial_corrected == "Adelina castana"] <- "Conoidasida"
  df$Order[df$binomial_corrected == "Adelina castana"] <- "Eucoccidiorida"
  df$Family[df$binomial_corrected == "Adelina castana"] <- "Adeleidae"
  
  df$Phylum[df$binomial_corrected == "Alternosema bostrichidis"] <- "Protozoa"
  df$Class[df$binomial_corrected == "Alternosema bostrichidis"] <- "Microsporidia"
  df$Order[df$binomial_corrected == "Alternosema bostrichidis"] <- "Microsporea"
  df$Family[df$binomial_corrected == "Alternosema bostrichidis"] <- "Alternosema"
  
  df$Phylum[df$binomial_corrected == "Ambrosiodmus obliquus"] <- "Arthropoda"
  df$Class[df$binomial_corrected == "Ambrosiodmus obliquus"] <- "Insecta"
  df$Order[df$binomial_corrected == "Ambrosiodmus obliquus"] <- "Coleoptera"
  df$Family[df$binomial_corrected == "Ambrosiodmus obliquus"] <- "Curculionidae"
  
  df$Phylum[df$binomial_corrected == "Analcellicampa danfengensis"] <- "Arthropoda"
  df$Class[df$binomial_corrected == "Analcellicampa danfengensis"] <- "Insecta"
  df$Order[df$binomial_corrected == "Analcellicampa danfengensis"] <- "Hymenoptera"
  df$Family[df$binomial_corrected == "Analcellicampa danfengensis"] <- "Tenthredinidae"
  
  df$Family[df$binomial_corrected == "Aphasmatylenchus variabilis"] <- "Hoplolaimidae"
  
  df$Family[df$binomial_corrected == "Amrasca biguttula"] <- "Cicadellidae"
  
  df$Phylum[df$binomial_corrected == "Aulophorus furcatus"] <- "Annelida"
  df$Class[df$binomial_corrected == "Aulophorus furcatus"] <- "Clitellata"
  df$Order[df$binomial_corrected == "Aulophorus furcatus"] <- "Tubificida"
  df$Family[df$binomial_corrected == "Aulophorus furcatus"] <- "Naididae"
  
  df$Phylum[df$binomial_corrected == "Beddingia siricidicola"] <- "Nematoda"
  df$Class[df$binomial_corrected == "Beddingia siricidicola"] <- "Chromadorea"
  df$Order[df$binomial_corrected == "Beddingia siricidicola"] <- "Rhabditida"
  df$Family[df$binomial_corrected == "Beddingia siricidicola"] <- "Neotylenchidae"
  
  df$Phylum[df$binomial_corrected == "Bonnetia comta"] <- "Arthropoda"
  df$Class[df$binomial_corrected == "Bonnetia comta"] <- "Insecta"
  df$Order[df$binomial_corrected == "Bonnetia comta"] <- "Diptera"
  df$Family[df$binomial_corrected == "Bonnetia comta"] <- "Tachinidae"
  
  
  df$Phylum[df$binomial_corrected == "Carpocapsa pomonella" & df$Phylum=="Ascomycota"] <- "Cossaviricota"
  df$Class[df$binomial_corrected == "Carpocapsa pomonella" & df$Phylum=="Ascomycota"] <- "Naldaviricetes"
  df$Order[df$binomial_corrected == "Carpocapsa pomonella" & df$Phylum=="Ascomycota"] <- "Lefavirales"
  df$Family[df$binomial_corrected == "Carpocapsa pomonella" & df$Phylum=="Ascomycota"] <- "Baculoviridae"
  df$Genus[df$binomial_corrected == "Carpocapsa pomonella" & df$Phylum=="Ascomycota"] <- "Betabaculovirus"
  df$Species[df$binomial_corrected == "Carpocapsa pomonella" & df$Phylum=="Ascomycota"] <- "cypomonellae"
  # common name: Carpocapsa pomonella granulovirus (CpGV)
  
  df$Phylum[df$binomial_corrected == "Cycloneda sanguinea"] <- "Arthropoda"
  df$Class[df$binomial_corrected == "Cycloneda sanguinea"] <- "Insecta"
  df$Order[df$binomial_corrected == "Cycloneda sanguinea"] <- "Coleoptera"
  df$Family[df$binomial_corrected == "Cycloneda sanguinea"] <- "Coccinellidae"
  
  
  df$Phylum[df$binomial_corrected == "Condenascus spp."] <- "Ascomycota"
  df$Class[df$binomial_corrected == "Condenascus spp."] <- "Sordariomycetes"
  df$Order[df$binomial_corrected == "Condenascus spp."] <- "Sordariales"
  df$Family[df$binomial_corrected == "Condenascus spp."] <- "Chaetomiaceae"
  
  df$Phylum[df$binomial_corrected == "Cyrtorhinus lividipennis"] <- "Arthropoda"
  df$Class[df$binomial_corrected == "Cyrtorhinus lividipennis"] <- "Insecta"
  df$Order[df$binomial_corrected == "Cyrtorhinus lividipennis"] <- "Hemiptera"
  df$Family[df$binomial_corrected == "Cyrtorhinus lividipennis"] <- "Miridae"
  
  
  df$Phylum[df$binomial_corrected == "Diaprepes abbreviatus"] <- "Arthropoda"
  df$Class[df$binomial_corrected == "Diaprepes abbreviatus"] <- "Insecta"
  df$Order[df$binomial_corrected == "Diaprepes abbreviatus"] <- "Coleoptera"
  df$Family[df$binomial_corrected == "Diaprepes abbreviatus"] <- "Curculionidae"
  
  df$Family[df$binomial_corrected == "Ditylenchus africanus"] <- "Anguinidae"
  
  df$Family[df$binomial_corrected == "Exelastis atomosa"] <- "Pterophoridae"
  
  df$Family[df$binomial_corrected == "Paliga machoeralis"] <- "Crambidae"
  
  df$Family[df$binomial_corrected == "Empoasca kraemeri"] <- "Cicadellidae"
  
  df$Family[df$binomial_corrected == "Ceutorhynchus assimilis"] <- "Curculionidae"
  
  df$Family[df$binomial_corrected == "Hyblaea puera"] <- "Hyblaeidae"
  
  df$Family[df$binomial_corrected == "Pachyneuron muscarum"] <- "Pteromalidae"
  
  df$Family[df$binomial_corrected == "Strobilomyia anthracina"] <- "Anthomyiidae"
  
  df$Family[df$binomial_corrected == "Acanthoscelides obvelatus"] <- "Chrysomelidae"
  
  df$Family[df$Genus == "Odontosema"] <- "Noctuidae"
  
  
  df$Order[df$binomial_corrected == "Retinia resinella"] <- "Lepidoptera"
  df$Family[df$binomial_corrected == "Retinia resinella"] <- "Tortricidae"
  
  df$Order[df$binomial_corrected == "Phytomyza heraclei"] <- "Diptera"
  df$Family[df$binomial_corrected == "Phytomyza heraclei"] <- "Agromyzidae"
  
  
  df$Phylum[df$Genus == "Fergusobia"] <- "Nematoda"
  df$Class[df$Genus == "Fergusobia"] <- "Chromadorea"
  df$Order[df$Genus == "Fergusobia"] <- "Rhabditida"
  df$Family[df$Genus == "Fergusobia"] <- "Neotylenchidae"
  
  df$Phylum[df$binomial_corrected == "Fonsecaia polymorpha"] <- "Myzozoa"
  df$Class[df$binomial_corrected == "Fonsecaia polymorpha"] <- "Conoidasida"
  df$Order[df$binomial_corrected == "Fonsecaia polymorpha"] <- "Eugregarinorida"
  df$Family[df$binomial_corrected == "Fonsecaia polymorpha"] <- "Lecudinidae"
  
  df$Phylum[df$binomial_corrected == "Stenophora nematoides"] <- "Myzozoa"
  df$Class[df$binomial_corrected == "Stenophora nematoides"] <- "Conoidasida"
  df$Order[df$binomial_corrected == "Stenophora nematoides"] <- "Eugregarinorida"
  df$Family[df$binomial_corrected == "Stenophora nematoides"] <- "Stenophoridae"
  
  df$Phylum[df$binomial_corrected == "Stenophora robusta"] <- "Myzozoa"
  df$Class[df$binomial_corrected == "Stenophora robusta"] <- "Conoidasida"
  df$Order[df$binomial_corrected == "Stenophora robusta"] <- "Eugregarinorida"
  df$Family[df$binomial_corrected == "Stenophora nematoides"] <- "Stenophoridae"
  
  df$Phylum[df$binomial_corrected == "Homalodisca vitripennis"] <- "Arthropoda"
  df$Class[df$binomial_corrected == "Homalodisca vitripennis"] <- "Insecta"
  df$Order[df$binomial_corrected == "Homalodisca vitripennis"] <- "Hemiptera"
  df$Family[df$binomial_corrected == "Homalodisca vitripennis"] <- "Cicadellidae"
  
  df$Order[df$binomial_corrected == "Melanagromyza obtusa"] <- "Diptera"
  df$Family[df$binomial_corrected == "Melanagromyza obtusa"] <- "Agromyzidae"
  
  df$Order[df$binomial_corrected == "Neomusotima conspurcatalis"] <- "Lepidoptera"
  df$Family[df$binomial_corrected == "Neomusotima conspurcatalis"] <- "Pyralidae"
  
  df$Order[df$binomial_corrected == "Probergrothius varicornis"] <- "Hemiptera"
  df$Family[df$binomial_corrected == "Probergrothius varicornis"] <- "Pyrrhocoridae"
  
  df$Phylum[df$binomial_corrected == "Rachis punctatus"] <- "Mollusca"
  df$Class[df$binomial_corrected == "Rachis punctatus"] <- "Gastropoda"
  df$Order[df$binomial_corrected == "Rachis punctatus"] <- "Stylommatophora"
  df$Family[df$binomial_corrected == "Rachis punctatus"] <- "Cerastidae"
  df$Genus[df$binomial_corrected == "Rachis punctatus"] <- "Rachis"
  df$Species[df$binomial_corrected == "Rachis punctatus"] <- "punctatus"
  
  df$Phylum[df$binomial_corrected == "Spanolepis selloanae"] <- "Arthropoda"
  df$Class[df$binomial_corrected == "Spanolepis selloanae"] <- "Insecta"
  df$Order[df$binomial_corrected == "Spanolepis selloanae"] <- "Diptera"
  df$Family[df$binomial_corrected == "Spanolepis selloanae"] <- "Cecidomyiidae"
  df$Genus[df$binomial_corrected == "Spanolepis selloanae"] <- "Spanolepis"
  df$Species[df$binomial_corrected == "Spanolepis selloanae"] <- "selloanae"
  
  
  df$Phylum[df$binomial_corrected == "Coleosoma octomaculatum"] <- "Arthropoda"
  df$Class[df$binomial_corrected == "Coleosoma octomaculatum"] <- "Arachnida"
  df$Order[df$binomial_corrected == "Coleosoma octomaculatum"] <- "Araneae"
  df$Family[df$binomial_corrected == "Coleosoma octomaculatum"] <- "Theridiidae"
  
  df$Phylum[df$binomial_corrected == "Pseudodorus	clavatus"] <- "Arthropoda"
  df$Class[df$binomial_corrected == "Pseudodorus	clavatus"] <- "Insecta"
  df$Order[df$binomial_corrected == "Pseudodorus	clavatus"] <- "Diptera"
  df$Family[df$binomial_corrected == "Pseudodorus	clavatus"] <- "Syrphidae"
  
  df$Phylum[df$binomial_corrected == "Pseudodorus clavatus"] <- "Arthropoda"
  df$Class[df$binomial_corrected == "Pseudodorus clavatus"] <- "Insecta"
  df$Order[df$binomial_corrected == "Pseudodorus clavatus"] <- "Diptera"
  df$Family[df$binomial_corrected == "Pseudodorus clavatus"] <- "Syrphidae"
  
  df$Phylum[df$binomial_corrected == "Holobus sp."] <- "Arthropoda"
  df$Class[df$binomial_corrected == "Holobus sp."] <- "Insecta"
  df$Order[df$binomial_corrected == "Holobus sp."] <- "Coleoptera"
  df$Family[df$binomial_corrected == "Holobus sp."] <- "Staphylinidae"
  
  df$Phylum[df$binomial_corrected == "Agrotis ipsilon"] <- "Arthropoda"
  df$Class[df$binomial_corrected == "Agrotis ipsilon"] <- "Insecta"
  df$Order[df$binomial_corrected == "Agrotis ipsilon"] <- "Lepidoptera"
  df$Family[df$binomial_corrected == "Agrotis ipsilon"] <- "Noctuidae"
  
  
  df$Phylum[df$Genus == "Gregarina"] <- "Myzozoa"
  df$Class[df$Genus == "Gregarina"] <- "Conoidasida"
  df$Order[df$Genus == "Gregarina"] <- "Eugregarinorida"
  df$Family[df$Genus == "Gregarina"] <- "Gregarinidae"
  
  df$Phylum[df$Genus == "Haemoproteus"] <- "Myzozoa"
  df$Class[df$Genus == "Haemoproteus"] <- "Aconoidasida"
  df$Order[df$Genus == "Haemoproteus"] <- "Haemospororida"
  df$Family[df$Genus == "Haemoproteus"] <- "Plasmodiidae"
  
  df$Phylum[df$Genus == "Hanseniella"] <- "Arthropoda"
  df$Class[df$Genus == "Hanseniella"] <- "Symphyla"
  df$Order[df$Genus == "Hanseniella"] <- "Cephalostigmata"
  df$Family[df$Genus == "Hanseniella"] <- "Scutigerellidae"
  
  df$Phylum[df$Genus == "Helicotylenchus"] <- "Nematoda"
  df$Class[df$Genus == "Helicotylenchus"] <- "Chromadorea"
  df$Order[df$Genus == "Helicotylenchus"] <- "Rhabditida"
  df$Family[df$Genus == "Helicotylenchus"] <- "Hoplolaimidae"
  
  
  df$Phylum[df$Genus == "Leidyana"] <- "Myzozoa"
  df$Class[df$Genus == "Leidyana"] <- "Eugregarinida"
  df$Family[df$Genus == "Leidyana"] <- "Leidyanidae"
  
  df$Phylum[df$Genus == "Mattesia"] <- "Myzozoa"
  df$Class[df$Genus == "Mattesia"] <- "Neogregarinida"
  df$Family[df$Genus == "Mattesia"] <- "Lipotrophidae"
  
  df$Phylum[df$Genus == "Mechoris"] <- "Arthropoda"
  df$Class[df$Genus == "Mechoris"] <- "Insecta"
  df$Order[df$Genus == "Mechoris"] <- "Coleoptera"
  df$Family[df$Genus == "Mechoris"] <- "Attelabidae"
  
  df$Phylum[df$Genus == "Mesosemia"] <- "Arthropoda"
  df$Class[df$Genus == "Mesosemia"] <- "Insecta"
  df$Order[df$Genus == "Mesosemia"] <- "Lepidoptera"
  df$Family[df$Genus == "Mesosemia"] <- "Riodinidae"
  
  df$Phylum[df$Genus == "Hohenbuehelia"] <- "Basidiomycota"
  df$Class[df$Genus == "Hohenbuehelia"] <- "Agaricomycetes"
  df$Order[df$Genus == "Hohenbuehelia"] <- "Agaricales"
  df$Family[df$Genus == "Hohenbuehelia"] <- "Pleurotaceae"
  
  df$Phylum[df$Genus == "Neoacrosternum"] <- "Arthropoda"
  df$Class[df$Genus == "Neoacrosternum"] <- "Insecta"
  df$Order[df$Genus == "Neoacrosternum"] <- "Hemiptera"
  df$Family[df$Genus == "Neoacrosternum"] <- "Pentatomidae"
  
  df$Phylum[df$Genus == "Paratylenchus"] <- "Nematoda"
  df$Class[df$Genus == "Paratylenchus"] <- "Chromadorea"
  df$Order[df$Genus == "Paratylenchus"] <- "Rhabditida"
  df$Family[df$Genus == "Paratylenchus"] <- "Tylenchulidae"
  
  df$Phylum[df$Genus == "Smicroplectrus"] <- "Arthropoda"
  df$Class[df$Genus == "Smicroplectrus"] <- "Insecta"
  df$Order[df$Genus == "Smicroplectrus"] <- "Hymenoptera"
  df$Family[df$Genus == "Smicroplectrus"] <- "Ichneumonidae"
  
  df$Phylum[df$Genus == "Scirtothrips"] <- "Arthropoda"
  df$Class[df$Genus == "Scirtothrips"] <- "Insecta"
  df$Order[df$Genus == "Scirtothrips"] <- "Thysanoptera"
  df$Family[df$Genus == "Scirtothrips"] <- "Thripidae"
  
  df$Phylum[df$Genus == "Spiroplasma"] <- "Firmicutes"
  df$Class[df$Genus == "Spiroplasma"] <- "Bacilli"
  df$Order[df$Genus == "Spiroplasma"] <- "Mycoplasmatales"
  df$Family[df$Genus == "Spiroplasma"] <- "Mycoplasmataceae"
  df$Genus[df$Genus == "Spiroplasma"] <- "Spiroplasma"
  
  df$Phylum[df$Genus == "Stenophora"] <- "Myzozoa"
  df$Class[df$Genus == "Stenophora"] <- NA
  df$Order[df$Genus == "Stenophora"] <- "Eugregarinida"
  df$Family[df$Genus == "Stenophora"] <- "Stenophoridae"
  df$Genus[df$Genus == "Stenophora"] <- "Stenophora"
  
  df$Phylum[df$Genus == "Stictospora"] <- "Myzozoa"
  df$Class[df$Genus == "Stictospora"] <- "Conoidasida"
  df$Order[df$Genus == "Stictospora"] <- "Eugregarinorida"
  df$Family[df$Genus == "Stictospora"] <- "Actinocephalidae"
  df$Genus[df$Genus == "Stictospora"] <- "Stictospora"
  
  df$Genus[df$Genus == "Streptomyces"] <- "Streptomyces"
  
  df$Genus[df$Genus == "Strongyluris"] <- "Strongyluris"
  
  df$Genus[df$Genus == "Telotylenchus"] <- "Telotylenchus"

  return(df)
}

