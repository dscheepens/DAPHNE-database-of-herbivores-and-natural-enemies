library(stringr)
library(tidyr)
library(purrr)
library(tibble)
library(dplyr)
library(tidyverse)
library(fuzzyjoin)
library(readxl)


eppoDir <- "EPPO_crop_pests/"

# load the finished interactions dataframe 
interactions_df <- readRDS("../DAPHNE_database.rds")

interactions_df <- interactions_df %>%
  mutate(
    Type = as.factor(Type),
    Feeding.Mode = as.factor(Feeding.Mode),
    Pest = as.factor(Pest),
    Pest.Importance = as.factor(Pest.Importance),
    Herbivore.IsBCA = as.factor(Herbivore.IsBCA),
    Pest.Importance = as.factor(Pest.Importance),
    Important.Enemy = as.factor(Important.Enemy),
    Biocontrol = as.factor(Biocontrol)
  )


herbivore_edges <- interactions_df %>% 
  filter(Type=='herbivore', 
         str_count(Subject, "\\w+") > 1 # filter out binomials that are genus-only
  ) %>% 
  mutate(Subject = word(Subject, 1, 2)) # keep only first two binomials (i.e. remove subspecies information)

herbivore_summary <- herbivore_edges %>%
  # Now continue with grouping/summarising
  group_by(Subject, Object) %>% 
  dplyr::summarise(
    nEID     = n_distinct(EID),
    nPest    = n_distinct(EID[Pest == TRUE & !is.na(Pest)]),
    nMajor   = n_distinct(EID[Pest.Importance == "major" & !is.na(Pest.Importance)]),
    Synonyms = list(unique(unlist(Subject.Synonyms))),
    .groups = "drop"
  ) %>% 
  mutate(
    fPest = nPest/nEID,
    fMajor = nMajor/nEID
  )

enemy_edges <- interactions_df %>% 
  filter(Type == 'natural enemy', 
         str_count(Subject, "\\w+") > 1 # Filters out genus-only entries
  ) %>% 
  mutate(
    # truncates to 2 words if 3+ words
    Subject = word(Subject, 1, 2),
    # truncates to 2 words if 3+ words
    Object = if_else(str_count(Object, "\\w+") > 2, word(Object, 1, 2), Object)
  )

enemy_summary <- enemy_edges %>%
  group_by(Subject, Object) %>% 
  dplyr::summarise(
    nEID             = n_distinct(EID),
    nImportantEnemy  = n_distinct(EID[Important.Enemy == TRUE & !is.na(Important.Enemy)]),
    nBiocontrol      = n_distinct(EID[Biocontrol == TRUE & !is.na(Biocontrol)]),
    Synonyms         = list(unique(unlist(Subject.Synonyms))),
    .groups = "drop"
  ) 







################################################################################
#               2. Oliver et al. pest control classifications                  # 
################################################################################

OliverClassifications <- read_excel("../../../0_data/Data_associated_with_paper_Declining_resilience_of_ecosystem_functions_under_biodiversity_loss/41467_2015_BFncomms10122_MOESM1630_ESM.xlsx", skip=1)

pc_list <- OliverClassifications %>% filter(`Pest control` %in% c("1")) %>% pull(`Species name`)
pc_list[lapply(pc_list, str_count,"\\w+")!=2] # "Aelurillus v-insignitus"  "Pardosa saltans/lugubris" "Zygiella x-notata" 
pc_list[pc_list=="Pardosa saltans/lugubris"] <- "Pardosa lugubris"

pc_summary <- enemy_summary %>% 
  group_by(Subject) %>% 
  summarise(nEID = sum(nEID),
            nImportantEnemy = sum(nImportantEnemy),
            nBiocontrol = sum(nBiocontrol),
            Synonyms = list(unique(unlist(Synonyms))),
            .groups = "drop"
            ) %>%
  filter(
    nEID >= 1, 
    # 1. Check if the main Subject matches
    Subject %in% pc_list | 
      # 2. Safely look inside the list column row-by-row
      map_lgl(Synonyms, ~ any(.x %in% pc_list))
  )
  

# 1. Biocontrol 
cat(nrow(pc_summary[pc_summary$nBiocontrol>0,]), "/", nrow(pc_summary), " = ", round(100*nrow(pc_summary[pc_summary$nBiocontrol>0,])/nrow(pc_summary),1), "%")
# nEID >= 1: 65 / 160  =  40.6 %
# nEID >= 3: 41 / 77  =  53.2 %
# nEID >= 5: 35 / 51  =  68.6 %
# nEID >= 10: 21 / 25  =  84 %
# nEID >= 20: 12 / 12  =  100 %

# cat(nrow(non_pc_summary[non_pc_summary$nBiocontrol==0,]), "/", nrow(non_pc_summary), " = ", round(100*nrow(non_pc_summary[non_pc_summary$nBiocontrol==0,])/nrow(non_pc_summary),1), "%")
# 2 / 2  =  100 %


# no_biocontrol <- pc_summary[pc_summary$nBiocontrol==0,]
# biocontrol <- pc_summary[pc_summary$nBiocontrol>0,]

# mean(no_biocontrol$nEID) # 2.810526
# mean(biocontrol$nEID) # 22.27692


# 2. Important Enemy
cat(nrow(pc_summary[pc_summary$nImportantEnemy>0,]), "/", nrow(pc_summary), " = ", round(100*nrow(pc_summary[pc_summary$nImportantEnemy>0,])/nrow(pc_summary),1), "%")
# nEID >= 1: 140 / 160  =  87.5 %
# nEID >= 3: 72 / 77  =  93.5 %
# nEID >= 5: 50 / 51  =  98 %
# nEID >= 10: 25 / 25  =  100 %
# nEID >= 20: 12 / 12  =  100 %

# cat(nrow(non_pc_summary[non_pc_summary$nImportantEnemy==0,]), "/", nrow(non_pc_summary), " = ", round(100*nrow(non_pc_summary[non_pc_summary$nImportantEnemy==0,])/nrow(non_pc_summary),1), "%")
# 1 / 2  =  50 %

not_important <- pc_summary[pc_summary$nImportantEnemy==0,]
important <- pc_summary[pc_summary$nImportantEnemy>0,]

mean(not_important$nEID) # 1.95
median(not_important$nEID) # 1
sum(not_important$nEID==1) # 13 

mean(important$nEID) # 11.97143
median(important$nEID) # 3 








################################################################################
#                     3. Martin et al. pest classifications                    # 
################################################################################

MartinClassifications <- read_excel("../../../0_data/Data_associated_with_paper_The_interplay_of_landscape_composition_and_configuration/Martin+et+al_2019_traits+database_300319.xlsx", skip=3)

pest_list <- MartinClassifications %>% filter(Functional_group %in% c("pest herbivore","larval pest herbivore, adult pollinator (adults)", "larval pest herbivore, adult pollinator")) %>% filter(str_count(SpeciesID, "\\w+") > 1) %>% mutate(SpeciesID = word(SpeciesID, 1, 2)) %>% pull(SpeciesID)
nonpest_list <- MartinClassifications %>% filter(Functional_group %in% c("non-pest herbivore","larval non-pest herbivore, adult pollinator")) %>% filter(str_count(SpeciesID, "\\w+") > 1) %>% mutate(SpeciesID = word(SpeciesID, 1, 2)) %>% pull(SpeciesID)
predator_list <- MartinClassifications %>% filter(Functional_group %in% c("predator", "aphid-tender, predator", "larval predator, adult pollinator")) %>% filter(str_count(SpeciesID, "\\w+") > 1) %>% mutate(SpeciesID = word(SpeciesID, 1, 2)) %>% pull(SpeciesID)
parasitoid_list <- MartinClassifications %>% filter(Functional_group %in% c("parasitoid","parasitoid of bees","larval parasitoid, adult pollinator")) %>% filter(str_count(SpeciesID, "\\w+") > 1) %>% mutate(SpeciesID = word(SpeciesID, 1, 2)) %>% pull(SpeciesID)

################################################################################
#                                   herbivores                                 #
################################################################################

herbivore_types <- interactions_df %>% 
  filter(str_count(Subject, "\\w+") > 1 # filter out binomials that are genus-only
  ) %>% 
  mutate(Subject = word(Subject, 1, 2)) %>% # keep only first two binomials (i.e. remove subspecies information)
  group_by(Subject, Type) %>%
  summarise(
    nEID.Enemy = n_distinct(EID[Type=='natural enemy' & !is.na(Type)]),
    nEID.Herbivore = n_distinct(EID[Type=='herbivore' & !is.na(Type)]),
    nPest = n_distinct(EID[Pest == TRUE & !is.na(Pest)]),
    nMajor = n_distinct(EID[Pest.Importance=='major' & !is.na(Pest.Importance)]),
    Subject.Synonyms = list(unique(unlist(Subject.Synonyms))),
    .groups = "drop"
  ) %>% 
  ungroup() %>%
  group_by(Subject) %>%
  summarise(
    Types = paste(sort(Type), collapse = " + "),
    nEID = sum(nEID.Enemy + nEID.Herbivore),
    Subject.Synonyms = list(unique(unlist(Subject.Synonyms))),
    .groups = "drop"
  ) %>%
  filter(
    nEID >= 20,
    # 1. Check if the main Subject matches
    Subject %in% c(pest_list,nonpest_list) | 
      # 2. Safely look inside the list column row-by-row
      map_lgl(Subject.Synonyms, ~ any(.x %in% c(pest_list,nonpest_list)))
  )

nrow(herbivore_types)

herbivore_types %>%
  # 3. Tally how many unique species share each exact combination
  count(Types, name = "Unique_Species_Count") %>%
  arrange(desc(Unique_Species_Count))

# nEID >= 1: 126/130 = 96.9
# nEID >= 3: 79/79 = 100
# nEID >= 5: 55/55 = 100
# nEID >= 10: 36/36 = 100
# nEID >= 20: 27/27 = 100

################################################################################
#                                herbivore pests                               #
################################################################################

herbivore_pests <- interactions_df %>% 
  filter(str_count(Subject, "\\w+") > 1 # filter out binomials that are genus-only
  ) %>% 
  mutate(Subject = word(Subject, 1, 2)) %>% # keep only first two binomials (i.e. remove subspecies information)
  group_by(Subject, Type) %>%
  summarise(
    nEID = n_distinct(EID),
    nPest = n_distinct(EID[Pest == TRUE & !is.na(Pest)]),
    nMajor = n_distinct(EID[Pest.Importance=='major' & !is.na(Pest.Importance)]),
    Subject.Synonyms = list(unique(unlist(Subject.Synonyms))),
    .groups = "drop"
  ) %>% 
  ungroup() %>%
  group_by(Subject) %>%
  summarise(
    Types = paste(sort(Type), collapse = " + "),
    nEID = sum(nEID),
    nPest = sum(nPest),
    nMajor = sum(nMajor),
    Subject.Synonyms = list(unique(unlist(Subject.Synonyms))),
    .groups = "drop"
  ) %>%
  filter(
    nEID >= 20,
    # 1. Check if the main Subject matches
    Subject %in% pest_list | 
      # 2. Safely look inside the list column row-by-row
      map_lgl(Subject.Synonyms, ~ any(.x %in% pest_list))
  )

nrow(herbivore_pests)
nrow(herbivore_pests[herbivore_pests$nMajor>0,])

# nEID >= 1: 22/22 = 100%
# nEID >= 3: 22/22 = 100%
# nEID >= 5: 19/19 = 100%
# nEID >= 10: 16/16 = 100%
# nEID >= 20: 14/14 = 100%

herbivore_pests <- interactions_df %>% 
  filter(str_count(Subject, "\\w+") > 1 # filter out binomials that are genus-only
  ) %>% 
  mutate(Subject = word(Subject, 1, 2)) %>% # keep only first two binomials (i.e. remove subspecies information)
  group_by(Subject, Subject.Synonyms, Type) %>%
  summarise(
    nEID.Enemy = n_distinct(EID[Type=='natural enemy' & !is.na(Type)]),
    nEID.Herbivore = n_distinct(EID[Type=='herbivore' & !is.na(Type)]),
    nPest = n_distinct(EID[Pest == TRUE & !is.na(Pest)]),
    nMajor = n_distinct(EID[Pest.Importance=='major' & !is.na(Pest.Importance)]),
    .groups = "drop"
  ) %>% 
  filter(
    nEID.Enemy + nEID.Herbivore >= 1,
    # 1. Check if the main Subject matches
    Subject %in% pest_list | 
      # 2. Safely look inside the list column row-by-row
      map_lgl(Subject.Synonyms, ~ any(.x %in% pest_list))
  )

table(herbivore_pests$Type)

roles <- herbivore_pests %>%
  # 1. Keep only unique Species (Subject) and Type combinations
  distinct(Subject, Type) %>%
  # 2. Group by species and combine all their Types into an alphabetical string
  group_by(Subject) %>%
  summarise(
    Types = paste(sort(Type), collapse = " + "),
    .groups = "drop"
  ) 

roles %>%
  # 3. Tally how many unique species share each exact combination
  count(Types, name = "Unique_Species_Count") %>%
  arrange(desc(Unique_Species_Count))

# Types                     Unique_Species_Count
# herbivore                                   20
# herbivore + natural enemy                    2

eid_counts <- herbivore_pests %>% 
  group_by(Subject) %>%
  summarise(
    nEID.Enemy = n_distinct(EID[Type=='natural enemy' & !is.na(Type)]),
    nEID.Herbivore = n_distinct(EID[Type=='herbivore' & !is.na(Type)]),
    nPest = n_distinct(EID[Pest == TRUE & !is.na(Pest)]),
    nMajor = n_distinct(EID[Pest.Importance=='major' & !is.na(Pest.Importance)]),
    .groups = "drop"
  )

nrow(eid_counts[eid_counts$nPest>0,]) # 22 
nrow(eid_counts[eid_counts$nPest>=3,]) # 20
nrow(eid_counts[eid_counts$nPest>=5,]) # 18 
nrow(eid_counts[eid_counts$nPest>=10,]) # 16 
nrow(eid_counts[eid_counts$nPest>=20,]) # 14 



# medians
median(eid_counts$nEID.Enemy)     # 0     mean = 0.1304348
median(eid_counts$nEID.Herbivore) # 43    mean = 109.5652
median(eid_counts$nPest)          # 41.5  mean = 94.73913
median(eid_counts$nMajor)         # 34    mean = 73.26087

# modes
as.numeric(names(table(eid_counts$nPest))[which.max(table(eid_counts$nPest))])                   # 1
as.numeric(names(table(eid_counts$nMajor))[which.max(table(eid_counts$nMajor))])                 # 1

# predators: 
# Lygus pratensis (abstract confirms it is omnivorous - zoophytophagous mirid bug that predates on Aphis gossypii and Helicoverpa armigera)
# Adelphocoris lineolatus (mirid plant bug that also feeds on Acyrthosiphon pisum, Empoasca fabae and Hypera postica)

eid_counts %>%
  filter(Subject %in% c("Lygus pratensis","Adelphocoris lineolatus")) %>%
  arrange(desc(nEID.Herbivore))

# Subject                   nEID.Enemy nEID.Herbivore nPest nMajor
# 1 Adelphocoris lineolatus          2             34    30     24
# 2 Lygus pratensis                  1             21    20     19


eid_counts %>% arrange(-desc(nPest))
eid_counts[eid_counts$nPest==0,]$Subject # character(0)

# accuracy: 
# 22 / 22 correct = 100% 

mean(eid_counts$nEID.Herbivore) # 114.2727
mean(eid_counts$nPest) # 98.77273

################################################################################
#                            herbivore non-pests                               #
################################################################################

herbivore_nonpests <- interactions_df %>% 
  filter(str_count(Subject, "\\w+") > 1 # filter out binomials that are genus-only
  ) %>% 
  mutate(Subject = word(Subject, 1, 2)) %>% # keep only first two binomials (i.e. remove subspecies information)
  group_by(Subject, Type) %>%
  summarise(
    nEID = n_distinct(EID),
    nPest = n_distinct(EID[Pest == TRUE & !is.na(Pest)]),
    nMajor = n_distinct(EID[Pest.Importance=='major' & !is.na(Pest.Importance)]),
    Subject.Synonyms = list(unique(unlist(Subject.Synonyms))),
    .groups = "drop"
  ) %>% 
  ungroup() %>%
  group_by(Subject) %>%
  summarise(
    Types = paste(sort(Type), collapse = " + "),
    nEID = sum(nEID),
    nPest = sum(nPest),
    nMajor = sum(nMajor),
    Subject.Synonyms = list(unique(unlist(Subject.Synonyms))),
    .groups = "drop"
  ) %>%
  filter(
    nEID >= 1,
    # 1. Check if the main Subject matches
    Subject %in% nonpest_list | 
      # 2. Safely look inside the list column row-by-row
      map_lgl(Subject.Synonyms, ~ any(.x %in% nonpest_list))
  )

nrow(herbivore_nonpests) # 108
nrow(herbivore_nonpests[herbivore_nonpests$nMajor==0,])
nrow(herbivore_nonpests[herbivore_nonpests$nMajor>0,])

# nEID >= 1: 51/108 = 47.2%


verified_pests <- c("Tribolium castaneum", # red flour beetle - major agricultural and stored-product pest 
                    "Apolygus lucorum", # small green plant bug - major agricultural pest 
                    "Hypera postica", # # alfalfa beetle - major pest of legume crops 
                    "Psylliodes chrysocephalus", # cabbage stem flea beetle - major agricultural pest 
                    "Ceutorhynchus obstrictus", # cabbage seedpod weevil - major agricultural pest 
                    "Hebata vitis", # vine leafhopper - significant vineyard pest 
                    "Phyllotreta cruciferae", # crucifer flea beetle - major agricultural pest 
                    "Sitona lineatus", # pea leaf beetle - major pest of legumes and pulses 
                    "Sitona obsoletus", # clover root weevil - major forage and pasture pest 
                    "Agriotes sputator", # wireworm - major pest 
                    "Philaenus spumarius", # vector of Xylella fastidiosa - major concern 
                    "Calliptamus italicus", # italian locust - major grassland pest 
                    "Trigonotylus caelestialium", # rice leaf bug - major rice/cereal pest 
                    "Cicadella viridis", # serious bamboo pest 
                    "Phyllotreta undulata", # chinese cabbage flea beetle - major cabbage pest 
                    "Dolycoris baccarum", # serious pest that affects soybean and other field crops 
                    "Psammotettix alienus", # striped grain leafhopper - major cereal pest and vector of Wheat Dwarf Virus 
                    "Brassicogethes viridescens", # pollen beetle - major pest of canola and other brassica crops 
                    "Phyllotreta vittula", # flea beetle - major agricultural pest 
                    "Zabrus tenebrioides", # cereal ground beetle - major grain pest
                    "Sitona hispidulus", # clover root curculio - major forage pest (e.g. alfalfa)
                    "Aiolopus thalassinus", # major pest of maize, alfalfa, millet, wheat, berseem, vegetables and grasses
                    "Aphthona euphorbiae", # major pest of flax 
                    "Apolygus spinolae", # green pale plant bug - major pest 
                    "Eurygaster testudinaria", # Sunn pest, "Eurygaster testudneria (Hemiptera: Scutelleridae), is one of the most economic pests that attack and cause serious damage to wheat and barley grains"
                    "Neophilaenus campestris", # serious threat to olives, almonds and grapevines, vector of Xylella fastidiosa
                    "Orchestes fagi", # beech flea weevil - not a crop pest but a pest of European beech 
                    "Sitona humeralis", # major pest of alfalfa
                    "Atomaria linearis", # pygmy mangold beetle - major cash crop pest 
                    "Brachypera zoilus", # aka Hypera punctata - stated as an important agricultural pest 
                    "Chaetocnema aridula", # cereal stem flea beetle - major cereal pest 
                    "Chaetocnema concinna", # mangold flea beetle - pest of sugar and fodder beet 
                    "Curculio glandium", # widespread acorn pest 
                    "Harpalus rufipes", # although also considered a beneficial predator, it is also stated as a major pest of wheat and grasses and injurous to strawberry
                    "Hebata solani", # stated as needing to be managed in orchards 
                    "Hypera nigrirostris", # lesser clover leaf beetle - major clover pest 
                    "Liocoris tripustulatus", # major pest of greenhouse vegetables 
                    "Piezodorus lituratus", # stated to be a serious problem in red lentils
                    "Vanessa cardui", # stated to be a pest of soybean and "a major pest of corn and soybeans in Iowa
                    "Zygina flammigera", # major forestry pest 
                    "Evacanthus interruptus", # one of "the most important leafhopper pests worldwide" 
                    "Exomias pellucidus", # root weevil stated as a strawberry pest in need of control 
                    "Glischrochilus quadrisignatus", # tomato pest 
                    "Plagiognathus chrysanthemi", # pest of birdsfoot trefoil (pasture forage crop)
                    "Stictocephala bisonia", # major jujube pest 
                    "Thymelicus lineola", # mentioned as an agricultural pest in Quebec needing to be controlled 
                    "Zyginidia scutellaris", # maize pest 
                    "Hebata decipiens" # widespread and polyphagous pest of several major crops
                    )

verified_nonpests <- c("Phyllotreta nigripes", # potentially harmful flea beetle mentioned in association with important pests 
                       "Javesella pellucida", # wheat pest, but not clear that is of major importance 
                       "Macrosteles laevis", # wheat pest, but not clear that is of major importance 
                       "Colias erate", # not clear that it is a major pest 
                       "Larinus planus", # weed biocontrol weevil predating native thistles 
                       "Aphrodes bicincta", # subject of a trial but not because of its pest status 
                       "Curculio venosus", # infesting oak trees but not clear that it's an important pest 
                       "Gryllus campestris", # mentioned as pest but not clear that it's an important pest 
                       "Typhlocyba quercus" # only stated as a potential vector of tomato stolbur disease but not definitive 
                       )


nrow(herbivore_nonpests %>% filter(!(Subject %in% verified_pests))) # 55
nrow(herbivore_nonpests%>% filter(!(Subject %in% verified_pests), nMajor==0)) # 48

mean(herbivore_nonpests %>% filter(!(Subject %in% verified_pests)) %>% pull(nEID)) # 2.2
median(herbivore_nonpests %>% filter(!(Subject %in% verified_pests)) %>% pull(nEID)) # 1 


# nEID >= 1: 51/60 = 85.0 %
# nEID >= 3: 13/17 = 76.5 % 
# nEID >= 5: 5/6 = 83.3 % 
# nEID >= 10: 1/1 = 100 % 
# nEID >= 20: 0/0 = NA  





herbivore_nonpests <- interactions_df %>% 
  filter(str_count(Subject, "\\w+") > 1 # filter out binomials that are genus-only
  ) %>% 
  mutate(Subject = word(Subject, 1, 2)) %>% # keep only first two binomials (i.e. remove subspecies information)
  filter(
    # 1. Check if the main Subject matches
    Subject %in% nonpest_list | 
      # 2. Safely look inside the list column row-by-row
      map_lgl(Subject.Synonyms, ~ any(.x %in% nonpest_list))
  )

table(herbivore_nonpests$Type)

roles <- herbivore_nonpests %>%
  # 1. Keep only unique Species (Subject) and Type combinations
  distinct(Subject, Type, EID) %>%
  group_by(Subject, Type) %>%
  summarise(nEID = n_distinct(EID)) %>%
  filter(nEID>=1) %>% 
  # 2. Group by species and combine all their Types into an alphabetical string
  group_by(Subject) %>%
  summarise(
    Types = paste(sort(Type), collapse = " + "),
    .groups = "drop"
  ) 

roles %>%
  # 3. Tally how many unique species share each exact combination
  count(Types, name = "Unique_Species_Count") %>%
  arrange(desc(Unique_Species_Count))

# Types                     Unique_Species_Count
# herbivore                                   96
# herbivore + natural enemy                    8
# natural enemy                                4

eid_counts <- herbivore_nonpests %>% 
  group_by(Subject) %>%
  summarise(
    nEID.Enemy = n_distinct(EID[Type=='natural enemy' & !is.na(Type)]),
    nEID.Herbivore = n_distinct(EID[Type=='herbivore' & !is.na(Type)]),
    nPest = n_distinct(EID[Pest == TRUE & !is.na(Pest)]),
    nMajor = n_distinct(EID[Pest.Importance=='major' & !is.na(Pest.Importance)]),
    .groups = "drop"
  )

eid_counts %>% arrange(desc(nEID.Herbivore))

cat(nrow(eid_counts[eid_counts$nPest>0,]), '/', nrow(eid_counts), '=', round(100*nrow(eid_counts[eid_counts$nPest>0,])/nrow(eid_counts),1),'%')
# 70 / 108 = 64.8 %

cat(nrow(eid_counts[eid_counts$nMajor>0,]), '/', nrow(eid_counts), '=', round(100*nrow(eid_counts[eid_counts$nMajor>0,])/nrow(eid_counts),1),'%')




# medians  
median(eid_counts$nEID.Enemy)     # 0                   mean = 0.3303571
median(eid_counts$nEID.Herbivore) # 2.5                 mean = 19.75
median(eid_counts$nPest)          # 1     mode = 0      mean = 18.05357
median(eid_counts$nMajor)         # 1     mode = 0      mean = 15.67857

# modes
as.numeric(names(table(eid_counts$nPest))[which.max(table(eid_counts$nPest))])                   # 0 
as.numeric(names(table(eid_counts$nMajor))[which.max(table(eid_counts$nMajor))])                 # 0


# herbivore + natural enemy: 
# Amara aenea
# Amara similata
# Apolygus lucorum
# Harpalus affinis
# Harpalus rufipes
# Plagiognathus chrysanthemi
# Tettigonia viridissima
# Tribolium castaneum

eid_counts %>%
  filter(Subject %in% c("Harpalus rufipes","Harpalus affinis","Tribolium castaneum","Tettigonia viridissima","Amara similata","Apolygus lucorum","Amara aenea","Plagiognathus chrysanthemi")) %>%
  arrange(desc(nEID.Herbivore))

# Subject                      nEID.Enemy nEID.Herbivore nPest nMajor
# 1 Tribolium castaneum                 1           1111  1107   1005          # red flour beetle - worldwide pest of stored products, particularly food grains, one abstract evidences intraguild predation between different Tribolium species including T. castaneum
# 2 Apolygus lucorum                    3            116   112    105          # consistently mentioned as an important pest (e.g., of apple in China), omnivorous and feeds on Helicoverpa armigera (e.g. 2-s2.0-84878875761)
# 3 Harpalus rufipes                   17              6     3      2          # predominantly a natural enemy, but also stated as a pest of wheat and other grasses (2-s2.0-85118942123) and as significantly damaging strawberries (2-s2.0-84993843470) and being a pest in strawberries (2-s2.0-33751004384)
# 4 Harpalus affinis                    6              3     0      0          # predominantly a natural enemy
# 5 Plagiognathus chrysanthemi          1              3     2      1          # stated to be a pest of the fodder crop birdsfoot trefoil (2-s2.0-0025527945) and as causing damage to strawberries (2-s2.0-0033923192), also stated to predate on Acyrthosiphon pisum, Empoasca fabae and Hypera postica
# 6 Amara similata                      1              2     0      0          # carabid predator 
# 7 Tettigonia viridissima              1              2     1      0          # minor pest in energy crops (2-s2.0-85179485142), predator of gall midge Obolodiplosis robiniae (2-s2.0-79961155405)
# 8 Amara aenea                         2              1     0      0          # predator, e.g. of apple maggot (2-s2.0-0040041164)

# natural enemy: 
# Amara bifrons
# Amara familiaris
# Amara ovata
# Harpalus distinguendus

eid_counts %>%
  filter(Subject %in% c("Amara bifrons","Amara familiaris","Amara ovata","Harpalus distinguendus")) %>%
  arrange(desc(nEID.Enemy))

# Subject                  nEID.Enemy nEID.Herbivore nPest nMajor
# 1 Amara bifrons                   1              0     0      0              # stated as a predator of the cabbage maggot, Delia radicum (2-s2.0-3142699420)
# 2 Amara familiaris                1              0     0      0              # stated as a common ground-foraging aphid predator (2-s2.0-0033135852)
# 3 Amara ovata                     1              0     0      0              # stated as a predatory beetle, predator of pollen beetle (2-s2.0-84963612982)
# 4 Harpalus distinguendus          1              0     0      0              # stated as a predatory beetle, predator of pollen beetle (2-s2.0-84963612982)


# removing Tribolium castaneum, Apolygus lucorum, Harpalus rufipes and Plagiognathus chrysanthemi due to pest evidence 
# removing Amara bifrons, Amara familiaris, Amara ovata, Harpalus distinguendus due to predominantly being natural enemies

verified_nonpest_herbivores <- append(eid_counts %>% filter(nPest==0) %>% pull(Subject), c("Larinus planus", "Thymelicus lineola", "Pieris napi", "Sphaeroderma rubidum", "Papilio machaon", "Typhlocyba quercus")) 

eid_nonpest <- eid_counts %>% filter(Subject %in% verified_nonpest_herbivores)

mean(eid_nonpest$nEID.Herbivore) # 1.9

################################################################################
#                                   predators                                  #
################################################################################

predator_types <- interactions_df %>% 
  filter(str_count(Subject, "\\w+") > 1 # filter out binomials that are genus-only
  ) %>% 
  mutate(Subject = word(Subject, 1, 2)) %>% # keep only first two binomials (i.e. remove subspecies information)
  group_by(Subject, Feeding.Mode) %>%
  summarise(
    nEID = n_distinct(EID),
    Subject.Synonyms = list(unique(unlist(Subject.Synonyms))),
    .groups = "drop"
  ) %>% 
  ungroup() %>%
  group_by(Subject) %>%
  summarise(
    Types = paste(sort(Feeding.Mode), collapse = " + "),
    nEID = sum(nEID),
    Subject.Synonyms = list(unique(unlist(Subject.Synonyms))),
    .groups = "drop"
  ) %>%
  filter(
    nEID >= 20,
    # 1. Check if the main Subject matches
    Subject %in% predator_list | 
      # 2. Safely look inside the list column row-by-row
      map_lgl(Subject.Synonyms, ~ any(.x %in% predator_list))
  )

nrow(predator_types)

predator_types %>%
  # 3. Tally how many unique species share each exact combination
  count(Types, name = "Unique_Species_Count") %>%
  arrange(desc(Unique_Species_Count))

# nEID >= 1: 148/151 = 98.0
# nEID >= 3: 56/56 = 100
# nEID >= 5: 38/38 = 100
# nEID >= 10: 27/27 = 100
# nEID >= 20: 19/19 = 100





enemy_predators <- interactions_df %>% 
  filter(str_count(Subject, "\\w+") > 1 # filter out binomials that are genus-only
  ) %>% 
  mutate(Subject = word(Subject, 1, 2)) %>% # keep only first two binomials (i.e. remove subspecies information)
  filter(
    # 1. Check if the main Subject matches
    Subject %in% predator_list #| 
      # 2. Safely look inside the list column row-by-row
      #map_lgl(Subject.Synonyms, ~ any(.x %in% predator_list))
  )

table(enemy_predators$Type)
table(enemy_predators$Feeding.Mode)

roles <- enemy_predators %>%
  # 1. Keep only unique Species (Subject) and Type combinations
  distinct(Subject, Type) %>%
  # 2. Group by species and combine all their Types into an alphabetical string
  group_by(Subject) %>%
  summarise(
    Types = paste(sort(Type), collapse = " + "),
    .groups = "drop"
  ) 

roles %>%
  # 3. Tally how many unique species share each exact combination
  count(Types, name = "Unique_Species_Count") %>%
  arrange(desc(Unique_Species_Count))

# Types                     Unique_Species_Count
# 1 natural enemy                              139
# 2 herbivore + natural enemy                    3
# 3 herbivore                                    2

feeding_modes <- enemy_predators %>%
  # 1. Keep only unique Species (Subject) and Type combinations
  distinct(Subject, Feeding.Mode) %>%
  # 2. Group by species and combine all their Types into an alphabetical string
  group_by(Subject) %>%
  summarise(
    Feeding.Modes = paste(sort(Feeding.Mode), collapse = " + "),
    .groups = "drop"
  ) 

feeding_modes %>%
  # 3. Tally how many unique species share each exact combination
  count(Feeding.Modes, name = "Unique_Species_Count") %>%
  arrange(desc(Unique_Species_Count))

# Feeding.Modes                                 Unique_Species_Count
# 1 predation                                                      136
# 2 herbivory                                                        2
# 3 parasitism + predation                                           2
# 4 frugivory + granivory + herbivory + predation                    1
# 5 frugivory + predation                                            1
# 6 granivory + predation                                            1
# 7 parasitism                                                       1


eid_counts <- enemy_predators %>% 
  group_by(Subject) %>%
  summarise(
    nEID.Enemy = n_distinct(EID[Type=='natural enemy' & !is.na(Type)]),
    nEID.Herbivore = n_distinct(EID[Type=='herbivore' & !is.na(Type)]),
    nPest = n_distinct(EID[Pest == TRUE & !is.na(Pest)]),
    nMajor = n_distinct(EID[Pest.Importance=='major' & !is.na(Pest.Importance)]),
    .groups = "drop"
  )

# medians  
median(eid_counts$nEID.Enemy)     # 2     mode = 1    mean = 14.27815
median(eid_counts$nEID.Herbivore) # 0                 mean = 0.1125828
median(eid_counts$nPest)          # 0                 mean = 0.1059603
median(eid_counts$nMajor)         # 0                 mean = 0.05298013

# modes
as.numeric(names(table(eid_counts$nEID.Enemy))[which.max(table(eid_counts$nEID.Enemy))])                   # 1


eid_counts %>% arrange(desc(nEID.Herbivore))

eid_counts[eid_counts$nEID.Enemy==0,]$Subject                        # Kleidocerys resedae, Subcoccinella vigintiquatuorpunctata
eid_counts[eid_counts$nEID.Enemy<eid_counts$nEID.Herbivore,]$Subject # Kleidocerys resedae, Subcoccinella vigintiquatuorpunctata

eid_counts %>%
  filter(Subject %in% c("Forficula auricularia","Subcoccinella vigintiquatuorpunctata","Pterostichus melanarius","Harmonia axyridis","Kleidocerys resedae")) %>%
  arrange(desc(nEID.Enemy))

# Subject                                nEID.Enemy nEID.Herbivore nPest nMajor
# 1 Harmonia axyridis                           366              1     1      0    # single pest evidence found it to be a minor fruit pest (2-s2.0-2342631295)
# 2 Pterostichus melanarius                      49              1     1      0    # single pest evidence relates to crop seed predation (2-s2.0-85064862082)
# 3 Forficula auricularia                        45             13    13      8    # European earwig, omnivorous, stated as a pest in some cases (e.g., 2-s2.0-84976402516)

# 4 Kleidocerys resedae                           0              1     0      0    # no evidence of predation could be found  
# 5 Subcoccinella vigintiquatuorpunctata          0              1     1      0    # unlike other ladybirds it is not predatory but rather herbivorous (https://en.wikipedia.org/wiki/Subcoccinella_vigintiquatuorpunctata)

# larval ectoparasitoids (three rove beetle species)
# Aleochara sparsa - mentioned as a parasite of carrot fly, Psila rosae (2-s2.0-84980113063)
# Aleochara bipustulata - e.g., mentioned as a parasitoid rove beetle in agroecosystems (2-s2.0-63849275716)
# Aleochara bilineata - e.g., mentioned as a parasitoid of root maggots, Delia spp. (2-s2.0-77958151917)


# removal of Kleidocerys resedae and Subcoccinella vigintiquatuorpunctata, for which no evidence of predation could be found 

length(unique(enemy_predators$Subject)) # 144

# accuracy: 
# 142 / 144 = 98.6%


################################################################################
#                                   parasitoids                                #
################################################################################

parasitoid_types <- interactions_df %>% 
  filter(str_count(Subject, "\\w+") > 1 # filter out binomials that are genus-only
  ) %>% 
  mutate(Subject = word(Subject, 1, 2)) %>% # keep only first two binomials (i.e. remove subspecies information)
  group_by(Subject, Feeding.Mode) %>%
  summarise(
    nEID = n_distinct(EID),
    Subject.Synonyms = list(unique(unlist(Subject.Synonyms))),
    .groups = "drop"
  ) %>% 
  ungroup() %>%
  group_by(Subject) %>%
  summarise(
    Types = paste(sort(Feeding.Mode), collapse = " + "),
    nEID = sum(nEID),
    Subject.Synonyms = list(unique(unlist(Subject.Synonyms))),
    .groups = "drop"
  ) %>%
  filter(
    nEID >= 1,
    # 1. Check if the main Subject matches
    Subject %in% parasitoid_list | 
      # 2. Safely look inside the list column row-by-row
      map_lgl(Subject.Synonyms, ~ any(.x %in% parasitoid_list))
  ) %>% 
  filter(!(Subject %in% c("Oscinella frit","Trogoderma glabrum"))) # no evidence found for acting as parasitoids

nrow(parasitoid_types)

parasitoid_types %>%
  # 3. Tally how many unique species share each exact combination
  count(Types, name = "Unique_Species_Count") %>%
  arrange(desc(Unique_Species_Count))

# nEID >= 1: 46/46 = 100
# nEID >= 3: 24/24 = 100
# nEID >= 5: 14/14 = 100
# nEID >= 10: 11/11 = 100
# nEID >= 20: 6/6 = 100



enemy_parasitoids <- interactions_df %>% 
  filter(str_count(Subject, "\\w+") > 1 # filter out binomials that are genus-only
  ) %>% 
  mutate(Subject = word(Subject, 1, 2)) %>% # keep only first two binomials (i.e. remove subspecies information)
  filter(
    # 1. Check if the main Subject matches
    Subject %in% parasitoid_list | 
      # 2. Safely look inside the list column row-by-row
      map_lgl(Subject.Synonyms, ~ any(.x %in% parasitoid_list))
  )

table(enemy_parasitoids$Type)
table(enemy_parasitoids$Feeding.Mode)

roles <- enemy_parasitoids %>%
  # 1. Keep only unique Species (Subject) and Type combinations
  distinct(Subject, Type) %>%
  # 2. Group by species and combine all their Types into an alphabetical string
  group_by(Subject) %>%
  summarise(
    Types = paste(sort(Type), collapse = " + "),
    .groups = "drop"
  ) 

roles %>%
  # 3. Tally how many unique species share each exact combination
  count(Types, name = "Unique_Species_Count") %>%
  arrange(desc(Unique_Species_Count))

# Types         Unique_Species_Count
# natural enemy                   46
# herbivore                        2

feeding_modes <- enemy_parasitoids %>%
  # 1. Keep only unique Species (Subject) and Type combinations
  distinct(Subject, Feeding.Mode) %>%
  # 2. Group by species and combine all their Types into an alphabetical string
  group_by(Subject) %>%
  summarise(
    Feeding.Modes = paste(sort(Feeding.Mode), collapse = " + "),
    .groups = "drop"
  ) 

feeding_modes%>%
  # 3. Tally how many unique species share each exact combination
  count(Feeding.Modes, name = "Unique_Species_Count") %>%
  arrange(desc(Unique_Species_Count))

# Feeding.Modes          Unique_Species_Count
# parasitism                               42
# hyperparasitism                           3
# granivory                                 1
# herbivory                                 1
# parasitism + predation                    1


eid_counts <- enemy_parasitoids %>% 
  group_by(Subject) %>%
  summarise(
    nEID.Enemy = n_distinct(EID[Type=='natural enemy' & !is.na(Type)]),
    nEID.Herbivore = n_distinct(EID[Type=='herbivore' & !is.na(Type)]),
    nPest = n_distinct(EID[Pest == TRUE & !is.na(Pest)]),
    nMajor = n_distinct(EID[Pest.Importance=='major' & !is.na(Pest.Importance)]),
    .groups = "drop"
  )

# medians  
median(eid_counts$nEID.Enemy)     # 2.5     mode = 1    mean = 11.83333
median(eid_counts$nEID.Herbivore) # 0                   mean = 0.5416667
median(eid_counts$nPest)          # 0                   mean = 0.5416667
median(eid_counts$nMajor)         # 0                   mean = 0.4166667

# modes
as.numeric(names(table(eid_counts$nEID.Enemy))[which.max(table(eid_counts$nEID.Enemy))])                   # 1



eid_counts %>% arrange(-desc(nEID.Enemy))
eid_counts[eid_counts$nEID.Enemy==0,]$Subject # Oscinella frit, Trogoderma glabrum
eid_counts[eid_counts$nEID.Enemy<eid_counts$nEID.Herbivore,]$Subject # Oscinella frit, Trogoderma glabrum


eid_counts %>% filter(Subject %in% c("Oscinella frit", "Trogoderma glabrum")) %>% arrange(desc(nEID.Herbivore))

# Subject            nEID.Enemy nEID.Herbivore nPest nMajor
# 1 Oscinella frit              0             25    25     20                  # major agricultural pest, not a parasite or parasitoid
# 2 Trogoderma glabrum          0              1     1      0                  # stored product pest beetle (2-s2.0-20444415047)







################################################################################
#                 1. EPPO global pest database pest agreements                 # 
################################################################################

# based on FAO definitions (https://www.fao.org/fileadmin/templates/ess/documents/world_census_of_agriculture/appendix3_r7.pdf)
crop_lookup <- tribble(
  ~crop_name, ~pattern, ~crop_group, ~crop_class,
  
  # --- 1. CEREALS ---
  "wheat", "\\b(wheat|triticum)\\b", "Cereals", "Wheat",
  "maize", "\\b(maize|corn|zea mays)\\b", "Cereals", "Maize",
  "rice", "\\b(rice|oryza)\\b", "Cereals", "Rice",
  "barley", "\\b(barley|hordeum)\\b", "Cereals", "Barley",
  "sorghum", "\\b(sorghum)\\b", "Cereals", "Sorghum",
  "millet", "\\b(millet|panicum|setaria|eleusine|pennisetum|digitaria)\\b", "Cereals", "Millets",
  "rye", "\\b(rye|secale)\\b", "Cereals", "Rye",
  "oats", "\\b(oat|avena)\\b", "Cereals", "Oats",
  "mixed cereals", "\\b(cereal|grain)\\b", "Cereals", "Other cereals",
  
  # --- 2. VEGETABLES ---
  # Leafy
  "cabbage", "\\b(cabbage|brassica oleracea)\\b", "Vegetables", "Leafy vegetables",
  "lettuce", "\\b(lettuce|lactuca sativa)\\b", "Vegetables", "Leafy vegetables",
  "spinach", "\\b(spinach|spinacia)\\b", "Vegetables", "Leafy vegetables",
  
  # Fruit vegetables
  "tomato", "\\b(tomato|solanum lycopersicum)\\b", "Vegetables", "Fruit-bearing vegetables",
  "eggplant", "\\b(eggplant|aubergine|solanum melongena)\\b", "Vegetables", "Fruit-bearing vegetables",
  "cucumber", "\\b(cucumber|cucumis sativus)\\b", "Vegetables", "Fruit-bearing vegetables",
  "melon", "\\b(melon|cucumis melo|cantaloupe)\\b", "Vegetables", "Fruit-bearing vegetables",
  "pumpkin", "\\b(pumpkin|squash|gourd|cucurbita)\\b", "Vegetables", "Fruit-bearing vegetables",
  
  # Roots & bulbs
  "carrot", "\\b(carrot|daucus carota)\\b", "Vegetables", "Root vegetables",
  "onion", "\\b(onion|allium cepa)\\b", "Vegetables", "Bulb vegetables",
  "garlic", "\\b(garlic|allium sativum)\\b", "Vegetables", "Bulb vegetables",
  
  # --- 3. FRUITS & NUTS ---
  # Tropical
  "banana", "\\b(banana|musa)\\b", "Fruit & Nuts", "Tropical fruit",
  "plantain", "\\b(plantain|musa paradisiaca)\\b", "Fruit & Nuts", "Tropical fruit",
  "mango", "\\b(mango|mangifera indica)\\b", "Fruit & Nuts", "Tropical fruit",
  "papaya", "\\b(papaya|carica papaya)\\b", "Fruit & Nuts", "Tropical fruit",
  "pineapple", "\\b(pineapple|ananas)\\b", "Fruit & Nuts", "Tropical fruit",
  "avocado", "\\b(avocado|persea americana)\\b", "Fruit & Nuts", "Tropical fruit",
  
  # Citrus
  "orange", "\\b(orange|citrus sinensis)\\b", "Fruit & Nuts", "Citrus",
  "lemon", "\\b(lemon|citrus limon)\\b", "Fruit & Nuts", "Citrus",
  "lime", "\\b(lime|citrus aurantiifolia)\\b", "Fruit & Nuts", "Citrus",
  "grapefruit", "\\b(grapefruit|citrus paradisi)\\b", "Fruit & Nuts", "Citrus",
  
  # Temperate
  "apple", "\\b(apple|malus domestica)\\b", "Fruit & Nuts", "Pome fruit",
  "pear", "\\b(pear|pyrus)\\b", "Fruit & Nuts", "Pome fruit",
  "peach", "\\b(peach|prunus persica)\\b", "Fruit & Nuts", "Stone fruit",
  "plum", "\\b(plum|prunus domestica)\\b", "Fruit & Nuts", "Stone fruit",
  "cherry", "\\b(cherry|prunus avium)\\b", "Fruit & Nuts", "Stone fruit",
  "grape", "\\b(grape|vitis)\\b", "Fruit & Nuts", "Grapes",
  
  # Nuts
  "almond", "\\b(almond|prunus dulcis)\\b", "Fruit & Nuts", "Nuts",
  "cashew", "\\b(cashew|anacardium occidentale)\\b", "Fruit & Nuts", "Nuts",
  "walnut", "\\b(walnut|juglans)\\b", "Fruit & Nuts", "Nuts",
  
  # --- 4. OILSEEDS ---
  "soybean", "\\b(soybean|glycine max)\\b", "Oilseed crops", "Soya beans",
  "groundnut", "\\b(groundnut|peanut|arachis hypogaea)\\b", "Oilseed crops", "Groundnuts",
  "rapeseed", "\\b(rapeseed|canola|brassica napus)\\b", "Oilseed crops", "Rapeseed",
  "sunflower", "\\b(sunflower|helianthus annuus)\\b", "Oilseed crops", "Sunflower",
  "sesame", "\\b(sesame|sesamum indicum)\\b", "Oilseed crops", "Sesame",
  "linseed", "\\b(linseed|flax|linum usitatissimum)\\b", "Oilseed crops", "Linseed",
  "mustard", "\\b(mustard|sinapis)\\b", "Oilseed crops", "Mustard",
  
  # Permanent oil crops
  "coconut", "\\b(coconut|cocos nucifera)\\b", "Oilseed crops", "Permanent oil crops",
  "oil palm", "\\b(oil palm|elaeis guineensis)\\b", "Oilseed crops", "Permanent oil crops",
  "olive", "\\b(olive|olea europaea)\\b", "Oilseed crops", "Permanent oil crops",
  
  # --- 5. ROOT / TUBER ---
  "potato", "\\b(potato|solanum tuberosum)\\b", "Roots & tubers", "Potatoes",
  "sweet potato", "\\b(sweet potato|ipomoea batatas)\\b", "Roots & tubers", "Sweet potatoes",
  "cassava", "\\b(cassava|manihot esculenta|tapioca)\\b", "Roots & tubers", "Cassava",
  "yam", "\\b(yam|dioscorea)\\b", "Roots & tubers", "Yams",
  "taro", "\\b(taro|colocasia esculenta)\\b", "Roots & tubers", "Other roots",
  
  # --- 6. BEVERAGE & SPICES ---
  "coffee", "\\b(coffee|coffea arabica|coffea canephora)\\b", "Beverage crops", "Coffee",
  "tea", "\\b(tea|camellia sinensis)\\b", "Beverage crops", "Tea",
  "cocoa", "\\b(cocoa|cacao|theobroma cacao)\\b", "Beverage crops", "Cocoa",
  
  "chili", "\\b(chili|chilli|bell pepper|capsicum)\\b", "Spice crops", "Temporary spices",
  "pepper spice", "\\b(black pepper|piper nigrum)\\b", "Spice crops", "Permanent spices",
  "ginger", "\\b(ginger|zingiber officinale)\\b", "Spice crops", "Permanent spices",
  "cinnamon", "\\b(cinnamon|cinnamomum)\\b", "Spice crops", "Permanent spices",
  
  # --- 7. LEGUMES ---
  "beans", "\\b(bean|phaseolus|vigna)\\b", "Legumes", "Beans",
  "chickpea", "\\b(chickpea|cicer arietinum)\\b", "Legumes", "Chickpeas",
  "cowpea", "\\b(cowpea|vigna unguiculata)\\b", "Legumes", "Cowpeas",
  "lentil", "\\b(lentil|lens culinaris)\\b", "Legumes", "Lentils",
  "pea", "\\b(pea|pisum sativum)\\b", "Legumes", "Peas",
  "pigeon pea", "\\b(pigeon pea|cajanus cajan)\\b", "Legumes", "Pigeon peas",
  
  # --- 8. SUGAR ---
  "sugarcane", "\\b(sugarcane|saccharum officinarum)\\b", "Sugar crops", "Sugar cane",
  "sugarbeet", "\\b(sugar beet|beta vulgaris)\\b", "Sugar crops", "Sugar beet",
  "sweet sorghum", "\\b(sweet sorghum)\\b", "Sugar crops", "Other sugar crops",
  
  # --- 9. OTHER ---
  "cotton", "\\b(cotton|gossypium)\\b", "Fibre crops", "Cotton",
  "jute", "\\b(jute|corchorus)\\b", "Fibre crops", "Fibre crops",
  "flax", "\\b(flax|linum)\\b", "Fibre crops", "Fibre crops",
  "rubber", "\\b(rubber|hevea brasiliensis)\\b", "Industrial crops", "Rubber",
  "tobacco", "\\b(tobacco|nicotiana)\\b", "Industrial crops", "Tobacco",
  "alfalfa", "\\b(alfalfa|medicago sativa)\\b", "Fodder crops", "Fodder",
  "grass", "\\b(grass|fodder|pasture)\\b", "Fodder crops", "Fodder",
  
  # Extra: Five common forest plantation species
  "pine", "\\b(pine|pinus)\\b", "Forest plantation", "Softwood forest",
  "douglas fir", "\\b(douglas-fir|douglas fir|pseudotsuga menziesii)\\b", "Forest plantation", "Softwood forest",
  "spruce", "\\b(spruce|picea)\\b", "Forest plantation", "Softwood forest",
  "teak", "\\b(teak|tectona grandis)\\b", "Forest plantation", "Hardwood forest",
  "eucalyptus", "\\b(eucalyptus|eucalypt)\\b", "Forest plantation", "Hardwood forest"
)

herbivore_edges <- interactions_df %>% 
  filter(Type=='herbivore', 
         str_count(Subject, "\\w+") > 1 # filter out binomials that are genus-only
  ) %>% 
  mutate(Subject = word(Subject, 1, 2)) %>% # keep only first two binomials (i.e. remove subspecies information)
  # Perform the match using a "Cross Join" 
  cross_join(crop_lookup) %>%
  # Match the pattern to the Object
  filter(str_detect(tolower(Object), pattern))

herbivore_summary <- herbivore_edges %>%
  # Now continue with grouping/summarising
  group_by(Subject, crop_name) %>% 
  dplyr::summarise(
    nEID     = n_distinct(EID),
    nPest    = n_distinct(EID[Pest == TRUE & !is.na(Pest)]),
    nMajor   = n_distinct(EID[Pest.Importance == "major" & !is.na(Pest.Importance)]),
    Synonyms = list(unique(unlist(Subject.Synonyms))),
    .groups = "drop"
  ) %>% 
  filter(nEID >= 1)



# *bacterial, viral and fungal pathogens have been manually removed from the .csv files

results <- lapply(crop_lookup$crop_name, FUN = function(crop){
  print(crop)
  
  if (crop=='coffee'){ 
    crop_pests <- rbind(read_csv(paste0(eppoDir, "filtered/pests_coffee_Coffea-arabica.csv"),show_col_types = FALSE) %>% filter(type %in% c("Host","Major host")) %>% dplyr::select(type, Pref_name),
                        read_csv(paste0(eppoDir, "filtered/pests_coffee_Coffea-canephora.csv"),show_col_types = FALSE) %>% filter(type %in% c("Host","Major host")) %>% dplyr::select(type, Pref_name))
  } else if (crop=='millet'){
    crop_pests <- rbind(read_csv(paste0(eppoDir, "filtered/pests_millet_Cenchrus-americanus.csv"),show_col_types = FALSE) %>% filter(type %in% c("Host","Major host")) %>% dplyr::select(type, Pref_name),
                        read_csv(paste0(eppoDir, "filtered/pests_millet_Panicum-miliaceum.csv"),show_col_types = FALSE) %>% filter(type %in% c("Host","Major host")) %>% dplyr::select(type, Pref_name),
                        read_csv(paste0(eppoDir, "filtered/pests_millet_Setaria-italica.csv"),show_col_types = FALSE) %>% filter(type %in% c("Host","Major host")) %>% dplyr::select(type, Pref_name))
  } else if (crop=='mustard'){
    crop_pests <- rbind(read_csv(paste0(eppoDir, "filtered/pests_mustard_Brassica-carinata.csv"),show_col_types = FALSE) %>% filter(type %in% c("Host","Major host")) %>% dplyr::select(type, Pref_name),
                        read_csv(paste0(eppoDir, "filtered/pests_mustard_Brassica-juncea.csv"),show_col_types = FALSE) %>% filter(type %in% c("Host","Major host")) %>% dplyr::select(type, Pref_name),
                        read_csv(paste0(eppoDir, "filtered/pests_mustard_Brassica-nigra.csv"),show_col_types = FALSE) %>% filter(type %in% c("Host","Major host")) %>% dplyr::select(type, Pref_name))
  } else {
    crop_pests <- tryCatch({read_csv(paste0(eppoDir, sprintf("filtered/pests_%s.csv", gsub(" ","_",crop))),show_col_types = FALSE) %>% filter(type %in% c("Host","Major host")) %>% dplyr::select(type, Pref_name)
    }, error = function(e) {
      message("file not found", conditionMessage(e))
      return(NULL) 
    })
  }
  
  if (is.null(crop_pests)) return(NULL) 
  
  # keep only first two words 
  crop_pests <- crop_pests %>%
    mutate(Match_Key = word(Pref_name, 1, 2)) %>% 
    distinct(type, Match_Key)
  
  
  
  df_hosts <- herbivore_summary %>% 
    filter(crop_name == crop) %>% 
    # Create a temporary column that unnests or extracts the matching text
    mutate(Match_Column = map2_chr(Subject, Synonyms, ~ {
      # Find which string (Subject or inside Synonyms) hits the reference list
      all_names <- c(.x, unlist(.y))
      matched <- all_names[all_names %in% crop_pests$Match_Key]
      if(length(matched) > 0) matched[1] else NA_character_
    })) %>% 
    # Perform a standard left join on the discovered match key
    left_join(crop_pests, by = c("Match_Column" = "Match_Key"), relationship = "many-to-many") %>% 
    # Optional: Remove the temporary helper column
    select(-Match_Column) %>% 
    filter(!is.na(type))
  
  if (nrow(df_hosts)==0) return(NULL) 
  
  # how many EPPO pests are in the database? 
  # cat(nrow(df_hosts[df_hosts$nPest>0,]), "/", nrow(df_hosts), " = ", round(100*nrow(df_hosts[df_hosts$nPest>0,])/nrow(df_hosts),1), "%\n")
  
  list(crop = crop,
       totPests = nrow(df_hosts[df_hosts$nPest>0,]),
       totHosts = nrow(df_hosts),
       totMajorHosts = nrow(df_hosts[df_hosts$type=='Major host',]),
       relPests = nrow(df_hosts[df_hosts$nPest>0,])/nrow(df_hosts),
       Hosts = list(df_hosts$Subject[df_hosts$type=='Host']),
       MajorHosts = list(df_hosts$Subject[df_hosts$type=='Major host']),
       MajorHosts.matched = list(df_hosts$Subject[df_hosts$nMajor>0 & df_hosts$type=='Major host']),
       MajorHosts.missed = list(df_hosts$Subject[df_hosts$nMajor==0 & df_hosts$type=='Major host']),
       # hosts
       tp.hosts = nrow(df_hosts[df_hosts$nPest>0 & (df_hosts$type=='Host'|df_hosts$type=='Major host'),]),  # TP 
       fn.hosts = nrow(df_hosts[df_hosts$nPest==0 & (df_hosts$type=='Host'|df_hosts$type=='Major host' ),]), # FN
       # major hosts
       tp.majorhosts = nrow(df_hosts[df_hosts$nMajor>0 & df_hosts$type=='Major host',]),  # TP 
       fn.majorhosts = nrow(df_hosts[df_hosts$nMajor==0 & df_hosts$type=='Major host',]), # FN
       tp.majorhosts.nPest = nrow(df_hosts[df_hosts$nPest>0 & df_hosts$type=='Major host',]),  # TP 
       fn.majorhosts.nPest = nrow(df_hosts[df_hosts$nPest==0 & df_hosts$type=='Major host',]), # FN
       mean.nEID.Hosts = mean(df_hosts$nEID[df_hosts$type=='Host']),
       mean.nEID.MajorHosts = mean(df_hosts$nEID[df_hosts$type=='Major host']),
       mean.nPest.Hosts = mean(df_hosts$nPest[df_hosts$type=='Host']),
       mean.nPest.MajorHosts = mean(df_hosts$nPest[df_hosts$type=='Major host']),
       mean.nMajor.Hosts = mean(df_hosts$nMajor[df_hosts$type=='Host']),
       mean.nMajor.MajorHosts = mean(df_hosts$nMajor[df_hosts$type=='Major host'])
  )
})

results <- bind_rows(results)

results$rec.hosts <- results$tp.hosts/(results$tp.hosts+results$fn.hosts)
results$rec.majorhosts <- results$tp.majorhosts/(results$tp.majorhosts+results$fn.majorhosts)
results$rec.majorhosts.nPest <- results$tp.majorhosts.nPest/(results$tp.majorhosts.nPest+results$fn.majorhosts.nPest)

# nEID >= 1: 
100*sum(results$tp.hosts)/(sum(results$tp.hosts) + sum(results$fn.hosts)) # 93.1 (1344/1444)
100*sum(results$tp.majorhosts)/(sum(results$tp.majorhosts) + sum(results$fn.majorhosts)) # 90.2 (388/430)
100*sum(results$tp.majorhosts.nPest)/(sum(results$tp.majorhosts.nPest) + sum(results$fn.majorhosts.nPest)) # 97.7 (420/430)

# nEID >= 3: 
100*sum(results$tp.hosts)/(sum(results$tp.hosts) + sum(results$fn.hosts)) # 99.5 (761/765)
100*sum(results$tp.majorhosts)/(sum(results$tp.majorhosts) + sum(results$fn.majorhosts)) # 99.3 (290/292)
100*sum(results$tp.majorhosts.nPest)/(sum(results$tp.majorhosts.nPest) + sum(results$fn.majorhosts.nPest)) # 100 (292/292)

# nEID >= 5: 
100*sum(results$tp.hosts)/(sum(results$tp.hosts) + sum(results$fn.hosts)) # 99.8 (551/552)
100*sum(results$tp.majorhosts)/(sum(results$tp.majorhosts) + sum(results$fn.majorhosts)) # 100 (227/227)
100*sum(results$tp.majorhosts.nPest)/(sum(results$tp.majorhosts.nPest) + sum(results$fn.majorhosts.nPest)) # 100 (227/227)

# nEID >= 10: 
100*sum(results$tp.hosts)/(sum(results$tp.hosts) + sum(results$fn.hosts)) # 100 (349/349)
100*sum(results$tp.majorhosts)/(sum(results$tp.majorhosts) + sum(results$fn.majorhosts)) # 100 (160/160)
100*sum(results$tp.majorhosts.nPest)/(sum(results$tp.majorhosts.nPest) + sum(results$fn.majorhosts.nPest)) # 100 (160/160)

hosts <- unlist(results$Hosts)
majorhosts <- unlist(results$MajorHosts)
majorhosts.matched <- unlist(results$MajorHosts.matched)
majorhosts.missed <- unlist(results$MajorHosts.missed)

length(hosts) # 1014
length(majorhosts) # 430
length(hosts) + length(majorhosts) # 1444


summary.hosts <- herbivore_summary %>% 
  filter(Subject %in% hosts) %>% 
  group_by(Subject) %>% 
  summarise(nEID = sum(nEID),
            nPest = sum(nPest),
            nMajor = sum(nMajor))

summary.majorhosts <- herbivore_summary %>% 
  filter(Subject %in% majorhosts) %>% 
  group_by(Subject) %>% 
  summarise(nEID = sum(nEID),
            nPest = sum(nPest),
            nMajor = sum(nMajor))

summary.majorhosts.matched <- herbivore_summary %>% 
  filter(Subject %in% majorhosts.matched) %>% 
  group_by(Subject) %>% 
  summarise(nEID = sum(nEID),
            nPest = sum(nPest),
            nMajor = sum(nMajor))

summary.majorhosts.missed <- herbivore_summary %>% 
  filter(Subject %in% majorhosts.missed) %>% 
  group_by(Subject) %>% 
  summarise(nEID = sum(nEID),
            nPest = sum(nPest),
            nMajor = sum(nMajor))

mean(summary.hosts$nEID, na.rm=TRUE) # 63.5 (median 12)
mean(summary.majorhosts$nEID, na.rm=TRUE) # 65.8 (median 14)

mean(summary.hosts$nPest, na.rm=TRUE) # 58.6 (median 11)
mean(summary.majorhosts$nPest, na.rm=TRUE) # 61.3 (median 13)

mean(summary.majorhosts.matched$nEID, na.rm=TRUE) # 71.3
mean(summary.majorhosts.missed$nEID, na.rm=TRUE) # 17.6
mean(summary.majorhosts.matched$nPest, na.rm=TRUE) # 66.5
mean(summary.majorhosts.missed$nPest, na.rm=TRUE) # 14.7



knitr::kable(results %>% 
               mutate(rec.hosts = round(100*rec.hosts,1),
                      rec.majorhosts = round(100*rec.majorhosts,1),
                      rec.majorhosts.nPest = round(100*rec.majorhosts.nPest,1),
                      mean.nEID.Hosts = round(mean.nEID.Hosts, 1),
                      mean.nEID.MajorHosts = round(mean.nEID.MajorHosts, 1),
                      mean.nPest.Hosts = round(mean.nPest.Hosts, 1),
                      mean.nPest.MajorHosts = round(mean.nPest.MajorHosts, 1),
                      mean.nMajor.Hosts = round(mean.nMajor.Hosts, 1),
                      mean.nMajor.MajorHosts = round(mean.nMajor.MajorHosts, 1)
               ) %>% 
               dplyr::select(`Crop name` = crop, 
                             `$n$ Hosts` = totHosts, 
                             `$n$ Major hosts` = totMajorHosts, 
                             `Host recall` = rec.hosts,
                             `MajorHost recall` = rec.majorhosts,
                             `MajorHost recall*` = rec.majorhosts,
                             `mean(nPest.Host)` = mean.nPest.Hosts,
                             `mean(nPest.MajorHost)` = mean.nPest.MajorHosts,
                             `mean(nEID.Host` = mean.nEID.Hosts,
                             `mean(nEID.MajorHost)` = mean.nEID.MajorHosts
               ),
             format = "latex") 








dat <- tribble(
  ~source, ~comparison, ~nEID, ~agreement, ~n_correct, ~n_total,
  
  # Oliver et al.
  "Oliver et al.",
  "Pest control & nImportantEnemy > 0",
  "nEID ≥ 1", 87.5, 140, 160,
  "Oliver et al.",
  "Pest control & nImportantEnemy > 0",
  "nEID ≥ 3", 93.5, 72, 77,
  "Oliver et al.",
  "Pest control & nImportantEnemy > 0",
  "nEID ≥ 5", 98.0, 50, 51,
  "Oliver et al.",
  "Pest control & nImportantEnemy > 0",
  "nEID ≥ 10", 100.0, 25, 25,
  "Oliver et al.",
  "Pest control & nImportantEnemy > 0",
  "nEID ≥ 20", 100.0, 12, 12,
  
  # Martin et al.
  "Martin et al.",
  "Predator & Type = predator",
  "nEID ≥ 1", 98.0, 148, 151,
  "Martin et al.",
  "Predator & Type = predator",
  "nEID ≥ 3", 100.0, 56, 56,
  "Martin et al.",
  "Predator & Type = predator",
  "nEID ≥ 5", 100.0, 38, 38,
  "Martin et al.",
  "Predator & Type = predator",
  "nEID ≥ 10", 100.0, 27, 27,
  "Martin et al.",
  "Predator & Type = predator",
  "nEID ≥ 20", 100.0, 19, 19,
  
  "Martin et al.",
  "Parasitoid & Type = parasitoid or hyperparasitoid",
  "nEID ≥ 1", 100, 46, 46,
  "Martin et al.",
  "Parasitoid & Type = parasitoid or hyperparasitoid",
  "nEID ≥ 3", 100, 24, 24,
  "Martin et al.",
  "Parasitoid & Type = parasitoid or hyperparasitoid",
  "nEID ≥ 5", 100, 14, 14,
  "Martin et al.",
  "Parasitoid & Type = parasitoid or hyperparasitoid",
  "nEID ≥ 10", 100, 11, 11,
  "Martin et al.",
  "Parasitoid & Type = parasitoid or hyperparasitoid",
  "nEID ≥ 20", 100, 6, 6,
  
  "Martin et al.",
  "Herbivore & Type = herbivore",
  "nEID ≥ 1", 96.9, 126, 130,
  "Martin et al.",
  "Herbivore & Type = herbivore",
  "nEID ≥ 3", 100.0, 79, 79,
  "Martin et al.",
  "Herbivore & Type = herbivore",
  "nEID ≥ 5", 100.0, 55, 55,
  "Martin et al.",
  "Herbivore & Type = herbivore",
  "nEID ≥ 10", 100.0, 36, 36,
  "Martin et al.",
  "Herbivore & Type = herbivore",
  "nEID ≥ 20", 100.0, 27, 27,
  
  "Martin et al.",
  "Pest herbivore & nMajor > 0",
  "nEID ≥ 1", 100.0, 22, 22,
  "Martin et al.",
  "Pest herbivore & nMajor > 0",
  "nEID ≥ 3", 100.0, 22, 22,
  "Martin et al.",
  "Pest herbivore & nMajor > 0",
  "nEID ≥ 5", 100.0, 19, 19,
  "Martin et al.",
  "Pest herbivore & nMajor > 0",
  "nEID ≥ 10", 100.0, 16, 16,
  "Martin et al.",
  "Pest herbivore & nMajor > 0",
  "nEID ≥ 20", 100.0, 14, 14,
  
  "Martin et al.",
  "Non-pest herbivore & nMajor = 0",
  "nEID ≥ 1", 85.0, 51, 60,
  "Martin et al.",
  "Non-pest herbivore & nMajor = 0",
  "nEID ≥ 3", 76.5, 13, 17,
  "Martin et al.",
  "Non-pest herbivore & nMajor = 0",
  "nEID ≥ 5", 83.3, 5, 6,
  "Martin et al.",
  "Non-pest herbivore & nMajor = 0",
  "nEID ≥ 10", 100.0, 1, 1,
  "Martin et al.",
  "Non-pest herbivore & nMajor = 0",
  "nEID ≥ 20", NA, 0, 0,
  
  # EPPO
  "EPPO et al.",
  "Host or major host & nPest > 0",
  "nEID ≥ 1", 93.1, 1344, 1444,
  "EPPO et al.",
  "Host or major host & nPest > 0",
  "nEID ≥ 3", 99.5, 761, 765,
  "EPPO et al.",
  "Host or major host & nPest > 0",
  "nEID ≥ 5", 99.8, 551, 552,
  "EPPO et al.",
  "Host or major host & nPest > 0",
  "nEID ≥ 10", 100.0, 349, 349,
  "EPPO et al.",
  "Host or major host & nPest > 0",
  "nEID ≥ 20", 100.0, 229, 229,
  
  "EPPO et al.",
  "Major host & nMajor > 0",
  "nEID ≥ 1", 90.2, 388, 430,
  "EPPO et al.",
  "Major host & nMajor > 0",
  "nEID ≥ 3", 99.3, 290, 292,
  "EPPO et al.",
  "Major host & nMajor > 0",
  "nEID ≥ 5", 100.0, 227, 227,
  "EPPO et al.",
  "Major host & nMajor > 0",
  "nEID ≥ 10", 100.0, 160, 160,
  "EPPO et al.",
  "Major host & nMajor > 0",
  "nEID ≥ 20", 100.0, 113, 113,
  
  "EPPO et al.",
  "Major host & nPest > 0",
  "nEID ≥ 1", 97.7, 420, 430,
  "EPPO et al.",
  "Major host & nPest > 0",
  "nEID ≥ 3", 100.0, 292, 292,
  "EPPO et al.",
  "Major host & nPest > 0",
  "nEID ≥ 5", 100.0, 227, 227,
  "EPPO et al.",
  "Major host & nPest > 0",
  "nEID ≥ 10", 100.0, 160, 160,
  "EPPO et al.",
  "Major host & nPest > 0",
  "nEID ≥ 20", 100.0, 113, 113
)

# -------------------------------------------------------------------------
# 2. Comparison order 
# -------------------------------------------------------------------------

comparison_order <- c(
  "Pest control & nImportantEnemy > 0",
  "Predator & Type = predator",
  "Parasitoid & Type = parasitoid or hyperparasitoid",
  "Herbivore & Type = herbivore",
  "Pest herbivore & nMajor > 0",
  "Non-pest herbivore & nMajor = 0",
  "Host or major host & nPest > 0",
  "Major host & nMajor > 0",
  "Major host & nPest > 0"
)


# -------------------------------------------------------------------------
# 3. Comparison labels 
# -------------------------------------------------------------------------

comparison_labels <- c(
  "Pest control\n(nImportantEnemy > 0)",
  "Predator\n(Type = predator)",
  "Parasitoid\n(Type = (hyper)parasitoid)",
  "Herbivore\n(Type = herbivore)",
  "Pest herbivore\n(nMajor > 0)",
  "Non-pest herbivore\n(nMajor = 0)",
  "Host or major host\n(nPest > 0)",
  "Major host\n(nMajor > 0)",
  "Major host\n(nPest > 0)"
)


# -------------------------------------------------------------------------
# 4. Threshold order
# -------------------------------------------------------------------------

threshold_order <- c(
  "nEID ≥ 1",
  "nEID ≥ 3",
  "nEID ≥ 5",
  "nEID ≥ 10",
  "nEID ≥ 20"
)


# -------------------------------------------------------------------------
# 5. Format data
# -------------------------------------------------------------------------

dat <- dat %>%
  mutate(
    comparison = factor(
      comparison,
      levels = comparison_order
    ),
    
    nEID = factor(
      nEID,
      levels = threshold_order
    ),
    
    agreement_label = case_when(
      is.na(agreement) ~ "NA",
      agreement %% 1 == 0 ~ paste0(
        formatC(
          agreement,
          format = "f",
          digits = 0
        )
      ),
      TRUE ~ paste0(
        formatC(
          agreement,
          format = "f",
          digits = 1
        )
      )
    ),
    
    n_label = paste0(
      n_correct,
      " / ",
      n_total
    )
  )


# -------------------------------------------------------------------------
# 6. Create numeric x positions
# -------------------------------------------------------------------------

dat_plot <- dat %>%
  mutate(
    x = as.numeric(comparison),
    
    nEID = factor(
      nEID,
      levels = threshold_order
    ),
    
    # Fixed position for each nEID within every comparison
    dodge_x = x + c(
      "nEID ≥ 1"  = -0.30,
      "nEID ≥ 3"  = -0.15,
      "nEID ≥ 5"  =  0.00,
      "nEID ≥ 10" =  0.15,
      "nEID ≥ 20" =  0.30
    )[as.character(nEID)],
    
    n_label = paste0(
      n_correct,
      " / ",
      n_total
    )
  )


# -------------------------------------------------------------------------
# 7. Custom x-axis labels
# -------------------------------------------------------------------------

label_dat <- tibble(
  x = 1:9,
  label = list(
    bquote(atop("Pest control"^"\u2020", "(nImportant > 0)")),
    bquote(atop("Predator", "(Type = predator)")),
    bquote(atop("Parasitoid*", "(Type = (hyper)parasitoid)")),
    bquote(atop("Herbivore", "(Type = herbivore)")),
    bquote(atop("Pest herbivore", "(nMajor > 0)")),
    bquote(atop("Non-pest herbivore*", "(nMajor = 0)")),
    bquote(atop("Host or major host", "(nPest > 0)")),
    bquote(atop("Major host", "(nMajor > 0)")),
    bquote(atop("Major host", "(nPest > 0)"))
  )
)


# -------------------------------------------------------------------------
# 8. Source brackets
# -------------------------------------------------------------------------

source_groups <- tibble(
  source = c(
    "Oliver et al. (2015)",
    "Martin et al. (2019)",
    "EPPO (2026)"
  ),
  
  # Oliver = comparison 1
  # Martin = comparisons 2–6
  # EPPO = comparisons 7–9
  xmin = c(
    0.55,
    1.55,
    6.55
  ),
  
  xmax = c(
    1.45,
    6.45,
    9.45
  )
) %>%
  mutate(
    xmid = (xmin + xmax) / 2
  )


# -------------------------------------------------------------------------
# 9. Colours
# -------------------------------------------------------------------------

nEID_colours <- c(
  "nEID ≥ 1"  = "#C6DBEF",
  "nEID ≥ 3"  = "#9ECAE1",
  "nEID ≥ 5"  = "#6BAED6",
  "nEID ≥ 10" = "#4682B4",
  "nEID ≥ 20" = "#245A7A"
)


# -------------------------------------------------------------------------
# 10. Plot
# -------------------------------------------------------------------------

p_publication <- ggplot(
  dat_plot,
  aes(
    x = x,
    y = agreement,
    fill = nEID
  )
) +
  
# -----------------------------------------------------------------------
# Bars
# -----------------------------------------------------------------------
geom_rect(
  aes(
    xmin = dodge_x - 0.07,
    xmax = dodge_x + 0.07,
    ymin = 50,
    ymax = agreement
  ),
  colour = NA,
  na.rm = TRUE
) +
  
# -----------------------------------------------------------------------
# n_correct / n_total labels inside bars (Shifted to base at y = 61)
# -----------------------------------------------------------------------
geom_text(
  data = dat_plot %>%
    filter(n_total > 0),
  aes(
    x = dodge_x,
    y = 51,
    label = n_label
  ),
  angle = 90,
  hjust = 0,
  vjust = 0.5,
  size = 2.5,
  colour = "white",
  inherit.aes = FALSE
) +
  
# -----------------------------------------------------------------------
# Agreement labels above bars
# -----------------------------------------------------------------------
geom_text(
  aes(
    x = dodge_x,
    y = agreement,
    label = agreement_label
  ),
  vjust = -0.35,
  size = 2.3,
  colour = "grey25",
  fontface = "bold",
  na.rm = TRUE
) +
  
# -----------------------------------------------------------------------
# Comparison labels 
# -----------------------------------------------------------------------
geom_text(
  data = label_dat,
  aes(
    x = x-0.1,
    y = 44.5,
    label = label
  ),
  inherit.aes = FALSE,
  angle = 40,
  hjust = 0.5,
  vjust = 1,
  size = 3.2,
  lineheight = 0.95,
  colour = "grey10",
  parse = TRUE
) +
  
# -----------------------------------------------------------------------
# Source brackets (Shifted to clear the comparison labels)
# -----------------------------------------------------------------------
geom_segment(
  data = source_groups,
  aes(
    x = xmin,
    xend = xmax,
    y = 34,
    yend = 34
  ),
  inherit.aes = FALSE,
  linewidth = 0.55,
  colour = "grey10"
) +
  
  geom_segment(
    data = source_groups,
    aes(
      x = xmin,
      xend = xmin,
      y = 34,
      yend = 34.6
    ),
    inherit.aes = FALSE,
    linewidth = 0.55,
    colour = "grey10"
  ) +
  
  geom_segment(
    data = source_groups,
    aes(
      x = xmax,
      xend = xmax,
      y = 34,
      yend =34.6
    ),
    inherit.aes = FALSE,
    linewidth = 0.55,
    colour = "grey10"
  ) +
  
# -----------------------------------------------------------------------
# Source labels (Shifted below the brackets)
# -----------------------------------------------------------------------
geom_text(
  data = source_groups,
  aes(
    x = xmid,
    y = 31.5,
    label = source
  ),
  inherit.aes = FALSE,
  size = 4.0,
  colour = "grey10",
  fontface = "italic",
  hjust = 0.5
) +
  
# -----------------------------------------------------------------------
# Colours
# -----------------------------------------------------------------------
scale_fill_manual(
  values = nEID_colours,
  name = NULL
) +
  
# -----------------------------------------------------------------------
# X scale 
# -----------------------------------------------------------------------
scale_x_continuous(
  breaks = 1:9,
  labels = NULL,
  limits = c(0.5, 9.5),
  expand = c(0, 0)
) +
  
# -----------------------------------------------------------------------
# Y scale 
# -----------------------------------------------------------------------
scale_y_continuous(
  breaks = seq(50, 100, 10),
  expand = c(0, 0)
) +
  
  labs(
    x = NULL,
    y = "Agreement (%)"
  ) +
  
# -----------------------------------------------------------------------
# Zero line 
# -----------------------------------------------------------------------
geom_segment(
  aes(
    x = 0.5,
    xend = 9.5,
    y = 50,
    yend = 50
  ),
  inherit.aes = FALSE,
  linewidth = 0.4,
  colour = "grey45"
) +
  
# -----------------------------------------------------------------------
# Y-axis 
# -----------------------------------------------------------------------
geom_segment(
  aes(
    x = 0.5,
    xend = 0.5,
    y = 50,
    yend = 100
  ),
  inherit.aes = FALSE,
  linewidth = 0.35,
  colour = "grey35"
) +
  
# -----------------------------------------------------------------------
# Theme
# -----------------------------------------------------------------------
theme_minimal(base_size = 12) +
  
  theme(
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank(),
    
    panel.grid.major.y = element_line(
      linewidth = 0.25,
      colour = "grey88"
    ),
    
    axis.line.y = element_blank(),
    
    axis.ticks.y = element_line(
      linewidth = 0.3,
      colour = "grey45"
    ),
    
    axis.text.y = element_text(
      size = 10,
      colour = "grey20"
    ),
    
    axis.title.y = element_text(
      size = 12,
      colour = "grey15",
      margin = margin(r = 8)
    ),
    
    axis.text.x = element_blank(),
    axis.ticks.x = element_blank(),
    
    legend.position = "top",
    legend.direction = "horizontal",
    
    legend.text = element_text(
      size = 10
    ),
    
    legend.key.width = unit(0.8, "cm"),
    
    legend.margin = margin(b = 4),
    
    # Bottom margin increased to prevent margins clipping the shifted text
    plot.margin = margin(
      t = 5,
      r = 10,
      b = 115,
      l = 10
    )
  ) +
  
  # -----------------------------------------------------------------------
# Cartesian Coordinates (Enforces viewport limits without data loss)
# -----------------------------------------------------------------------
coord_cartesian(
  ylim = c(50, 100),
  clip = "off"
)

p_publication

ggsave(
  "figures/sources_comparison.pdf",
  p_publication,
  width = 12,
  height = 6,
  units = "in",
  device = cairo_pdf
)
   
