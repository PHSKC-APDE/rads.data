# Header ----
# Author: Danny Colombara
# Date: August 29, 2022
# Purpose: Create machine usable long form of Other Causes of Death ICD 10 codes ----
# Notes: This is for causes of death that are not part of the CDC 113 Causes of death
#        and are not covered by the death injury matrix, but that are still of interest
#        for systematic analyses

library(data.table)

# Function to clean / prep imported data to fix random white spaces (sql_clean) ----
    source("https://raw.githubusercontent.com/PHSKC-APDE/rads/main/R/utilities.R") # pull in rads utilities, particularly sql_clean()


# Function to enumerator all ICD per other cause of death (split.dash) ----
  # E.g., split.dash("X0-X04, X17-X19") >> "X00, X01, X02, X03, X04, X17, X18, X19"
    source("https://raw.githubusercontent.com/PHSKC-APDE/rads.data/main/data-raw/icd_utility_split.dash.R")

# Read in raw Other Causes of Death ICD codes ----
    icd_other_causes_of_death <- fread("data-raw/icd_other_causes_of_death_raw.csv")
    icd_other_causes_of_death[, source := NULL]
    othercod <- copy(icd_other_causes_of_death)
    sql_clean(othercod)

# Format other causes of death ----
    # convert dashes to enumerated ICD codes
    othercod[, icd := split.dash(icd10), by = 1:nrow(othercod)]
    setnames(othercod, "icd10", "orig.coding")

    # split icds so there is one per column
    splits <- max(lengths(strsplit(othercod$icd, ", ")))
    wide <- copy(othercod)[, paste0("icd", 1:splits) := tstrsplit(icd, ", ", fixed=T)]
    wide[, icd := NULL]

    # wide to long
    icd_other_causes_of_death <- melt(wide, id.vars = c("cod", "orig.coding", "desc"), value.name = "icd10")
    icd_other_causes_of_death[, variable := NULL]
    icd_other_causes_of_death <- icd_other_causes_of_death[!is.na(icd10)]
    icd_other_causes_of_death <- icd_other_causes_of_death[, .(cause.of.death = cod, orig.coding, icd10)]
    setorder(icd_other_causes_of_death, cause.of.death, icd10)

    # Make didn't loose any orig coding when reshaping and cleaning
    if(identical(sort(unique(wide$orig.coding)), sort(unique(icd_other_causes_of_death$orig.coding)))){
      message("Kept all original codings")
    } else {stop("The original codings do not match those present at the start. Stop and check for errors.")}

# Write to package ----
    usethis::use_data(icd_other_causes_of_death, overwrite = TRUE)
    write.csv(icd_other_causes_of_death, "inst/extdata/icd_data/icd_other_causes_of_death.csv", row.names = F)
