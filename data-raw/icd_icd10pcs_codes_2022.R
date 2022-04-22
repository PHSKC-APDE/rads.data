# Header ----
# Author: Danny Colombara
# Date: April 22, 2022
# Purpose: Create tidy table of CMS 2022 ICD10 PCS codes
# Notes: Raw text file read below was originally from https://www.cms.gov/files/zip/errata-january-12-2022.zip

library(data.table)
library(readr)

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

  # Import full list of ICD 10 PCS ----
  icd_icd10pcs_codes_2022 = setDT(readr::read_fwf("data-raw/icd_icd10pcs_codes_2022.txt",
                                  fwf_widths(c(5,1,7,1,1,1,60,1,200)), show_col_types = FALSE))
  icd_icd10pcs_codes_2022 <- icd_icd10pcs_codes_2022[, .(order = X1, icd10 = X3, header = X5, short = X7, long = X9)]
  sql_clean(icd_icd10pcs_codes_2022)

# Write to package
    usethis::use_data(icd_icd10pcs_codes_2022, overwrite = TRUE)
    write.csv(icd_icd10pcs_codes_2022, "inst/extdata/icd_data/icd10pcs_codes_2022.csv", row.names = F)
