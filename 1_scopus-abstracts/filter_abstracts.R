
library(dplyr)
library(readr)
library(rgbif)
library(spocc)
library(remotes)
library(ggplot2)
library(jsonlite)

remotes::install_github("poldham/gnfinderr")
library(gnfinderr)

scopusDir <- "Scopus/"

filter_for_abstracts_with_taxa <- function(search.results){
  df <- read_csv(paste0(scopusDir, search.results, '.csv'))
  
  t.start <- Sys.time()
  for (i in 1:nrow(df)){
    
    if (i %% 1000 == 0) {
      cat("Iteration:", i, "\n")
    }
    
    my_text <- df$Abstract[i]
    
    cmd <- paste0("echo ", shQuote(my_text), " | gnfinder -U -f compact")
    out <- system(cmd, intern = TRUE)
    res <- fromJSON(paste(out, collapse = ""))
    res
    if (!is.null(nrow(res$names))){
      df[i,"NamesFound"] <- nrow(res$names)
    } else {
      df[i,"NamesFound"] <- 0
    }
  }
  t.end <- Sys.time()
  print(t.end-t.start)
  
  df <- df[df$NamesFound > 0,]
  saveRDS(object = df, file = paste0(scopusDir, search.results, '.rds'))
}

search.complete <- rbind(read_csv(paste0(scopusDir, "export_2ffe3d67-1dba-4eda-b235-d5bf0b058d39_2025-08-24T20_19_00.364355101.csv")),
      read_csv(paste0(scopusDir, "export_25be7adb-0e6d-47b6-9129-3a290bafc8af_2025-08-24T20_30_35.246722592.csv")),
      read_csv(paste0(scopusDir, "export_67d394ef-576b-4198-82d7-a6e4cc253cc9_2025-08-24T20_26_20.523132421.csv")),
      read_csv(paste0(scopusDir, "export_71e456e4-31e4-41d1-9d90-57a9a7aabc74_2025-08-24T20_18_36.726340475.csv")),
      read_csv(paste0(scopusDir, "export_95ce8400-f987-4481-bc0a-86699cddca60_2025-08-24T20_17_41.093895810.csv")),
      read_csv(paste0(scopusDir, "export_d062b0aa-a511-4a97-9d1c-571922446a80_2025-08-25T17_26_26.152316033.csv")),
      read_csv(paste0(scopusDir, "export_fec52884-1f59-41b4-8b8f-a5331eac2834_2025-08-25T17_26_09.102103177.csv")),
      read_csv(paste0(scopusDir, "export_565a8258-3a3e-457d-96d1-582ae53af9b6_2025-08-24T20_16_54.168710566.csv")),
      read_csv(paste0(scopusDir, "export_b6c730d4-ac7f-4c2f-81bf-b0f72a3815ca_2025-08-24T20_19_36.931219694.csv")),
      read_csv(paste0(scopusDir, "export_c3a804bb-31a5-4079-9f6c-f3edd19c4622_2025-08-24T20_31_04.370328659.csv")),
      read_csv(paste0(scopusDir, "export_f1459b99-b677-4f01-8aa1-5957ba8af43c_2025-08-24T20_21_11.746507396.csv")),
      read_csv(paste0(scopusDir, "export_9b01d6d9-b417-41a0-87ab-fc248fccb9e2_2025-08-25T18_45_47.706146572.csv")),
      read_csv(paste0(scopusDir, "export_65dd9ca9-b719-4045-89b2-c6719eb05e3c_2025-08-25T18_44_00.832213554.csv")),
      read_csv(paste0(scopusDir, "export_781ef919-d2ac-402d-aec7-fb287887ace1_2025-08-25T18_43_35.927976733.csv")),
      read_csv(paste0(scopusDir, "export_a320881c-5beb-4e47-935d-8223f554ffe6_2025-08-25T18_44_49.217068331.csv")),
      read_csv(paste0(scopusDir, "export_bd63845b-83f7-425f-8f77-dc7f10987968_2025-08-25T18_44_35.028977485.csv")),
      read_csv(paste0(scopusDir, "export_eed5b52f-835e-46e3-9513-264b27de9e2f_2025-08-25T18_44_13.298152718.csv")),
      read_csv(paste0(scopusDir, "export_f9a6974f-add8-4d91-8f5c-7c3515c4ed29_2025-08-25T18_43_17.584212013.csv")),
      read_csv(paste0(scopusDir, "export_f50ff05e-aa8d-4993-a75d-361b7804daef_2025-08-25T18_45_25.449557866.csv")),
      read_csv(paste0(scopusDir, "export_fb20a09a-b30f-4dd6-be2b-08238ee70679_2025-08-25T18_45_10.168656744.csv")),
      read_csv(paste0(scopusDir, "export_064c1ea5-0952-4c9a-91a5-ee25c68e5862_2025-08-25T18_53_00.332185549.csv"))
) %>% filter(Year != 2026) %>% arrange(Year, increasing=TRUE) %>% unique()

ggplot(
  data = as.data.frame(table(search.complete$Year)) %>%
    rename(Year = Var1, Count = Freq),
  aes(x = as.numeric(as.character(Year)), y = Count)) +
  geom_col(fill = "skyblue", color = "black") +
  labs(x = "Year", y = "Count") + 
  theme_minimal()

nrow(search.complete) # 139,434

# filter through all 139,434 abstracts: 
filter_for_abstracts_with_taxa("export_2ffe3d67-1dba-4eda-b235-d5bf0b058d39_2025-08-24T20_19_00.364355101") # Time difference of ~1.5 hours
filter_for_abstracts_with_taxa("export_25be7adb-0e6d-47b6-9129-3a290bafc8af_2025-08-24T20_30_35.246722592") # Time difference of ~1.5 hours
filter_for_abstracts_with_taxa("export_67d394ef-576b-4198-82d7-a6e4cc253cc9_2025-08-24T20_26_20.523132421") # Time difference of ~1.5 hours
filter_for_abstracts_with_taxa("export_71e456e4-31e4-41d1-9d90-57a9a7aabc74_2025-08-24T20_18_36.726340475") # Time difference of ~1.5 hours
filter_for_abstracts_with_taxa("export_95ce8400-f987-4481-bc0a-86699cddca60_2025-08-24T20_17_41.093895810") # Time difference of ~1.5 hours
filter_for_abstracts_with_taxa("export_d062b0aa-a511-4a97-9d1c-571922446a80_2025-08-25T17_26_26.152316033") # Time difference of 1.317066 hours
filter_for_abstracts_with_taxa("export_fec52884-1f59-41b4-8b8f-a5331eac2834_2025-08-25T17_26_09.102103177") # Time difference of 1.203843 hours
filter_for_abstracts_with_taxa("export_565a8258-3a3e-457d-96d1-582ae53af9b6_2025-08-24T20_16_54.168710566") # Time difference of 2.693573 hours
filter_for_abstracts_with_taxa("export_b6c730d4-ac7f-4c2f-81bf-b0f72a3815ca_2025-08-24T20_19_36.931219694") # Time difference of 58.1903 mins
filter_for_abstracts_with_taxa("export_c3a804bb-31a5-4079-9f6c-f3edd19c4622_2025-08-24T20_31_04.370328659") # Time difference of 1.266742 hours
filter_for_abstracts_with_taxa("export_f1459b99-b677-4f01-8aa1-5957ba8af43c_2025-08-24T20_21_11.746507396") # Time difference of 1.41751 hours
filter_for_abstracts_with_taxa("export_9b01d6d9-b417-41a0-87ab-fc248fccb9e2_2025-08-25T18_45_47.706146572") # Time difference of 1.025041 hours
filter_for_abstracts_with_taxa("export_65dd9ca9-b719-4045-89b2-c6719eb05e3c_2025-08-25T18_44_00.832213554") # Time difference of 28.04541 mins
filter_for_abstracts_with_taxa("export_781ef919-d2ac-402d-aec7-fb287887ace1_2025-08-25T18_43_35.927976733") # Time difference of 19.43156 mins
filter_for_abstracts_with_taxa("export_a320881c-5beb-4e47-935d-8223f554ffe6_2025-08-25T18_44_49.217068331") # Time difference of 44.83455 mins
filter_for_abstracts_with_taxa("export_bd63845b-83f7-425f-8f77-dc7f10987968_2025-08-25T18_44_35.028977485") # Time difference of 44.26518 mins
filter_for_abstracts_with_taxa("export_eed5b52f-835e-46e3-9513-264b27de9e2f_2025-08-25T18_44_13.298152718") # Time difference of 32.07898 mins
filter_for_abstracts_with_taxa("export_f9a6974f-add8-4d91-8f5c-7c3515c4ed29_2025-08-25T18_43_17.584212013") # Time difference of 20.54482 mins
filter_for_abstracts_with_taxa("export_f50ff05e-aa8d-4993-a75d-361b7804daef_2025-08-25T18_45_25.449557866") # Time difference of 53.34408 mins
filter_for_abstracts_with_taxa("export_fb20a09a-b30f-4dd6-be2b-08238ee70679_2025-08-25T18_45_10.168656744") # Time difference of 51.80999 mins
filter_for_abstracts_with_taxa("export_064c1ea5-0952-4c9a-91a5-ee25c68e5862_2025-08-25T18_53_00.332185549") # Time difference of 1.430871 hours


# combine all together 
df.complete <- rbind(readRDS(paste0(scopusDir, "export_2ffe3d67-1dba-4eda-b235-d5bf0b058d39_2025-08-24T20_19_00.364355101.rds")),
                     readRDS(paste0(scopusDir, "export_25be7adb-0e6d-47b6-9129-3a290bafc8af_2025-08-24T20_30_35.246722592.rds")),
                     readRDS(paste0(scopusDir, "export_67d394ef-576b-4198-82d7-a6e4cc253cc9_2025-08-24T20_26_20.523132421.rds")),
                     readRDS(paste0(scopusDir, "export_71e456e4-31e4-41d1-9d90-57a9a7aabc74_2025-08-24T20_18_36.726340475.rds")),
                     readRDS(paste0(scopusDir, "export_95ce8400-f987-4481-bc0a-86699cddca60_2025-08-24T20_17_41.093895810.rds")),
                     readRDS(paste0(scopusDir, "export_d062b0aa-a511-4a97-9d1c-571922446a80_2025-08-25T17_26_26.152316033.rds")),
                     readRDS(paste0(scopusDir, "export_fec52884-1f59-41b4-8b8f-a5331eac2834_2025-08-25T17_26_09.102103177.rds")),
                     readRDS(paste0(scopusDir, "export_565a8258-3a3e-457d-96d1-582ae53af9b6_2025-08-24T20_16_54.168710566.rds")),
                     readRDS(paste0(scopusDir, "export_b6c730d4-ac7f-4c2f-81bf-b0f72a3815ca_2025-08-24T20_19_36.931219694.rds")),
                     readRDS(paste0(scopusDir, "export_c3a804bb-31a5-4079-9f6c-f3edd19c4622_2025-08-24T20_31_04.370328659.rds")),
                     readRDS(paste0(scopusDir, "export_f1459b99-b677-4f01-8aa1-5957ba8af43c_2025-08-24T20_21_11.746507396.rds")),
                     readRDS(paste0(scopusDir, "export_9b01d6d9-b417-41a0-87ab-fc248fccb9e2_2025-08-25T18_45_47.706146572.rds")),
                     readRDS(paste0(scopusDir, "export_65dd9ca9-b719-4045-89b2-c6719eb05e3c_2025-08-25T18_44_00.832213554.rds")),
                     readRDS(paste0(scopusDir, "export_781ef919-d2ac-402d-aec7-fb287887ace1_2025-08-25T18_43_35.927976733.rds")),
                     readRDS(paste0(scopusDir, "export_a320881c-5beb-4e47-935d-8223f554ffe6_2025-08-25T18_44_49.217068331.rds")),
                     readRDS(paste0(scopusDir, "export_bd63845b-83f7-425f-8f77-dc7f10987968_2025-08-25T18_44_35.028977485.rds")),
                     readRDS(paste0(scopusDir, "export_eed5b52f-835e-46e3-9513-264b27de9e2f_2025-08-25T18_44_13.298152718.rds")),
                     readRDS(paste0(scopusDir, "export_f9a6974f-add8-4d91-8f5c-7c3515c4ed29_2025-08-25T18_43_17.584212013.rds")),
                     readRDS(paste0(scopusDir, "export_f50ff05e-aa8d-4993-a75d-361b7804daef_2025-08-25T18_45_25.449557866.rds")),
                     readRDS(paste0(scopusDir, "export_fb20a09a-b30f-4dd6-be2b-08238ee70679_2025-08-25T18_45_10.168656744.rds")),
                     readRDS(paste0(scopusDir, "export_064c1ea5-0952-4c9a-91a5-ee25c68e5862_2025-08-25T18_53_00.332185549.rds"))
) %>% filter(Year != 2026) %>% arrange(Year, increasing=TRUE) %>% unique() %>% droplevels()

ggplot(
  data = as.data.frame(table(df.complete$Year)) %>%
    rename(Year = Var1, Count = Freq),
  aes(x = as.numeric(as.character(Year)), y = Count)) +
  geom_col(fill = "skyblue", color = "black") +
  labs(x = "Year", y = "Count") + 
  theme_minimal()

nrow(df.complete) # 112,831

saveRDS(object = df.complete, file = paste0(scopusDir, 'scopus_complete.rds'))





