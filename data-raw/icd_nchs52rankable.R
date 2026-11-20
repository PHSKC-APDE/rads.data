# Header ----
# Author: Danny Colombara
# Date: 2026
# Purpose: Create machine usable long form of the 52 NCHS rankable causes of death
#          (one row per ICD-10 code per cause).
#
# Notes: - Built from `icd_nchs52rankable_raw` (see data-raw/icd_nchs52rankable_raw.R).
#
#        - The rankable causes are related to, but not a strict subset of, the
#          NCHS 113 causes in `icd_nchs113causes`. See ?icd_nchs52rankable_raw.
#
#        - The CDC does not assign numbers to the rankable causes, so this table
#          intentionally has no cause id.
#
#        - Output codes are 4 characters: [A-Z][0-9][0-9][0-9] (see split.dash()).

# Set up ----
  rm(list = ls())
  library(data.table)

# Function to enumerate all ICD per cause (split.dash) ----
  # E.g., split.dash("X0-X04, X17-X19") >> "X00, X01, X02, X03, X04, X17, X18, X19"
  source(here::here('data-raw', 'icd_utility_split.dash.R'))

# Load the raw table ----
  load("data/icd_nchs52rankable_raw.rda")
  dt52 <- copy(icd_nchs52rankable_raw)
  setnames(dt52, "icd10", "orig.coding")
  dt52 <- dt52[, .(cause.of.death, orig.coding, version)]

# Expand codes and make long ----
  # convert dashes to enumerated ICD codes (needs to be run row by row)
  dt52[, icd := split.dash(orig.coding), by = 1:nrow(dt52)]

  # split icds so there is one per column
  splits <- max(lengths(strsplit(dt52$icd, ", ")))
  wide52 <- copy(dt52)[, paste0("icd", 1:splits) := tstrsplit(icd, ", ", fixed = TRUE)]
  wide52[, icd := NULL]

  # wide to long
  icd_nchs52rankable <- melt(wide52,
                             id.vars = c("cause.of.death", "orig.coding", "version"),
                             value.name = "icd10")
  icd_nchs52rankable[, variable := NULL]
  icd_nchs52rankable <- icd_nchs52rankable[!is.na(icd10)]
  setcolorder(icd_nchs52rankable, c("cause.of.death", "orig.coding", "icd10", "version"))
  setorder(icd_nchs52rankable, cause.of.death, icd10)

# Checks ----
  # no ICD-10 code may belong to more than one rankable cause
  # (within a version, since a future version could legitimately reuse codes)
  if (anyDuplicated(icd_nchs52rankable[, .(version, icd10)]) > 0) {
    dups <- icd_nchs52rankable[duplicated(icd_nchs52rankable[, .(version, icd10)]) |
                                 duplicated(icd_nchs52rankable[, .(version, icd10)], fromLast = TRUE)]
    print(dups)
    stop("ICD-10 codes assigned to more than one rankable cause")
  }

  # all 52 causes must be present
  if (uniqueN(icd_nchs52rankable$cause.of.death) != 52) stop("Expected 52 causes")

  # codes must be 4 characters
  if (any(!grepl("^[A-Z][0-9]{3}$", icd_nchs52rankable$icd10))) stop("Unexpected ICD-10 format")

  # the two carve-outs must land in their own causes
  if (!identical(icd_nchs52rankable[icd10 == "A047"]$cause.of.death, "Enterocolitis due to Clostridium difficile")) stop("A04.7 misassigned")
  if (!identical(icd_nchs52rankable[icd10 == "U071"]$cause.of.death, "COVID-19")) stop("U07.1 misassigned")

# Write to package ----
  setindex(icd_nchs52rankable, NULL) # drop auto-created indices created by the checks above
  usethis::use_data(icd_nchs52rankable, overwrite = TRUE)
  write.csv(icd_nchs52rankable, "inst/extdata/icd_data/nchs52rankable.csv", row.names = FALSE)
