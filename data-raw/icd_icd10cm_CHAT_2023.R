# Author: Danny Colombara
# R version: 4.21.1
# Date: Jan 10, 2023
# Purpose: import, process, and save CHAT ICD10 CM codings
# Source: https://secureaccess.wa.gov/ >> Community Health Assessment Tool
#         (CHAT) >> User Guides >> CHAT Hospital CCS Codes Sorted By ICD10cm Codes
# Note: CCS ==  Clinical Classifications Software (CCS) for ICD-10-PCS


# Set up ----
library(data.table)
rm(list=ls())

# import
icd_icd10cm_CHAT_2023 = fread("C:/code/rads.data/data-raw/icd_icd10cm_CHAT_2023.csv")

# rename
setnames(icd_icd10cm_CHAT_2023, c("icd10", "ccs", "icd10_desc", "ccs_desc", "ccs_lvl_1", "ccs_lvl_1_desc", "ccs_lvl_2", "ccs_lvl_2_desc"))


# remove extraneous punctuation
for(ii in c("icd10", "ccs", "ccs_lvl_1", "ccs_lvl_2")){
  icd_icd10cm_CHAT_2023[, paste0(ii) := gsub("'", "", get(ii))]
}

# save as RDA file
usethis::use_data(icd_icd10cm_CHAT_2023, compress = "bzip2", version = 3, overwrite = TRUE)

# save as CSV file
write.csv(icd_icd10cm_CHAT_2023, file = "inst/extdata/icd_data/icd_icd10cm_CHAT_2023.csv", row.names = FALSE)


# the end !
