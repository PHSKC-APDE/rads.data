# Header ----
# Author: Danny Colombara
# Date: November 19, 2026
# Purpose: ONE-TIME script that reverse engineers the display CSVs for
#          `icd_other_causes_of_death` and `icd10_death_injury_matrix` from the
#          long tables in rads.data v1.0.27 (see rads.data issue #115).
#
# Notes:  - After this script, the display CSVs below are the source of truth. Future
#           changes to the definitions are made in the display CSVs, not here.
#         - This script is kept in git history only. To find it:
#           git log --all -- data-raw/icd_reverse_engineer_display_csvs.R
#         - Run from the root of the rads.data repo.
#
# Output: data-raw/icd_other_causes_of_death_display.csv
#           one row per cause: cause.of.death, icd10, source
#           - DOH causes are summarized into ranges (e.g., "F11.1, F11.2, F11.3" >> "F11.1-F11.3")
#             and complete sets of subcodes become the 3 character code (e.g., T67.0-T67.9 >> "T67")
#           - CDC causes keep the codes as the CDC wrote them
#           - Causes built from rads.data::icd_nchs113causes ("CDC 113 COD") are NOT
#             included because the build script creates them
#         data-raw/icd10_death_injury_matrix_display.csv
#           one row per mechanism & intent: mechanism, intent, icd10
#           - keeps the CDC bracket notation (e.g., "V20-V28[.0-.2]")
#           - removes leftover text from the PDF conversion ("\\R")
#           - "Motor vehicle traffic" is NOT included because the build script creates it
#
#         Each display row is expanded back to 4 character codes and must match the
#         v1.0.27 long table exactly. Otherwise the script stops.

# Set up ----
library(data.table)
source("data-raw/icd_utility_split.dash.R")       # split.dash()
source("data-raw/icd_utility_expand_brackets.R")  # expand.brackets()

dash.chars <- "[\u2010-\u2015\u2212]" # any dash-like character (\u escapes keep this file ASCII)

# Check split.dash() & expand.brackets() handle every kind of dash ----
for (dash in c("-", "\u2013", "\u2014", "\u2212")) {
  stopifnot(identical(split.dash(paste0("X40", dash, "X41")), split.dash("X40-X41")))
  stopifnot(identical(split.dash(paste0("F11.1", dash, "F11.3")), "F111, F112, F113"))
  stopifnot(identical(expand.brackets(paste0("V87[.0", dash, ".2]")), "V87.0, V87.1, V87.2"))
}

# Check expand.brackets() gives the right codes for valid input ----
stopifnot(identical(expand.brackets("V02-V04[.1,.9], V09.2"),
                    "V02.1, V02.9, V03.1, V03.9, V04.1, V04.9, V09.2"))
stopifnot(identical(expand.brackets("V80[.0-.1,.9]"), "V80.0, V80.1, V80.9"))
stopifnot(identical(expand.brackets("V01-X59, Y85"), "V01-X59, Y85")) # no brackets: unchanged

# Check expand.brackets() stops for bad input ----
bad.inputs <- list(
  NA_character_,                  # missing
  "",                             # empty
  c("V87[.0-.2]", "V89.2"),       # more than one string
  "V20-V28[.0-.2",                # missing closing bracket
  "V20-V28.0-.2]",                # missing opening bracket
  "V20-V28[0-2]",                 # 4th digits without decimal points
  "V2-V28[.0-.2]",                # stem with 2 characters
  "V200-V28[.0-.2]",              # stem with 4 characters
  "V20-W28[.0-.2]",               # range across letters
  "V28-V20[.0-.2]",               # descending stems
  "V20-V28[.2-.0]"                # descending 4th digits
)
for (bad in bad.inputs) {
  stopped <- tryCatch({expand.brackets(bad); FALSE}, error = function(e) TRUE)
  if (!stopped) stop("expand.brackets() should have stopped for: ", paste(bad, collapse = " | "))
}

# Helper: summarize a vector of codes into ranges ----
# E.g., c("F11.1", "F11.2", "F11.3", "T67.0", ..., "T67.9", "X40", "X41") >> "F11.1-F11.3, T67, X40-X41"
# Pieces that are already ranges (e.g., "X60-Y09") are kept as they are.
summarize.codes <- function(pieces) {
  pieces <- unique(gsub(dash.chars, "-", trimws(pieces)))
  is.4char <- grepl("^[A-Z][0-9]{2}\\.[0-9]$", pieces) # e.g., F11.1
  is.3char <- grepl("^[A-Z][0-9]{2}$", pieces)          # e.g., X40
  other <- pieces[!is.4char & !is.3char]                # e.g., X60-Y09

  # 4 character codes: complete sets of .0 to .9 become the 3 character code
  four <- data.table(stem = substr(pieces[is.4char], 1, 3),
                     dec = as.integer(substr(pieces[is.4char], 5, 5)))
  complete.stems <- four[, list(n = data.table::uniqueN(dec)), by = stem][n == 10]$stem
  four <- four[!stem %in% complete.stems]

  # 3 character codes (original ones plus the complete stems)
  three <- data.table(code = unique(c(pieces[is.3char], complete.stems)))
  three[, letter := substr(code, 1, 1)]
  three[, num := as.integer(substr(code, 2, 3))]

  out <- data.table(code = other, start = sub("-.*$", "", other))

  # consecutive 4 character codes within a stem become a range
  if (nrow(four) > 0) {
    setorder(four, stem, dec)
    four[, run := cumsum(c(1, diff(dec) != 1)), by = stem]
    four <- four[, list(first = paste0(stem, ".", dec[1]),
                        last = paste0(stem, ".", dec[.N])), by = list(stem, run)]
    out <- rbind(out, four[, list(code = ifelse(first == last, first, paste0(first, "-", last)),
                                  start = first)])
  }

  # consecutive 3 character codes within a letter become a range
  if (nrow(three) > 0) {
    setorder(three, letter, num)
    three[, run := cumsum(c(1, diff(num) != 1)), by = letter]
    three <- three[, list(first = sprintf("%s%02d", letter, num[1]),
                          last = sprintf("%s%02d", letter, num[.N])), by = list(letter, run)]
    out <- rbind(out, three[, list(code = ifelse(first == last, first, paste0(first, "-", last)),
                                   start = first)])
  }

  out <- out[order(start, method = "radix")]
  return(paste(out$code, collapse = ", "))
}

# Helper: expand a display string to a sorted vector of unique 4 character codes ----
to.codes <- function(x) {
  sort(unique(strsplit(split.dash(expand.brackets(x)), ", ")[[1]]), method = "radix")
}

# Other causes of death ----
  # load v1.0.27 long table ----
    load("data/icd_other_causes_of_death.rda")
    other.long <- copy(icd_other_causes_of_death)

  # build display rows ----
    other.display <- other.long[source != "CDC 113 COD"] # these are built from icd_nchs113causes in the build script
    other.display <- other.display[, list(
      icd10 = if (source[1] == "DOH") {
        summarize.codes(orig.coding)
      } else {
        # CDC: keep the codes as the CDC wrote them, only fixing the dashes
        pieces <- unique(gsub(dash.chars, "-", orig.coding))
        paste(pieces[order(sub("-.*$", "", pieces), method = "radix")], collapse = ", ")
      },
      source = source[1]
    ), by = cause.of.death]
    setorder(other.display, cause.of.death)

  # check: one source per cause ----
    stopifnot(other.long[source != "CDC 113 COD", data.table::uniqueN(source), by = cause.of.death]$V1 == 1)

  # check: each display row expands to exactly the v1.0.27 codes ----
    for (cod in other.display$cause.of.death) {
      new.codes <- to.codes(other.display[cause.of.death == cod]$icd10)
      old.codes <- sort(unique(other.long[cause.of.death == cod]$icd10), method = "radix")
      if (!identical(new.codes, old.codes)) {
        stop("Display codes for '", cod, "' do not match the long table.",
             "\n  Missing: ", paste(setdiff(old.codes, new.codes), collapse = ", "),
             "\n  Extra: ", paste(setdiff(new.codes, old.codes), collapse = ", "))
      }
    }
    message("\u2705 Other causes of death: all ", nrow(other.display), " display rows match the long table")

# Injury matrix ----
  # load v1.0.27 long table ----
    load("data/icd10_death_injury_matrix.rda")
    injury.long <- copy(icd10_death_injury_matrix)

  # build display rows ----
    # unique() keeps the order of first appearance, which is the CDC's order
    injury.display <- unique(injury.long[mechanism != "Motor vehicle traffic", list(mechanism, intent, icd10 = orig.coding)])
    injury.display[, icd10 := gsub("\\\\+R", "", icd10)]     # leftover text from the PDF conversion, e.g., "V81-\\RV82"
    injury.display[, icd10 := gsub(dash.chars, "-", icd10)]

  # check: one row per mechanism & intent, no backslashes left ----
    stopifnot(nrow(injury.display) == nrow(unique(injury.display[, list(mechanism, intent)])))
    stopifnot(!any(grepl("\\\\", injury.display$icd10)))

  # check: each display row expands to exactly the v1.0.27 codes ----
    for (i in seq_len(nrow(injury.display))) {
      mech <- injury.display$mechanism[i]
      int <- injury.display$intent[i]
      new.codes <- to.codes(injury.display$icd10[i])
      old.codes <- sort(unique(injury.long[mechanism == mech & intent == int]$icd10), method = "radix")
      if (!identical(new.codes, old.codes)) {
        stop("Display codes for '", mech, " / ", int, "' do not match the long table.",
             "\n  Missing: ", paste(setdiff(old.codes, new.codes), collapse = ", "),
             "\n  Extra: ", paste(setdiff(new.codes, old.codes), collapse = ", "))
      }
    }

  # check: 'Motor vehicle traffic' can be rebuilt from the 'Motor vehicle traffic: ...' rows ----
    mv.codes <- sort(unique(unlist(lapply(
      injury.display[grepl("^Motor vehicle traffic: ", mechanism) & intent == "Unintentional"]$icd10,
      to.codes))), method = "radix")
    mv.old <- sort(unique(injury.long[mechanism == "Motor vehicle traffic"]$icd10), method = "radix")
    stopifnot(identical(unique(injury.long[mechanism == "Motor vehicle traffic"]$intent), "Unintentional"))
    stopifnot(identical(mv.codes, mv.old))

    message("\u2705 Injury matrix: all ", nrow(injury.display), " display rows match the long table")

# Write display CSVs ----
  # same format as the CSVs in inst/extdata/icd_data/ (write.csv, UTF-8, no row names)
  stopifnot(!any(grepl("[^ -~]", unlist(other.display))), !any(grepl("[^ -~]", unlist(injury.display)))) # ASCII only
  write.csv(other.display, "data-raw/icd_other_causes_of_death_display.csv", row.names = FALSE, fileEncoding = "UTF-8")
  write.csv(injury.display, "data-raw/icd10_death_injury_matrix_display.csv", row.names = FALSE, fileEncoding = "UTF-8")

# the end ----
