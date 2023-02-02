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
    setnames(icd_icd10cm_CHAT_2023, c("icd10", "ccs_lvl_3", "icd10_desc", "ccs_lvl_3_desc", "ccs_lvl_1", "ccs_lvl_1_desc", "ccs_lvl_2", "ccs_lvl_2_desc"))
    setcolorder(icd_icd10cm_CHAT_2023, c("icd10_desc", "icd10", "ccs_lvl_1_desc", "ccs_lvl_1", "ccs_lvl_2_desc", "ccs_lvl_2", "ccs_lvl_3_desc", "ccs_lvl_3"))

# tidy ----
    # clean white spaces
    rads::sql_clean(icd_icd10cm_CHAT_2023) # clean whitespaces, etc.

    # eliminate useless punctuation
    for(ii in c("icd10", "ccs_lvl_1", "ccs_lvl_2", "ccs_lvl_3")){
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
