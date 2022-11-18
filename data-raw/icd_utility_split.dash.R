# Header ----
# Author: Danny Colombara
# Date: April 29, 2022
# Purpose: Create function to thoughtfully split summary ICD10 codes into individual
# machine readable codes
#
# Notes: used by icd_nchs113causes.R and icd_icd10_death_injury_matrix.R (and
#        possibly other ICD related prep code in the future)
#
#        Because of its complexity and my tired brain, this function needs to be
#        run for each row in data.table separately.
#        E.g., dt[, icd := split.dash(codes), by = 1:nrow(dt)]
#
#        This code will output 4 character ICD10 codes: [A-Z][0-9][0-9][0-9]

# Set-up ----
  library(data.table)

# General warning message when loading ----
  warning("Remember that this function needs to be run row by row in data.table:
          e.g., dt[, icd := split.dash(codes), by = 1:nrow(dt)]")

# Function to enumerator all ICD per 113 causes of death (split.dash) ----
  # E.g., split.dash("X0-X04, X17-X19") >> "X00, X01, X02, X03, X04, X17, X18, X19"
    split.dash <- function(myvar){
      myvar <- toupper(myvar)
      myvar <- gsub("–", "-", myvar) # replace en dash with true hyphen
      myvar <- gsub("—", "-", myvar) # replace em dash with true hyphen
      myvar <- gsub("^ *|(?<= ) | *$", "", myvar, perl = TRUE) # collapse multiple consecutive white spaces into one
      myvar <- gsub("\\.|\\*|[:blank:]|[:space:]| |\\s", "", myvar) # drop decimal, drop *, try 4 ways to drop spaces!
      myvar <- strsplit(myvar, ",")[[1]] # split at commas & unlist
      nuevo <- c() #empty character vector
      for(TT in 1:length(myvar)){
        tt <- myvar[TT]
        if(grepl("-", tt) == TRUE){
          tt.1 <- gsub("-.*$","",tt)
          tt.2 <- gsub("^.*-","",tt)

          tt.prefix1 <- gsub("[0-9].*$", "", tt.1)
          tt.prefix2 <- gsub("[0-9].*$", "", tt.2)

          tt.start <- gsub("[A-Z]|[a-z]", "", tt.1)
            if(nchar(tt.start)==2){tt.start = paste0(tt.start, "0")} # want it to be three digits for specificity
          tt.end <- gsub("[A-Z]|[a-z]", "", tt.2)
            if(nchar(tt.end)==2){tt.end = paste0(tt.end, "9")}

          if(tt.prefix1 != tt.prefix2){
            # identify whether prefixes are consecutive letters. If not, identify letters between them.
            tt.prefix1.num <- match(tolower(tt.prefix1), letters[])
            tt.prefix2.num <- match(tolower(tt.prefix2), letters[])
            if(tt.prefix2.num - tt.prefix1.num > 1){
              tt.prefixbonus <- toupper(letters[(tt.prefix1.num+1):(tt.prefix2.num-1)])
            } else {tt.prefixbonus <- NULL}

            # full sequence for first letter
            tt.1.seq <- sprintf("%03i", seq(as.integer(tt.start),999, 1))
            tt.1 <- paste0(tt.prefix1, tt.1.seq)

            # full sequence for intermediate letters
            if(isFALSE(is.null(tt.prefixbonus))){
              tt.bonus <- sort(as.vector(outer(tt.prefixbonus, sprintf("%03i", seq(0, 999, 1)), paste0))) # create every combination of prefix and numbers
            } else {tt.bonus <- NULL}

            # full sequence for final letter
            tt.2.seq <- sprintf("%03i", seq(as.integer(0), as.integer(tt.end), 1))
            tt.2 <- paste0(tt.prefix2, tt.2.seq)

            # combine the first, intermediate, and final sets of codes
            if(is.null(tt.bonus)){
              tt <- c(tt.1, tt.2)
            } else {
              tt <- c(tt.1, tt.bonus, tt.2)
            }
          }

          if(tt.prefix1 == tt.prefix2){
            tt.seq <- formatC(seq(as.integer(tt.start), as.integer(tt.end), 1), width = 3, format = "d", flag = "0")
            tt <- paste0(tt.prefix1, tt.seq)
          }

        } else {
          if(nchar(tt)<4){tt <- paste0(tt, 0:9)}
          }
        nuevo <- c(nuevo, tt)
      }
      nuevo <- paste(nuevo, collapse = ", ")
      return(nuevo)
    }

# the end ----
