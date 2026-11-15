################################################################################
#                                                                              #
#   Post-processing of LLM-extracted interactions into the DAPHNE database     #
#                                                                              #
#   1. Load data                                                               #
#   2. Parse list columns                                                      #
#   3. Clean species names                                                     #
#   4. Species reference table                                                 #
#   5. GBIF name matching                                                      #
#   6. Attach GBIF taxonomy and common names to the reference table            #
#   7. Build interactions                                                      #
#   8. Combine, filter and save                                                #
#   9. Summary statistics                                                      #
#  10. Figures                                                                 #
#                                                                              #
################################################################################

library(stringr)
library(tidyr)
library(purrr)
library(tibble)
library(dplyr)
library(rgbif)
library(httr)
library(jsonlite)
library(ggplot2)
library(patchwork)
library(arrow)

source("taxonomy_corrections.r") # all taxon-specific corrections

# GBIF lookup (section 5):
#   "all"     - query every name (~6 hours)
#   "missing" - only query names not yet in saved_datasets/gbif_ref_table.rds
#   "none"    - use the saved results as they are
gbif_mode <- "missing"



################################################################################
#                              1. Load data                                    #
################################################################################

parts <- sprintf("../2_ollama-main/raw_data/dataset_complete_part%02d.feather", 1:10)
df <- purrr::map_dfr(parts, arrow::read_feather) %>% dplyr::select(-Synonyms)

df <- df %>%
  mutate(is_empty = Phylum == "" & Class == "" & Order == "" & Family == "" & Genus == "" & Species == "" & `Common Name` == "")

# abstracts where nothing was extracted: 25,224
df %>% filter(is_empty) %>% pull(EID) %>% n_distinct() # 25,224

df <- df %>% filter(!is_empty) %>% dplyr::select(-is_empty)

# abstracts where species were extracted: 78,704
n_distinct(df$EID)

# Pest / natural-enemy attributes only apply when host plants / prey were extracted
df <- df %>%
  mutate(
    across(c(`Herbivore Is Pest`, `Pest Importance`, `Herbivore Is BCA`),
           ~ ifelse(`Host Plants` != "", ifelse(!is.na(.x), .x, "NA"), NA)),
    across(c(`Important Natural Enemy`, `Biological Control`),
           ~ ifelse(`Herbivore Prey` != "", ifelse(!is.na(.x), .x, "NA"), NA))
  )



################################################################################
#                          2. Parse list columns                               #
################################################################################

is_scientific_name <- function(x) {
  str_detect(x, "^[A-Z][a-z]+\\s+[a-z×.-]+")
}

# Split a comma/semicolon-separated string into a character vector, keeping
# commas inside parentheses and quoted cultivar lists intact, and re-joining
# lists of scientific names that share a trailing parenthetical.
split_to_list <- function(x) {
  lapply(x, function(v) {
    if (is.na(v) || v == "") return(character(0))

    v <- str_replace_all(v, ";", ",")

    # Protect commas inside cultivar lists, e.g. "cultivars 'A', 'B', Apple (...)"
    cultivar_pattern <- "(?i)cultivars\\s+(['\"].+?['\"])(?=\\s*,\\s*[A-Z]|$)"
    if (str_detect(v, cultivar_pattern)) {
      v <- str_replace_all(v, cultivar_pattern, function(m) str_replace_all(m, ",", "|||"))
    }

    # Split on commas not inside parentheses, then restore protected commas
    parts <- str_split(v, ",\\s*(?![^()]*\\))")[[1]] |> str_trim()
    parts <- str_replace_all(parts, fixed("|||"), ",")

    # Merge "Species A, Species B (common name)" back into a single element
    out <- character(0)
    i <- 1
    while (i <= length(parts)) {
      part <- parts[i]
      if (str_detect(part, "\\(") && is_scientific_name(part)) {
        j <- i - 1
        while (j >= 1 && is_scientific_name(parts[j]) && !str_detect(parts[j], "\\(")) {
          j <- j - 1
        }
        j <- j + 1
        if (j < i) {
          out <- c(out, paste(parts[j:i], collapse = ", "))
          i <- i + 1
          next
        }
      }
      out <- c(out, part)
      i <- i + 1
    }
    out
  })
}

# Examples:
# split_to_list("Trachycarpus fortunei, palms (Arecaceae)")
# split_to_list("Castanea sativa × Castanea crenata (hybrid sweet chestnut), Quercus robur, Quercus petraea (oak)")
# split_to_list("Pear (Pyrus spp.) – cultivars 'Conference', 'Dicolor', 'Bohemica', Apple (Malus domestica)")

df <- df %>%
  mutate(
    host_plants            = split_to_list(`Host Plants`),
    herbivore_is_pest      = split_to_list(`Herbivore Is Pest`),
    pest_importance        = split_to_list(`Pest Importance`),
    herbivore_is_bca       = split_to_list(`Herbivore Is BCA`),

    prey_species           = split_to_list(`Herbivore Prey`),
    important_enemy        = split_to_list(`Important Natural Enemy`),
    biological_control     = split_to_list(`Biological Control`),

    associated_plants      = split_to_list(`Associated Plants`),
    associated_industries  = split_to_list(`Associated Industries`),
    hyperparasitoids       = split_to_list(`Hyperparasitoids`),
    invasive               = split_to_list(`Invasive`),
    vectors                = split_to_list(`Vectors`)
  )

# manual correction: hybrid name that the splitter can't handle
df <- df %>%
  mutate(
    host_plants = if_else(
      `Host Plants` == "Castanea sativa × Castanea crenata (hybrid sweet chestnut), Quercus robur, Quercus petraea (oak)",
      list(c(
        "Castanea sativa × Castanea crenata (hybrid sweet chestnut)",
        "Quercus robur, Quercus petraea (oak)"
      )),
      host_plants
    )
  )

# one row lists two species in Species ("Vespula germanica, Vespula vulgaris")
df <- df %>% separate_rows(Species, sep = ", ")


# Check: list columns that are unnested together must have equal lengths (should return 0 rows)
df %>%
  mutate(n_host = lengths(host_plants),
         n_pest = lengths(herbivore_is_pest),
         n_imp  = lengths(pest_importance),
         n_bca  = lengths(herbivore_is_bca)) %>%
  filter(!(n_host == n_pest & n_host == n_imp & n_host == n_bca)) %>%
  dplyr::select(`Host Plants`, n_host, n_pest, n_imp, n_bca, `Herbivore Is Pest`, `Pest Importance`, `Herbivore Is BCA`, EID)

df %>%
  mutate(n_prey = lengths(prey_species),
         n_imp  = lengths(important_enemy),
         n_bio  = lengths(biological_control)) %>%
  filter(!(n_prey == n_imp & n_prey == n_bio)) %>%
  dplyr::select(`Herbivore Prey`, n_prey, n_imp, n_bio, `Important Natural Enemy`, `Biological Control`, EID)


# Expand elements that share a parenthetical into one element per species, e.g.
#   "Quercus robur, Quercus petraea (oak)" | TRUE
#   -> "Quercus robur (oak)", "Quercus petraea (oak)" | TRUE, TRUE
shared_paren_pattern <- "^(.+),\\s+([A-Z][a-z]+(?:\\s+[a-z.-]+)+)\\s+(\\([^)]+\\))$"

expand_shared_parentheses <- function(vec) {
  if (length(vec) == 0) return(vec)
  unlist(lapply(vec, function(item) {
    if (!str_detect(item, shared_paren_pattern)) return(item)
    parts <- str_match(item, shared_paren_pattern) # [2] prefix list, [3] last name, [4] "(suffix)"
    split_prefixes <- str_split(parts[2], ",\\s*")[[1]]
    c(paste(split_prefixes, parts[4]), paste(parts[3], parts[4]))
  }))
}

# Expand the name column (first of `target_cols`) and repeat the matching
# metadata values so all list columns stay aligned.
expand_synced_lists <- function(df, target_cols) {
  df %>%
    rowwise() %>%
    mutate(
      # number of elements each name expands into
      split_map = list(map_int(!!sym(target_cols[1]), ~ {
        if (!is.na(.x) && str_detect(.x, shared_paren_pattern)) {
          parts <- str_match(.x, shared_paren_pattern)
          return(length(str_split(parts[2], ",\\s*")[[1]]) + 1L)
        }
        1L
      }))
    ) %>%
    mutate(across(all_of(target_cols), ~ {
      val <- .x
      if (length(val) == 0) return(list(val))
      res <- if (cur_column() %in% c("host_plants", "prey_species")) {
        expand_shared_parentheses(val)
      } else {
        rep(val, times = split_map)
      }
      list(res)
    })) %>%
    dplyr::select(-split_map) %>%
    ungroup()
}

df <- expand_synced_lists(df, c("host_plants", "herbivore_is_pest", "pest_importance", "herbivore_is_bca"))
df <- expand_synced_lists(df, c("prey_species", "important_enemy", "biological_control"))



################################################################################
#                          3. Clean species names                              #
################################################################################

# Combine Genus and Species into a single (bi)nomial
prepare_binomial <- function(genus, species) {
  # invalid species -> genus (if valid) or NA
  if (is.na(species) || species == "" || toupper(species) == "NA") {
    if (!is.na(genus) && genus != "" && toupper(genus) != "NA") return(genus)
    return(NA_character_)
  }
  # invalid genus -> species as is
  if (is.na(genus) || genus == "" || toupper(genus) == "NA") return(species)

  # drop abbreviated genus, e.g. "A. helianthi" -> "helianthi"
  clean_species <- sub(paste0("^", substr(genus, 1, 1), "\\.\\s+"), "", species, ignore.case = TRUE)

  # species already a binomial (the trailing space stops "rattus" matching "^Rattus")
  if (grepl(paste0("^", genus, "\\s+"), clean_species, ignore.case = TRUE)) return(clean_species)

  paste(genus, clean_species)
}

# prepare_binomial("Acanthiophilus", "A. helianthi")             -> "Acanthiophilus helianthi"
# prepare_binomial("Acanthiophilus", "Acanthiophilus helianthi") -> "Acanthiophilus helianthi"
# prepare_binomial("Acanthiophilus", NA)                         -> "Acanthiophilus"
# prepare_binomial("Rattus", "rattus")                           -> "Rattus rattus"

# remove hidden format characters and redundant whitespace
df <- df %>%
  mutate(across(where(is.character), ~ {
    str_replace_all(.x, "\\p{Cf}", "") %>%
      str_replace_all("[[:space:]]+", " ") %>%
      trimws()
  }))

# manual fixes of the extracted taxa (taxonomy_corrections.r)
df <- fix_extracted_taxa(df)

df <- df %>%
  rowwise() %>%
  mutate(clean_name = prepare_binomial(Genus, Species)) %>%
  ungroup()

# Rows without genus or species (clean_name NA, e.g. "thrips" given only as Thripidae)
# are kept with their extracted taxonomy but are not matched to GBIF (see section 7)


# Important.Enemy must be True whenever Biocontrol is True (but not vice versa)
violations <- map2_lgl(df$biological_control, df$important_enemy, ~ any(.x == "True" & .y == "False"))
sum(violations) # 186

df$important_enemy    <- map2(df$biological_control, df$important_enemy, ~ as.character(ifelse(.x == "True", "True", .y)))
df$biological_control <- lapply(df$biological_control, as.character)

# Pest must be True whenever Pest.Importance is "major"
df$herbivore_is_pest <- map2(df$pest_importance, df$herbivore_is_pest, ~ as.character(ifelse(.x == "major", "True", .y)))

df <- df %>% unique() %>% mutate(row_id = row_number())



################################################################################
#                        4. Species reference table                            #
################################################################################

# One row per (name, EID) for every named taxon: main species, prey and hyperparasitoids
main_species_ref <- df %>%
  filter(!is.na(clean_name)) %>%
  dplyr::select(clean_name, Phylum, Class, Order, Family, Genus, Species, EID)

other_species <- df %>%
  dplyr::select(EID, prey_species, hyperparasitoids) %>%
  pivot_longer(cols = -EID, names_to = "source", values_to = "clean_name") %>%
  unnest(clean_name) %>%
  filter(!is.na(clean_name), clean_name != "", clean_name != "NA") %>%
  # hyperparasitoids are insects; narrows their GBIF query (e.g. "Asaphes" is a homonym)
  mutate(Class = if_else(source == "hyperparasitoids", "Insecta", NA_character_)) %>%
  dplyr::select(EID, clean_name, Class)

main_species_ref <- bind_rows(main_species_ref, other_species) %>%
  arrange(clean_name)


# Apply manual binomial corrections (taxonomy_corrections.r)
resolve_names <- function(data, correction) {
  data %>%
    left_join(correction, by = "clean_name") %>%
    mutate(
      binomial_corrected = coalesce(corrected_name, clean_name),
      Genus   = coalesce(corrected_genus, Genus),
      Species = coalesce(corrected_species, Species),
      mentioned_as = if_else(is_synonym, clean_name, NA_character_) # original name if it was a synonym
    ) %>%
    dplyr::select(-c(corrected_name, corrected_genus, corrected_species, is_synonym))
}

main_species_ref <- main_species_ref %>%
  resolve_names(binomial_corrections) %>%
  higher_taxonomy_correction()


main_species_ref <- main_species_ref %>%
  # strip qualifiers (sp., spp., nr., cf., aff., ...) to obtain the name queried on GBIF
  mutate(binomial_shortened = str_replace_all(
    binomial_corrected,
    "(?i)\\s+((sp\\.|spp\\.|ssp\\.|sp\\.\\s+nov\\.|sp\\.\\s+nov\\s+near\\b|sp\\.\\s+nr\\.|sp\\.\\s+nr|sp\\.\\s+n\\.|n\\.\\s+sp\\.|sp\\.\\s+near\\b|near\\b|sp\\.\\s+indet\\.|sp\\.\\s+Indet\\.|sp\\.\\s+innom\\.|innom\\.|indet\\.|Indet\\.|nr\\.|cf\\.|aff\\.|prob\\.|nov\\.|n\\.sp\\.|n\\.1|n\\.2|n\\.\\s+1|n\\.\\s+2|sp\\.\\s+A\\b|sp\\.\\s+B\\b|sp\\.\\s+C\\b|sp\\.\\s+D\\b|sp\\.\\s+E\\b|sp\\.\\s+F\\b|sp\\.\\s+G\\b|sp\\.\\s+I\\b|sp\\.\\s+II\\b|sp\\.\\s+III\\b|sp\\.\\s+IV\\b|sp\\.\\s+V\\b|sp\\.\\s+VI\\b|sp\\.\\s+VII\\b|sp\\.\\s+VIII\\b|sp\\.\\s+IX\\b|sp\\.\\s+X\\b|sp\\.\\s+XI\\b|sp\\.\\s+XII\\b|nr\\b|s\\.l\\.)\\s*\\d*\\s*)+",
    " "
  ) %>% str_squish()) %>%
  # remove rows without any name or higher taxonomy
  filter(!(
    (is.na(binomial_corrected) | binomial_corrected %in% c("", "NA")) &
      (is.na(Phylum) | Phylum %in% c("", "NA")) &
      (is.na(Class)  | Class  %in% c("", "NA")) &
      (is.na(Order)  | Order  %in% c("", "NA")) &
      (is.na(Family) | Family %in% c("", "NA"))
  ))


# Most frequent valid value of x (NA if none)
get_most_common <- function(x) {
  valid_x <- x[!is.na(x) & !x %in% c("", "character(0)", "NA")]
  if (length(valid_x) == 0) return(NA_character_)
  counts <- table(valid_x)
  names(counts)[which.max(counts)]
}

main_species_ref <- main_species_ref %>%
  # fix taxonomy shifted by one rank (`%in%` keeps rows with missing ranks unchanged)
  mutate(Phylum = if_else(Class %in% c("Insecta", "Arachnida", "Arthropoda", "Hexapoda"), "Arthropoda", Phylum),
         Phylum = if_else(Class %in% c("Amphibia", "Mammalia", "Aves"), "Chordata", Phylum)) %>%
  mutate(is_insect = Order %in% "Insecta",       # Order == Insecta: shift Family -> Order
         Class  = if_else(is_insect, "Insecta", Class),
         Order  = if_else(is_insect, Family, Order),
         Family = if_else(is_insect, NA_character_, Family),
         is_arthropod = Class %in% "Arthropoda", # Class == Arthropoda: shift Order -> Class, Family -> Order
         Class  = if_else(is_arthropod, Order, Class),
         Order  = if_else(is_arthropod, Family, Order),
         Family = if_else(is_arthropod, NA_character_, Family)) %>%
  dplyr::select(-is_insect, -is_arthropod) %>%
  # harmonise taxonomy across mentions of the same name
  group_by(binomial_shortened) %>%
  mutate(across(c(Phylum, Class, Order, Family, Genus, Species), get_most_common)) %>%
  ungroup() %>%
  unique()

saveRDS(main_species_ref, "saved_datasets/main_species_ref.rds")



################################################################################
#                          5. GBIF name matching                               #
################################################################################

# One row per name to query; names that only differ by synonym are merged
main_species_ref_merged <- main_species_ref %>%
  group_by(binomial_shortened, Phylum, Class, Order, Family, Genus) %>%
  dplyr::summarise(
    EIDs = list(unique(unlist(EID))),
    Synonyms = list({
      syns <- unlist(str_split(mentioned_as[mentioned_as != binomial_corrected], ",\\s*"))
      syns <- unique(syns)
      syns[!is.na(syns) & !trimws(syns) %in% c("", "NA")]
    }),
    .groups = "drop"
  )


safe_extract <- function(val) {
  if (is.null(val) || length(val) == 0) return(NA_character_)
  as.character(val)
}

# GET a GBIF API url, retrying on failure; returns parsed JSON or NULL
safe_api_call <- function(url, max_retries = 5) {
  for (attempt in seq_len(max_retries)) {
    res <- tryCatch({
      response <- GET(url)
      if (status_code(response) != 200) stop(paste("HTTP Error:", status_code(response)))
      if (!grepl("application/json", headers(response)[["content-type"]])) stop("Received HTML/non-JSON response from server")
      fromJSON(content(response, "text", encoding = "UTF-8"))
    }, error = function(e) {
      message(paste("Attempt", attempt, "failed for", url, "-", e$message))
      NULL
    })
    if (!is.null(res)) return(res)
    Sys.sleep(1.5 * attempt)
  }
  NULL
}

# Match one name on GBIF, constrained by the extracted higher taxonomy
gbif_match <- function(name, rank, row) {
  query_list <- list(
    name    = name,
    rank    = rank,
    strict  = "false",
    verbose = "true",
    phylum  = row$Phylum,
    class   = row$Class,
    order   = row$Order,
    family  = row$Family,
    genus   = row$Genus
  )
  query_list <- query_list[sapply(query_list, function(x) !is.null(x) && !is.na(x) && !x %in% c("", "NA"))]
  query_string <- paste0(names(query_list), "=", sapply(query_list, URLencode), collapse = "&")
  safe_api_call(paste0("https://api.gbif.org/v1/species/match?", query_string))
}

# GBIF match of each name in `names_df`; names without a match get a row with
# matchType "NONE", failed requests get no row (and are retried on the next run)
query_gbif <- function(names_df) {
  map_df(seq_len(nrow(names_df)), function(i) {

    row <- names_df[i, ]
    cat(i, "\t|", row$binomial_shortened, "\n")

    if (is.na(row$binomial_shortened) || row$binomial_shortened == "") return(NULL)

    rank_name <- if (str_count(row$binomial_shortened, "\\S+") >= 2) "SPECIES" else "GENUS"
    is_miss <- function(d) is.null(d) || is.null(d$usageKey) || !identical(d$rank, rank_name)

    # 1. main name
    data <- gbif_match(row$binomial_shortened, rank_name, row)

    # 2. synonyms
    if (is_miss(data)) {
      for (syn in row$Synonyms[[1]]) {
        data_syn <- gbif_match(syn, rank_name, row)
        if (!is_miss(data_syn)) {
          data <- data_syn
          break
        }
      }
    }

    # 3. best alternative, if it is an exact match within the same phylum
    if (is_miss(data) && !is.null(data$alternatives) && length(data$alternatives) > 0) {
      data_alt <- data$alternatives[1, ]
      if (isTRUE(data_alt$matchType == "EXACT") && isTRUE(data_alt$phylum == row$Phylum)) {
        data <- data_alt
      }
    }

    if (is.null(data)) return(NULL)                                   # request failed: retried next run
    if (is.null(data$usageKey)) data <- list(matchType = "NONE")      # no match: recorded as such

    status    <- data$status
    matchType <- data$matchType
    taxon_key <- data$usageKey %||% NA_integer_

    synonyms_vec <- character(0)
    if (!matchType %in% c("HIGHERRANK", "NONE")) {
      # if the match is a synonym, take the info of the accepted taxon
      if (!is.null(data$acceptedUsageKey) && !is.na(data$acceptedUsageKey) && data$usageKey != data$acceptedUsageKey) {
        taxon_key <- data$acceptedUsageKey
        data <- safe_api_call(paste0("https://api.gbif.org/v1/species/", taxon_key))
      }
      # GBIF synonyms (skipped for HIGHERRANK, which would return the synonyms of the genus/family)
      synonyms_data <- safe_api_call(paste0("https://api.gbif.org/v1/species/", taxon_key, "/synonyms"))
      if (!is.null(synonyms_data$results)) synonyms_vec <- synonyms_data$results$canonicalName
    }

    data.frame(
      gbif_id        = taxon_key,
      gbif_phylum    = safe_extract(data$phylum),
      gbif_class     = safe_extract(data$class),
      gbif_order     = safe_extract(data$order),
      gbif_family    = safe_extract(data$family),
      gbif_genus     = safe_extract(data$genus),
      gbif_species   = safe_extract(data$species),
      original_names = row$binomial_shortened,
      EIDs           = I(row$EIDs),
      synonyms       = I(row$Synonyms),
      gbif_synonyms  = I(list(synonyms_vec)),
      scientificName = safe_extract(data$scientificName),
      canonicalName  = safe_extract(data$canonicalName),
      rank           = safe_extract(data$rank),
      status         = safe_extract(status),
      matchType      = safe_extract(matchType)
    )
  })
}

st1 <- Sys.time()
if (gbif_mode == "all") {
  ref_table <- query_gbif(main_species_ref_merged)
} else {
  ref_table <- readRDS("saved_datasets/gbif_ref_table.rds")
  if (gbif_mode == "missing") {
    new_names <- main_species_ref_merged %>% filter(!binomial_shortened %in% ref_table$original_names)
    message(nrow(new_names), " names to query on GBIF")
    ref_table <- bind_rows(ref_table, query_gbif(new_names))
  }
}
print(Sys.time() - st1) # "all": ~6 hours

if (gbif_mode != "none") saveRDS(ref_table, "saved_datasets/gbif_ref_table.rds")



################################################################################
#       6. Attach GBIF taxonomy and common names to the reference table        #
################################################################################

is_higher_rank <- ref_table$matchType %in% "HIGHERRANK"

ref_table <- ref_table %>%
  # HIGHERRANK matches (e.g. species only matched to its genus) keep the higher
  # taxonomy but not the name, ID or synonyms of the matched higher taxon
  mutate(scientificName = if_else(is_higher_rank, NA, scientificName),
         canonicalName  = if_else(is_higher_rank, NA, canonicalName),
         gbif_id        = if_else(is_higher_rank, NA, gbif_id),
         gbif_synonyms  = I(map2(gbif_synonyms, is_higher_rank, ~ if (.y) character(0) else .x))) %>%
  group_by(original_names) %>%
  mutate(synonyms = list({
           combined <- unique(c(unlist(synonyms), unlist(gbif_synonyms)))
           combined[!is.na(combined) & combined != ""]
         }),
         across(c(gbif_id, gbif_phylum, gbif_class, gbif_order, gbif_family, gbif_genus, gbif_species, scientificName, canonicalName),
                get_most_common)) %>%
  ungroup() %>%
  # remove wrong GBIF synonyms (taxonomy_corrections.r)
  mutate(synonyms = map2(synonyms, gbif_species, ~ .x[!.x %in% gbif_synonym_errors$synonym[gbif_synonym_errors$species %in% .y]])) %>%
  dplyr::select(gbif_id, gbif_phylum, gbif_class, gbif_order, gbif_family, gbif_genus, gbif_species, scientificName, canonicalName,
                binomial_shortened = original_names, synonyms) %>%
  # one row per name: GBIF results don't depend on the abstract, so names from
  # abstracts that weren't in the GBIF run are matched as well
  distinct(binomial_shortened, .keep_all = TRUE)


# ref_* columns: GBIF taxonomy, falling back to the extracted (harmonised) taxonomy
main_species_ref <- main_species_ref %>%
  left_join(ref_table, by = "binomial_shortened") %>%
  mutate(ref_phylum  = coalesce(gbif_phylum, Phylum),
         ref_class   = coalesce(gbif_class, Class),
         ref_order   = coalesce(gbif_order, Order),
         ref_family  = coalesce(gbif_family, Family),
         ref_genus   = coalesce(gbif_genus, Genus),
         ref_species = coalesce(gbif_species, Species)) %>%
  dplyr::select(-c(Phylum, Class, Order, Family, Genus, Species, gbif_phylum, gbif_class, gbif_order, gbif_family, gbif_genus, gbif_species)) %>%
  distinct()


# Lower-case, unique, non-empty common names
clean_common_names <- function(x) {
  x <- str_squish(tolower(x))
  unique(x[!is.na(x) & !x %in% c("", "na")])
}

# Common names, pooled per canonical name (or clean_name if unmatched)
common_names_df <- df %>%
  filter(!is.na(clean_name)) %>%
  left_join(main_species_ref %>% dplyr::select(clean_name, EID, canonicalName), by = c("clean_name", "EID")) %>%
  mutate(common_key = coalesce(canonicalName, clean_name)) %>%
  group_by(common_key) %>%
  summarise(common_names = I(list(clean_common_names(`Common Name`))), .groups = "drop")

main_species_ref <- main_species_ref %>%
  mutate(common_key = coalesce(canonicalName, clean_name)) %>%
  left_join(common_names_df, by = "common_key") %>%
  dplyr::select(-common_key)

saveRDS(main_species_ref, "saved_datasets/main_species_ref.rds")



################################################################################
#                          7. Build interactions                               #
################################################################################

# Full binomial from genus + name; NA unless the name resolves to species level
combine_binomial <- function(genus, species) {
  genus <- if_else(genus == "" | toupper(genus) == "NA", NA_character_, genus)
  species_clean <- if_else(is.na(species) | species == "" | toupper(species) == "NA", "", species)

  case_when(
    is.na(genus) ~ NA_character_,
    toupper(genus) == toupper(species_clean) ~ NA_character_,
    species_clean == "" ~ NA_character_,
    TRUE ~ {
      # drop the genus if it is already part of the name, e.g. "Aphis fabae" -> "fabae"
      epithet <- str_remove(species_clean, regex(paste0("^", genus, "\\s*"), ignore_case = TRUE))
      if_else(epithet == "", NA_character_, paste(genus, epithet))
    }
  )
}

na_blank <- function(x) if_else(x %in% c("", "NA"), NA_character_, x)

# Columns describing a taxon; prefixed with "Subject." or "Object." in the output
taxon_cols <- c("Phylum", "Class", "Order", "Family", "Genus", "Species", "ScientificName", "CanonicalName", "Verbatim", "Synonyms", "Common", "ID")

# Named taxa (one row per name and EID), described by the GBIF-matched reference table
named_taxa <- main_species_ref %>%
  transmute(EID,
            Verbatim       = clean_name,
            Name           = coalesce(canonicalName, binomial_shortened),
            Phylum         = ref_phylum,
            Class          = ref_class,
            Order          = ref_order,
            Family         = ref_family,
            Genus          = ref_genus,
            Species        = combine_binomial(Genus, Name),
            ScientificName = scientificName,
            CanonicalName  = canonicalName,
            Synonyms       = unclass(synonyms),
            Common         = unclass(common_names),
            ID             = gbif_id)

# Main species of each row of df: the named taxon or, for rows without genus/species,
# the extracted taxonomy and common name, named after the lowest rank given
main_taxa <- bind_rows(
  df %>%
    filter(!is.na(clean_name)) %>%
    dplyr::select(row_id, EID, clean_name) %>%
    left_join(named_taxa, by = c("clean_name" = "Verbatim", "EID")) %>%
    rename(Verbatim = clean_name),
  df %>%
    filter(is.na(clean_name)) %>%
    mutate(across(c(Phylum, Class, Order, Family), na_blank)) %>%
    transmute(row_id, EID,
              Name     = coalesce(Family, Order, Class, Phylum),
              Verbatim = Name,
              Phylum, Class, Order, Family,
              Synonyms = list(NULL),
              Common   = map(`Common Name`, clean_common_names))
) %>%
  dplyr::select(-EID)

# Prefix taxon columns with `role`; the taxon name becomes the `role` column itself
as_role <- function(taxa, role) {
  taxa %>%
    rename(!!role := Name) %>%
    rename_with(~ paste0(role, ".", .x), any_of(taxon_cols))
}

subject_cols <- paste0("Subject.", taxon_cols)
object_cols  <- paste0("Object.", taxon_cols)


# --- Herbivores: Subject = herbivore, Object = host plant (not GBIF-matched) ---

herbivory_interactions <- df %>%
  dplyr::select(row_id, Type, `Feeding Mode`, host_plants, herbivore_is_pest, pest_importance, herbivore_is_bca,
                associated_industries, invasive, vectors, EID, Abstract, Generated.Response = `Generated Response`) %>%
  unnest(c(host_plants, herbivore_is_pest, pest_importance, herbivore_is_bca)) %>%
  left_join(as_role(main_taxa, "Subject"), by = "row_id") %>%
  mutate(Object                = host_plants,
         Object.Verbatim       = host_plants,
         Feeding.Mode          = `Feeding Mode`,
         Pest                  = as.logical(herbivore_is_pest),
         Pest.Importance       = pest_importance,
         Herbivore.IsBCA       = as.logical(herbivore_is_bca),
         Associated.Industries = I(associated_industries),
         InvasiveIn            = I(invasive),
         Vectors               = I(vectors)) %>%
  dplyr::select(Subject, Object, Type, Feeding.Mode, Pest, Pest.Importance, Herbivore.IsBCA,
                Associated.Industries, InvasiveIn, Vectors, EID, Abstract, Generated.Response,
                all_of(subject_cols), Object.Verbatim)


# --- Natural enemies: Subject = natural enemy, Object = prey ---

predation_interactions <- df %>%
  dplyr::select(row_id, Type, `Feeding Mode`, prey_species, important_enemy, biological_control,
                associated_plants, associated_industries, vectors, EID, Abstract, Generated.Response = `Generated Response`) %>%
  unnest(c(prey_species, important_enemy, biological_control)) %>%
  left_join(as_role(main_taxa, "Subject"), by = "row_id") %>%
  left_join(as_role(named_taxa, "Object"), by = c("prey_species" = "Object.Verbatim", "EID")) %>%
  mutate(Object.Verbatim       = prey_species,
         Feeding.Mode          = `Feeding Mode`,
         Important.Enemy       = as.logical(important_enemy),
         Biocontrol            = as.logical(biological_control),
         Associated.Plants     = I(associated_plants),
         Associated.Industries = I(associated_industries),
         Vectors               = I(vectors)) %>%
  dplyr::select(Subject, Object, Type, Feeding.Mode, Important.Enemy, Biocontrol,
                Associated.Plants, Associated.Industries, Vectors, EID, Abstract, Generated.Response,
                all_of(subject_cols), all_of(object_cols))


# --- Hyperparasitoids: Subject = hyperparasitoid, Object = primary parasitoid (main species) ---

hyperparasitoid_interactions <- df %>%
  dplyr::select(row_id, hyperparasitoids, EID, Abstract, Generated.Response = `Generated Response`) %>%
  unnest(hyperparasitoids) %>%
  left_join(as_role(named_taxa, "Subject"), by = c("hyperparasitoids" = "Subject.Verbatim", "EID")) %>%
  left_join(as_role(main_taxa, "Object"), by = "row_id") %>%
  mutate(Subject.Verbatim = hyperparasitoids,
         Type             = "natural enemy",
         Feeding.Mode     = "hyperparasitism") %>%
  dplyr::select(Subject, Object, Type, Feeding.Mode, EID, Abstract, Generated.Response,
                all_of(subject_cols), all_of(object_cols))



################################################################################
#                        8. Combine, filter and save                           #
################################################################################

interactions_df <- herbivory_interactions %>%
  full_join(full_join(predation_interactions, hyperparasitoid_interactions)) %>%
  relocate(Object.Verbatim, .after = Object.CanonicalName)

# remove cannibalism (Subject == Object); keep rows where either side is unresolved
interactions_df <- interactions_df %>% filter(is.na(Subject) | is.na(Object) | Subject != Object)

# add Scopus metadata
scopus_dir <- "../1_scopus-abstracts/scopus/"
scopus_files <- c("export_2ffe3d67-1dba-4eda-b235-d5bf0b058d39_2025-08-24T20_19_00.364355101.rds",
                  "export_25be7adb-0e6d-47b6-9129-3a290bafc8af_2025-08-24T20_30_35.246722592.rds",
                  "export_67d394ef-576b-4198-82d7-a6e4cc253cc9_2025-08-24T20_26_20.523132421.rds",
                  "export_71e456e4-31e4-41d1-9d90-57a9a7aabc74_2025-08-24T20_18_36.726340475.rds",
                  "export_95ce8400-f987-4481-bc0a-86699cddca60_2025-08-24T20_17_41.093895810.rds",
                  "export_d062b0aa-a511-4a97-9d1c-571922446a80_2025-08-25T17_26_26.152316033.rds",
                  "export_fec52884-1f59-41b4-8b8f-a5331eac2834_2025-08-25T17_26_09.102103177.rds",
                  "export_565a8258-3a3e-457d-96d1-582ae53af9b6_2025-08-24T20_16_54.168710566.rds",
                  "export_b6c730d4-ac7f-4c2f-81bf-b0f72a3815ca_2025-08-24T20_19_36.931219694.rds",
                  "export_c3a804bb-31a5-4079-9f6c-f3edd19c4622_2025-08-24T20_31_04.370328659.rds",
                  "export_f1459b99-b677-4f01-8aa1-5957ba8af43c_2025-08-24T20_21_11.746507396.rds",
                  "export_9b01d6d9-b417-41a0-87ab-fc248fccb9e2_2025-08-25T18_45_47.706146572.rds",
                  "export_65dd9ca9-b719-4045-89b2-c6719eb05e3c_2025-08-25T18_44_00.832213554.rds",
                  "export_781ef919-d2ac-402d-aec7-fb287887ace1_2025-08-25T18_43_35.927976733.rds",
                  "export_a320881c-5beb-4e47-935d-8223f554ffe6_2025-08-25T18_44_49.217068331.rds",
                  "export_bd63845b-83f7-425f-8f77-dc7f10987968_2025-08-25T18_44_35.028977485.rds",
                  "export_eed5b52f-835e-46e3-9513-264b27de9e2f_2025-08-25T18_44_13.298152718.rds",
                  "export_f9a6974f-add8-4d91-8f5c-7c3515c4ed29_2025-08-25T18_43_17.584212013.rds",
                  "export_f50ff05e-aa8d-4993-a75d-361b7804daef_2025-08-25T18_45_25.449557866.rds",
                  "export_fb20a09a-b30f-4dd6-be2b-08238ee70679_2025-08-25T18_45_10.168656744.rds",
                  "export_064c1ea5-0952-4c9a-91a5-ee25c68e5862_2025-08-25T18_53_00.332185549.rds")

scopus <- do.call(rbind, lapply(paste0(scopus_dir, scopus_files), readRDS)) %>%
  filter(Year != 2026) %>%
  distinct(EID, .keep_all = TRUE) %>% # one record per abstract (2-s2.0-85201321666 was exported twice with different author formatting)
  droplevels()
interactions_df <- left_join(interactions_df, scopus %>% dplyr::select(-Abstract), by = "EID")


# --- Pathogens and plants ---

# unique(c(unique(interactions_df$Object.Phylum, unique(interactions_df$Subject.Phylum))))
fungi_phyla    <- c("Ascomycota", "Basidiomycota", "Blastocladiomycota", "Chytridiomycota", "Entomophthoromycota", "Glomeromycota", "Mucoromycota", "Microsporidia", "Ochrophyta", "Oomycota") # incl. stramenopiles and water moulds
bacteria_phyla <- c("Actinobacteriota", "Cyanobacteria", "Firmicutes", "Proteobacteria")
protozoa_phyla <- c("Amoebozoa", "Apicomplexa", "Cercozoa", "Ciliophora", "Euglenozoa", "Metamonada", "Mycetozoa", "Myzozoa", "Protozoa")
plants_phyla   <- c("Chlorophyta", "Rhodophyta", "Tracheophyta")

# number of species and of interactions (as Subject) per group
count_species <- function(phyla) {
  n_distinct(na.omit(c(
    interactions_df %>% filter(Subject.Phylum %in% phyla) %>% pull(Subject.Species),
    interactions_df %>% filter(Object.Phylum %in% phyla) %>% pull(Object.Species)
  )))
}
count_rows <- function(phyla) {
  interactions_df %>% filter(Subject.Phylum %in% phyla) %>% count(Type)
}

count_species(fungi_phyla)    # 334
count_species(bacteria_phyla) # 74
count_species(protozoa_phyla) # 38
count_species(plants_phyla)   # 29

count_rows(fungi_phyla)    # herbivore 1,  natural enemy 3128
count_rows(bacteria_phyla) # herbivore 0,  natural enemy 333
count_rows(protozoa_phyla) # herbivore 4,  natural enemy 108
count_rows(plants_phyla)   # herbivore 19, natural enemy 10

# remove plants; label fungi, bacteria and protozoa as pathogens
interactions_df <- interactions_df %>% filter(!(Subject.Phylum %in% plants_phyla))

is_pathogen <- interactions_df$Subject.Phylum %in% c(fungi_phyla, bacteria_phyla, protozoa_phyla)
interactions_df[is_pathogen, c("Type", "Feeding.Mode")] <- list("pathogen", NA)


# --- Final clean-up ---

interactions_df <- interactions_df %>%
  mutate(across(where(is.character), ~ na_if(., "NA")))

# misspellings of "arable crops"
bad_industries <- c("arby crops", "arberry crops", "arbitrary crops", "arbyle crops", "arbage crops", "arbile crops",
                    "arbor​e crops", "arbrate crops", "arbyl crops", "ardrable crops", "array crops")

interactions_df <- interactions_df %>%
  mutate(Associated.Industries = map(Associated.Industries, ~ .x[!(.x %in% bad_industries)]))


# drop exact duplicates (e.g. a host plant listed twice for the same species)
interactions_df <- interactions_df %>% distinct()

saveRDS(interactions_df %>% filter(Type == "pathogen"), "saved_datasets/interactions_data_pathogens.rds", compress = "xz")
saveRDS(interactions_df %>% filter(Type != "pathogen"), "../DAPHNE.rds", compress = "xz")



################################################################################
#                          9. Summary statistics                               #
################################################################################

interactions_df <- readRDS("../DAPHNE.rds")

nrow(interactions_df) # 175359

# invasive species and vectors
interactions_df %>% filter(lengths(InvasiveIn) != 0) %>% pull(Subject) %>% n_distinct() # 780
interactions_df %>% filter(lengths(InvasiveIn) != 0) %>% pull(Type) %>% table()         # herbivore 7148

interactions_df %>% filter(lengths(Vectors) != 0) %>% pull(Subject) %>% n_distinct()   # 711
interactions_df %>% filter(lengths(Vectors) != 0) %>% pull(Type) %>% table()           # herbivore 4317, natural enemy 397
interactions_df %>% filter(lengths(Vectors) != 0, Type == "herbivore") %>% pull(Subject) %>% n_distinct()     # 625
interactions_df %>% filter(lengths(Vectors) != 0, Type == "natural enemy") %>% pull(Subject) %>% n_distinct() # 86

sum(lengths(interactions_df$InvasiveIn) != 0) # 7148
sum(lengths(interactions_df$Vectors) != 0)    # 4714

# interactions per type and feeding mode
nrow(interactions_df %>% filter(Type == "herbivore"))     # 131120
nrow(interactions_df %>% filter(Type == "natural enemy")) # 44239

nrow(interactions_df %>% filter(Feeding.Mode == "herbivory"))      # 104552
nrow(interactions_df %>% filter(Feeding.Mode == "frugivory"))      # 9649
nrow(interactions_df %>% filter(Feeding.Mode == "granivory"))      # 12178
nrow(interactions_df %>% filter(Feeding.Mode == "gall formation")) # 4741
nrow(interactions_df %>% filter(Type == "herbivore" & is.na(Feeding.Mode))) # 0

nrow(interactions_df %>% filter(Feeding.Mode == "predation"))       # 18095
nrow(interactions_df %>% filter(Feeding.Mode == "parasitism"))      # 25224
nrow(interactions_df %>% filter(Feeding.Mode == "hyperparasitism")) # 810
nrow(interactions_df %>% filter(Type == "natural enemy" & is.na(Feeding.Mode))) # 110

# unique taxa resolved at species level
n_distinct(c(interactions_df$Subject.Species, interactions_df$Object.Species)) # 16882

# ... of which matched to a GBIF species
n_distinct(c(
  interactions_df %>% filter(str_count(Subject.CanonicalName, "\\w+") > 1) %>% pull(Subject.CanonicalName),
  interactions_df %>% filter(str_count(Object.CanonicalName, "\\w+") > 1) %>% pull(Object.CanonicalName)
)) # 15089



################################################################################
#                               10. Figures                                    #
################################################################################

# Horizontal stacked bars of species counts per class, split into orders for `target_classes`
plot_classes <- function(interactions_df, title, feeding_modes, target_classes, filename, order_text_size = 1.8, xlab = "Species Count", ylab = "Class") {

  plot_data <- interactions_df %>%
    filter(Feeding.Mode %in% feeding_modes,
           str_count(Subject.CanonicalName, "\\w+") > 1) %>%
    dplyr::select(Subject.CanonicalName, Subject.Phylum, Subject.Class, Subject.Order) %>%
    distinct() %>%

    # class labels; incomplete taxonomy goes to "Other classes"
    mutate(Phylum_Class = case_when(
      is.na(Subject.Phylum) | is.na(Subject.Class) | Subject.Phylum == "" | Subject.Class == "" ~ "Other classes",
      TRUE ~ paste0(Subject.Phylum, ": ", Subject.Class)
    )) %>%

    # classes with fewer than 10 species also go to "Other classes"
    group_by(Phylum_Class) %>%
    mutate(class_total = n()) %>%
    ungroup() %>%
    mutate(Phylum_Class = if_else(Phylum_Class != "Other classes" & class_total < 10, "Other classes", Phylum_Class)) %>%

    # label orders (>= 10 species) within target classes
    group_by(Phylum_Class, Subject.Order) %>%
    mutate(order_count = n()) %>%
    ungroup() %>%
    mutate(Sub_Group_Name = if_else(Phylum_Class %in% target_classes & order_count >= 10, Subject.Order, Phylum_Class)) %>%

    count(Phylum_Class, Sub_Group_Name) %>%
    group_by(Phylum_Class) %>%
    arrange(desc(n)) %>%
    mutate(rank_in_bar = row_number(),
           total_bar_n = sum(n),
           color_id = if_else(Phylum_Class %in% target_classes, as.character(rank_in_bar), "base")) %>%
    ungroup() %>%
    # order segments by size and bars by total (instead of alphabetically)
    mutate(Sub_Group_Name = reorder(Sub_Group_Name, n),
           Phylum_Class = reorder(Phylum_Class, total_bar_n))

  # grey for non-target classes, pastel colours by segment rank otherwise
  unique_ranks <- sort(unique(plot_data$color_id[plot_data$color_id != "base"]))
  target_colors <- colorRampPalette(scales::brewer_pal(palette = "Pastel2")(8))(length(unique_ranks))
  palette_values <- c("base" = "grey90", setNames(target_colors, unique_ranks))

  ggplot(plot_data, aes(y = Phylum_Class, x = n, fill = color_id, group = rank_in_bar)) +
    geom_col(show.legend = FALSE, color = "white", linewidth = 0.2) +
    geom_text(
      aes(label = if_else(Phylum_Class %in% target_classes, Sub_Group_Name, "")),
      position = position_stack(vjust = 0.5),
      color = "black", size = order_text_size, check_overlap = TRUE
    ) +
    geom_text(
      aes(x = total_bar_n, label = total_bar_n),
      hjust = -0.5, color = "black", size = 2.5, fontface = "bold"
    ) +
    scale_fill_manual(values = palette_values) +
    scale_y_discrete(limits = rev) +
    scale_x_continuous(expand = expansion(mult = c(0, 0.15))) +
    labs(title = title, x = xlab, y = ylab) +
    theme_minimal() +
    theme(panel.grid.minor = element_blank())
}

p1 <- plot_classes(interactions_df,
                   title = "a. Herbivores",
                   feeding_modes = c("herbivory"),
                   target_classes = c("Arthropoda: Insecta", "Arthropoda: Arachnida", "Chordata: Mammalia", "Nematoda: Chromadorea"),
                   filename = "class_counts_herbivores.png",
                   order_text_size = 1.3,
                   xlab = "", ylab = "")

p2 <- plot_classes(interactions_df,
                   title = "b. Predators",
                   feeding_modes = c("predation"),
                   target_classes = c("Arthropoda: Insecta", "Arthropoda: Arachnida", "Chordata: Mammalia", "Chordata: Aves"),
                   filename = "class_counts_predators.png",
                   order_text_size = 1.6,
                   xlab = "", ylab = "Class")

p3 <- plot_classes(interactions_df,
                   title = "c. Parasites, parasitoids and hyperparasitoids",
                   feeding_modes = c("parasitism", "hyperparasitism"),
                   target_classes = c("Arthropoda: Insecta", "Ascomycota: Sordariomycetes", "Nematoda: Chromadorea"),
                   filename = "class_counts_parasitoids.png",
                   order_text_size = 1.6,
                   xlab = "Species Count", ylab = "")

combined_plot <- (p1 / p2 / p3) +
  plot_layout(guides = "collect") &
  theme(axis.title = element_text(size = 12),
        axis.text.y = element_text(size = 8))

ggsave("../figures/class_counts.pdf", combined_plot, width = 350, height = 200, units = "mm", dpi = 500)
