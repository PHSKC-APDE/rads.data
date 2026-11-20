# Header ----
# Author: Danny Colombara
# Date: August 29, 2022 (rewritten November 19, 2026 for rads.data issue #115)
# Purpose: Create the Other Causes of Death tables from the display CSV:
#          - icd_other_causes_of_death_display: one row per cause
#          - icd_other_causes_of_death: long, one row per 4 character ICD-10 code
#
# Notes:  - These are causes of death that are not part of the CDC 113 Causes of Death
#           and are not covered by the death injury matrix, but that are still of
#           interest for systematic analyses. DOH refers to some of these as "Special Codes".
#
#         - SOURCE OF TRUTH: data-raw/icd_other_causes_of_death_display.csv
#           To add or change a cause, edit that CSV and rerun this script.
#           Never edit the long table directly.
#
#         - The CSV was reverse engineered from the long table in rads.data v1.0.27, which
#           had been built from a CDC list and a WA DOH CHAT "Special Code Sets" workbook
#           (CHAT_SpecialCodeSets_20221006.xlsx). The DOH codes were summarized into
#           ranges. To see the script that did this:
#           git log --all -- data-raw/icd_reverse_engineer_display_csvs.R
#
#         - Causes with source "CDC 113 COD" are NOT in the CSV. They are built below
#           from icd_nchs113causes so that each definition lives in one place.
#
#         - Run from the root of the rads.data repo.

# Set up ----
library(data.table)
source("data-raw/icd_utility_split.dash.R") # split.dash()

allow_changes <- FALSE # set to TRUE only after reviewing the code changes reported below

# Read the display CSV ----
display <- fread("data-raw/icd_other_causes_of_death_display.csv", encoding = "UTF-8")

stopifnot(identical(names(display), c("cause.of.death", "icd10", "source")))
stopifnot(!anyNA(display))
stopifnot(!anyDuplicated(display$cause.of.death))
stopifnot(!any(display$source == "CDC 113 COD")) # these are built below

display[, icd10 := gsub("[\u2010-\u2015\u2212]", "-", icd10)] # any dash-like character to a true hyphen

# Long table for the causes in the CSV ----
# orig.coding = each code or range as written in the CSV (e.g., "F11.1-F11.5")
# >> had to think this though vs tstrsplit(), but strsplit() is correct because
# first item of it's list is a vector of the components, which data.table then
# uses for expansion. tstringsplit() would have made it wide, then I'd need to reshape
pieces <- display[, list(orig.coding = trimws(strsplit(icd10, ",")[[1]])),
                  by = list(cause.of.death, source)]

# icd10 = expansion of each orig.coding into 4 character code(s) (e.g., "F111", "F112", ...)
from.csv <- pieces[, list(icd10 = strsplit(split.dash(orig.coding), ", ")[[1]]),
                   by = list(cause.of.death, orig.coding, source)]

# Causes built from the CDC 113 Causes of Death ----
load("data/icd_nchs113causes.rda") # local copy, so it matches the rest of this repo

combos113 <- list(
  "Chronic liver disease and cirrhosis" = c("Alcoholic liver disease",
                                            "Other chronic liver disease and cirrhosis"),
  "Chronic lower respiratory disease"   = c("Asthma",
                                            "Bronchitis, chronic and unspecified",
                                            "Emphysema",
                                            "Other chronic lower respiratory diseases"),
  "Influenza/pneumonia"                 = c("Influenza",
                                            "Pneumonia")
)
stopifnot(all(unlist(combos113) %in% icd_nchs113causes$cause.of.death))

from.113 <- rbindlist(lapply(names(combos113), function(new.cause) {
  unique(icd_nchs113causes[cause.of.death %in% combos113[[new.cause]],
                           list(cause.of.death = new.cause, orig.coding, icd10, source = "CDC 113 COD")])
}))

# Combine & check the long table ----
icd_other_causes_of_death <- rbind(from.csv[, list(cause.of.death, orig.coding, icd10, source)],
                                   from.113[, list(cause.of.death, orig.coding, icd10, source)])
icd_other_causes_of_death <- unique(icd_other_causes_of_death)
setorder(icd_other_causes_of_death, cause.of.death, icd10, -orig.coding)

stopifnot(all(grepl("^[A-Z][0-9]{3}$", icd_other_causes_of_death$icd10))) # 4 character codes
stopifnot(!anyDuplicated(icd_other_causes_of_death[, list(cause.of.death, icd10)])) # each code once per cause
stopifnot(!any(grepl("[^ -~]", unlist(icd_other_causes_of_death)))) # ASCII only (b/c had encoding problems in imported files)

# Display table (one row per cause) ----
display.113 <- from.113[order(cause.of.death, icd10)]
display.113 <- display.113[, list(icd10 = paste(unique(orig.coding), collapse = ", ")), by = list(cause.of.death, source)]

icd_other_causes_of_death_display <- rbind(display,
                                           display.113[, list(cause.of.death, icd10, source)])
setorder(icd_other_causes_of_death_display, cause.of.death)

# Compare with the version currently saved in data/ ----
# Lists every code added to or removed from a cause. Stops unless allow_changes is TRUE.
old <- new.env()
load("data/icd_other_causes_of_death.rda", envir = old)
old <- old$icd_other_causes_of_death[, list(cause.of.death, icd10, source)]
new <- icd_other_causes_of_death[, list(cause.of.death, icd10, source)]

added <- fsetdiff(new, old)
removed <- fsetdiff(old, new)

if (nrow(added) == 0 && nrow(removed) == 0) {
  message("\u2705 No codes were added or removed compared with the version in data/")
} else {
  message("\u26A0\ufe0f Codes added: ", nrow(added), " | Codes removed: ", nrow(removed))
  if (nrow(added) > 0) print(added[, list(codes = paste(icd10, collapse = ", ")), by = list(cause.of.death, source)])
  if (nrow(removed) > 0) print(removed[, list(codes = paste(icd10, collapse = ", ")), by = list(cause.of.death, source)])
  if (!isTRUE(allow_changes)) {
    stop("The codes changed. Review the lists above. If the changes are intended, set allow_changes <- TRUE and rerun.")
  }
}

# Write to package ----
usethis::use_data(icd_other_causes_of_death, overwrite = TRUE)
usethis::use_data(icd_other_causes_of_death_display, overwrite = TRUE)
write.csv(icd_other_causes_of_death, "inst/extdata/icd_data/icd_other_causes_of_death.csv", row.names = FALSE, fileEncoding = "UTF-8")
write.csv(icd_other_causes_of_death_display, "inst/extdata/icd_data/icd_other_causes_of_death_display.csv", row.names = FALSE, fileEncoding = "UTF-8")

# the end ----
