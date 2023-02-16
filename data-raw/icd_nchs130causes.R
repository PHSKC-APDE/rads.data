# Header ----
# Author: Danny Colombara
# Date: February 15, 2023
# Purpose: Create machine usable long form of NCHS 130 Selected Causes of Infant Death
#          - Majority of the data is from the documentation in CHAT:
#            https://secureaccess.wa.gov/doh/chat/Content/FilesForDownload/TechnicalNotes.pdf#nameddest=Infant%20Mortality
#          - Presume the source of the CHAT/DOH table is:
#            https://www.cdc.gov/nchs/data/dvs/Part9InstructionManual2020-508.pdf, pages 18-20
#
# Notes: The only intentional made to the CHAT/DOH table was to add ICD codes for
#        cause 130 (All other residual) because this was blank in the DOH table
#
# Notes:  A lot of manual cleaning of the Excel file that was exported by Adobe Acrobat
#         was necessary. Why the CDC and or state departments of health don't release
#         these tables as machine readable text files is a mystery.
#

# Set up ----
  rm(list=ls())
  library(data.table)

# Function to clean / prep imported data to fix random white spaces (sql_clean) ----
    source("https://raw.githubusercontent.com/PHSKC-APDE/rads/main/R/utilities.R") # pull in rads utilities, particularly sql_clean()


# Function to enumerate all ICD per 130 causes of death (split.dash) ----
  # E.g., split.dash("X0-X04, X17-X19") >> "X00, X01, X02, X03, X04, X17, X18, X19"
    source("https://raw.githubusercontent.com/PHSKC-APDE/rads.data/main/data-raw/icd_utility_split.dash.R")

# Read in raw NCHS 130 Selected Causes of Death ICD codes ----
    # Refer to ?icd_nchs130causes_raw for details on source that is going to be manipulated
    load("data/icd_nchs130causes_raw.rda")
    icd_nchs130causes_raw[, icd10 := gsub("l", "1", icd10)] # there is at least one case with the letter 'l' instead of 1 in the numeric portion
    dt130 <- copy(icd_nchs130causes_raw)
    sql_clean(dt130)

# Format 130 cause of death ----
    # keep bare minimum columns
    dt130 <- dt130[, .(causeid, cause.of.death, icd10)]

    # convert dashes to enumerated ICD codes
    dt130[, icd := split.dash(icd10), by = 1:nrow(dt130)]
    setnames(dt130, "icd10", "orig.coding")

    # split icds so there is one per column (i.e., make a wide table)
    splits <- max(lengths(strsplit(dt130$icd, ", ")))
    wide130 <- copy(dt130)[, paste0("icd", 1:splits) := tstrsplit(icd, ", ", fixed=T)]
    wide130[, icd := NULL]

    # wide to long
    icd_nchs130causes <- melt(wide130, id.vars = c("causeid", "cause.of.death", "orig.coding"), value.name = "icd10")
    icd_nchs130causes[, variable := NULL]
    icd_nchs130causes <- icd_nchs130causes[!is.na(icd10)]
    setorder(icd_nchs130causes, causeid, icd10)
    setcolorder(icd_nchs130causes, c('causeid', 'cause.of.death', 'icd10', 'orig.coding'))

    # make sure all ICDs are used only once
    if(sum(duplicated(icd_nchs130causes$icd10)) != 0){stop("Duplicates in icd10 values")}

# Write to package ----
    usethis::use_data(icd_nchs130causes, overwrite = TRUE)
    write.csv(icd_nchs130causes, "inst/extdata/icd_data/nchs130causes.csv", row.names = F)
