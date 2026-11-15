################################################################################
#                                                                              #
#   Crop definitions shared by the post-processing scripts and the Shiny app   #
#                                                                              #
#   crop_lookup: one row per crop, with the regular expression used to match   #
#   host plant names (lower case) to the crop, and its FAO group and class     #
#   (https://www.fao.org/fileadmin/templates/ess/documents/world_census_of_agriculture/appendix3_r7.pdf)
#                                                                              #
################################################################################

library(tibble)

crop_lookup <- tribble(
  ~crop_name, ~pattern, ~crop_group, ~crop_class,
  
  # --- 1. CEREALS ---
  "wheat", "\\b(wheats?|triticum)\\b", "Cereals", "Wheat",
  "maize", "\\b(maize|corns?|zea mays)\\b", "Cereals", "Maize",
  "rice", "\\b(rice|oryza)\\b", "Cereals", "Rice",
  "barley", "\\b(barleys?|hordeum)\\b", "Cereals", "Barley",
  "sorghum", "\\b(sorghums?|great millet|indian millet)\\b", "Cereals", "Sorghum",
  "millet", "\\b((?<!pearl )(?<!great )(?<!indian )millet|panicum|setaria|eleusine|pennisetum|digitaria)\\b", "Cereals", "Millets",
  "rye", "\\b(rye|secale)\\b", "Cereals", "Rye",
  "oats", "\\b(oats?|avena)\\b", "Cereals", "Oats",
  "mixed cereals", "\\b(cereals?|grains?)\\b", "Cereals", "Other cereals",
  
  # --- 2. VEGETABLES ---
  # Leafy
  "cabbage", "\\b(cabbages?|brassica oleracea)\\b", "Vegetables", "Leafy vegetables",
  "lettuce", "\\b(lettuces?|lactuca sativa)\\b", "Vegetables", "Leafy vegetables",
  "spinach", "\\b(spinach|spinacia)\\b", "Vegetables", "Leafy vegetables",
  
  # Fruit vegetables
  "tomato", "\\b(tomatoes|tomato|solanum lycopersicum)\\b", "Vegetables", "Fruit-bearing vegetables",
  "eggplant", "\\b(eggplants?|aubergines?|solanum melongena)\\b", "Vegetables", "Fruit-bearing vegetables",
  "cucumber", "\\b(cucumbers?|cucumis sativus)\\b", "Vegetables", "Fruit-bearing vegetables",
  "melon", "\\b(melons?|cucumis melo|cantaloupes?)\\b", "Vegetables", "Fruit-bearing vegetables",
  "pumpkin", "\\b(pumpkins?|squash|gourds?|cucurbita)\\b", "Vegetables", "Fruit-bearing vegetables",
  
  # Roots & bulbs
  "carrot", "\\b(carrots?|daucus carota)\\b", "Vegetables", "Root vegetables",
  "onion", "\\b(onions?|allium cepa)\\b", "Vegetables", "Bulb vegetables",
  "garlic", "\\b(garlic|allium sativum)\\b", "Vegetables", "Bulb vegetables",
  
  # --- 3. FRUITS & NUTS ---
  # Tropical
  "banana", "\\b(bananas?|musa)\\b", "Fruit", "Tropical fruit",
  "plantain", "\\b(plantains?|musa paradisiaca)\\b", "Fruit", "Tropical fruit",
  "mango", "\\b(mangos?|mangoes?|mangifera indica)\\b", "Fruit", "Tropical fruit",
  "papaya", "\\b(papayas?|carica papaya)\\b", "Fruit", "Tropical fruit",
  "pineapple", "\\b(pineapples?|ananas)\\b", "Fruit", "Tropical fruit",
  "avocado", "\\b(avocados?|persea americana)\\b", "Fruit", "Tropical fruit",
  
  # Citrus
  "orange", "\\b(oranges?|citrus sinensis)\\b", "Fruit", "Citrus",
  "lemon", "\\b(lemons?|citrus limon)\\b", "Fruit", "Citrus",
  "lime", "\\b(limes?|citrus aurantiifolia)\\b", "Fruit", "Citrus",
  "grapefruit", "\\b(grapefruits?|citrus paradisi)\\b", "Fruit", "Citrus",
  
  # Temperate
  "apple", "\\b(apples?|malus domestica)\\b", "Fruit", "Pome fruit",
  "pear", "\\b(pears?|pyrus)\\b", "Fruit", "Pome fruit",
  "peach", "\\b(peaches?|peach|prunus persica)\\b", "Fruit", "Stone fruit",
  "plum", "\\b(plums?|prunus domestica)\\b", "Fruit", "Stone fruit",
  "cherry", "\\b(cherries|cherry|prunus avium)\\b", "Fruit", "Stone fruit",
  "grape", "\\b(grape(?!fruit)s?|vitis)\\b", "Fruit", "Grapes",
  
  # Nuts
  "almond", "\\b(almonds?|prunus dulcis)\\b", "Fruit", "Nuts",
  "cashew", "\\b(cashews?|anacardium occidentale)\\b", "Fruit", "Nuts",
  "walnut", "\\b(walnuts?|juglans)\\b", "Fruit", "Nuts",
  
  # --- 4. OILSEEDS ---
  "soybean", "\\b(soybeans?|soy\\s?beans?|glycine max)\\b", "Oilseed crops", "Soya beans",
  "groundnut", "\\b(groundnuts?|peanuts?|arachis hypogaea)\\b", "Oilseed crops", "Groundnuts",
  "rapeseed", "\\b(rapeseeds?|canola|brassica napus)\\b", "Oilseed crops", "Rapeseed",
  "sunflower", "\\b(sunflowers?|helianthus annuus)\\b", "Oilseed crops", "Sunflower",
  "sesame", "\\b(sesame|sesamum indicum)\\b", "Oilseed crops", "Sesame",
  "linseed", "\\b(linseed|flax|linum usitatissimum)\\b", "Oilseed crops", "Linseed",
  "mustard", "\\b(mustard|brassica)\\b", "Oilseed crops", "Mustard",
  
  # Permanent oil crops
  "coconut", "\\b(coconuts?|cocos nucifera)\\b", "Oilseed crops", "Permanent oil crops",
  "oil palm", "\\b(oil\\s?palms?|elaeis guineensis)\\b", "Oilseed crops", "Permanent oil crops",
  "olive", "\\b(olives?|olea europaea)\\b", "Oilseed crops", "Permanent oil crops",
  
  # --- 5. ROOT / TUBER ---
  "potato", "\\b((?<!sweet )potatoes|(?<!sweet )potato|solanum tuberosum)\\b", "Roots & tubers", "Potatoes",
  "sweet potato", "\\b(sweet potatoes|sweet potato|ipomoea batatas)\\b", "Roots & tubers", "Sweet potatoes",
  "cassava", "\\b(cassava|manihot esculenta|tapioca)\\b", "Roots & tubers", "Cassava",
  "yam", "\\b(yams?|dioscorea)\\b", "Roots & tubers", "Yams",
  "taro", "\\b(taro|colocasia esculenta)\\b", "Roots & tubers", "Other roots",
  
  # --- 6. BEVERAGE & SPICES ---
  "coffee", "\\b(coffees?|coffea arabica|coffea canephora)\\b", "Beverage crops", "Coffee",
  "tea", "\\b(teas?|camellia sinensis)\\b", "Beverage crops", "Tea",
  "cocoa", "\\b(cocoa|cacao|theobroma cacao)\\b", "Beverage crops", "Cocoa",
  
  "chili", "\\b(chili|chilies|capsicum|(?<!black )pepper(?!\\s+spice))\\b", "Spice crops", "Temporary spices",
  "pepper spice", "\\b(black pepper|piper nigrum)\\b", "Spice crops", "Permanent spices",
  "ginger", "\\b(ginger|zingiber officinale)\\b", "Spice crops", "Permanent spices",
  "cinnamon", "\\b(cinnamon|cinnamomum)\\b", "Spice crops", "Permanent spices",
  
  # --- 7. LEGUMES ---
  "beans", "(?<!soy)(?<!coffee\\s)\\bbeans?\\b|\\bphaseolus\\b|\\bvigna\\b(?!\\s+unguiculata)", "Legumes", "Beans",
  "chickpea", "\\b(chickpeas?|cicer arietinum)\\b", "Legumes", "Chickpeas",
  "cowpea", "\\b(cowpeas?|vigna unguiculata)\\b", "Legumes", "Cowpeas",
  "lentil", "\\b(lentils?|lens culinaris)\\b", "Legumes", "Lentils",
  "pea", "\\b((?<!pigeon\\s)peas?|pisum sativum)\\b", "Legumes", "Peas",
  "pigeon pea", "\\b(pigeon peas?|cajanus cajan)\\b", "Legumes", "Pigeon peas",
  
  # --- 8. SUGAR ---
  "sugarcane", "\\b(sugarcane|sugar\\s?cane|saccharum officinarum)\\b", "Sugar crops", "Sugar cane",
  "sugarbeet", "\\b(sugarbeet|sugar\\s?beet|beta vulgaris)\\b", "Sugar crops", "Sugar beet",
  "sweet sorghum", "\\b(sweet sorghum)\\b", "Sugar crops", "Other sugar crops",
  
  # --- 9. OTHER ---
  "cotton", "\\b(cotton|gossypium)\\b", "Fibre crops", "Cotton",
  "jute", "\\b(jute|corchorus)\\b", "Fibre crops", "Fibre crops",
  "flax", "\\b(flax|linum)\\b", "Fibre crops", "Fibre crops",
  "rubber", "\\b(rubber|hevea brasiliensis)\\b", "Industrial crops", "Rubber",
  "tobacco", "\\b(tobacco|nicotiana)\\b", "Industrial crops", "Tobacco",
  "alfalfa", "\\b(alfalfa|medicago sativa)\\b", "Fodder crops", "Fodder",
  "grass", "\\b(grass|fodder|pasture)\\b", "Fodder crops", "Fodder",
  
  # Extra: five common forest plantation species
  "pine", "\\b(pines?|pinus)\\b", "Forest plantation", "Softwood forest",
  "douglas fir", "\\b(douglas-fir|douglas fir|pseudotsuga menziesii)\\b", "Forest plantation", "Softwood forest",
  "spruce", "\\b(spruces?|picea)\\b", "Forest plantation", "Softwood forest",
  "teak", "\\b(teak|tectona grandis)\\b", "Forest plantation", "Hardwood forest",
  "eucalyptus", "\\b(eucalyptus|eucalypts?)\\b", "Forest plantation", "Hardwood forest"
)


# Prints crop_lookup as LaTeX table rows (name & pattern & group & class),
# e.g. for the supplementary material: print_crop_latex_table(crop_lookup)
print_crop_latex_table <- function(crop_lookup) {
  for (i in seq_len(nrow(crop_lookup))) {
    row <- crop_lookup[i,]
  
    # Turn literal backslashes into "\textbackslash{}" for proper text mode rendering
    clean_pattern <- gsub("\\\\", "\\\\textbackslash{}", row$pattern)
  
    # Escape lookaround angle brackets so LaTeX doesn't skip them
    clean_pattern <- gsub("<", "\\\\textless ", clean_pattern)
    clean_pattern <- gsub(">", "\\\\textgreater ", clean_pattern)
  
    # Escape standard text underscores (crucial for scientific names)
    clean_pattern <- gsub("_", "\\\\_", clean_pattern)
  
    # Inject an invisible text breakpoint right after each pipe to enforce wrapping
    clean_pattern <- gsub("\\|", "|\\\\allowbreak ", clean_pattern)
  
    # Wrap the finished regex string in a typewriter command block
    latex_pattern <- paste0("\\texttt{", clean_pattern, "}")
  
    # Sanitize the other dataframe table text strings
    c_name  <- gsub("_", "\\\\_", row$crop_name)
    c_group <- gsub("_", "\\\\_", row$crop_group)
    c_class <- gsub("_", "\\\\_", row$crop_class)
  
    # Print the structural line
    cat(c_name, " & ", latex_pattern, " & ", c_group, " & ", c_class, " \\\\ \\hline \n")
  }
}
