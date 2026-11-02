# Paper code to "DAPHNE: A global database of pest herbivores and their natural enemies"

This is the code to the preprint "DAPHNE: A global database of pest herbivores and their natural enemies"

Daan R. Scheepens, Tim Newbold, Robin Freeman

bioRxiv 2026.09.28.754864; doi: https://doi.org/10.64898/2026.09.28.754864 

## Overview

`1_ollama-main`: The main LLM pipeline used to run gpt-oss:120b on an Nvidia run:ai server. `ollama-main.ipynb` contains the full pipeline.

`2_model-validation`: All validation steps used to validate the model against the manually-labelled training and test set. `model-validation.ipynb` contains the full code.

`3_dataset-post-processing`: All post-processing and taxonomy-correction steps are detailed in `1_post_processing.r`. Comparison with other sources is detailed in `2_comparison_with_other_sources`.
