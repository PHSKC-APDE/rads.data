# Header ----
# Author: Danny Colombara
# Date: April 22, 2022
# Purpose: Create machine usable long form of NCHS 113 Selected Causes of Death ICD 10 codes

# Set up ----
  library(data.table)
  rm(list=ls())

# Function to clean / prep imported data to fix random white spaces (sql_clean) ----
    source("https://raw.githubusercontent.com/PHSKC-APDE/rads/main/R/utilities.R") # pull in rads utilities, particularly sql_clean()

# Function to enumerator all ICD per 113 causes of death (split.dash) ----
    # E.g., split.dash("X0-X04, X17-X19") >> "X00, X01, X02, X03, X04, X17, X18, X19"
      source("https://raw.githubusercontent.com/PHSKC-APDE/rads.data/main/data-raw/icd_utility_split.dash.R")

# Read in raw NCHS 113 Selected Causes of Death ICD codes ----
    # Based on pp. 15-17, https://www.cdc.gov/nchs/data/dvs/Part9InstructionManual2020-508.pdf
    # See also https://secureaccess.wa.gov/doh/chat/Content/FilesForDownload/CodeSetDefinitions/NCHS113CausesOfDeath.pdf
    # Refer to ?icd_nchs113causes_raw for details

    load("data/icd_nchs113causes_raw.rda")
    icd_nchs113causes_raw[, icd10 := gsub("l", "1", icd10, ignore.case = FALSE)] # there is at least one case with the letter 'l' instead of 1 in the numeric portion
    icd_nchs113causes_raw[causeid == 95, icd10 := gsub("N15.1, ", "", icd10)] # N15.1 is already accounted for under causeid==87, "Infections fo kidney"
    icd_nchs113causes_raw[causeid == 95, icd10 := gsub("N014, |N01.4, ", "", icd10)] # N014 is already accounted for under causeid==83, "Acute ... nephrotic syndrome"
    dt113 <- copy(icd_nchs113causes_raw)
    sql_clean(dt113)

# Format 113 cause of death ----
    # keep bare minimum columns
    dt113 <- dt113[, .(causeid, cause.of.death, icd10)]

    # convert dashes to enumerated ICD codes
    dt113[, icd := split.dash(icd10), by = 1:nrow(dt113)]
    setnames(dt113, "icd10", "orig.coding")

    # split icds so there is one per column
    splits <- max(lengths(strsplit(dt113$icd, ", ")))
    wide113 <- copy(dt113)[, paste0("icd", 1:splits) := tstrsplit(icd, ", ", fixed=T)]
    wide113[, icd := NULL]

    # wide to long
    icd_nchs113causes <- melt(wide113, id.vars = c("causeid", "cause.of.death", "orig.coding"), value.name = "icd10")
    icd_nchs113causes[, variable := NULL]
    icd_nchs113causes <- icd_nchs113causes[!is.na(icd10)]
    setorder(icd_nchs113causes, causeid, icd10)

    # make sure all ICDs are used only once
    if(sum(duplicated(icd_nchs113causes[causeid != 114]$icd10)) != 0){stop("Duplicates in icd10 values")}

# Write to package ----
    usethis::use_data(icd_nchs113causes, overwrite = TRUE)
    write.csv(icd_nchs113causes, "inst/extdata/icd_data/nchs113causes.csv", row.names = F)
