# Header ----
# Author: Danny Colombara
# Date: November 19, 2026
# Purpose: Convert CDC bracket notation for ICD-10 codes into a plain list of codes
#          that split.dash() can expand into 4 character codes.
#
# Notes: The CDC injury matrix writes codes like "V20-V28[.0-.2]", which means
#        every 3 character code from V20 to V28 combined with every decimal from
#        .0 to .2 (V20.0, V20.1, V20.2, V21.0, ..., V28.2).
#
#        Pieces without brackets (e.g., "V01-X59" or "Y87.0") are returned unchanged
#        so split.dash() can handle them.
#
#        Run it on one string at a time, e.g.,
#        dt[, codes := expand.brackets(orig.coding), by = 1:nrow(dt)]
#        then dt[, icd := split.dash(codes), by = 1:nrow(dt)]
#
#        E.g., expand.brackets("V87[.0-.2], V89.2") >> "V87.0, V87.1, V87.2, V89.2"
#
#        The function stops with an error for NA or empty input, more than one string,
#        unbalanced brackets, malformed bracket notation, stems that are not 3
#        characters, ranges across letters, and descending ranges.

# Function ----
expand.brackets <- function(myvar){
  # Validate input ----
    # exactly one non-missing, non-empty string
    if (length(myvar) != 1 || !is.character(myvar) || is.na(myvar) || trimws(myvar) == "") {
      stop("expand.brackets() needs exactly one non-missing, non-empty string. You passed: ",
           paste(deparse(myvar), collapse = ""))
    }

    myvar <- toupper(myvar)
    myvar <- gsub("[\u2010-\u2015\u2212]", "-", myvar) # any dash-like character to a true hyphen

    # opening and closing brackets must match
    n.open <- lengths(regmatches(myvar, gregexpr("\\[", myvar)))
    n.close <- lengths(regmatches(myvar, gregexpr("\\]", myvar)))
    if (n.open != n.close) {
      stop("Unbalanced brackets in: `", myvar, "`")
    }

    # split at commas that are NOT inside brackets
    pieces <- trimws(strsplit(myvar, ",(?![^\\[]*\\])", perl = TRUE)[[1]])

    # every bracketed piece must look like "V20[.0-.2]" or "V20-V28[.0-.2,.6,.8-.9]"
    # i.e., 3 character stem(s), then 4th digits written as .# or .#-.#, separated by commas
    bracket.pattern <- "^[A-Z][0-9]{2}(-[A-Z][0-9]{2})?\\[\\.[0-9](-\\.[0-9])?(,\\.[0-9](-\\.[0-9])?)*\\]$"
    bracketed <- pieces[grepl("\\[|\\]", pieces)]
    bad <- bracketed[!grepl(bracket.pattern, bracketed)]
    if (length(bad) > 0) {
      stop("Invalid bracket notation: ", paste0("`", bad, "`", collapse = ", "),
           "\nExpected something like `V20-V28[.0-.2]` or `V80[.0-.2,.6-.9]`")
    }

    # ranges must stay within one letter and go from low to high
    for (piece in bracketed) {
      stem.ends <- strsplit(sub("\\[.*$", "", piece), "-")[[1]]
      if (substr(stem.ends[1], 1, 1) != substr(stem.ends[length(stem.ends)], 1, 1)) {
        stop("Bracketed ranges across letters are not supported: `", piece, "`")
      }
      if (stem.ends[1] > stem.ends[length(stem.ends)]) {
        stop("Descending range of codes: `", piece, "`")
      }
      for (dec in strsplit(sub("^.*\\[(.*)\\]$", "\\1", piece), ",")[[1]]) {
        dec.ends <- strsplit(dec, "-")[[1]]
        if (dec.ends[1] > dec.ends[length(dec.ends)]) {
          stop("Descending range of 4th digits: `", piece, "`")
        }
      }
    }

  # Expand ----
  nuevo <- c()
  for (piece in pieces) {
    # pieces without brackets are left for split.dash()
    if (!grepl("\\[", piece)) {
      nuevo <- c(nuevo, piece)
      next
    }

    # 3 character stems, e.g., "V20-V28" >> V20, V21, ..., V28
    stem <- sub("\\[.*$", "", piece)
    stem.ends <- strsplit(stem, "-")[[1]]
    stem.letter <- substr(stem.ends[1], 1, 1) # same letter on both ends (validated above)
    stem.nums <- seq(as.integer(substr(stem.ends[1], 2, 3)),
                     as.integer(substr(stem.ends[length(stem.ends)], 2, 3)))
    stems <- paste0(stem.letter, sprintf("%02d", stem.nums))

    # decimals, e.g., ".0-.2,.6" >> 0, 1, 2, 6
    inside <- sub("^.*\\[(.*)\\]$", "\\1", piece)
    decimals <- c()
    for (dec in strsplit(inside, ",")[[1]]) {
      dec.ends <- as.integer(gsub("\\.", "", strsplit(dec, "-")[[1]]))
      decimals <- c(decimals, seq(dec.ends[1], dec.ends[length(dec.ends)]))
    }

    # every stem combined with every decimal
    combos <- expand.grid(stem = stems, decimal = decimals, stringsAsFactors = FALSE)
    combos <- combos[order(combos$stem, combos$decimal), ]
    nuevo <- c(nuevo, paste0(combos$stem, ".", combos$decimal))
  }

  return(paste(nuevo, collapse = ", "))
}

# the end ----
