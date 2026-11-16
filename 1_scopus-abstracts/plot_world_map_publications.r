################################################################################
#                                                                              #
#   World map of the number of articles per country                            #
#   (figures/world_map_publications.png)                                       #
#                                                                              #
#   Article counts per country are taken from the Scopus search results.       #
#                                                                              #
################################################################################

library(sf)
library(dplyr)
library(ggplot2)
library(rnaturalearth)

# -----------------------------
# 1. Create dataframe
# -----------------------------

data <- tribble(
  ~country, ~articles,
  "United States", 34860,
  "China", 18118,
  "India", 11846,
  "United Kingdom", 8492,
  "Brazil", 8370,
  "Australia", 7159,
  "Canada", 6068,
  "France", 5315,
  "Germany", 5079,
  "Italy", 4697,
  "Spain", 4424,
  "Japan", 3368,
  "New Zealand", 3291,
  "Iran", 3017,
  "Pakistan", 2902,
  "Mexico", 2879,
  "South Africa", 2857,
  "Turkey", 2642,
  "Netherlands", 2600,
  "Egypt", 2502,
  "Switzerland", 2469,
  "Argentina", 2070,
  "Belgium", 1966,
  "South Korea", 1814,
  "Kenya", 1645,
  "Sweden", 1632,
  "Indonesia", 1511,
  "Czech Republic", 1505,
  "Poland",1387,
  "Greece",1370,
  "Israel",1351,
  "Saudi Arabia",1280,
  "Nigeria",1234,
  "Denmark",1135,
  "Colombia",1099,
  "Malaysia",1077,
  "Russian Federation",1047,
  "Austria",954,
  "Thailand",952,
  "Portugal",911,
  "Hungary",879,
  "Philippines",827,
  "Chile",771,
  "Taiwan",768,
  "Finland",745,
  "Ethiopia",640,
  "Norway",602,
  "Benin",558,
  "Viet Nam",545,
  "Tunisia",545,
  "Ghana",538,
  "Bangladesh",529,
  "Tanzania",517,
  "Morocco",493,
  "Serbia",455,
  "Uganda",450,
  "Iraq",424,
  "Cameroon",420,
  "Ireland",419,
  "Algeria",395,
  "Romania",380,
  "Bulgaria",363,
  "Slovenia",342,
  "Ecuador",314,
  "Croatia",314,
  "Slovakia",304,
  "Peru",288,
  "Costa Rica",268,
  "Ukraine",264,
  "Sri Lanka",234,
  "Uruguay",228,
  "Burkina Faso",213,
  "Zimbabwe",210,
  "Senegal",210,
  "Syrian Arab Republic",182,
  "Nepal",167,
  "Sudan",161,
  "Estonia",156,
  "Jordan",148,
  "Lithuania",145,
  "Cote d'Ivoire",144,
  "Venezuela",137,
  "Singapore",135,
  "Panama",133,
  "Cuba",132,
  "Kazakhstan",130,
  "Zambia",124,
  "Malawi",121,
  "Puerto Rico",114,
  "Trinidad and Tobago",104,
  "United Arab Emirates",97,
  "Hong Kong",96,
  "Oman",95,
  "Niger",95,
  "Mali",94,
  "Lebanon",93,
  "Rwanda",90,
  "Papua New Guinea",89,
  "Botswana",89,
  "Cyprus",86,
  "Uzbekistan",84,
  "Latvia",83,
  "Madagascar",72,
  "Togo",70,
  "Georgia",70,
  "Mozambique",69,
  "Guatemala",64,
  "Cambodia",57,
  "Myanmar",56,
  "Honduras",55,
  "Democratic Republic Congo",52,
  "Qatar",47,
  "Palestine",46,
  "Laos",45,
  "Luxembourg",44,
  "Bolivia",44,
  "Türkiye",43,
  "Guam",43,
  "Namibia",42,
  "Fiji",42,
  "Azerbaijan",39,
  "Bosnia and Herzegovina",38,
  "Swaziland",37,
  "Jamaica",35,
  "Albania",35,
  "Mauritius",34,
  "Iceland",34,
  "Congo",34,
  "Yemen",32,
  "Armenia",32,
  "Paraguay",30,
  "Mongolia",29,
  "Kuwait",29,
  "North Macedonia",28,
  "Belarus",28,
  "New Caledonia",27,
  "Nicaragua",25,
  "Burundi",23,
  "Dominican Republic",22,
  "Bhutan",21,
  "Sierra Leone",20,
  "Reunion", 20,
  "Kyrgyzstan", 20,
  "El Salvador", 19,
  "North Korea", 18,
  "Moldova", 18,
  "French Polynesia", 17,
  "Guadeloupe", 17,
  "Solomon Islands", 16,
  "Libya", 16,
  "Martinique", 15,
  "Gabon", 14,
  "Montenegro", 13,
  "Gambia", 13,
  "Afghanistan", 13,
  "Samoa", 12,
  "Mauritania", 12,
  "Brunei Darussalam", 12
)

# -----------------------------
# 2. Harmonize country names
# -----------------------------

data <- data %>%
  mutate(country = recode(country,
                          "United States" = "United States of America",
                          "Russian Federation" = "Russia",
                          "Viet Nam" = "Vietnam",
                          "Syrian Arab Republic" = "Syria",
                          "Cote d'Ivoire" = "Côte d'Ivoire",
                          "Brunei Darussalam" = "Brunei",
                          "Swaziland" = "eSwatini",
                          "Türkiye" = "Turkey",
                          "Democratic Republic Congo" = "Dem. Rep. Congo",
                          "Bosnia and Herzegovina" = "Bosnia and Herz.",
                          "Czech Republic" = "Czechia",
                          "Dominican Republic" = "Dominican Rep.",
                          "French Polynesia" = "Fr. Polynesia",
                          "Solomon Islands" = "Solomon Is.",
                          "Guadeloupe" = "France",
                          "Martinique" = "France",
                          "Reunion" = "France"
  ))

# Because multiple rows may now map to the same sovereign country (e.g., France + Guadeloupe + Reunion), aggregate first:
data <- data %>%
  group_by(country) %>%
  summarise(articles = sum(articles), .groups = "drop")

# -----------------------------
# 3. Load world map
# -----------------------------

world <- ne_countries(scale = "medium", returnclass = "sf")

# countries in the data without a match on the map (should be empty)
setdiff(data$country, world$name)

# -----------------------------
# 4. Join data
# -----------------------------

map_data <- world %>%
  left_join(data, by = c("sovereignt" = "country"))

# -----------------------------
# 5. Plot
# -----------------------------

plt <- ggplot(map_data) +
  geom_sf(aes(fill = articles), color = "grey60", size = 0.1) +
  scale_fill_gradient(
    trans = "log10",
    breaks = c(100, 1000, 10000),
    labels = c("100", "1,000", "10,000"),
    low = "red",
    high = "blue",
    na.value = "grey90",
    name = "Number of articles"
  ) +
  theme_minimal() +
  theme(
    panel.grid = element_blank(),                     # Removes standard gridlines
    panel.grid.major = element_line(color = "transparent") # Removes sf/map graticule lines
  )


ggsave("../figures/world_map_publications.png", plt, width = 10, height = 8, dpi = 300)


