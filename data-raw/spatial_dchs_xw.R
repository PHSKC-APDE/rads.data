
# code to create this file is in the frankenpop repo (spatial_crosswalks.R)
spatial_ids_and_names = data.table::fread("//dphcifs/APDE-CDIP/Population/Xwalks/xw_lab.csv")
usethis::use_data(spatial_ids_and_names, overwrite = TRUE)
ootfile = file.path(getwd(), 'inst', 'extdata', 'spatial_data', paste0('spatial_ids_and_names', '.csv'))
write.csv(spatial_ids_and_names, file = ootfile, row.names = FALSE)
