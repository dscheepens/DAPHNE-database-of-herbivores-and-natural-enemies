################################################################################
#                                                                              #
#   Agreement between DAPHNE and independent classifications                   #
#                                                                              #
#   1. Setup and helpers                                                       #
#   2. Oliver et al. (2015): pest control agents                               #
#   3. Martin et al. (2019): herbivores, pests, predators, parasitoids         #
#   4. EPPO global database: crop hosts of pests                               #
#   5. Agreement summary and figure                                            #
#                                                                              #
#   Each comparison is evaluated for species with at least `thresholds`        #
#   abstracts (nEID) in DAPHNE.                                                #
#                                                                              #
################################################################################

library(tidyverse)
library(readxl)

data_dir <- "other_sources/"
eppo_dir <- "other_sources/EPPO_crop_pests/" # bacterial, viral and fungal pathogens were manually removed from these files

thresholds <- c(1, 3, 5, 10, 20)



################################################################################
#                          1. Setup and helpers                                #
################################################################################

interactions_df <- readRDS("../DAPHNE.rds") %>%
  mutate(across(c(Type, Feeding.Mode, Pest, Pest.Importance, Herbivore.IsBCA, Important.Enemy, Biocontrol), as.factor))

# Keep species-level Subjects only, dropping subspecies (first two words)
species_level <- function(df) {
  df %>%
    filter(str_count(Subject, "\\w+") > 1) %>%
    mutate(Subject = word(Subject, 1, 2))
}

# TRUE where the Subject, or one of its synonyms, is in `ref`
in_list <- function(subject, synonyms, ref) {
  subject %in% ref | map_lgl(synonyms, ~ any(.x %in% ref))
}

# Per-species summary for species in `ref`, with the combination of roles
# (`role` = Type or Feeding.Mode) they appear in, e.g. "herbivore + natural enemy"
summarise_roles <- function(df, role, ref) {
  df %>%
    group_by(Subject, role = {{ role }}) %>%
    summarise(nEID     = n_distinct(EID),
              nPest    = n_distinct(EID[Pest == TRUE & !is.na(Pest)]),
              nMajor   = n_distinct(EID[Pest.Importance == "major" & !is.na(Pest.Importance)]),
              Synonyms = list(unique(unlist(Subject.Synonyms))),
              .groups = "drop") %>%
    group_by(Subject) %>%
    summarise(Types    = paste(sort(role), collapse = " + "),
              nEID     = sum(nEID),
              nPest    = sum(nPest),
              nMajor   = sum(nMajor),
              Synonyms = list(unique(unlist(Synonyms))),
              .groups = "drop") %>%
    filter(in_list(Subject, Synonyms, ref))
}

# Number of abstracts per species in each role
eid_counts <- function(df) {
  df %>%
    group_by(Subject) %>%
    summarise(nEID.Enemy     = n_distinct(EID[Type == "natural enemy"]),
              nEID.Herbivore = n_distinct(EID[Type == "herbivore"]),
              nPest          = n_distinct(EID[Pest == TRUE & !is.na(Pest)]),
              nMajor         = n_distinct(EID[Pest.Importance == "major" & !is.na(Pest.Importance)]),
              .groups = "drop")
}

# Number of species per combination of values in `col`
count_combinations <- function(df, col) {
  df %>%
    distinct(Subject, {{ col }}) %>%
    group_by(Subject) %>%
    summarise(Types = paste(sort({{ col }}), collapse = " + "), .groups = "drop") %>%
    count(Types, name = "Unique_Species_Count") %>%
    arrange(desc(Unique_Species_Count))
}

stat_mode <- function(x) as.numeric(names(which.max(table(x))))

# Agreement at each nEID threshold; `is_correct` maps the filtered summary to a logical vector
agreement <- function(summary, is_correct, source, comparison) {
  map_dfr(thresholds, function(k) {
    d <- filter(summary, nEID >= k)
    tibble(source = source, comparison = comparison, min_nEID = k,
           n_correct = sum(is_correct(d)), n_total = nrow(d))
  })
}


species_df <- species_level(interactions_df)



################################################################################
#               2. Oliver et al. (2015): pest control agents                   #
################################################################################

oliver <- read_excel(paste0(data_dir, "Data_associated_with_paper_Declining_resilience_of_ecosystem_functions_under_biodiversity_loss/41467_2015_BFncomms10122_MOESM1630_ESM.xlsx"), skip = 1)

pc_list <- oliver %>% filter(`Pest control` %in% "1") %>% pull(`Species name`)
pc_list[str_count(pc_list, "\\w+") != 2] # "Aelurillus v-insignitus" "Pardosa saltans/lugubris" "Zygiella x-notata"
pc_list[pc_list == "Pardosa saltans/lugubris"] <- "Pardosa lugubris"

# nEID is summed over prey, i.e. counts (prey, abstract) pairs
pc_summary <- interactions_df %>%
  filter(Type == "natural enemy") %>%
  species_level() %>%
  mutate(Object = if_else(str_count(Object, "\\w+") > 2, word(Object, 1, 2), Object)) %>%
  group_by(Subject, Object) %>%
  summarise(nEID            = n_distinct(EID),
            nImportantEnemy = n_distinct(EID[Important.Enemy == TRUE & !is.na(Important.Enemy)]),
            nBiocontrol     = n_distinct(EID[Biocontrol == TRUE & !is.na(Biocontrol)]),
            Synonyms        = list(unique(unlist(Subject.Synonyms))),
            .groups = "drop") %>%
  group_by(Subject) %>%
  summarise(nEID            = sum(nEID),
            nImportantEnemy = sum(nImportantEnemy),
            nBiocontrol     = sum(nBiocontrol),
            Synonyms        = list(unique(unlist(Synonyms))),
            .groups = "drop") %>%
  filter(in_list(Subject, Synonyms, pc_list))

# share of pest control agents flagged as biocontrol agents / important enemies
map_dfr(thresholds, function(k) {
  d <- filter(pc_summary, nEID >= k)
  tibble(min_nEID = k, n = nrow(d),
         pct_biocontrol = round(100 * mean(d$nBiocontrol > 0), 1),
         pct_important  = round(100 * mean(d$nImportantEnemy > 0), 1))
})

# species not flagged as important enemies are rarely mentioned
not_important <- pc_summary %>% filter(nImportantEnemy == 0)
important     <- pc_summary %>% filter(nImportantEnemy > 0)
c(mean = mean(not_important$nEID), median = median(not_important$nEID), n_single = sum(not_important$nEID == 1))
c(mean = mean(important$nEID), median = median(important$nEID))

agreement_oliver <- agreement(pc_summary, \(d) d$nImportantEnemy > 0,
                              "Oliver et al.", "Pest control & nImportantEnemy > 0")



################################################################################
#        3. Martin et al. (2019): herbivores, pests, predators, parasitoids    #
################################################################################

martin <- read_excel(paste0(data_dir, "Data_associated_with_paper_The_interplay_of_landscape_composition_and_configuration/Martin+et+al_2019_traits+database_300319.xlsx"), skip = 3)

martin_species <- function(groups) {
  martin %>%
    filter(Functional_group %in% groups, str_count(SpeciesID, "\\w+") > 1) %>%
    mutate(SpeciesID = word(SpeciesID, 1, 2)) %>%
    pull(SpeciesID)
}

pest_list       <- martin_species(c("pest herbivore", "larval pest herbivore, adult pollinator (adults)", "larval pest herbivore, adult pollinator"))
nonpest_list    <- martin_species(c("non-pest herbivore", "larval non-pest herbivore, adult pollinator"))
predator_list   <- martin_species(c("predator", "aphid-tender, predator", "larval predator, adult pollinator"))
parasitoid_list <- martin_species(c("parasitoid", "parasitoid of bees", "larval parasitoid, adult pollinator"))


# --- 3a. Herbivores (pest and non-pest): classified as herbivore? ---

herbivore_types <- summarise_roles(species_df, Type, c(pest_list, nonpest_list))
count(herbivore_types, Types, name = "Unique_Species_Count") %>% arrange(desc(Unique_Species_Count))

agreement_herbivores <- agreement(herbivore_types, \(d) str_detect(d$Types, "herbivore"),
                                  "Martin et al.", "Herbivore & Type = herbivore")


# --- 3b. Pest herbivores: flagged as a major pest? ---

herbivore_pests <- summarise_roles(species_df, Type, pest_list)

agreement_pests <- agreement(herbivore_pests, \(d) d$nMajor > 0,
                             "Martin et al.", "Pest herbivore & nMajor > 0")

pest_rows <- species_df %>% filter(in_list(Subject, Subject.Synonyms, pest_list))
table(pest_rows$Type)
count_combinations(pest_rows, Type) # herbivore 20, herbivore + natural enemy 2

pest_counts <- eid_counts(pest_rows)
map_int(thresholds, ~ sum(pest_counts$nPest >= .x)) # species with >= k pest mentions
summarise(pest_counts, across(-Subject, list(median = median, mean = mean)))
c(mode_nPest = stat_mode(pest_counts$nPest), mode_nMajor = stat_mode(pest_counts$nMajor))

# Both are omnivorous mirids:
# Lygus pratensis - zoophytophagous, predates on Aphis gossypii and Helicoverpa armigera
# Adelphocoris lineolatus - also feeds on Acyrthosiphon pisum, Empoasca fabae and Hypera postica
pest_counts %>% filter(Subject %in% c("Lygus pratensis", "Adelphocoris lineolatus"))


# --- 3c. Non-pest herbivores: not flagged as a major pest? ---

herbivore_nonpests <- summarise_roles(species_df, Type, nonpest_list)

# Non-pests that are in fact pests, verified manually from the abstracts and literature
verified_pests <- c("Tribolium castaneum",           # red flour beetle - major agricultural and stored-product pest
                    "Apolygus lucorum",              # small green plant bug - major agricultural pest
                    "Hypera postica",                # alfalfa beetle - major pest of legume crops
                    "Psylliodes chrysocephalus",     # cabbage stem flea beetle - major agricultural pest
                    "Ceutorhynchus obstrictus",      # cabbage seedpod weevil - major agricultural pest
                    "Hebata vitis",                  # vine leafhopper - significant vineyard pest
                    "Phyllotreta cruciferae",        # crucifer flea beetle - major agricultural pest
                    "Sitona lineatus",               # pea leaf beetle - major pest of legumes and pulses
                    "Sitona obsoletus",              # clover root weevil - major forage and pasture pest
                    "Agriotes sputator",             # wireworm - major pest
                    "Philaenus spumarius",           # vector of Xylella fastidiosa - major concern
                    "Calliptamus italicus",          # italian locust - major grassland pest
                    "Trigonotylus caelestialium",    # rice leaf bug - major rice/cereal pest
                    "Cicadella viridis",             # serious bamboo pest
                    "Phyllotreta undulata",          # chinese cabbage flea beetle - major cabbage pest
                    "Dolycoris baccarum",            # serious pest that affects soybean and other field crops
                    "Psammotettix alienus",          # striped grain leafhopper - major cereal pest and vector of Wheat Dwarf Virus
                    "Brassicogethes viridescens",    # pollen beetle - major pest of canola and other brassica crops
                    "Phyllotreta vittula",           # flea beetle - major agricultural pest
                    "Zabrus tenebrioides",           # cereal ground beetle - major grain pest
                    "Sitona hispidulus",             # clover root curculio - major forage pest (e.g. alfalfa)
                    "Aiolopus thalassinus",          # major pest of maize, alfalfa, millet, wheat, berseem, vegetables and grasses
                    "Aphthona euphorbiae",           # major pest of flax
                    "Apolygus spinolae",             # green pale plant bug - major pest
                    "Eurygaster testudinaria",       # Sunn pest, "one of the most economic pests that attack and cause serious damage to wheat and barley grains"
                    "Neophilaenus campestris",       # serious threat to olives, almonds and grapevines, vector of Xylella fastidiosa
                    "Orchestes fagi",                # beech flea weevil - not a crop pest but a pest of European beech
                    "Sitona humeralis",              # major pest of alfalfa
                    "Atomaria linearis",             # pygmy mangold beetle - major cash crop pest
                    "Brachypera zoilus",             # aka Hypera punctata - stated as an important agricultural pest
                    "Chaetocnema aridula",           # cereal stem flea beetle - major cereal pest
                    "Chaetocnema concinna",          # mangold flea beetle - pest of sugar and fodder beet
                    "Curculio glandium",             # widespread acorn pest
                    "Harpalus rufipes",              # also a beneficial predator, but stated as a major pest of wheat and grasses and injurious to strawberry
                    "Hebata solani",                 # stated as needing to be managed in orchards
                    "Hypera nigrirostris",           # lesser clover leaf beetle - major clover pest
                    "Liocoris tripustulatus",        # major pest of greenhouse vegetables
                    "Piezodorus lituratus",          # stated to be a serious problem in red lentils
                    "Vanessa cardui",                # stated to be a pest of soybean and "a major pest of corn and soybeans in Iowa"
                    "Zygina flammigera",             # major forestry pest
                    "Evacanthus interruptus",        # one of "the most important leafhopper pests worldwide"
                    "Exomias pellucidus",            # root weevil stated as a strawberry pest in need of control
                    "Glischrochilus quadrisignatus", # tomato pest
                    "Plagiognathus chrysanthemi",    # pest of birdsfoot trefoil (pasture forage crop)
                    "Stictocephala bisonia",         # major jujube pest
                    "Thymelicus lineola",            # mentioned as an agricultural pest in Quebec needing to be controlled
                    "Zyginidia scutellaris",         # maize pest
                    "Hebata decipiens")              # widespread and polyphagous pest of several major crops

# Non-pests flagged by DAPHNE where the pest status could not be confirmed (kept as non-pests)
verified_nonpests <- c("Phyllotreta nigripes",  # potentially harmful flea beetle mentioned in association with important pests
                       "Javesella pellucida",   # wheat pest, but not clear that it is of major importance
                       "Macrosteles laevis",    # wheat pest, but not clear that it is of major importance
                       "Colias erate",          # not clear that it is a major pest
                       "Larinus planus",        # weed biocontrol weevil predating native thistles
                       "Aphrodes bicincta",     # subject of a trial but not because of its pest status
                       "Curculio venosus",      # infesting oak trees but not clear that it's an important pest
                       "Gryllus campestris",    # mentioned as pest but not clear that it's an important pest
                       "Typhlocyba quercus")    # only stated as a potential vector of tomato stolbur disease

true_nonpests <- herbivore_nonpests %>% filter(!Subject %in% verified_pests)
c(mean = mean(true_nonpests$nEID), median = median(true_nonpests$nEID))

agreement_nonpests <- agreement(true_nonpests, \(d) d$nMajor == 0,
                                "Martin et al.", "Non-pest herbivore & nMajor = 0")

nonpest_rows <- species_df %>% filter(in_list(Subject, Subject.Synonyms, nonpest_list))
table(nonpest_rows$Type)
count_combinations(nonpest_rows, Type) # herbivore 96, herbivore + natural enemy 8, natural enemy 4

nonpest_counts <- eid_counts(nonpest_rows)
nonpest_counts %>% arrange(desc(nEID.Herbivore))
c(pct_pest = round(100 * mean(nonpest_counts$nPest > 0), 1), pct_major = round(100 * mean(nonpest_counts$nMajor > 0), 1))
summarise(nonpest_counts, across(-Subject, list(median = median, mean = mean)))
c(mode_nPest = stat_mode(nonpest_counts$nPest), mode_nMajor = stat_mode(nonpest_counts$nMajor))

# Non-pests classified as herbivore + natural enemy:
# Tribolium castaneum        - worldwide stored-product pest; one abstract shows intraguild predation between Tribolium species
# Apolygus lucorum           - consistently an important pest (e.g. of apple in China), omnivorous, feeds on Helicoverpa armigera (2-s2.0-84878875761)
# Harpalus rufipes           - predominantly a natural enemy, but a pest of wheat and grasses (2-s2.0-85118942123) and strawberries (2-s2.0-84993843470, 2-s2.0-33751004384)
# Harpalus affinis           - predominantly a natural enemy
# Plagiognathus chrysanthemi - pest of birdsfoot trefoil (2-s2.0-0025527945) and strawberries (2-s2.0-0033923192), predates on A. pisum, E. fabae and H. postica
# Amara similata             - carabid predator
# Tettigonia viridissima     - minor pest in energy crops (2-s2.0-85179485142), predator of Obolodiplosis robiniae (2-s2.0-79961155405)
# Amara aenea                - predator, e.g. of apple maggot (2-s2.0-0040041164)
nonpest_counts %>%
  filter(Subject %in% c("Tribolium castaneum", "Apolygus lucorum", "Harpalus rufipes", "Harpalus affinis",
                        "Plagiognathus chrysanthemi", "Amara similata", "Tettigonia viridissima", "Amara aenea")) %>%
  arrange(desc(nEID.Herbivore))

# Non-pests classified as natural enemy only:
# Amara bifrons          - predator of the cabbage maggot, Delia radicum (2-s2.0-3142699420)
# Amara familiaris       - common ground-foraging aphid predator (2-s2.0-0033135852)
# Amara ovata            - predator of pollen beetle (2-s2.0-84963612982)
# Harpalus distinguendus - predator of pollen beetle (2-s2.0-84963612982)
nonpest_counts %>%
  filter(Subject %in% c("Amara bifrons", "Amara familiaris", "Amara ovata", "Harpalus distinguendus")) %>%
  arrange(desc(nEID.Enemy))

# Non-pest herbivores without any pest mention, plus manually verified non-pests.
# Excluded: T. castaneum, A. lucorum, H. rufipes, P. chrysanthemi (pest evidence)
# and the four Amara/Harpalus species above (predominantly natural enemies).
verified_nonpest_herbivores <- c(nonpest_counts %>% filter(nPest == 0) %>% pull(Subject),
                                 "Larinus planus", "Thymelicus lineola", "Pieris napi", "Sphaeroderma rubidum", "Papilio machaon", "Typhlocyba quercus")

mean(nonpest_counts %>% filter(Subject %in% verified_nonpest_herbivores) %>% pull(nEID.Herbivore))


# --- 3d. Predators: classified as predator? ---

predator_types <- summarise_roles(species_df, Feeding.Mode, predator_list)
count(predator_types, Types, name = "Unique_Species_Count") %>% arrange(desc(Unique_Species_Count))

agreement_predators <- agreement(predator_types, \(d) str_detect(d$Types, "predation"),
                                 "Martin et al.", "Predator & Type = predator")

# note: matched on Subject only (not synonyms)
predator_rows <- species_df %>% filter(Subject %in% predator_list)
table(predator_rows$Type)
table(predator_rows$Feeding.Mode)
count_combinations(predator_rows, Type)         # natural enemy 139, herbivore + natural enemy 3, herbivore 2
count_combinations(predator_rows, Feeding.Mode)

predator_counts <- eid_counts(predator_rows)
summarise(predator_counts, across(-Subject, list(median = median, mean = mean)))
stat_mode(predator_counts$nEID.Enemy)

predator_counts %>% arrange(desc(nEID.Herbivore))
predator_counts %>% filter(nEID.Enemy < nEID.Herbivore) %>% pull(Subject) # Kleidocerys resedae, Subcoccinella vigintiquatuorpunctata

# Harmonia axyridis                    - single pest evidence: a minor fruit pest (2-s2.0-2342631295)
# Pterostichus melanarius              - single pest evidence relates to crop seed predation (2-s2.0-85064862082)
# Forficula auricularia                - European earwig, omnivorous, stated as a pest in some cases (e.g. 2-s2.0-84976402516)
# Kleidocerys resedae                  - no evidence of predation could be found
# Subcoccinella vigintiquatuorpunctata - unlike other ladybirds not predatory but herbivorous
predator_counts %>%
  filter(Subject %in% c("Forficula auricularia", "Subcoccinella vigintiquatuorpunctata", "Pterostichus melanarius", "Harmonia axyridis", "Kleidocerys resedae")) %>%
  arrange(desc(nEID.Enemy))

# Larval ectoparasitoids among the predators (three rove beetles):
# Aleochara sparsa      - parasite of carrot fly, Psila rosae (2-s2.0-84980113063)
# Aleochara bipustulata - parasitoid rove beetle in agroecosystems (2-s2.0-63849275716)
# Aleochara bilineata   - parasitoid of root maggots, Delia spp. (2-s2.0-77958151917)

n_distinct(predator_rows$Subject)


# --- 3e. Parasitoids: classified as (hyper)parasitoid? ---

# Oscinella frit (major agricultural pest) and Trogoderma glabrum (stored-product
# pest, 2-s2.0-20444415047): no evidence found for acting as parasitoids
not_parasitoids <- c("Oscinella frit", "Trogoderma glabrum")

parasitoid_types <- summarise_roles(species_df, Feeding.Mode, parasitoid_list) %>%
  filter(!Subject %in% not_parasitoids)
count(parasitoid_types, Types, name = "Unique_Species_Count") %>% arrange(desc(Unique_Species_Count))

agreement_parasitoids <- agreement(parasitoid_types, \(d) str_detect(d$Types, "parasitism"), # also matches hyperparasitism
                                   "Martin et al.", "Parasitoid & Type = parasitoid or hyperparasitoid")

parasitoid_rows <- species_df %>% filter(in_list(Subject, Subject.Synonyms, parasitoid_list))
table(parasitoid_rows$Type)
table(parasitoid_rows$Feeding.Mode)
count_combinations(parasitoid_rows, Type)         # natural enemy 46, herbivore 2
count_combinations(parasitoid_rows, Feeding.Mode)

parasitoid_counts <- eid_counts(parasitoid_rows)
summarise(parasitoid_counts, across(-Subject, list(median = median, mean = mean)))
stat_mode(parasitoid_counts$nEID.Enemy)

parasitoid_counts %>% filter(nEID.Enemy < nEID.Herbivore) # Oscinella frit, Trogoderma glabrum



################################################################################
#              4. EPPO global database: crop hosts of pests                    #
################################################################################

source("crop_definitions.r") # crop_lookup: crop name patterns shared by all scripts

# Herbivore-crop pairs in DAPHNE (host plant matched to a crop by name pattern)
herbivore_summary <- interactions_df %>%
  filter(Type == "herbivore") %>%
  species_level() %>%
  cross_join(crop_lookup) %>%
  filter(str_detect(tolower(Object), pattern)) %>%
  group_by(Subject, crop_name) %>%
  summarise(nEID     = n_distinct(EID),
            nPest    = n_distinct(EID[Pest == TRUE & !is.na(Pest)]),
            nMajor   = n_distinct(EID[Pest.Importance == "major" & !is.na(Pest.Importance)]),
            Synonyms = list(unique(unlist(Subject.Synonyms))),
            .groups = "drop")

# EPPO file names that differ from the crop name (or that are split over several host species)
eppo_files <- list(
  `oil palm` = "oilpalm",
  coffee  = c("coffee_Coffea-arabica", "coffee_Coffea-canephora"),
  millet  = c("millet_Cenchrus-americanus", "millet_Panicum-miliaceum", "millet_Setaria-italica"),
  mustard = c("mustard_Brassica-carinata", "mustard_Brassica-juncea", "mustard_Brassica-nigra")
)

# EPPO pests recorded on a crop as "Host" or "Major host" (NULL if there is no file)
read_eppo_pests <- function(crop) {
  paths <- paste0(eppo_dir, "pests_", eppo_files[[crop]] %||% gsub(" ", "_", crop), ".csv")
  paths <- paths[file.exists(paths)]
  if (length(paths) == 0) {
    message("no EPPO file for ", crop)
    return(NULL)
  }
  map_dfr(paths, ~ read_csv(.x, show_col_types = FALSE) %>% dplyr::select(type, Pref_name)) %>%
    filter(type %in% c("Host", "Major host")) %>%
    transmute(type, Match_Key = word(Pref_name, 1, 2)) %>%
    distinct()
}

# DAPHNE herbivore-crop pairs whose herbivore (or a synonym) is an EPPO pest of that crop
eppo_matches <- map_dfr(crop_lookup$crop_name, function(crop) {
  crop_pests <- read_eppo_pests(crop)
  if (is.null(crop_pests)) return(NULL)
  herbivore_summary %>%
    filter(crop_name == crop) %>%
    mutate(Match_Key = map2_chr(Subject, Synonyms, ~ {
      all_names <- c(.x, unlist(.y))
      all_names[all_names %in% crop_pests$Match_Key][1]
    })) %>%
    inner_join(crop_pests, by = "Match_Key", relationship = "many-to-many") %>%
    dplyr::select(-Match_Key)
})

agreement_eppo <- bind_rows(
  agreement(eppo_matches, \(d) d$nPest > 0,
            "EPPO", "Host or major host & nPest > 0"),
  agreement(eppo_matches %>% filter(type == "Major host"), \(d) d$nMajor > 0,
            "EPPO", "Major host & nMajor > 0"),
  agreement(eppo_matches %>% filter(type == "Major host"), \(d) d$nPest > 0,
            "EPPO", "Major host & nPest > 0")
)


# --- Per-crop results (nEID >= 1) ---

eppo_results <- eppo_matches %>%
  group_by(crop = factor(crop_name, levels = crop_lookup$crop_name)) %>%
  summarise(
    totHosts               = n(),
    totMajorHosts          = sum(type == "Major host"),
    rec.hosts              = mean(nPest > 0),
    rec.majorhosts         = mean(nMajor[type == "Major host"] > 0),
    rec.majorhosts.nPest   = mean(nPest[type == "Major host"] > 0),
    mean.nEID.Hosts        = mean(nEID[type == "Host"]),
    mean.nEID.MajorHosts   = mean(nEID[type == "Major host"]),
    mean.nPest.Hosts       = mean(nPest[type == "Host"]),
    mean.nPest.MajorHosts  = mean(nPest[type == "Major host"]),
    mean.nMajor.Hosts      = mean(nMajor[type == "Host"]),
    mean.nMajor.MajorHosts = mean(nMajor[type == "Major host"]),
    .groups = "drop"
  )

knitr::kable(eppo_results %>%
               mutate(across(starts_with("rec."), ~ round(100 * .x, 1)),
                      across(starts_with("mean."), ~ round(.x, 1))) %>%
               dplyr::select(`Crop name`             = crop,
                             `$n$ Hosts`             = totHosts,
                             `$n$ Major hosts`       = totMajorHosts,
                             `Host recall`           = rec.hosts,
                             `MajorHost recall`      = rec.majorhosts,
                             `MajorHost recall*`     = rec.majorhosts.nPest,
                             `mean(nPest.Host)`      = mean.nPest.Hosts,
                             `mean(nPest.MajorHost)` = mean.nPest.MajorHosts,
                             `mean(nEID.Host)`       = mean.nEID.Hosts,
                             `mean(nEID.MajorHost)`  = mean.nEID.MajorHosts),
             format = "latex")


# --- Hosts vs major hosts, and matched vs missed major hosts ---

summarise_species <- function(subjects) {
  herbivore_summary %>%
    filter(Subject %in% subjects) %>%
    group_by(Subject) %>%
    summarise(nEID = sum(nEID), nPest = sum(nPest), nMajor = sum(nMajor), .groups = "drop")
}

major <- eppo_matches %>% filter(type == "Major host")

hosts              <- eppo_matches %>% filter(type == "Host") %>% pull(Subject)
majorhosts         <- major %>% pull(Subject)
majorhosts.matched <- major %>% filter(nMajor > 0) %>% pull(Subject)
majorhosts.missed  <- major %>% filter(nMajor == 0) %>% pull(Subject)

c(hosts = length(hosts), majorhosts = length(majorhosts))

map_dfr(list(hosts = hosts, majorhosts = majorhosts, majorhosts.matched = majorhosts.matched, majorhosts.missed = majorhosts.missed),
        ~ summarise_species(.x) %>% summarise(mean_nEID = mean(nEID), median_nEID = median(nEID),
                                              mean_nPest = mean(nPest), median_nPest = median(nPest)),
        .id = "group")



################################################################################
#                    5. Agreement summary and figure                           #
################################################################################

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

threshold_order <- paste0("nEID ≥ ", thresholds)

dat <- bind_rows(agreement_oliver, agreement_predators, agreement_parasitoids, agreement_herbivores,
                 agreement_pests, agreement_nonpests, agreement_eppo) %>%
  mutate(
    agreement       = if_else(n_total > 0, round(100 * n_correct / n_total, 1), NA_real_),
    comparison      = factor(comparison, levels = comparison_order),
    nEID            = factor(paste0("nEID ≥ ", min_nEID), levels = threshold_order),
    agreement_label = case_when(is.na(agreement)   ~ "NA",
                                agreement %% 1 == 0 ~ formatC(agreement, format = "f", digits = 0),
                                TRUE                ~ formatC(agreement, format = "f", digits = 1)),
    n_label         = paste0(n_correct, " / ", n_total)
  ) %>%
  arrange(comparison, nEID)

print(dat %>% dplyr::select(source, comparison, nEID, agreement, n_correct, n_total), n = Inf)

# Overall EPPO recall: hosts and major hosts of all EPPO crops pooled
# (equal to the nEID >= 1 rows of the EPPO comparisons above)
eppo_major <- eppo_matches %>% filter(type == "Major host")
eppo_recall <- tibble(
  comparison = c("Host or major host & nPest > 0", "Major host & nMajor > 0", "Major host & nPest > 0"),
  n_correct  = c(sum(eppo_matches$nPest > 0), sum(eppo_major$nMajor > 0), sum(eppo_major$nPest > 0)),
  n_total    = c(nrow(eppo_matches), nrow(eppo_major), nrow(eppo_major))
) %>%
  mutate(recall = round(100 * n_correct / n_total, 1))

print(eppo_recall)


# --- Plot layout ---

# x position of each bar: one group per comparison, bars dodged by threshold
dat_plot <- dat %>%
  mutate(x = as.numeric(comparison),
         dodge_x = x + setNames(seq(-0.30, 0.30, by = 0.15), threshold_order)[as.character(nEID)])

# x-axis labels († and * are explained in the figure caption)
label_dat <- tibble(
  x = 1:9,
  label = list(
    bquote(atop("Pest control"^"†", "(nImportant > 0)")),
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

# brackets grouping comparisons by source: Oliver = 1, Martin = 2-6, EPPO = 7-9
source_groups <- tibble(
  source = c("Oliver et al. (2015)", "Martin et al. (2019)", "EPPO (2026)"),
  xmin   = c(0.55, 1.55, 6.55),
  xmax   = c(1.45, 6.45, 9.45)
) %>%
  mutate(xmid = (xmin + xmax) / 2)

nEID_colours <- setNames(c("#C6DBEF", "#9ECAE1", "#6BAED6", "#4682B4", "#245A7A"), threshold_order)


# --- Plot ---

p_publication <- ggplot(dat_plot, aes(x = x, y = agreement, fill = nEID)) +

  # bars (starting at 50%)
  geom_rect(aes(xmin = dodge_x - 0.07, xmax = dodge_x + 0.07, ymin = 50, ymax = agreement),
            colour = NA, na.rm = TRUE) +

  # n_correct / n_total inside bars
  geom_text(data = dat_plot %>% filter(n_total > 0),
            aes(x = dodge_x, y = 51, label = n_label),
            angle = 90, hjust = 0, vjust = 0.5, size = 2.5, colour = "white", inherit.aes = FALSE) +

  # agreement above bars
  geom_text(aes(x = dodge_x, y = agreement, label = agreement_label),
            vjust = -0.35, size = 2.3, colour = "grey25", fontface = "bold", na.rm = TRUE) +

  # comparison labels below the axis
  geom_text(data = label_dat, aes(x = x - 0.1, y = 44.5, label = label), inherit.aes = FALSE,
            angle = 40, hjust = 0.5, vjust = 1, size = 3.2, lineheight = 0.95, colour = "grey10", parse = TRUE) +

  # source brackets and labels
  geom_segment(data = source_groups, aes(x = xmin, xend = xmax, y = 34, yend = 34),
               inherit.aes = FALSE, linewidth = 0.55, colour = "grey10") +
  geom_segment(data = source_groups, aes(x = xmin, xend = xmin, y = 34, yend = 34.6),
               inherit.aes = FALSE, linewidth = 0.55, colour = "grey10") +
  geom_segment(data = source_groups, aes(x = xmax, xend = xmax, y = 34, yend = 34.6),
               inherit.aes = FALSE, linewidth = 0.55, colour = "grey10") +
  geom_text(data = source_groups, aes(x = xmid, y = 31.5, label = source), inherit.aes = FALSE,
            size = 4.0, colour = "grey10", fontface = "italic", hjust = 0.5) +

  # axes
  annotate("segment", x = 0.5, xend = 9.5, y = 50, yend = 50, linewidth = 0.4, colour = "grey45") +
  annotate("segment", x = 0.5, xend = 0.5, y = 50, yend = 100, linewidth = 0.35, colour = "grey35") +

  scale_fill_manual(values = nEID_colours, name = NULL) +
  scale_x_continuous(breaks = 1:9, labels = NULL, limits = c(0.5, 9.5), expand = c(0, 0)) +
  scale_y_continuous(breaks = seq(50, 100, 10), expand = c(0, 0)) +
  labs(x = NULL, y = "Agreement (%)") +

  theme_minimal(base_size = 12) +
  theme(
    panel.grid.major.x = element_blank(),
    panel.grid.minor   = element_blank(),
    panel.grid.major.y = element_line(linewidth = 0.25, colour = "grey88"),
    axis.line.y        = element_blank(),
    axis.ticks.y       = element_line(linewidth = 0.3, colour = "grey45"),
    axis.text.y        = element_text(size = 10, colour = "grey20"),
    axis.title.y       = element_text(size = 12, colour = "grey15", margin = margin(r = 8)),
    axis.text.x        = element_blank(),
    axis.ticks.x       = element_blank(),
    legend.position    = "top",
    legend.direction   = "horizontal",
    legend.text        = element_text(size = 10),
    legend.key.width   = unit(0.8, "cm"),
    legend.margin      = margin(b = 4),
    plot.margin        = margin(t = 5, r = 10, b = 115, l = 10) # room for the labels below the axis
  ) +

  # limit the view to 50-100% without dropping data, and allow drawing outside the panel
  coord_cartesian(ylim = c(50, 100), clip = "off")

p_publication

ggsave("../figures/sources_comparison.pdf", p_publication, width = 12, height = 6, units = "in", device = cairo_pdf)
