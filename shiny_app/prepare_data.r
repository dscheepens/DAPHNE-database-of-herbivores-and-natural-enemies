################################################################################
#                                                                              #
#   Builds the data files used by app.r from DAPHNE.rds                        #
#                                                                              #
#   - crops.rds                   crop names and FAO groups (menu of the app)  #
#   - herbivore_edges_<crop>.rds  herbivore interactions on each crop          #
#   - enemy_edges.rds             all natural-enemy interactions               #
#                                                                              #
#   Run from the shiny_app/ folder:  Rscript prepare_data.r                    #
#                                                                              #
################################################################################

library(dplyr)
library(stringr)

daphne_path <- "../DAPHNE.rds"


source("../4_dataset-post-processing/crop_definitions.r") # crop_lookup: crop name patterns shared with the post-processing scripts


# Columns of DAPHNE used by the app
app_cols <- c("Subject", "Object", "Feeding.Mode", "Pest", "Pest.Importance", "Important.Enemy", "Biocontrol",
              "InvasiveIn", "Vectors", "EID", "Abstract", "Generated.Response",
              "Subject.Verbatim", "Object.Verbatim",
              "Subject.Phylum", "Subject.Class", "Subject.Order", "Subject.Family",
              "Object.Phylum", "Object.Class", "Object.Order", "Object.Family",
              "Title", "Year", "Source title", "DOI", "Link", "Author Keywords", "Index Keywords")

# Keep species-level Subjects only (genus-only names are dropped), without subspecies
species_level <- function(df) {
  df %>%
    filter(str_count(Subject, "\\w+") > 1) %>%
    mutate(Subject = word(Subject, 1, 2))
}

daphne <- readRDS(daphne_path)


# Herbivores on each crop (host plant matched to the crop's name pattern)
herbivore_edges <- daphne %>%
  filter(Type == "herbivore") %>%
  species_level() %>%
  dplyr::select(all_of(app_cols)) %>%
  cross_join(crop_lookup %>% dplyr::select(crop_name, pattern)) %>%
  filter(str_detect(tolower(Object), pattern)) %>%
  dplyr::select(-pattern)

# Natural enemies; prey are also cut to species level (single-word prey names are kept)
enemy_edges <- daphne %>%
  filter(Type == "natural enemy") %>%
  species_level() %>%
  mutate(Object = if_else(str_count(Object, "\\w+") > 2, word(Object, 1, 2), Object)) %>%
  dplyr::select(all_of(app_cols))


# One file per crop, so the app only loads the crop being viewed
for (crop in crop_lookup$crop_name) {
  saveRDS(herbivore_edges %>% filter(crop_name == crop),
          paste0("herbivore_edges_", crop, ".rds"), compress = "xz")
}
saveRDS(enemy_edges, "enemy_edges.rds", compress = "xz")
saveRDS(crop_lookup %>% dplyr::select(crop_name, crop_group, crop_class), "crops.rds")

# Summary: herbivore interactions per crop
print(herbivore_edges %>% count(crop_name, sort = TRUE), n = Inf)
