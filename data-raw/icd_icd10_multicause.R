# Header ----
# Author: Danny Colombara
# Date: July 31, 2025
# Purpose: Create machine usable long form of ICD-10 multicause death definitions
#          Starting with opioid-related deaths that require both underlying
#          poisoning codes AND contributing opioid codes
#
# Notes: A death is classified as opioid-related when BOTH conditions are met:
#        1. Underlying Cause of Death is a poisoning code (X40-X44, X60-X64, X85, Y10-Y14)
#        2. Contributing Causes include at least one opioid code (T40.0-T40.4, T40.6)
#

# Set up ----
rm(list=ls())
library(data.table)

# Function to enumerate all ICD per cause (split.dash) ----
# E.g., split.dash("X40-X44") >> "X40, X41, X42, X43, X44"
source("https://raw.githubusercontent.com/PHSKC-APDE/rads.data/main/data-raw/icd_utility_split.dash.R")

# Create the opioid death definition ----
# Underlying causes (poisoning intents)
underlying_codes <- data.table(
  cause_name = "Opioid",
  underlying_contributing = "underlying",
  orig.coding = c("X40-X44", "X60-X64", "X85", "Y10-Y14"),
  description = c(
    "Unintentional poisoning",
    "Suicide by poisoning",
    "Homicide by poisoning",
    "Undetermined intent poisoning"
  )
)

# Contributing causes (opioid types)
contributing_codes <- data.table(
  cause_name = "Opioid",
  underlying_contributing = "contributing",
  orig.coding = c("T40.0", "T40.1", "T40.2", "T40.3", "T40.4", "T40.6"),
  description = c(
    "Opium",
    "Heroin",
    "Natural and semi-synthetic opioids",
    "Methadone",
    "Synthetic opioids other than methadone",
    "Other and unspecified opioids"
  )
)

# Combine underlying and contributing
icd10_multicause_raw <- rbind(underlying_codes, contributing_codes)

# Expand ranges to individual codes
icd10_multicause_raw[, icd := split.dash(orig.coding), by = 1:nrow(icd10_multicause_raw)]

# Split codes so there is one per row
splits <- max(lengths(strsplit(icd10_multicause_raw$icd, ", ")))
wide_multicause <- copy(icd10_multicause_raw)[, paste0("icd", 1:splits) := tstrsplit(icd, ", ", fixed=TRUE)]
wide_multicause[, icd := NULL]

# Wide to long
icd10_multicause <- melt(wide_multicause,
                         id.vars = c("cause_name", "underlying_contributing", "orig.coding", "description"),
                         value.name = "icd10")
icd10_multicause[, variable := NULL]
icd10_multicause <- icd10_multicause[!is.na(icd10)]

# Clean up - remove orig.coding and description as they're not needed in final table
icd10_multicause[, c("orig.coding", "description") := NULL]

# Ensure proper formatting of ICD codes (add zeros as needed)
# Underlying codes should be 4 characters (e.g., X400, Y100)
# Contributing codes should be 4 characters (e.g., T400, T401)
icd10_multicause[nchar(icd10) == 3 & substr(icd10, 1, 1) %in% c("X", "Y"),
                 icd10 := paste0(icd10, "0")]

# Sort by cause, type, and code
setorder(icd10_multicause, cause_name, -underlying_contributing, icd10)

# Apply sql_clean to ensure no trailing spaces
rads::string_clean(icd10_multicause)

# Verify no duplicates
if(sum(duplicated(icd10_multicause[, .(cause_name, icd10)])) > 0){
  stop("Duplicates found in cause_name + icd10 combination")
}

# Show summary
cat("Created multicause death definitions for:\n")
print(icd10_multicause[, .N, by = .(cause_name, underlying_contributing)])
cat("\nTotal rows:", nrow(icd10_multicause), "\n")

# Write to package ----
usethis::use_data(icd10_multicause, overwrite = TRUE)
write.csv(icd10_multicause, "inst/extdata/icd_data/icd10_multicause.csv", row.names = FALSE)
