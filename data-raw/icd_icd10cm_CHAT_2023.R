# Author: Danny Colombara
# R version: 4.2.1
# Date: Jan 10, 2023
# Purpose: import, process, and save CHAT ICD10 CM codings
# Source: https://secureaccess.wa.gov/ >> Community Health Assessment Tool
#         (CHAT) >> User Guides >> CHAT Hospital CCS Codes Sorted By ICD10cm Codes
# Note: CCS ==  Clinical Classifications Software (CCS) for ICD-10-PCS


# Set up ----
    library(data.table)
    rm(list=ls())

# import ----
    icd_icd10cm_CHAT_2023 = fread("C:/code/rads.data/data-raw/icd_icd10cm_CHAT_2023.csv")

# rename & set column order ----
    icd_icd10cm_CHAT_2023 <- icd_icd10cm_CHAT_2023[, list(
      icd10cm_desc = `'ICD-10-CM CODE DESCRIPTION'`,
      icd10cm = `'ICD-10-CM CODE'`,
      ccs_lvl_1_desc = `'MULTI CCS LVL 1 LABEL'`,
      ccs_lvl_1 = `'MULTI CCS LVL 1'`,
      ccs_lvl_2_desc = `'MULTI CCS LVL 2 LABEL'`,
      ccs_lvl_2 = `'MULTI CCS LVL 2'`,
      ccs_lvl_3_desc = `'CCS CATEGORY DESCRIPTION'`,
      ccs_lvl_3 = `'CCS CATEGORY'`
    )]

# tidy ----
    # clean white spaces
    rads::sql_clean(icd_icd10cm_CHAT_2023) # clean whitespaces, etc.

    # eliminate useless punctuation
    for(ii in c("icd10cm", "ccs_lvl_1", "ccs_lvl_2", "ccs_lvl_3")){
      icd_icd10cm_CHAT_2023[, paste0(ii) := gsub("'", "", get(ii))]
    }
    rm(ii)

    # remove bracketed level 3 values in level 2 descriptions
    icd_icd10cm_CHAT_2023[, ccs_lvl_2_desc := gsub(" \\[.*", "", ccs_lvl_2_desc)]

    # remove bracketed level 3 values in level 1 descriptions
    icd_icd10cm_CHAT_2023[, ccs_lvl_1_desc := gsub(" \\[.*", "", ccs_lvl_1_desc)]

    # fill in missing ccs_lvl_2_desc to match CHAT
    icd_icd10cm_CHAT_2023[grepl("^Residual codes", ccs_lvl_1_desc) & is.na(ccs_lvl_2_desc),
                          ccs_lvl_2_desc := ccs_lvl_1_desc]

# save as RDA file ----
usethis::use_data(icd_icd10cm_CHAT_2023, compress = "bzip2", version = 3, overwrite = TRUE)

# save as CSV file -----
write.csv(icd_icd10cm_CHAT_2023, file = "inst/extdata/icd_data/icd_icd10cm_CHAT_2023.csv", row.names = FALSE)


# the end !
