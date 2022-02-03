# Purpose: Create machine usable long form of NCHS 113 Selected Causes of Death ICD 10 codes ----

library(data.table)

# Function to clean / prep imported data to fix random white spaces (sql_clean) ----
  sql_clean <- function (dat = NULL, stringsAsFactors = FALSE)
      {
        # check date.frame
        if(!is.null(dat)){
          if(!is.data.frame(dat)){
            stop("'dat' must be the name of a data.frame or data.table")
          }
          if(is.data.frame(dat) && !data.table::is.data.table(dat)){
            data.table::setDT(dat)
          }
        } else {stop("'dat' (the name of a data.frame or data.table) must be specified")}

        original.order <- names(dat)
        factor.columns <- which(vapply(dat,is.factor, FUN.VALUE=logical(1) )) # identify factor columns
        if(length(factor.columns)>0) {
          dat[, (factor.columns) := lapply(.SD, as.character), .SDcols = factor.columns] # convert factor to string
        }
        string.columns <- which(vapply(dat,is.character, FUN.VALUE=logical(1) )) # identify string columns
        if(length(string.columns)>0) {
          dat[, (string.columns) := lapply(.SD, trimws, which="both"), .SDcols = string.columns] # trim white space to right or left
          dat[, (string.columns) := lapply(.SD, function(x){gsub("^ *|(?<= ) | *$", "", x, perl = TRUE)}), .SDcols = string.columns] # collapse multiple consecutive white spaces into one
          dat[, (string.columns) := lapply(.SD, function(x){gsub("^$|^ $", NA, x)}), .SDcols = string.columns] # replace blanks with NA
          if(stringsAsFactors==TRUE){
            dat <- dat[, (string.columns) := lapply(.SD, factor), .SDcols = string.columns] # convert strings to factors
          }
        }
        # reorder table
        data.table::setcolorder(dat, original.order)
      }

# Function to enumerator all ICD per 113 causes of death (split.dash) ----
  # E.g., split.dash("X0-X04, X17-X19") >> "X00, X01, X02, X03, X04, X17, X18, X19"
    split.dash <- function(myvar){
      myvar <- toupper(myvar)
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

    # Per CDC guidance, contains •	COVID-19 (U07.1) in cause id 17 (“Other and unspecified
    # infectious and parasitic diseases and their sequelae”)

    # Cause id 95 (“All other diseases (Residual)”) uses codings discovered on a PHSKC
    # network drive. They were propbably created by Mike Smyzer, who has retired. These
    # are being used instead of the CDC codes due to better alignment with WA DOH. The
    # official CDC coding is now saved as cause id 114 “CDC version of cause id 95 (Residual)”

    dt113 <- data.table::fread("data-raw/icd_nchs113causes_raw.csv")
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
    write.csv(icd_nchs113causes, "data-raw/icd_nchs113causes.csv", row.names = F)
    usethis::use_data(icd_nchs113causes, overwrite = TRUE)
