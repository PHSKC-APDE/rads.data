# Create copy of all .rda as .csv for GitHub & non-R users ----

# Note! Expects all files in /data to begin with a stem that will be the name
# of folder in /inst/extdata. E.g., spatial_zip_hca.rda >>
# inst/extdata/spatial_data/zip_hca.csv

library(data.table)

# convert .rda to .csv and move to /inst/extdata
    fn <- list.files("data", pattern = "rda$", ignore.case = T)
    for(i in fn){
      rdaname <- gsub("\\.rda", "", i, ignore.case = T)
      stem <- gsub("\\_.*", "", i, ignore.case = T)
      assign(rdaname, get(rdaname))
      write.csv(get(data(list = rdaname)), file = paste0("inst/extdata/", stem, "_data/", gsub("rda$", "csv", gsub(paste0(stem, "_"), "", i, ignore.case = T), ignore.case = T)), row.names = F)
      rm(list=rdaname)
    }

# convert .csv to .rda (if beginning with *.csv in /data)
  # fn <- list.files("data", pattern = "csv$", ignore.case = T)
  # for(i in fn){
  #   rdaname <- gsub("\\.csv", "", i, ignore.case = T)
  #   assign(rdaname, data.table::fread(paste0("data/", i)) )
  #   save(list = rdaname, file = paste0("data/", gsub("csv$", "rda", i, ignore.case = T)) , compress = "bzip2", version = 3)
  #   unlink(paste0("data/", i))
  #   rm(rdaname)
  # }


