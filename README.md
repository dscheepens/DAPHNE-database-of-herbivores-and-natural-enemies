# Paper code to "DAPHNE: A global database of pest herbivores and their natural enemies"

This repository contains the code and data for the preprint "DAPHNE: A global database of pest herbivores and their natural enemies"

Daan R. Scheepens, Tim Newbold, Robin Freeman

bioRxiv 2026.09.28.754864; doi: https://doi.org/10.64898/2026.09.28.754864 

## Overview

The complete, post-processed dataset is contained in `DAPHNE.rds`. 

`1_scopus-abstracts`: Run `filter_abstracts.R` to filter out abstracts from the raw .csv Scopus downloads (in `scopus/`) that do not contain any scientific names. The script then combines the filtered data (`scopus/*.rds`) into a complete dataframe `scopus/scopus_complete.rds`. `4_world_map_publications.r` creates the map of the number of publications per country.

`2_ollama-main`: The main LLM pipeline used to run gpt-oss:120b on an Nvidia run:ai server. `ollama-main.ipynb` contains the full pipeline to run the model on all abstracts in `scopus_complete.rds`. The raw model output is saved in `raw_data/`, split across ten .feather files.

`3_model-validation`: All validation steps used to validate the model against the manually-labelled training and test set. `model-validation.ipynb` contains the full code.

`4_dataset-post-processing`: All post-processing and taxonomy-correction steps are detailed in `1_post_processing.r`, with all manual taxonomic corrections listed in `taxonomy_corrections.r`. Comparison with other sources is detailed in `2_comparison_with_other_sources.r` (source data in `other_sources/`), and `3_plot_network.r` creates the overview figure of the database. The crop definitions used to match host plants to crops are shared between scripts in `crop_definitions.r`.

`figures`: All figures of the manuscript, as created by the scripts above.

`shiny_app`: The Shiny web application to explore the interaction networks of selected crops, hosted at https://ddx5w5-daan-scheepens.shinyapps.io/daphne-interaction-network/. `app.r` contains the app, and `prepare_data.r` creates its data files from `DAPHNE.rds`.
