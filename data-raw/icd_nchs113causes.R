# Header ----
# Author: Danny Colombara
# Date: April 22, 2022
# Purpose: Create machine usable long form of NCHS 113 Selected Causes of Death ICD 10 codes ----

library(data.table)

# Function to clean / prep imported data to fix random white spaces (sql_clean) ----
    source("https://raw.githubusercontent.com/PHSKC-APDE/rads/main/R/utilities.R") # pull in rads utilities, particularly sql_clean()


# Function to enumerator all ICD per 113 causes of death (split.dash) ----
  # E.g., split.dash("X0-X04, X17-X19") >> "X00, X01, X02, X03, X04, X17, X18, X19"
    split.dash <- function(myvar){
      myvar <- toupper(myvar)
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
          tt.end <- gsub("[A-Z]|[a-z]", "", tt.2)

          if(tt.prefix1 != tt.prefix2){
            tt.1.seq <- seq(as.integer(tt.start), as.integer("99"), 1)
            if(grepl("^0", tt.start)){tt.1.seq <- paste0("0", tt.1.seq)}
            tt.1 <- paste0(tt.prefix1, tt.1.seq)

            tt.2.seq <- seq(as.integer(0), as.integer(tt.end), 1)
            if(grepl("^0", tt.end)){tt.2.seq <- paste0("0", tt.2.seq)}
            tt.2 <- paste0(tt.prefix2, tt.2.seq)

            tt <- c(tt.1, tt.2)
          }

          if(tt.prefix1 == tt.prefix2){
            tt.seq <- seq(as.integer(tt.start), as.integer(tt.end), 1)
            if(grepl("^0", tt.start) & grepl("^0", tt.end)){tt.seq <- paste0("0", tt.seq)} else{
              for(i in 1:length(tt.seq)){if( nchar(tt.seq[i])==1 ){tt.seq[i] <- paste0("0", tt.seq[i])}}
            }

            tt <- paste0(tt.prefix1, tt.seq)
          }

        } else {tt}
        nuevo <- c(nuevo, tt)
      }
      nuevo <- paste(nuevo, collapse = ", ")
      return(nuevo)
    }

# Read in raw NCHS 113 Selected Causes of Death ICD codes ----
    # Based on pp. 15-17, https://www.cdc.gov/nchs/data/dvs/Part9InstructionManual2020-508.pdf
    # See also https://secureaccess.wa.gov/doh/chat/Content/FilesForDownload/CodeSetDefinitions/NCHS113CausesOfDeath.pdf
    # Refer to ?icd_nchs113causes_raw for details

    load("data/icd_nchs113causes_raw.rda")
    dt113 <- copy(icd_nchs113causes_raw)
    sql_clean(dt113)

# Format 113 cause of death ----
    # convert dashes to enumerated ICD codes
    dt113[, icd := split.dash(icd10), by = 1:nrow(dt113)]
    dt113[, icd10 := NULL]

    # split icds so there is one per column
    splits <- max(lengths(strsplit(dt113$icd, ", ")))
    wide113 <- copy(dt113)[, paste0("icd", 1:splits) := tstrsplit(icd, ", ", fixed=T)]
    wide113[, icd := NULL]

    # wide to long
    icd_nchs113causes <- melt(wide113, id.vars = c("causeid", "cause.of.death"), value.name = "icd10")
    icd_nchs113causes[, variable := NULL]
    icd_nchs113causes <- icd_nchs113causes[!is.na(icd10)]
    setorder(icd_nchs113causes, causeid, icd10)

# Write to package
    usethis::use_data(icd_nchs113causes, overwrite = TRUE)
    write.csv(icd_nchs113causes_raw, "inst/extdata/icd_data/nchs113causes_raw.csv", row.names = F)
    write.csv(icd_nchs113causes, "inst/extdata/icd_data/nchs113causes.csv", row.names = F)
