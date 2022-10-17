# Create copy of all .rda as .csv for GitHub & non-R users ----

# Note! Expects all files in /data to begin with a stem that will be the name
# of folder in /inst/extdata. E.g., spatial_zip_hca.rda >>
# inst/extdata/spatial_data/zip_hca.csv

devtools::source_url("https://raw.githubusercontent.com/PHSKC-APDE/rads/main/R/utilities.R") # get sql_clean
library(data.table)

# convert .rda to .csv and move to /inst/extdata ----
    fn <- list.files("data", pattern = "rda$", ignore.case = T)
    for(i in fn){
      rdaname <- gsub("\\.rda", "", i, ignore.case = T)
      stem <- gsub("\\_.*", "", i, ignore.case = T)
      assign(rdaname, get(rdaname))
      write.csv(get(data(list = rdaname)), file = paste0("inst/extdata/", stem, "_data/", gsub("rda$", "csv", gsub(paste0(stem, "_"), "", i, ignore.case = T), ignore.case = T)), row.names = F)
      rm(list=rdaname)
    }



# convert .csv to .rda (if beginning with *.csv in /inst/extdata) ----
  stem <- 'population-OR-spatial-OR-occupation-OR-icd' # choose ONE
  fn <- list.files(paste0("inst/extdata/", stem, "_data/"), pattern = "csv$", ignore.case = T)

  for(i in fn){
    rdaname <- paste0(stem, "_", gsub("\\.csv", "", i, ignore.case = T))
    myrda <- data.table::fread(paste0("inst/extdata/", stem, "_data/", i))
    sql_clean(myrda)

    # convert integer64 (from bit64 pacakge) to character
    coltypes <- sapply(myrda, class)
    if("integer64" %in% coltypes){
      # identify columns with integer64 to be converted
      int64.cols <- names(coltypes)[coltypes == "integer64"]
      for(ii in int64.cols){
        message(paste0("converting ", ii, " from ", rdaname))
        myrda[, paste0(ii) := as.character(get(ii))]
      }
    }
    assign(rdaname, myrda)
    save(list = rdaname, file = paste0("data/", rdaname, ".rda") , compress = "bzip2", version = 3)
    rm(list=c(rdaname, 'myrda'))
  }


# convert .csv to .rda (if beginning with *.csv in /data) ----
  # fn <- list.files("data", pattern = "csv$", ignore.case = T)
  # for(i in fn){
  #   rdaname <- gsub("\\.csv", "", i, ignore.case = T)
  #   assign(rdaname, data.table::fread(paste0("data/", i)) )
  #   save(list = rdaname, file = paste0("data/", gsub("csv$", "rda", i, ignore.case = T)) , compress = "bzip2", version = 3)
  #   unlink(paste0("data/", i))
  #   rm(rdaname)
  # }


