################################################################################
#                                                                              #
#   Main figure (figures/interaction_network_summary.png)                      #
#                                                                              #
#   a. global crop - herbivore - natural enemy network                         #
#   b. interactions per feeding mode                                           #
#   c. interactions with pest / natural-enemy labels and associated industries #
#   d. number of taxa per group                                                #
#                                                                              #
#   1. Load data and crop definitions                                          #
#   2. Interactions: herbivores on crops, natural enemies on their prey        #
#   3. Graph (largest connected component)                                     #
#   4. Panel a: network                                                        #
#   5. Panels b-d: summaries                                                   #
#   6. Combine and save                                                        #
#                                                                              #
################################################################################

library(dplyr)
library(stringr)
library(igraph)
library(ggraph)
library(ggplot2)



################################################################################
#                   1. Load data and crop definitions                          #
################################################################################

interactions_df <- readRDS("../DAPHNE.rds")

source("crop_definitions.r") # crop_lookup: crop name patterns shared by all scripts



################################################################################
#       2. Interactions: herbivores on crops, natural enemies on their prey    #
################################################################################

# Species-level Subjects only (genus-only names are dropped), without subspecies
species_level <- function(df) {
  df %>%
    filter(str_count(Subject, "\\w+") > 1) %>%
    mutate(Subject = word(Subject, 1, 2))
}

# Herbivore -> crop (one edge per crop matched by the host plant name)
herbivory <- interactions_df %>%
  filter(Type == "herbivore") %>%
  species_level() %>%
  cross_join(crop_lookup %>% dplyr::select(crop_name, pattern)) %>%
  filter(str_detect(tolower(Object), pattern)) %>%
  mutate(Object = crop_name)

# Natural enemy -> prey (predation, parasitism, hyperparasitism); prey are cut to
# species level, single-word prey names (e.g. "Aphididae") are kept
enemies <- interactions_df %>%
  filter(Type == "natural enemy", Feeding.Mode %in% c("predation", "parasitism", "hyperparasitism")) %>%
  species_level() %>%
  mutate(Object = if_else(str_count(Object, "\\w+") > 2, word(Object, 1, 2), Object))

interactions <- bind_rows(herbivory, enemies) %>%
  filter(!is.na(Subject), Subject != "", !is.na(Object), Object != "", !is.na(Feeding.Mode)) %>%
  mutate(Label = str_to_sentence(Feeding.Mode)) # e.g. "gall formation" -> "Gall formation"

# One edge per Subject, Object and interaction type, with the number of abstracts
edges <- interactions %>%
  group_by(Subject, Object, Label) %>%
  summarise(n = n_distinct(EID), .groups = "drop")

# Node roles (a species with several roles gets the highest trophic one)
herbivore_modes <- c("Herbivory", "Frugivory", "Granivory", "Gall formation")
role_of <- function(labels) unique(interactions$Subject[interactions$Label %in% labels])

nodes <- tibble(name = unique(c(edges$Subject, edges$Object))) %>%
  mutate(role = case_when(
    name %in% role_of("Hyperparasitism")             ~ "Hyperparasitoid",
    name %in% role_of(c("Predation", "Parasitism"))  ~ "Natural enemy",
    name %in% role_of(herbivore_modes)               ~ "Herbivore",
    name %in% crop_lookup$crop_name                  ~ "Crop",
    TRUE                                             ~ "Prey only"
  ))

table(edges$Label)
table(nodes$role)



################################################################################
#                  3. Graph (largest connected component)                      #
################################################################################

g <- graph_from_data_frame(d = edges, vertices = nodes, directed = TRUE)

# sizes of the largest components
sort(components(g)$csize, decreasing = TRUE)[1:20]

comp   <- components(g)
g_main <- induced_subgraph(g, vids = which(comp$membership == which.max(comp$csize)))

cat("Nodes:", vcount(g_main), "\n")
cat("Edges:", ecount(g_main), "\n")



################################################################################
#                            4. Panel a: network                               #
################################################################################

interaction_colors <- c(
  "Herbivory"       = "#228B22", # dark green
  "Frugivory"       = "#F0A202", # orange
  "Granivory"       = "#8C510A", # brown
  "Gall formation"  = "grey",
  "Predation"       = "#377EB8", # blue
  "Parasitism"      = "#B2182B", # dark red
  "Hyperparasitism" = "#762A83"  # dark purple
)

# Force-directed layout (DrL); fixed seed for a reproducible figure
set.seed(123)
lay <- create_layout(g_main, layout = "drl")

# Edges only, faint so that dense parts of the network stand out
network_plot <- ggraph(lay) +
  geom_edge_link(aes(colour = Label), linewidth = 0.2, alpha = 0.15, show.legend = FALSE) +
  scale_edge_colour_manual(values = interaction_colors) +
  theme_void()

# Legend from a dummy plot, as the faint network edges would give a near-invisible legend
legend_plot <- ggplot(tibble(Interaction = factor(names(interaction_colors), levels = names(interaction_colors))),
                      aes(colour = Interaction)) +
  geom_segment(aes(x = 0, xend = 1, y = Interaction, yend = Interaction), linewidth = 2.5, lineend = "round") +
  scale_colour_manual(values = interaction_colors, name = "Interaction") +
  guides(colour = guide_legend(nrow = 2, byrow = TRUE, override.aes = list(linewidth = 3, alpha = 1))) +
  theme_void() +
  theme(legend.position = "bottom",
        legend.title = element_text(face = "bold", size = 11),
        legend.text  = element_text(size = 10))

final_network <- cowplot::plot_grid(network_plot, cowplot::get_legend(legend_plot),
                                    ncol = 1, rel_heights = c(1, 0.08))



################################################################################
#                         5. Panels b-d: summaries                             #
################################################################################

# Shared style of the bar charts
bar_theme <- theme_classic() +
  theme(axis.text    = element_text(size = 13),
        axis.title.x = element_text(size = 14),
        axis.title.y = element_text(size = 14))

bar_labels <- function(...) geom_text(aes(label = scales::comma(n)), size = 4, ...)


# --- b. Interactions (records) per feeding mode ---

mode_summary <- interactions_df %>%
  filter(!is.na(Feeding.Mode)) %>%
  count(Interaction = str_to_sentence(Feeding.Mode)) %>%
  mutate(Interaction = factor(Interaction, levels = rev(names(interaction_colors))))

bar_plot <- ggplot(mode_summary, aes(x = n, y = Interaction, fill = Interaction)) +
  geom_col(width = 0.7) +
  bar_labels(hjust = -0.1) +
  scale_x_continuous(labels = scales::comma, breaks = scales::breaks_width(50000), expand = expansion(mult = c(0, 0.25))) +
  scale_fill_manual(values = interaction_colors, guide = "none") +
  labs(x = "Number of interactions", y = NULL) +
  bar_theme +
  theme(plot.margin = margin(5.5, 25, 5.5, 5.5)) # room for the last axis label


# --- c. Interactions (records) with pest / natural-enemy labels ---

n_records_with <- function(flag) sum(flag %in% TRUE)

importance_summary <- tibble(
  Category = c("Pest", "Major pest", "Minor pest", "Herbivore Biocontrol", "Important enemy", "Enemy Biocontrol"),
  Group    = c(rep("Herbivore", 4), rep("Natural enemy", 2)),
  n = c(n_records_with(interactions_df$Pest),
        n_records_with(interactions_df$Pest.Importance == "major"),
        n_records_with(interactions_df$Pest.Importance == "minor"),
        n_records_with(interactions_df$Herbivore.IsBCA),
        n_records_with(interactions_df$Important.Enemy),
        n_records_with(interactions_df$Biocontrol))
) %>%
  mutate(Category = factor(Category, levels = Category))

importance_plot <- ggplot(importance_summary, aes(x = Category, y = n, fill = Group)) +
  geom_col(width = 0.7, alpha = 0.5) +
  bar_labels(vjust = -0.3) +
  scale_fill_manual(values = c("Herbivore" = "darkgreen", "Natural enemy" = "darkblue"), guide = "none") +
  scale_y_continuous(labels = scales::comma, expand = expansion(mult = c(0, 0.3))) +
  labs(x = "Interaction label", y = "Number of interactions") +
  bar_theme +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        plot.margin = margin(70, 5.5, 5.5, 5.5)) # room for the panel label "c."


# --- c. Interactions (records) per associated industry ---

industry_summary <- interactions_df %>%
  tidyr::unnest(cols = Associated.Industries) %>%
  filter(!is.na(Associated.Industries), !Associated.Industries %in% c("NA", "other")) %>%
  count(Associated.Industries) %>%
  mutate(Associated.Industries = forcats::fct_reorder(Associated.Industries, n, .desc = TRUE))

industry_plot <- ggplot(industry_summary, aes(x = Associated.Industries, y = n)) +
  geom_col(width = 0.7, alpha = 0.4, fill = "darkgreen") +
  bar_labels(vjust = -0.3) +
  scale_y_continuous(labels = scales::comma, expand = expansion(mult = c(0, 0.3))) +
  labs(x = "Industry associated with the species or host plant", y = "Number of interactions") +
  bar_theme +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, vjust = 1))


# --- d. Number of taxa (resolved at species level) per group ---

n_species <- function(rows, include_objects = TRUE) {
  n_distinct(c(interactions_df$Subject.Species[rows],
               if (include_objects) interactions_df$Object.Species[rows]), na.rm = TRUE)
}
all_rows <- rep(TRUE, nrow(interactions_df))

taxa_summary <- tibble(
  Taxa = c("Total", "Herbivore", "Natural enemy", "Invasive", "Vector"),
  n = c(n_species(all_rows),                                                   # all Subjects and Objects
        n_species(interactions_df$Type == "herbivore", include_objects = FALSE), # herbivores
        n_species(interactions_df$Type == "natural enemy", include_objects = FALSE), # natural enemies
        n_species(lengths(interactions_df$InvasiveIn) > 0, include_objects = FALSE), # invasive species
        n_species(lengths(interactions_df$Vectors) > 0, include_objects = FALSE))    # vectors
) %>%
  mutate(Taxa = forcats::fct_reorder(Taxa, n, .desc = TRUE))

taxa_numbers_plot <- ggplot(taxa_summary, aes(x = Taxa, y = n, fill = Taxa)) +
  geom_col(width = 0.7, alpha = 0.5) +
  bar_labels(vjust = -0.3) +
  scale_fill_manual(values = c("Total" = "black", "Herbivore" = "darkgreen", "Natural enemy" = "darkblue",
                               "Invasive" = "darkred", "Vector" = "darkorange"), guide = "none") +
  scale_y_continuous(labels = scales::comma, expand = expansion(mult = c(0, 0.15))) +
  labs(x = "Group", y = "Number of taxa") +
  bar_theme +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, vjust = 1))

mode_summary
importance_summary
taxa_summary



################################################################################
#                           6. Combine and save                                #
################################################################################

panel_label <- list(label_size = 24, label_fontface = "bold")

top_row <- do.call(cowplot::plot_grid, c(list(final_network, bar_plot, rel_widths = c(1.705, 1), labels = c("a.", "b.")), panel_label))

left_column <- do.call(cowplot::plot_grid, c(list(importance_plot, industry_plot, ncol = 1, align = "v", labels = c("c.", "")), panel_label))

bottom_row <- do.call(cowplot::plot_grid, c(list(left_column, taxa_numbers_plot, rel_widths = c(1.5, 1), labels = c("", "d.")), panel_label))

final_figure <- cowplot::plot_grid(top_row, bottom_row, ncol = 1, rel_heights = c(1, 1))

ggsave("../figures/interaction_network_summary.png", final_figure,
       width = 14, height = 14, units = "in", dpi = 400, bg = "white")
