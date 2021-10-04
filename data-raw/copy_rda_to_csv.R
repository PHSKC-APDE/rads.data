# Create copy of all .rda as .csv for GitHub & non-R users ----

# Note! Expects all files in /data to begin with a stem that will be the name
# of folder in /inst/extdata. E.g., spatial_zip_hca.rda >>
# inst/extdata/spatial_data/zip_hca.csv

library(data.table)


# convert .csv to .rda (if beginning with *.csv in /data)
fn <- list.files("data", pattern = "csv$")
for(i in fn){
  rdaname <- gsub("\\.csv", "", i)
  assign(rdaname, data.table::fread(paste0("data/", i)) )
  save(list = rdaname, file = paste0("data/", gsub("csv$", "rda", i)) , compress = "bzip2", version = 3)
  unlink(paste0("data/", i))
  rm(rdaname)
}

# convert .rda to .csv and move to /inst/extdata
fn <- list.files("data", pattern = "rda$")
for(i in fn){
  rdaname <- gsub("\\.rda", "", i)
  stem <- gsub("\\_.*", "", i)
  write.csv(get(data(list = rdaname)), file = paste0("inst/extdata/", stem, "_data/", gsub("rda$", "csv", gsub(paste0(stem, "_"), "", i))), row.names = F)
  rm(list=rdaname)
}

