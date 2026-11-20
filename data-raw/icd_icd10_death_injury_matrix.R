# Header ----
# Author: Danny Colombara
# Date: April 26, 2022 (rewritten November 19, 2026 for rads.data issue #115)
# Purpose: Create the WA DOH Death Injury Matrix tables from the display CSV:
#          - icd10_death_injury_matrix_display: one row per mechanism & intent
#          - icd10_death_injury_matrix: long, one row per 4 character ICD-10 code
#
# Notes:  - Labeled "ICE", so based on the International Collaborative Effort on Injury Statistics.
#           Original is from WA DOH CHAT:
#           https://secureaccess.wa.gov/doh/chat/Content/FilesForDownload/CodeSetDefinitions/CHATInjury(ICE)codes.pdf
#
#         - SOURCE OF TRUTH: data-raw/icd10_death_injury_matrix_display.csv
#           To add or change a definition, edit that CSV and rerun this script.
#           Never edit the long table directly.
#
#         - The CSV keeps the CDC bracket notation. E.g., "V20-V28[.0-.2]" means every
#           3 character code from V20 to V28 combined with every 4th digit from .0 to .2.
#           This matches the CDC SAS code for the matrix:
#           https://ftp.cdc.gov/pub/Health_Statistics/NCHS/injury/sascodes/icd10_external.sas
#
#         - The CSV was reverse engineered from the long table in rads.data v1.0.27, which
#           had been built from a CSV made from the CHAT PDF. To see the script that did this:
#           git log --all -- data-raw/icd_reverse_engineer_display_csvs.R
#
#         - "Motor vehicle traffic" is NOT in the CSV. It is built below from the
#           "Motor vehicle traffic: ..." rows so that each definition lives in one place.
#
#         - Run from the root of the rads.data repo.

# Set up ----
library(data.table)
source("data-raw/icd_utility_split.dash.R")      # split.dash()
source("data-raw/icd_utility_expand_brackets.R") # expand.brackets()

allow_changes <- FALSE # set to TRUE only after reviewing the code changes reported below

# Read the display CSV ----
display <- fread("data-raw/icd10_death_injury_matrix_display.csv", encoding = "UTF-8")

stopifnot(identical(names(display), c("mechanism", "intent", "icd10")))
stopifnot(!anyNA(display))
stopifnot(!anyDuplicated(display[, list(mechanism, intent)]))
stopifnot(!any(display$mechanism == "Motor vehicle traffic")) # built below

display[, icd10 := gsub("[\u2010-\u2015\u2212]", "-", icd10)] # any dash-like character to a true hyphen

# Long table for the rows in the CSV ----
# orig.coding = the whole definition for the mechanism & intent, as written in the CSV
# icd10 = expansion of each orig.coding into 4 character code(s) (e.g., "F111", "F112", ...)
display[, row.order := .I] # keep the CSV's order, which is the CDC's order
display[, orig.coding := icd10]

long <- display[, list(icd10 = strsplit(split.dash(expand.brackets(orig.coding)), ", ")[[1]]),
                by = list(row.order, mechanism, intent, orig.coding)]
setorder(long, row.order, icd10)

# Motor vehicle traffic = all of the "Motor vehicle traffic: ..." rows ----
mv <- copy(long[grepl("^Motor vehicle traffic: ", mechanism)])
stopifnot(identical(unique(mv$intent), "Unintentional"))
mv[, mechanism := "Motor vehicle traffic"]

# Combine & check the long table ----
icd10_death_injury_matrix <- rbind(long, mv)[, list(mechanism, intent, orig.coding, icd10)]

stopifnot(all(grepl("^[A-Z][0-9]{3}$", icd10_death_injury_matrix$icd10))) # 4 character codes
stopifnot(!anyDuplicated(icd10_death_injury_matrix[, list(mechanism, intent, icd10)])) # each code once per mechanism & intent
stopifnot(!any(grepl("[^ -~]", unlist(icd10_death_injury_matrix)))) # ASCII only (b/c had encoding problems in imported files)

# Display table (one row per mechanism & intent) ----
display.mv <- data.table(mechanism = "Motor vehicle traffic",
                         intent = "Unintentional",
                         icd10 = paste(display[grepl("^Motor vehicle traffic: ", mechanism)]$icd10, collapse = ", "))

icd10_death_injury_matrix_display <- rbind(display[, list(mechanism, intent, icd10)],
                                           display.mv)

# Compare with the version currently saved in data/ ----
# Lists every code added to or removed from a mechanism & intent. Stops unless allow_changes is TRUE.
old <- new.env()
load("data/icd10_death_injury_matrix.rda", envir = old)
old <- old$icd10_death_injury_matrix[, list(mechanism, intent, icd10)]
new <- icd10_death_injury_matrix[, list(mechanism, intent, icd10)]

added <- fsetdiff(new, old)
removed <- fsetdiff(old, new)

if (nrow(added) == 0 && nrow(removed) == 0) {
  message("\u2705 No codes were added or removed compared with the version in data/")
} else {
  message("\u26A0\ufe0f Codes added: ", nrow(added), " | Codes removed: ", nrow(removed))
  if (nrow(added) > 0) print(added[, list(codes = paste(icd10, collapse = ", ")), by = list(mechanism, intent)])
  if (nrow(removed) > 0) print(removed[, list(codes = paste(icd10, collapse = ", ")), by = list(mechanism, intent)])
  if (!isTRUE(allow_changes)) {
    stop("The codes changed. Review the lists above. If the changes are intended, set allow_changes <- TRUE and rerun.")
  }
}

# Write to package ----
usethis::use_data(icd10_death_injury_matrix, overwrite = TRUE)
usethis::use_data(icd10_death_injury_matrix_display, overwrite = TRUE)
write.csv(icd10_death_injury_matrix, "inst/extdata/icd_data/icd10_death_injury_matrix.csv", row.names = FALSE, fileEncoding = "UTF-8")
write.csv(icd10_death_injury_matrix_display, "inst/extdata/icd_data/icd10_death_injury_matrix_display.csv", row.names = FALSE, fileEncoding = "UTF-8")

# the end ----
