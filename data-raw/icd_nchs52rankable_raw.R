# Header ----
# Author: Danny Colombara
# Date: 2026
# Purpose: Create the raw (one row per cause) table of the 52 NCHS rankable
#          causes of death, i.e., the causes marked with # in Table B of the
#          NCHS Instruction Manual, Part 9 (2020).
#
# Notes: - To change the list, edit `data-raw/icd_nchs52rankable_raw.csv` (the
#          hand-entered source) and re-run this script. It writes the package
#          data and the copy in `inst/extdata/icd_data/`, which should not be
#          edited directly.
#
#        - Source: https://www.cdc.gov/nchs/data/dvs/Part9InstructionManual2020-508.pdf
#          Table B ("List of 113 Selected Causes of Death, Enterocolitis due to
#          Clostridium difficile, and COVID-19"), pp. 15-17. The manual says causes
#          marked with # "are eligible to be ranked as leading causes of death".
#
#        - The rankable causes are NOT identical to the 113 causes. Many are headings
#          that group several of the 113 causes (e.g., "Malignant neoplasms" = 113
#          causes 18-40), and two are carved out of 113 causes:
#            * Enterocolitis due to Clostridium difficile (A04.7), which is part of
#              113 cause 3 ("Certain other intestinal infections").
#            * COVID-19 (U07.1), which is part of 113 cause 17 in `icd_nchs113causes`.
#          This is why they are saved as their own table.
#
#        - The CDC does not assign numbers to the rankable causes, so this table
#          intentionally has no cause id.
#
#        - `icd10` is the code summary as printed in the manual, with spaces
#          normalized to ", " and OCR typos in the PDF text corrected. A leading *
#          marks the codes the manual flags for terrorism-related causes (U01-U03);
#          the * is removed when the codes are expanded.
#
#        - `version` is the edition of the manual used to define the list. The
#          list has changed over time (C. diff was added in 2006, COVID-19 in 2020).

# Set up ----
  rm(list = ls())
  library(data.table)

# Read the hand-entered source ----
  icd_nchs52rankable_raw <- fread("data-raw/icd_nchs52rankable_raw.csv",
                                  colClasses = "character", na.strings = c("", "NA"))

# Checks ----
  expected_cols <- c("cause.of.death", "icd10", "version", "notes")
  if (!identical(names(icd_nchs52rankable_raw), expected_cols)) {
    stop("Columns must be exactly: ", paste(expected_cols, collapse = ", "))
  }
  if (nrow(icd_nchs52rankable_raw) != 52) stop("Expected 52 rankable causes, found ", nrow(icd_nchs52rankable_raw))
  if (anyDuplicated(icd_nchs52rankable_raw$cause.of.death) > 0) stop("Duplicate cause names")
  if (anyNA(icd_nchs52rankable_raw[, .(cause.of.death, icd10, version)])) stop("Missing values in required columns")

# Clean up white space ----
  rads::string_clean(icd_nchs52rankable_raw)

# Write to package ----
  usethis::use_data(icd_nchs52rankable_raw, overwrite = TRUE)
  write.csv(icd_nchs52rankable_raw, "inst/extdata/icd_data/nchs52rankable_raw.csv", row.names = FALSE)
