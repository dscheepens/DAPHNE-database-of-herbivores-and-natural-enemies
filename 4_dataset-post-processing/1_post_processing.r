
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

source("taxonomy_corrections.R")

df <- read_feather("../1_ollama-main/feather_results/dataset_complete.feather") %>% dplyr::select(-Synonyms)
#colnames(df)

# number of abstracts where nothing was extracted: 25,224
df %>% filter(
  (Phylum=="" & Class=="" & Order=="" & Family=="" & Genus=="" & Species=="" & `Common Name`=="")
) %>% dplyr::summarize(length(unique(EID))) # 25,224

# filter out empty rows (abstracts where nothing was extracted)
df <- df %>% filter(
  !(Phylum=="" & Class=="" & Order=="" & Family=="" & Genus=="" & Species=="" & `Common Name`=="")
)

# number of abstracts where species were extracted: 78,704
length(unique(df$EID)) 

# ensure that the following columns are NA if either `Host Plants` or `Herbivore Prey` are NA, respectively: 

df$`Herbivore Is Pest` <- ifelse(!is.na(df$`Host Plants`), df$`Herbivore Is Pest`, "NA")
df$`Pest Importance`   <- ifelse(!is.na(df$`Host Plants`), df$`Pest Importance`, "NA")
df$`Herbivore Is BCA`  <- ifelse(!is.na(df$`Host Plants`), df$`Herbivore Is BCA`, "NA")

df$`Important Natural Enemy` <- ifelse(!is.na(df$`Herbivore Prey`), df$`Important Natural Enemy`, "NA")
df$`Biological Control`      <- ifelse(!is.na(df$`Herbivore Prey`), df$`Biological Control`, "NA")

df$`Herbivore Is Pest` <- ifelse(df$`Host Plants`!="", ifelse(!is.na(df$`Herbivore Is Pest`), df$`Herbivore Is Pest`, "NA"), NA)
df$`Pest Importance`   <- ifelse(df$`Host Plants`!="", ifelse(!is.na(df$`Pest Importance`), df$`Pest Importance`, "NA"), NA)
df$`Herbivore Is BCA`  <- ifelse(df$`Host Plants`!="", ifelse(!is.na(df$`Herbivore Is BCA`), df$`Herbivore Is BCA`, "NA"), NA)

df$`Important Natural Enemy` <- ifelse(df$`Herbivore Prey`!="", ifelse(!is.na(df$`Important Natural Enemy`), df$`Important Natural Enemy`, "NA"), NA)
df$`Biological Control`      <- ifelse(df$`Herbivore Prey`!="", ifelse(!is.na(df$`Biological Control`), df$`Biological Control`, "NA"), NA)






is_scientific_name <- function(x) {
  str_detect(x, "^[A-Z][a-z]+\\s+[a-z×.-]+")
}

split_to_list <- function(x) {
  lapply(x, function(v) {
    if (is.na(v) || v == "") return(character(0))
    
    v <- str_replace_all(v, ";", ",")
    
    # --- ROBUST PRE-PROCESSING FOR CULTIVARS ---
    # We find the sequence starting with 'cultivars' and ending at the LAST quote 
    # that is part of that cultivar list. 
    # Logic: Look for "cultivars" and grab everything until a quote that is 
    # followed by a comma AND a new species start (capital letter) OR the end of string.
    
    cultivar_pattern <- "(?i)cultivars\\s+(['\"].+?['\"])(?=\\s*,\\s*[A-Z]|$)"
    
    if (str_detect(v, cultivar_pattern)) {
      v <- str_replace_all(v, cultivar_pattern, function(m) {
        # Replace ONLY the commas inside this specific cultivar block
        str_replace_all(m, ",", "|||")
      })
    }
    
    # Step 1: Split on commas not inside parentheses
    parts <- str_split(v, ",\\s*(?![^()]*\\))")[[1]] |> str_trim()
    
    # Step 2: Restore the internal commas
    parts <- str_replace_all(parts, fixed("|||"), ",")
    
    out <- character(0)
    i <- 1
    
    # Step 3: Standard scientific name merging behavior
    while (i <= length(parts)) {
      part <- parts[i]
      if (str_detect(part, "\\(") && is_scientific_name(part)) {
        j <- i - 1
        while (j >= 1 && is_scientific_name(parts[j]) && !str_detect(parts[j], "\\(")) {
          j <- j - 1
        }
        j <- j + 1
        if (j < i) {
          merged <- paste(parts[j:i], collapse = ", ")
          out <- c(out, merged)
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

#split_to_list("Trachycarpus fortunei, palms (Arecaceae)")
#split_to_list("Castanea sativa × Castanea crenata (hybrid sweet chestnut), Quercus robur, Quercus petraea (oak)")
#split_to_list("Malus spp., Prunus spp., Quercus spp., Ulmus spp., Wisteria spp., Rubus spp., Grasses (amenity turf), Solanum tuberosum, Zea mays, Glycine max, Pinus parviflora (grafted onto P. thunbergii)")
#split_to_list("Pear (Pyrus spp.) – cultivars 'Conference', 'Dicolor', 'Bohemica', Apple (Malus domestica)")
#split_to_list("tea gardens (Camellia sinensis) – cultivars \"Shu\", \"Ping yang te zao\", Pear (Pyrus spp.)")
#split_to_list("mungbean, pigeonpea, soybean, wheat, rice, maize")
#split_to_list("vegetable seedlings; crops")

#comm2sci(c("mungbean", "pigeonpea", "soybean", "wheat", "rice", "maize"), db = 'ncbi', simplify = TRUE)
#res <- gna_verifier("tea gardens (Camellia sinensis)")

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
    #synonyms               = split_to_list(`Synonyms`)
  )

# this one needs manual correction: 
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


# fix one case where the Species entry is given as "Vespula germanica, Vespula vulgaris"
df <- df %>% separate_rows(Species, sep = ", ")
df <- df %>%
  mutate(`Common Name` = case_when(
    EID == "2-s2.0-84920862739" & Species == "Vespula germanica" ~ "German wasp",
    EID == "2-s2.0-84920862739" & Species == "Vespula vulgaris"  ~ "Common wasp",
    TRUE ~ `Common Name` # Keeps all other rows the same
  ))






# check if there are any lists that are different in length 
check_lengths <- df %>%
  mutate(
    n_host = lengths(host_plants),
    n_pest = lengths(herbivore_is_pest),
    n_imp  = lengths(pest_importance),
    n_bca  = lengths(herbivore_is_bca)
  ) %>%
  filter(!(n_host == n_pest & n_host == n_imp & n_host == n_bca))

check_lengths %>%
  dplyr::select(`Host Plants`, n_host, n_pest, n_imp, n_bca, `Herbivore Is Pest`, `Pest Importance`,`Herbivore Is BCA`, EID) 

check_lengths <- df %>%
  mutate(
    n_prey = lengths(prey_species),
    n_imp = lengths(important_enemy),
    n_bio  = lengths(biological_control)
  ) %>%
  filter(!(n_prey == n_imp & n_imp == n_bio & n_prey == n_bio))

check_lengths %>%
  dplyr::select(`Herbivore Prey`, n_prey, n_imp, n_bio, `Important Natural Enemy`, `Biological Control`, EID)






# expand host plants such that each element represents a unique species
# e.g. "Castanea sativa × Castanea crenata (hybrid sweet chestnut)", "Quercus robur, Quercus petraea (oak)" | TRUE, TRUE 
# becomes "Castanea sativa × Castanea crenata (hybrid sweet chestnut)", "Quercus robur (oak)", "Quercus petraea (oak)" | TRUE, TRUE, TRUE 

expand_shared_parentheses <- function(vec) {
  if (length(vec) == 0) return(vec)
  
  # This regex identifies: "Species A, Species B (Common Name)"
  # Group 1: "Species A"
  # Group 2: "Species B"
  # Group 3: "(Common Name)"
  pattern <- "^(.+),\\s+([A-Z][a-z]+(?:\\s+[a-z.-]+)+)\\s+(\\([^)]+\\))$"
  
  unlist(lapply(vec, function(item) {
    if (str_detect(item, pattern)) {
      parts <- str_match(item, pattern)
      prefix_list <- parts[2] 
      last_name   <- parts[3] 
      suffix      <- parts[4] 
      
      split_prefixes <- str_split(prefix_list, ",\\s*")[[1]]
      return(c(paste(split_prefixes, suffix), paste(last_name, suffix)))
    } else {
      return(item)
    }
  }))
}

# 2. Main expansion function
expand_synced_lists <- function(df, target_cols) {
  df %>% 
    rowwise() %>%
    mutate(
      # Create a map of how many items each element in the list will become
      split_map = list(map_int(!!sym(target_cols[1]), ~{
        pattern <- "^(.+),\\s+([A-Z][a-z]+(?:\\s+[a-z.-]+)+)\\s+(\\([^)]+\\))$"
        if (!is.na(.x) && str_detect(.x, pattern)) {
          parts <- str_match(.x, pattern)
          return(length(str_split(parts[2], ",\\s*")[[1]]) + 1)
        }
        return(1)
      }))
    ) %>%
    mutate(across(all_of(target_cols), ~{
      # val is the current list element (e.g., a vector of booleans)
      val <- .x 
      if (length(val) == 0) return(list(val))
      
      res <- if (cur_column() %in% c("host_plants", "prey_species")) {
        # Apply the string split logic
        expand_shared_parentheses(val)
      } else {
        # Duplicate metadata values (TRUE/FALSE) to match the new length
        # Using the split_map calculated from the names column
        rep(val, times = split_map)
      }
      # Return as a list so it stays contained within the single row cell
      list(res)
    })) %>%
    dplyr::select(-split_map) %>%
    ungroup()
}

# 3. Apply to dataset
df <- expand_synced_lists(df, c("host_plants", "herbivore_is_pest", "pest_importance", "herbivore_is_bca"))
df <- expand_synced_lists(df, c("prey_species", "important_enemy", "biological_control"))



############################################
#        harmonising species names         #   
############################################


# Helper: Standardize Binomials (Genus + Species)
prepare_binomial <- function(genus, species) {
  # 1. If species is invalid, return genus (if valid) or NA
  if (is.na(species) || species == "" || toupper(species) == "NA") {
    if (!is.na(genus) && genus != "" && toupper(genus) != "NA") {
      return(genus)
    }
    return(NA_character_)
  }

  # 2. If genus is invalid but species exists, return species as is
  if (is.na(genus) || genus == "" || toupper(genus) == "NA") {
    return(species)
  }

  # 3. Handle abbreviated species (e.g., "A. helianthi" -> "helianthi")
  genus_initial <- substr(genus, 1, 1)
  pattern <- paste0("^", genus_initial, "\\.\\s+")
  clean_species <- sub(pattern, "", species, ignore.case = TRUE)

  # 4. Check if species is ALREADY a binomial.
  # Using a space check prevents "rattus" from matching "^Rattus" and getting cut.
  full_binomial_pattern <- paste0("^", genus, "\\s+")

  if (grepl(full_binomial_pattern, clean_species, ignore.case = TRUE)) {
    return(clean_species)
  }

  # 5. Combine them
  return(paste(genus, clean_species))
}

# Testing the logic:
# prepare_binomial("Acanthiophilus", "A. helianthi")             -> "Acanthiophilus helianthi"
# prepare_binomial("Acanthiophilus", "helianthi")                -> "Acanthiophilus helianthi"
# prepare_binomial("Acanthiophilus", "Acanthiophilus helianthi") -> "Acanthiophilus helianthi"
# prepare_binomial("Acanthiophilus", NA)                         -> "Acanthiophilus helianthi"
# prepare_binomial("Rattus","rattus")                            -> "Rattus rattus"
# prepare_binomial("Rattus","Rattus")                            -> "Rattus"

df <- df %>%
  rowwise() %>%
  mutate(clean_name = prepare_binomial(Genus, Species)) %>%
  ungroup() %>%
  # remove invisible whitespaces and hidden characters
  mutate(across(where(is.character), ~ {
    str_replace_all(.x, "\\p{Cf}", "") %>% # Removes all hidden "Format" characters
      str_replace_all("[[:space:]]+", " ") %>%
      trimws()
  })) # %>% 
  # make sure Synonyms are cleaned up 
  # mutate(Synonyms = if_else(Synonyms %in% c("NA", "", " "), NA, Synonyms)) 



# general corrections
df <- df %>% filter(Genus != "Vastrad") # duplicate of Megastigmus dharwadicus
df <- df %>% filter(Genus != "Rohdain") # duplicate of Turanogonia smirnovi
df <- df %>% filter(clean_name != "Oteifa spp.") # duplicate of Pratylenchus neglectus
df <- df %>% mutate(Phylum = recode(Phylum, "Arterropoda" = "Arthropoda"))




# ensure that `ImportantEnemy` is True if `Biocontrol` is True (but not vice versa)
violations <- mapply(function(bc, ie) {
  any(bc == "True" & ie == "False")
}, df$biological_control, df$important_enemy)

# Count how many rows are affected
sum(violations) # 186

df$important_enemy <- mapply(function(bc, ie) {
  # If biological_control is True, force important_enemy to True; 
  # otherwise, keep the original value of important_enemy
  ifelse(bc == "True", "True", ie)
}, df$biological_control, df$important_enemy, SIMPLIFY = FALSE)

df$important_enemy <- lapply(df$important_enemy, as.character)
df$biological_control <- lapply(df$biological_control, as.character)

# finally, ensuring that there are no repeated entries anywhere
df <- df %>% unique()



# --- Phase 1: Process main species (with synonyms) ---
main_species_ref <- df %>%
  rowwise() %>%
  mutate(clean_name = prepare_binomial(Genus, Species)) %>%
  ungroup() %>%
  filter(!is.na(clean_name)) %>%
  # make sure Synonyms are cleaned up 
  #mutate(Synonyms = if_else(Synonyms %in% c("NA", "", " "), NA, Synonyms)) %>%
  dplyr::select(clean_name, Phylum, Class, Order, Family, Genus, Species, EID) %>% 
  arrange(clean_name)

# --- Phase 2: Process other species (prey species and hyperparasitoids) ---

all_other_species <- df %>%
  # 1. Select the EID and the specific columns of interest
  dplyr::select(EID, prey_species, hyperparasitoids) %>%
  # 2. Pivot the columns so we have one column for the source and one for the lists
  pivot_longer(cols = -EID, names_to = "source_column", values_to = "clean_name") %>%
  # 3. Unnest the list-column into individual rows
  unnest(clean_name) %>%
  # 4. Clean up: remove NAs, empty strings, and duplicates
  filter(!is.na(clean_name), clean_name != "", clean_name != "NA") %>%
  arrange(clean_name) %>% 
  dplyr::select(-source_column)

# 3. Merge 
# Using full_join to keep taxonomic info from main_prep where clean_names match
main_species_ref <- bind_rows(main_species_ref, all_other_species) %>%
  arrange(clean_name)





source("taxonomy_corrections.R")

correction_df <- binomial_corrections

resolve_names <- function(data, correction) {
  data %>%
    left_join(correction, by = "clean_name") %>%
    mutate(
      # Always move toward the corrected name if it exists
      binomial_corrected = coalesce(corrected_name, clean_name),
      Genus = coalesce(corrected_genus, Genus),
      Species = coalesce(corrected_species, Species),
      # If this was a synonym, the original clean_name is the synonym
      mentioned_as  = if_else(is_synonym, clean_name, NA_character_)
    ) %>%
    dplyr::select(-c("corrected_name","corrected_genus","corrected_species","is_synonym"))
}

# correct binomials in `main_species_ref`:
main_species_ref <- resolve_names(main_species_ref, correction_df)

# also correct higher taxonomy: 
main_species_ref <- higher_taxonomy_correction(main_species_ref)





# preprocessing
main_species_ref <- main_species_ref %>%
  # 1. Targeted Cleaning:
  # This regex matches: 
  #   ^        : Start of string
  #   (\\S+)   : First word (captured in group 1)
  #   \\s+     : Space
  #   (?i)...  : Case-insensitive shorthand
  #   $        : End of string (This prevents matching "A. sp. nr. ...")
  mutate(binomial_shortened = str_replace_all(
    binomial_corrected, 
    # Match markers followed by optional space and optional digits
    "(?i)\\s+((sp\\.|spp\\.|ssp\\.|sp\\.\\s+nov\\.|sp\\.\\s+nov\\s+near\\b|sp\\.\\s+nr\\.|sp\\.\\s+nr|sp\\.\\s+n\\.|n\\.\\s+sp\\.|sp\\.\\s+near\\b|near\\b|sp\\.\\s+indet\\.|sp\\.\\s+Indet\\.|sp\\.\\s+innom\\.|innom\\.|indet\\.|Indet\\.|nr\\.|cf\\.|aff\\.|prob\\.|nov\\.|n\\.sp\\.|n\\.1|n\\.2|n\\.\\s+1|n\\.\\s+2|sp\\.\\s+A\\b|sp\\.\\s+B\\b|sp\\.\\s+C\\b|sp\\.\\s+D\\b|sp\\.\\s+E\\b|sp\\.\\s+F\\b|sp\\.\\s+G\\b|sp\\.\\s+I\\b|sp\\.\\s+II\\b|sp\\.\\s+III\\b|sp\\.\\s+IV\\b|sp\\.\\s+V\\b|sp\\.\\s+VI\\b|sp\\.\\s+VII\\b|sp\\.\\s+VIII\\b|sp\\.\\s+IX\\b|sp\\.\\s+X\\b|sp\\.\\s+XI\\b|sp\\.\\s+XII\\b|nr\\b|s\\.l\\.)\\s*\\d*\\s*)+", 
    " " 
  ) %>% str_squish()) %>% # Clean up any double spaces or trailing whitespace
  
  # 2. remove any rows that are completely empty or NA 
  filter(!(
    (is.na(binomial_corrected) | binomial_corrected == "" | binomial_corrected == "NA") &
      (is.na(Phylum)     | Phylum == ""     | Phylum == "NA")     &
      (is.na(Class)      | Class == ""      | Class == "NA")      &
      (is.na(Order)      | Order == ""      | Order == "NA")      &
      (is.na(Family)     | Family == ""     | Family == "NA")
  ))





# harmonising higher taxonomy by replacing taxonomy with most common terms 
get_most_common <- function(x) {
  # Remove NA and empty strings
  valid_x <- x[!is.na(x) & x != "" & x != "character(0)" & x != "NA"]
  
  if (length(valid_x) == 0) return(NA_character_)
  
  # Count frequencies and return the name of the most common one
  counts <- table(valid_x)
  names(counts)[which.max(counts)]
}


# main_species_ref <- readRDS("saved_datasets/main_species_ref.rds")


# Apply to main_species_ref dataframe
main_species_ref <- main_species_ref %>%
  
  # correct errors due to shifted taxonomy: 
  mutate(Phylum = if_else(Class %in% c("Insecta","Arachnida","Arthropoda","Hexapoda"), "Arthropoda", Phylum)) %>% 
  mutate(Phylum = if_else(Class %in% c("Amphibia", "Mammalia", "Aves"), "Chordata", Phylum)) %>% 
  mutate(is_insect = Order == "Insecta",
         Class = if_else(is_insect, "Insecta", Class), # if Order==Insecta, change class to Insecta 
         Order = if_else(is_insect, Family, Order), # if Order==Insecta, shift family info to order 
         Family = if_else(is_insect, NA_character_, Family), # ... and change family to NA 
         is_arthropod = Class == "Arthropoda",
         Class = if_else(is_arthropod, Order, Class), # if Class==Arthropoda, shift order info to class 
         Order = if_else(is_arthropod, Family, Order), # ... and shift family info to order 
         Family = if_else(is_arthropod, NA_character_, Family) # ... and change family to NA 
  ) %>% dplyr::select(-is_insect, -is_arthropod) %>% 
  
  group_by(binomial_shortened) %>%
  mutate(
    Phylum = #if_else(is.na(Phylum) | Phylum == "" | Phylum == "NA", 
                     get_most_common(Phylum),
    Class  = #if_else(is.na(Class) | Class == "" | Class == "NA", 
                     get_most_common(Class), 
    Order  = #if_else(is.na(Order) | Order == "" | Order == "NA", 
                     get_most_common(Order), 
    Family = #if_else(is.na(Family) | Family == "" | Family == "NA", 
                     get_most_common(Family), 
    Genus = #if_else(is.na(Genus) | Genus == "" | Genus == "NA", 
                     get_most_common(Genus), 
    Species = #if_else(is.na(Species) | Species == "" | Species == "NA", 
                     get_most_common(Species)
  ) %>%
  ungroup() %>% 
  unique() 
  
saveRDS(main_species_ref, "saved_datasets/main_species_ref.rds")



# merge these rows into single species entries before calling GBIF
# this combines different species names that point towards the same GBIF name into synonyms

main_species_ref_merged <- main_species_ref %>%
  group_by(binomial_shortened, Phylum, Class, Order, Family, Genus) %>%
  dplyr::summarise(
    EIDs = list(unique(unlist(EID))),
    Synonyms = list({
      # 1. Combine existing synonyms 
      raw_syns <- c(mentioned_as[mentioned_as != binomial_corrected]) # don't use the Synonyms column as it's error-prone -> raw_syns <- c(unlist(Synonyms), mentioned_as[mentioned_as != binomial_corrected])
      
      # 2. Split any strings that contain commas, then flatten (unlist)
      split_syns <- unlist(str_split(raw_syns, ",\\s*"))
      
      # 3. Clean: remove duplicates, NAs, and empty/placeholder strings
      clean_syns <- unique(split_syns)
      clean_syns[!is.na(clean_syns) & trimws(clean_syns) != "" & trimws(clean_syns) != "NA"]
    }),
    .groups = "drop"
  )

# rm(binomial_corrections, all_other_species, check_lengths, correction_df, violations, higher_taxonomy_correction)


safe_extract <- function(val) {
  if (is.null(val) || length(val) == 0) return(NA_character_)
  return(as.character(val))
}


# Helper function to retry API calls on failure
safe_api_call <- function(url, max_retries = 3) {
  attempt <- 1
  while (attempt <= max_retries) {
    res <- tryCatch({
      response <- GET(url)
      
      # Check for HTTP errors before parsing
      if (status_code(response) != 200) {
        stop(paste("HTTP Error:", status_code(response)))
      }
      
      # Verify it's actually JSON content
      if (!grepl("application/json", headers(response)[["content-type"]])) {
        stop("Received HTML/non-JSON response from server")
      }
      
      fromJSON(content(response, "text", encoding = "UTF-8"))
    }, error = function(e) {
      message(paste("Attempt", attempt, "failed for", url, "-", e$message))
      NULL
    })
    
    if (!is.null(res)) return(res)
    
    # Wait before retrying
    Sys.sleep(1.5 * attempt)
    attempt <- attempt + 1
  }
  return(NULL)
}


# obtaining GBIF names and taxonomy for each species name in `main_species_ref_merged` to harmonise names

st1 <- Sys.time()
ref_table <- map_df(1:nrow(main_species_ref_merged), function(i) {
  
  row <- main_species_ref_merged[i, ]
  
  cat(i,"\t|",row$binomial_shortened,"\n")
  
  # ----------------------------
  # Helper function to query GBIF
  # ----------------------------
  try_match <- function(name_to_query, rank_to_query) {
    
    query_list <- list(
      name   = name_to_query,
      rank   = rank_to_query,
      strict = "false",
      verbose = "true",
      phylum = row$Phylum,
      class  = row$Class,
      order  = row$Order,
      family = row$Family,
      genus = row$Genus
    )
    
    query_list <- query_list[sapply(query_list, function(x) {
      !is.na(x) && x != "" && x != "NA" && !is.null(x)
    })]
    
    query_string <- paste0(names(query_list), "=",
                           sapply(query_list, URLencode),
                           collapse = "&")
    
    match_url <- paste0("https://api.gbif.org/v1/species/match?", query_string)
    
    safe_api_call(match_url)
  }
  
  # ----------------------------
  # Define fallback hierarchy
  # ----------------------------
  hierarchy <- list(
    SPECIES = row$binomial_shortened,
    GENUS   = row$Genus,
    FAMILY  = row$Family,
    ORDER   = row$Order,
    CLASS   = row$Class,
    PHYLUM  = row$Phylum
  )
  
  # Clean hierarchy (remove missing levels)
  hierarchy <- hierarchy[sapply(hierarchy, function(x) {
    !is.na(x) && x != "" && x != "NA"
  })]
  
  data <- NULL
  
  # ----------------------------
  # 1. Try main name first
  # ----------------------------
  if (!is.na(row$binomial_shortened) && row$binomial_shortened != "") {
    
    word_count <- str_count(row$binomial_shortened, "\\S+")
    
    if (word_count >= 2) {
      rank_name <- "SPECIES" # assume species
    } else {
      rank_name <- "GENUS"
    }
    data <- try_match(row$binomial_shortened, rank_name)
  }
  
  # ----------------------------
  # 2. Try synonyms if species fails
  # ----------------------------
  if ((is.null(data) || is.null(data$usageKey) || data$rank!=rank_name) &&
      length(row$Synonyms[[1]]) > 0) {
    
    for (syn in row$Synonyms[[1]]) {
      data_syn <- try_match(syn, rank_name)
      if (!is.null(data_syn$usageKey) && data_syn$rank==rank_name){
        data <- data_syn
        break
      }
    }
  }
  
  # if still failed to retreive at the right rank level, check alterantives: 
  if ((is.null(data) || is.null(data$usageKey) || data$rank!=rank_name) && 
      (!is.null(data$alternatives) && length(data$alternatives)>0)){
    # pick first alternative (with highest similarity)
    data_alt <- data$alternatives[1,]
    if (data_alt$matchType=="EXACT"){ 
      if (!is.na(row$Phylum)){
        if (data_alt$phylum==row$Phylum){ # only extract data if it's from the same phylum
          data <- data_alt
        }
      }
    }
  }
  
  # ----------------------------
  # Process success
  # ----------------------------
  if (!is.null(data) && !is.null(data$usageKey)) {
    
    status <- data$status
    matchType <- data$matchType
    
    # obtain synonyms 
    
    taxon_key <- data$usageKey
    
    
    if (matchType!="HIGHERRANK"){
      # if taxon is itself a synonym, take info from species it is a synonym of 
      if (!is.null(data$acceptedUsageKey) && !is.na(data$acceptedUsageKey)){
        if (data$usageKey!=data$acceptedUsageKey){
          taxon_key <- data$acceptedUsageKey
          taxon_url <- paste0(
            "https://api.gbif.org/v1/species/",
            taxon_key)
          data <- safe_api_call(taxon_url)
        }
      }
    }
    
    synonyms_url <- paste0(
      "https://api.gbif.org/v1/species/",
      taxon_key,
      "/synonyms"
    )
    
    synonyms_data <- safe_api_call(synonyms_url)
    
    synonyms_vec <- if (!is.null(synonyms_data$results)) {
      synonyms_data$results$canonicalName
    } else {
      character(0)
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
  }
  
})

# %>% distinct(gbif_id, .keep_all = TRUE)

st2 <- Sys.time()
print(st2 - st1) # Time difference of 6.624816 hours

saveRDS(ref_table, "saved_datasets/gbif_ref_table.rds")


# ref_table <- readRDS("saved_datasets/gbif_ref_table.rds")
ref_table <- ref_table %>%
  mutate(scientificName = if_else(matchType!="HIGHERRANK", scientificName, NA),
         canonicalName  = if_else(matchType!="HIGHERRANK", canonicalName, NA),
         gbif_id        = if_else(matchType!="HIGHERRANK", gbif_id, NA)) %>% 
  # separate higher rank names from rest
  group_by(original_names) %>%
  mutate(synonyms = list({
           combined <- unique(c(unlist(synonyms), unlist(gbif_synonyms)))
           combined[!is.na(combined) & combined != ""]
           }),
         gbif_id        = get_most_common(gbif_id),
         gbif_phylum    = get_most_common(gbif_phylum),
         gbif_class     = get_most_common(gbif_class),
         gbif_order     = get_most_common(gbif_order),
         gbif_family    = get_most_common(gbif_family),
         gbif_genus     = get_most_common(gbif_genus),
         gbif_species   = get_most_common(gbif_species),
         scientificName = get_most_common(scientificName),
         canonicalName  = get_most_common(canonicalName)
         ) %>%
  ungroup() %>% 
  mutate(synonyms = I(synonyms)) %>% 
  # manually correct a GBIF error: 
  mutate(
    synonyms = purrr::map2(
      synonyms,
      gbif_species,
      ~ if (isTRUE(.y == "Pterostichus strenuus")) {
        .x[.x != "Harpalus pygmaeus"]
      } else {
        .x
      }
    )
  ) %>% 
  dplyr::select(gbif_id, gbif_phylum, gbif_class, gbif_order, gbif_family, gbif_genus, gbif_species, scientificName, canonicalName, binomial_shortened = original_names, synonyms, EID = EIDs) %>%
  unnest(EID) %>% 
  distinct() 


#main_species_ref <- readRDS("saved_datasets/main_species_ref.rds")
main_species_ref <- main_species_ref %>% 
  left_join(ref_table, by=c("EID", "binomial_shortened")) %>% 
  mutate(ref_phylum = coalesce(gbif_phylum, if_else(is.na(gbif_phylum), NA, Phylum)),
         ref_class  = coalesce(gbif_class, if_else(is.na(gbif_class), NA, Class)),
         ref_order  = coalesce(gbif_order, if_else(is.na(gbif_order), NA, Order)),
         ref_family = coalesce(gbif_family, if_else(is.na(gbif_family), NA, Family)),
         ref_genus  = coalesce(gbif_genus, if_else(is.na(gbif_genus), NA, Genus)),
         ref_species  = coalesce(gbif_species, if_else(is.na(gbif_species), NA, Species))
         ) %>% 
  dplyr::select(-c(Phylum, Class, Order, Family, Genus, Species, gbif_phylum, gbif_class, gbif_order, gbif_family, gbif_genus, gbif_species)) %>% 
  distinct()


# summarise common names in main_species_ref
# df <- readRDS("saved_datasets/dataset_postprocessed.rds")
main_species_ref <- main_species_ref %>% 
  left_join(
    df %>%
      left_join(main_species_ref %>% dplyr::select(clean_name,EID,canonicalName), by = c("clean_name", "EID")) %>%
      mutate(clean_name = coalesce(canonicalName, clean_name)) %>% 
      group_by(clean_name) %>%
      summarise(
        common_names = I(list(
          `Common Name` %>%
            tolower() %>%
            str_squish() %>%
            .[!{ . %in% c("", "na") | is.na(.) }] %>%
            unique()
        )),
        .groups = "drop"
      ),
    by = c("clean_name")
  )
  

saveRDS(main_species_ref, "saved_datasets/main_species_ref.rds")




combine_binomial <- function(genus, species) {
  # 1. Standardise NAs and empty strings
  genus <- if_else(genus == "" | toupper(genus) == "NA", NA_character_, genus)
  # Treat empty/NA species as an empty string for the logic below
  species_clean <- if_else(is.na(species) | species == "" | toupper(species) == "NA", "", species)
  
  # 2. Logic
  case_when(
    # If genus is NA, return NA
    is.na(genus) ~ NA_character_,
    
    # If genus and species are identical, return NA
    toupper(genus) == toupper(species_clean) ~ NA_character_,
    
    # If species is empty, return NA (since we want a binomial, not just a genus)
    species_clean == "" ~ NA_character_,
    
    TRUE ~ {
      # Remove Genus from the start of species if it's already there
      # e.g., "Aphis" + "Aphis fabae" -> "fabae"
      epithet <- str_remove(species_clean, regex(paste0("^", genus, "\\s*"), ignore_case = TRUE))
      
      # Final check: if after removing the genus nothing is left, return NA
      if_else(epithet == "", NA_character_, paste(genus, epithet))
    }
  )
}



################################################################################
#                               Herbivores                                     # 
################################################################################

herbivory_interactions <- df %>% 
  dplyr::select(clean_name, Phylum, Class, Order, Family, Genus, Species,
                Type, `Feeding Mode`, host_plants, herbivore_is_pest, pest_importance, herbivore_is_bca, associated_plants, associated_industries, invasive, vectors, EID, Abstract, Generated.Response = `Generated Response`) %>%
  unnest(c(host_plants, herbivore_is_pest, pest_importance, herbivore_is_bca)) %>%
  
  # Use the cleaned main_species_ref for the join
  left_join(main_species_ref, by = c("clean_name", "EID")) %>%
  
  mutate(Subject = coalesce(canonicalName, binomial_shortened),
         Subject.Phylum = coalesce(ref_phylum, if_else(is.na(ref_phylum), NA, Phylum)), 
         Subject.Class  = coalesce(ref_class, if_else(is.na(ref_class), NA, Class)), 
         Subject.Order  = coalesce(ref_order, if_else(is.na(ref_order), NA, Order)), 
         Subject.Family = coalesce(ref_family, if_else(is.na(ref_family), NA, Family)), 
         Subject.Genus  = coalesce(ref_genus, if_else(is.na(ref_genus), NA, Genus)), 
         Subject.Species = combine_binomial(Subject.Genus, Subject), # stitch together species name if Subject is composed of genus and/or species
         Subject.ScientificName = scientificName,
         Subject.CanonicalName = canonicalName,
         Subject.Verbatim = clean_name,
         Subject.Synonyms = synonyms, 
         Subject.Common = common_names,
         Subject.ID = gbif_id) %>%
  
  mutate(Object = host_plants) %>% 
  # Final formatting
  transmute(
    Subject = Subject,
    Object = Object,
    Type, 
    Feeding.Mode = `Feeding Mode`,
    Pest = as.logical(herbivore_is_pest),
    Pest.Importance = pest_importance,
    Herbivore.IsBCA = as.logical(herbivore_is_bca),
    Associated.Industries = I(associated_industries), 
    InvasiveIn = I(invasive), 
    Vectors = I(vectors),
    EID, 
    Abstract,
    Generated.Response,
    Subject.Phylum, Subject.Class, Subject.Order, Subject.Family, Subject.Genus, Subject.Species, Subject.ScientificName, Subject.CanonicalName, Subject.Verbatim, Subject.Synonyms, Subject.Common, Subject.ID
  )



################################################################################
#                             Natural enemies                                  # 
################################################################################


predation_interactions <- df %>%
  dplyr::select(clean_name, Phylum, Class, Order, Family, Genus, Species,
                Type, `Feeding Mode`, prey_species, important_enemy, biological_control, associated_plants, associated_industries, vectors, EID, Abstract, Generated.Response = `Generated Response`) %>%
  unnest(c(prey_species, important_enemy, biological_control)) %>%
  
  # 1. Join for Subject
  left_join(main_species_ref, by = c("clean_name", "EID")) %>%
  mutate(Subject = coalesce(canonicalName, binomial_shortened),
         Subject.Phylum = coalesce(ref_phylum, if_else(is.na(ref_phylum), NA, Phylum)), 
         Subject.Class  = coalesce(ref_class, if_else(is.na(ref_class), NA, Class)), 
         Subject.Order  = coalesce(ref_order, if_else(is.na(ref_order), NA, Order)), 
         Subject.Family = coalesce(ref_family, if_else(is.na(ref_family), NA, Family)), 
         Subject.Genus  = coalesce(ref_genus, if_else(is.na(ref_genus), NA, Genus)), 
         Subject.Species = combine_binomial(Subject.Genus, Subject), # stitch together species name if Subject is composed of genus and/or species
         Subject.ScientificName = scientificName,
         Subject.CanonicalName = canonicalName,
         Subject.Verbatim = clean_name,
         Subject.Synonyms = synonyms,
         Subject.Common = common_names,
         Subject.ID = gbif_id) %>%
  
  # Drop joined columns so the next join is 'clean'
  dplyr::select(-starts_with("ref_"), -c(canonicalName, scientificName, binomial_corrected, binomial_shortened, mentioned_as, gbif_id, synonyms, common_names)) %>% 
  
  # 2. Join for Object (Prey)
  left_join(main_species_ref, by = c("prey_species" = "clean_name", "EID")) %>%
  mutate(Object = coalesce(canonicalName, binomial_shortened),
         Object.Phylum = ref_phylum, 
         Object.Class  = ref_class, 
         Object.Order  = ref_order, 
         Object.Family = ref_family, 
         Object.Genus  = ref_genus, 
         Object.Species = combine_binomial(Object.Genus, Object), # stitch together species name if Subject is composed of genus and/or species
         Object.ScientificName = scientificName,
         Object.CanonicalName = canonicalName,
         Object.Verbatim = clean_name,
         Object.Synonyms = synonyms,
         Object.Common = common_names,
         Object.ID = gbif_id) %>%
  
  # 3. Final formatting
  transmute(
    Subject, 
    Object,
    Type,
    Feeding.Mode = `Feeding Mode`,
    Important.Enemy = as.logical(important_enemy),
    Biocontrol = as.logical(biological_control),
    Associated.Plants = I(associated_plants),
    Associated.Industries = I(associated_industries),
    Vectors = I(vectors),
    EID, 
    Abstract,
    Generated.Response,
    Subject.Phylum, Subject.Class, Subject.Order, Subject.Family, Subject.Genus, Subject.Species, Subject.ScientificName, Subject.CanonicalName, Subject.Verbatim, Subject.Synonyms, Subject.Common, Subject.ID,
    Object.Phylum, Object.Class, Object.Order, Object.Family, Object.Genus, Object.Species, Object.ScientificName, Object.CanonicalName, Object.Verbatim, Object.Synonyms, Object.Common, Object.ID
  )



################################################################################
#                            Hyperparasitoids                                  # 
################################################################################

hyperparasitoid_interactions <- df %>%
  dplyr::select(clean_name, Phylum, Class, Order, Family, Genus, Species,
                hyperparasitoids, EID, Abstract, Generated.Response = `Generated Response`) %>%
  unnest(hyperparasitoids) %>%
  
  # 1. Join for Subject
  left_join(main_species_ref, by = c("hyperparasitoids" = "clean_name", "EID")) %>%
  mutate(Subject = coalesce(canonicalName, binomial_shortened),
         Subject.Phylum = ref_phylum,
         Subject.Class  = ref_class, 
         Subject.Order  = ref_order, 
         Subject.Family = ref_family,
         Subject.Genus  = ref_genus, 
         Subject.Species = combine_binomial(Subject.Genus, Subject), # stitch together species name if Subject is composed of genus and/or species
         Subject.ScientificName = scientificName,
         Subject.CanonicalName = canonicalName,
         Subject.Verbatim = clean_name,
         Subject.Synonyms = synonyms,
         Subject.Common = common_names,
         Subject.ID = gbif_id) %>%
  
  # Drop columns so the next join is "clean"
  dplyr::select(-starts_with("ref_"), -c(canonicalName, scientificName, binomial_corrected, binomial_shortened, mentioned_as, gbif_id, synonyms, common_names)) %>% 
  
  # 2. Join for Object (Prey)
  left_join(main_species_ref, by = c("clean_name", "EID")) %>%
  mutate(Object = coalesce(canonicalName, binomial_shortened),
         Object.Phylum = coalesce(ref_phylum, if_else(is.na(ref_phylum), NA, Phylum)), 
         Object.Class  = coalesce(ref_class, if_else(is.na(ref_class), NA, Class)), 
         Object.Order  = coalesce(ref_order, if_else(is.na(ref_order), NA, Order)), 
         Object.Family = coalesce(ref_family, if_else(is.na(ref_family), NA, Family)), 
         Object.Genus  = coalesce(ref_genus, if_else(is.na(ref_genus), NA, Genus)), 
         Object.Species = combine_binomial(Object.Genus, Object), # stitch together species name if Subject is composed of genus and/or species
         Object.ScientificName = scientificName,
         Object.CanonicalName = canonicalName,
         Object.Verbatim = clean_name,
         Object.Synonyms = synonyms,
         Object.Common = common_names,
         Object.ID = gbif_id) %>%
  
  # 3. Final formatting
  transmute(
    Subject, 
    Object,
    Type = "natural enemy",
    Feeding.Mode = "hyperparasitism",
    EID, 
    Abstract,
    Generated.Response,
    Subject.Phylum, Subject.Class, Subject.Order, Subject.Family, Subject.Genus, Subject.Species, Subject.ScientificName, Subject.Verbatim, Subject.Synonyms, Subject.Common, Subject.ID,
    Object.Phylum, Object.Class, Object.Order, Object.Family, Object.Genus, Object.Species, Object.ScientificName, Object.Verbatim, Object.Synonyms, Object.Common, Object.ID
  )



################################################################################
#                       Final interactions dataframe                           # 
################################################################################


predation_interactions <- full_join(predation_interactions, hyperparasitoid_interactions)

interactions_df <- full_join(herbivory_interactions, predation_interactions)

# remove possible cases of cannibalism  
interactions_df <- interactions_df %>% filter(Subject != Object) # 21 cases

# include other meta data from scopus 
scopus <- readRDS("../1_ollama-main/scopus/scopus_complete.rds")

interactions_df <- left_join(interactions_df, scopus %>% dplyr::select(-Abstract), by="EID")



# removal of viral, bacterial and fungal pathogens: 

# how many fungi (including stramenopiles and water moulds)? 
fungi_phyla <- c("Ascomycota","Basidiomycota","Blastocladiomycota","Chytridiomycota","Entomophthoromycota","Glomeromycota","Mucoromycota","Microsporidia","Ochrophyta","Oomycota")
length(
  unique(
    na.omit(append(
      interactions_df %>% filter(Subject.Phylum %in% fungi_phyla) %>% pull(Subject.Species), 
      interactions_df %>% filter(Object.Phylum %in% fungi_phyla) %>% pull(Object.Species)
    )
  ))
) # 331

# how many bacteria? 
bacteria_phyla <- c("Actinobacteriota","Cyanobacteria","Firmicutes","Proteobacteria")
length(
  unique(
    na.omit(append(
      interactions_df %>% filter(Subject.Phylum %in% bacteria_phyla) %>% pull(Subject.Species), 
      interactions_df %>% filter(Object.Phylum %in% bacteria_phyla) %>% pull(Object.Species)
    )
  ))
) # 75

# how many protozoa? 
protozoa_phyla <- c("Amoebozoa","Cercozoa","Ciliophora","Euglenozoa","Metamonada","Mycetozoa","Myzozoa")
length(
  unique(
    na.omit(append(
      interactions_df %>% filter(Subject.Phylum %in% protozoa_phyla) %>% pull(Subject.Species), 
      interactions_df %>% filter(Object.Phylum %in% protozoa_phyla) %>% pull(Object.Species)
    )
  ))
) # 33

# how many plants? 
plants_phyla <- c("Chlorophyta","Rhodophyta","Tracheophyta")
length(
  unique(
    na.omit(append(
      interactions_df %>% filter(Subject.Phylum %in% plants_phyla) %>% pull(Subject.Species), 
      interactions_df %>% filter(Object.Phylum %in% plants_phyla) %>% pull(Object.Species)
    )
  ))
) # 29

# fungi
nrow(interactions_df %>% filter(Subject.Phylum %in% fungi_phyla, Type=='herbivore')) # 1
nrow(interactions_df %>% filter(Subject.Phylum %in% fungi_phyla, Type=='natural enemy')) # 3127

# bacteria
nrow(interactions_df %>% filter(Subject.Phylum %in% bacteria_phyla, Type=='herbivore')) # 0
nrow(interactions_df %>% filter(Subject.Phylum %in% bacteria_phyla, Type=='natural enemy')) # 333

# protozoa
nrow(interactions_df %>% filter(Subject.Phylum %in% protozoa_phyla, Type=='herbivore')) # 4
nrow(interactions_df %>% filter(Subject.Phylum %in% protozoa_phyla, Type=='natural enemy')) # 102

# plants
nrow(interactions_df %>% filter(Subject.Phylum %in% plants_phyla, Type=='herbivore')) # 19
nrow(interactions_df %>% filter(Subject.Phylum %in% plants_phyla, Type=='natural enemy')) # 10


# filter out plants entirely 
interactions_df <- interactions_df %>% filter(!(Subject.Phylum %in% plants_phyla))

# categorise rest as "Pathogen" 
interactions_df[(interactions_df$Subject.Phylum %in% fungi_phyla) | 
                (interactions_df$Subject.Phylum %in% bacteria_phyla) | 
                (interactions_df$Subject.Phylum %in% protozoa_phyla),
                c("Type","Feeding.Mode")] <- list("pathogen",NA)


interactions_df <- interactions_df %>%
  mutate(across(where(is.character), ~na_if(., "NA")))


bad_industries <- c(
  "arby crops",
  "arberry crops",
  "arbitrary crops",
  "arbyle crops",
  "arbage crops",
  "arbile crops",
  "arbor​e crops",
  "arbrate crops",
  "arbyl crops",
  "ardrable crops",
  "array crops"
)

interactions_df <- interactions_df %>%
  mutate(
    Associated.Industries = map(
      Associated.Industries,
      ~ .x[!(.x %in% bad_industries)]
    )
  )


saveRDS(interactions_df %>% filter(Type == 'pathogen'), "saved_datasets/interactions_data_pathogens.rds", compress = "xz")
saveRDS(interactions_df %>% filter(Type != 'pathogen'), "../DAPHNE_database.rds", compress = "xz")





interactions_df <- readRDS("../DAPHNE_database.rds")

nrow(interactions_df) # 175404
 
interactions_df %>% filter(lengths(InvasiveIn)!=0) %>% pull(Subject) %>% n_distinct() # 782
interactions_df %>% filter(lengths(InvasiveIn)!=0) %>% pull(Type) %>% table # herbivore 7150

interactions_df %>% filter(lengths(Vectors)!=0) %>% pull(Subject) %>% n_distinct() # 711
interactions_df %>% filter(lengths(Vectors)!=0) %>% pull(Type) %>% table # herbivore 4319, natural enemy 397
interactions_df %>% filter(lengths(Vectors)!=0, Type=='herbivore') %>% pull(Subject) %>% n_distinct() # 625
interactions_df %>% filter(lengths(Vectors)!=0, Type=='natural enemy') %>% pull(Subject) %>% n_distinct() # 86

sum(lengths(interactions_df$InvasiveIn) != 0) # 7150
sum(lengths(interactions_df$Vectors) != 0) # 4716

nrow(interactions_df %>% filter(Type=='herbivore')) # 131129 
nrow(interactions_df %>% filter(Type=='natural enemy')) # 44275

nrow(interactions_df %>% filter(Feeding.Mode=='herbivory')) # 104557
nrow(interactions_df %>% filter(Feeding.Mode=='frugivory')) # 9653
nrow(interactions_df %>% filter(Feeding.Mode=='granivory')) # 12178
nrow(interactions_df %>% filter(Feeding.Mode=='gall formation')) # 4741
nrow(interactions_df %>% filter(Type=='herbivore' & is.na(Feeding.Mode))) # 0

nrow(interactions_df %>% filter(Feeding.Mode=='predation')) # 18112
nrow(interactions_df %>% filter(Feeding.Mode=='parasitism')) # 25233
nrow(interactions_df %>% filter(Feeding.Mode=='hyperparasitism')) # 820
nrow(interactions_df %>% filter(Type=='natural enemy' & is.na(Feeding.Mode))) # 110


# number of unique taxa resolved at the species level
length(
  unique(
    append(
      interactions_df %>% pull(Subject.Species), 
      interactions_df %>% pull(Object.Species)
    )
  )
) # 16755

# linked to GBIF specifically 
length(
  unique(
    append(
      interactions_df %>% filter(str_count(Subject.CanonicalName, "\\w+") > 1) %>% pull(Subject.CanonicalName), 
      interactions_df %>% filter(str_count(Object.CanonicalName, "\\w+") > 1) %>% pull(Object.CanonicalName)
    )
  )
) # 15017



# Plotting classes 

plot_classes <- function(interactions_df, title, feeding_modes, target_classes, filename, order_text_size=1.8, xlab="Species Count", ylab="Class"){
  
  plot_data <- interactions_df %>%
    filter(
      Feeding.Mode %in% feeding_modes,
      str_count(Subject.CanonicalName, "\\w+") > 1
    ) %>%
    dplyr::select(Subject.CanonicalName, Subject.Phylum, Subject.Class, Subject.Order) %>%
    distinct() %>%
    
    # Create class labels, putting incomplete taxonomy into "Other classes"
    mutate(
      Phylum_Class = case_when(
        is.na(Subject.Phylum) | is.na(Subject.Class) |
          Subject.Phylum == "" | Subject.Class == "" ~ "Other classes",
        TRUE ~ paste0(Subject.Phylum, ": ", Subject.Class)
      )
    ) %>%
    
    # Also collapse singleton classes into "Other classes"
    group_by(Phylum_Class) %>%
    mutate(class_total = n()) %>%
    ungroup() %>%
    mutate(
      Phylum_Class = if_else(
        Phylum_Class != "Other classes" & class_total < 10,
        "Other classes",
        Phylum_Class
      )
    ) %>%
    
    # Count orders within classes
    group_by(Phylum_Class, Subject.Order) %>%
    mutate(order_count = n()) %>%
    ungroup() %>%
    
    # Decide which labels to show
    mutate(
      Sub_Group_Name = case_when(
        Phylum_Class %in% target_classes & order_count >= 10 ~ Subject.Order,
        TRUE ~ Phylum_Class
      )
    ) %>%
    
    # Aggregate counts
    count(Phylum_Class, Sub_Group_Name) %>%
    group_by(Phylum_Class) %>%
    # 1. Arrange strictly by size (Descending for Large -> Small)
    arrange(desc(n)) %>% 
    mutate(
      # 2. Assign color rank based on this strict descending order
      rank_in_bar = row_number(),
      total_bar_n = sum(n),
      color_id = if_else(Phylum_Class %in% target_classes, as.character(rank_in_bar), "base")
    ) %>%
    ungroup() %>%
    # 3. CRITICAL: Force the factor levels of the subgroup to follow the size order
    # This prevents ggplot from default-sorting alphabetically
    mutate(Sub_Group_Name = reorder(Sub_Group_Name, n)) %>%
    mutate(Phylum_Class = reorder(Phylum_Class, total_bar_n))
  
  # 2. Define consistent color palette
  # "base" is grey; "1", "2", etc., follow a specific sequence
  unique_ranks <- sort(unique(plot_data$color_id[plot_data$color_id != "base"]))
  #palette_values <- c("base" = "grey85", setNames(scales::hue_pal()(length(unique_ranks)), unique_ranks))
  n_colors <- length(unique_ranks)
  target_colors <- colorRampPalette(scales::brewer_pal(palette = "Pastel2")(8))(n_colors)
  palette_values <- c("base" = "grey90", setNames(target_colors, unique_ranks))
  
  # 3. Plot
  classPlot <- ggplot(plot_data, aes(y = Phylum_Class, x = n, fill = color_id, group = rank_in_bar)) +
    geom_col(show.legend = FALSE, color = "white", linewidth = 0.2) + 
    geom_text(
      aes(label = if_else(Phylum_Class %in% target_classes, Sub_Group_Name, "")),
      # position_stack uses the 'group' aesthetic to decide order
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
    labs(
      title = title,
      x = xlab,
      y = ylab
    ) +
    theme_minimal() + 
    theme(
      #panel.grid.major = element_blank(), 
      panel.grid.minor = element_blank()
    )
  
  #ggsave(filename = sprintf("figures/%s", filename), classPlot, width = 320, height = 130, units = "mm", dpi = 300)
  
  return(classPlot) 
}


# 1. plot herbivore phyla
p1 <- plot_classes(interactions_df,
                   title = "a. Herbivores",
                   feeding_modes = c('herbivory'), 
                   target_classes = c("Arthropoda: Insecta", "Arthropoda: Arachnida", "Chordata: Mammalia", "Nematoda: Chromadorea"), 
                   filename="class_counts_herbivores.png",
                   order_text_size=1.3,
                   xlab="", ylab="")

# 2. plot predator phyla 
p2 <- plot_classes(interactions_df,
                   title = "b. Predators",
                   feeding_modes = c('predation'), 
                   target_classes = c("Arthropoda: Insecta", "Arthropoda: Arachnida", "Chordata: Mammalia", "Chordata: Aves"), 
                   filename="class_counts_predators.png",
                   order_text_size=1.6,
                   xlab="", ylab="Class")

# 3. plot parasite/parasitoid/hyperparasitoid phyla 
p3 <- plot_classes(interactions_df,
                   title = "c. Parasites, parasitoids and hyperparasitoids", 
                   feeding_modes = c('parasitism', 'hyperparasitism'), 
                   target_classes = c("Arthropoda: Insecta", "Ascomycota: Sordariomycetes", "Nematoda: Chromadorea"), 
                   filename="class_counts_parasitoids.png",
                   order_text_size=1.6,
                   xlab="Species Count", ylab="")


combined_plot <- (p1 / p2 / p3) + 
  plot_layout(guides = "collect") & 
  theme(axis.title = element_text(size = 12),
        axis.text.y = element_text(size = 8))

ggsave("figures/class_counts.pdf", combined_plot, width = 350, height = 200, units = "mm", dpi = 500)



