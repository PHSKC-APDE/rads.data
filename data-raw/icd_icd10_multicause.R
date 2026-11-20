# Header ----
# Author: Danny Colombara
# Date: July 31, 2025
# Purpose: Create machine usable long form of ICD-10 multicause death definitions
#          (i.e., deaths that require BOTH specific underlying cause(s) AND specific
#          contributing cause(s), such as opioid-related deaths)
#
# Notes: A death meets a multicause definition when BOTH conditions are met:
#        1. Underlying Cause of Death is in the `underlying` codes
#        2. Contributing Causes include any (or all) of the `contributing` codes,
#           depending on `contributing_logic`
#
#        ** HOW TO ADD OR CHANGE A DEFINITION **
#        Do NOT edit this script. Edit `data-raw/icd_icd10_multicause_raw.csv`
#        (one row per code or range), then re-run this script.
#        Columns:
#          - cause_name:              name of the definition (what users pass to
#                                     rads::death_multicause_count(cause_name = ))
#          - underlying_contributing: "underlying" or "contributing"
#          - contributing_logic:      "ANY" or "ALL" (whether any or all of the
#                                     contributing codes must be present). Required
#                                     for "contributing" rows, identical for every
#                                     contributing row of a cause_name, and left
#                                     blank for "underlying" rows
#          - orig.coding:             code or range as originally defined,
#                                     e.g., "X40-X44", "X85", "T40.1"
#          - description:             plain-language label for orig.coding
#          - source:                  where the definition came from (URL, etc.)
#        After re-running, update the version in DESCRIPTION and the rads
#        tests/documentation as needed.
#
#        The final table keeps `cause_name`, `underlying_contributing`, `icd10`,
#        `orig.coding`, `description`, `contributing_logic`, `source`.

# Set up ----
rm(list=ls())
library(data.table)

# Function to enumerate all ICD per cause (split.dash) ----
# E.g., split.dash("X40-X44") >> "X40, X41, X42, X43, X44"
source(here::here('data-raw', 'icd_utility_split.dash.R'))

# Read the raw definitions ----
icd10_multicause_raw <- fread(here::here('data-raw', 'icd_icd10_multicause_raw.csv'),
                              colClasses = "character", na.strings = "")

icd10_multicause_raw[trimws(contributing_logic) == "", contributing_logic := NA_character_] # quoted blanks are not read as NA

# Validate the raw definitions ----
need_cols <- c("cause_name", "underlying_contributing", "contributing_logic",
               "orig.coding", "description", "source")
if(!identical(sort(names(icd10_multicause_raw)), sort(need_cols))){
  stop("icd_icd10_multicause_raw.csv must have exactly these columns: ", paste(need_cols, collapse = ", "))
}
if(anyNA(icd10_multicause_raw[, .(cause_name, underlying_contributing, orig.coding, description, source)])){
  stop("Missing values found in cause_name, underlying_contributing, orig.coding, description, or source")
}
if(!all(icd10_multicause_raw$underlying_contributing %in% c("underlying", "contributing"))){
  stop("underlying_contributing must be 'underlying' or 'contributing'")
}
if(!all(icd10_multicause_raw[underlying_contributing == "contributing"]$contributing_logic %in% c("ANY", "ALL"))){
  stop("contributing_logic must be 'ANY' or 'ALL' for every contributing row")
}
if(!all(is.na(icd10_multicause_raw[underlying_contributing == "underlying"]$contributing_logic))){
  stop("contributing_logic must be blank for underlying rows")
}
if(any(icd10_multicause_raw[underlying_contributing == "contributing", uniqueN(contributing_logic), by = cause_name]$V1 != 1)){
  stop("contributing_logic must be the same for all contributing rows of a cause_name")
}
if(any(icd10_multicause_raw[, uniqueN(underlying_contributing), by = cause_name]$V1 != 2)){
  stop("Every cause_name needs both underlying and contributing rows")
}

# Expand ranges to individual codes ----
icd10_multicause_raw[, icd := split.dash(orig.coding), by = 1:nrow(icd10_multicause_raw)]

# Split codes so there is one per row
splits <- max(lengths(strsplit(icd10_multicause_raw$icd, ", ")))
wide_multicause <- copy(icd10_multicause_raw)[, paste0("icd", 1:splits) := tstrsplit(icd, ", ", fixed=TRUE)]
wide_multicause[, icd := NULL]

# Wide to long
icd10_multicause <- melt(wide_multicause,
                         id.vars = c("cause_name", "underlying_contributing", "contributing_logic", "orig.coding", "description", "source"),
                         value.name = "icd10")
icd10_multicause[, variable := NULL]
icd10_multicause <- icd10_multicause[!is.na(icd10)]

# Keep orig.coding, description, & source so users can see the source definition
# (e.g., "X40-X44") rather than only the expanded 4-character codes.
# Put new columns after the original columns so their positions are unchanged.
setcolorder(icd10_multicause, c("cause_name", "underlying_contributing", "icd10", "orig.coding", "description", "contributing_logic", "source"))

# Ensure proper formatting of ICD codes (add zeros as needed)
# Underlying codes should be 4 characters (e.g., X400, Y100)
# Contributing codes should be 4 characters (e.g., T400, T401)
icd10_multicause[nchar(icd10) == 3 & substr(icd10, 1, 1) %in% c("X", "Y"),
                 icd10 := paste0(icd10, "0")]

# Sort by cause, type, and code
setorder(icd10_multicause, cause_name, -underlying_contributing, icd10)

# Apply string_clean to ensure no trailing spaces
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
