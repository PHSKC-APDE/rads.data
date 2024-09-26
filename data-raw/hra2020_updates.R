library('data.table')
library('sf')
library('dplyr')
library('spatagg')
library('kcparcelpop')
library('usethis')
library('DBI')
#  outfol = 'C:/Users/DCASEY/King County/DPH-APDEData - HRA/xwalks'
newreg = st_read("//dphcifs/APDE-CDIP/Shapefiles/Region/region_hra20.shp")
newhra = st_read('//dphcifs/APDE-CDIP/Shapefiles/HRA/hra_2020.shp')
newhra = newhra[, c('id', 'name', 'reg_id', 'reg_nm')]
zipo = st_read("//dphcifs/APDE-CDIP/Shapefiles/ZIP/zipcode.shp")
tract10 = st_read("//dphcifs/APDE-CDIP/Shapefiles/Census_2010/tract/kc_tract.shp")
tract20 = st_read("//dphcifs/APDE-CDIP/Shapefiles/Census_2020/tract/kc_tract.shp")
blk10 = st_read("//dphcifs/APDE-CDIP/Shapefiles/Census_2010/block/kc_block.shp")
hracombo = st_read("//dphcifs/APDE-CDIP/Shapefiles/HRA_Combo/Custom_HRA_regions.shp")

kc = summarize(newhra, id = n())

which_max_olap = function(x){
  setDT(x)
  x[x[,.I[which.max(s2t_fraction)], by = source_id]$V1]
}
# Note: The existing ZIP to region and School district
# # generate crosswalks
# # ZIP to region
zip =  zipo %>% group_by(ZIP) %>% summarize()
zip = st_transform(zip, st_crs(newreg))
zip = reduce_overlaps(zip,snap = .5)
zip_tokc = create_xwalk(zip, kc, source_id = 'ZIP', target_id = 'id', min_overlap = .1)
setDT(zip_tokc)
zip = zip[zip$ZIP %in% zip_tokc[s2t_fraction >.01, source_id],]

# z2r_fo = create_xwalk(zip, newreg, source_id = 'ZIP', target_id = 'id', min_overlap = .1)
# z2r_fp = create_xwalk(zip, newreg, source_id = 'ZIP', target_id = 'id', min_overlap = .1,method = 'point pop',point_pop = kcparcelpop::parcel_pop, pp_min_overlap = .1)
#
# z2r_fo = which_max_olap(z2r_fo)
# z2r_fo = z2r_fo[s2t_fraction >=.05]
# z2r_fp = which_max_olap(z2r_fp)
#
# z2r = data.table(ZIP = zipo[zipo$COUNTY == '033', c('ZIP'), drop = T])
# z2r = merge(z2r, z2r_fo[, .(ZIP = source_id, region_id_fo = target_id)], by = 'ZIP')
# z2r = merge(z2r, z2r_fp[, .(ZIP = source_id, region_id_fp = target_id)], by = 'ZIP', all.x = T)
# z2r[is.na(region_id_fp), region_id_fp := region_id_fo]
# z2r[, match := region_id_fp == region_id_fo]
# z2r = merge(z2r,
#             rads.data::spatial_zip_city_region_scc[, .(ZIP = zip, region_orig = region_id)],
#             all.x = T, by = 'ZIP')
# z2r[is.na(region_orig), region_orig := region_id_fo]
# z2r[, match2 := region_id_fo == region_orig]
#
# # make a map showing where population and geography don't overlap
# zzz = merge(zip, z2r, by = 'ZIP')
#
# z2r = z2r[, .(ZIP, region_id_fo, region_id_fp, region_id_og = region_orig)]
# z2r[, paste0('region_name_', c('fo', 'fp', 'og')) := lapply(.SD, function(x) newreg$name[x]), .SDcols = paste0('region_id_', c('fo', 'fp', 'og'))]
# write.csv(z2r, file.path(outfol, 'zip_to_region2020.csv'), row.names = FALSE)

# ZIP to HRA
z2h_fo = create_xwalk(zip, newhra, source_id = 'ZIP', target_id = 'id', min_overlap = .1)
z2h_fp = create_xwalk(zip, newhra, source_id = 'ZIP', target_id = 'id', min_overlap = .1,method = 'point pop',point_pop = kcparcelpop::parcel_pop, pp_min_overlap = .1)
setDT(z2h_fo); setDT(z2h_fp);
z2h_fo = merge(z2h_fo, newhra[, c('id', 'name'), drop = T], all.x = T, by.x = 'target_id', by.y = 'id')
z2h_fp = merge(z2h_fp, newhra[, c('id', 'name'), drop = T], all.x = T, by.x = 'target_id', by.y = 'id')
setnames(z2h_fo, c('target_id', 'source_id', 'name'), c('hra20_id', 'ZIP', 'hra20_name'))
setnames(z2h_fp, c('target_id', 'source_id', 'name'), c('hra20_id', 'ZIP', 'hra20_name'))
z2h_fo[, c('source_id', 'target_id') := list(ZIP, hra20_id)][, method := 'geographic overlap']
z2h_fp[, c('source_id', 'target_id') := list(ZIP, hra20_id)][, method := 'point population']

z2h_fo[, creation_date := Sys.Date()]
z2h_fp[, creation_date := Sys.Date()]
spatial_zip_to_hra20_geog = z2h_fo
spatial_zip_to_hra20_pop = z2h_fp

setcolorder(spatial_zip_to_hra20_geog, c('ZIP', 'hra20_id', 's2t_fraction'))
setcolorder(spatial_zip_to_hra20_pop, c('ZIP', 'hra20_id', 's2t_fraction'))

#
# write.csv(z2h_fo, file.path(outfol, 'zip_to_hra2020_geo.csv'), row.names = FALSE)
# write.csv(z2h_fp, file.path(outfol, 'zip_to_hra2020_pop.csv'), row.names = FALSE)
usethis::use_data(spatial_zip_to_hra20_pop, overwrite = T)
usethis::use_data(spatial_zip_to_hra20_geog, overwrite = T)

# 2010 tracts to HRAs to region
t102h_fo = create_xwalk(tract10, newhra, source_id = 'GEOID10', target_id = 'id', min_overlap = .1)
t102h_fp = create_xwalk(tract10, newhra, source_id = 'GEOID10', target_id = 'id', min_overlap = .1,method = 'point pop',point_pop = kcparcelpop::parcel_pop, pp_min_overlap = .1)
setDT(t102h_fo); setDT(t102h_fp);
t102h_fo = merge(t102h_fo, newhra[, c('id', 'name'), drop = T], all.x = T, by.x = 'target_id', by.y = 'id')
t102h_fp = merge(t102h_fp, newhra[, c('id', 'name'), drop = T], all.x = T, by.x = 'target_id', by.y = 'id')
setnames(t102h_fo, c('target_id', 'source_id', 'name'), c('hra20_id', 'GEOID10', 'hra20_name'))
setnames(t102h_fp, c('target_id', 'source_id', 'name'), c('hra20_id', 'GEOID10', 'hra20_name'))
t102h_fo[, c('source_id', 'target_id') := list(GEOID10, hra20_id)][, method := 'geographic overlap']
t102h_fp[, c('source_id', 'target_id') := list(GEOID10, hra20_id)][, method := 'point population']

t102h_fo[, creation_date := Sys.Date()]
t102h_fp[, creation_date := Sys.Date()]
spatial_tract10_to_hra20_geog = t102h_fo
spatial_tract10_to_hra20_pop = t102h_fp

setcolorder(spatial_tract10_to_hra20_geog, c('GEOID10', 'hra20_id', 's2t_fraction'))
setcolorder(spatial_tract10_to_hra20_pop, c('GEOID10', 'hra20_id', 's2t_fraction'))

usethis::use_data(spatial_tract10_to_hra20_pop, overwrite = T)
usethis::use_data(spatial_tract10_to_hra20_geog, overwrite = T)
# write.csv(t102h_fo, file.path(outfol, 'tract10_to_hra2020_geo.csv'), row.names = FALSE)
# write.csv(t102h_fp, file.path(outfol, 'tract10_to_hra2020_pop.csv'), row.names = FALSE)

# Add 2020 tracts to HRAs?
tract20$GEOID20 = tract20$GEOID
t202h_fo = create_xwalk(tract20, newhra, source_id = 'GEOID20', target_id = 'id', min_overlap = .1)
t202h_fp = create_xwalk(tract20, newhra, source_id = 'GEOID20', target_id = 'id', min_overlap = .1,method = 'point pop',point_pop = kcparcelpop::parcel_pop, pp_min_overlap = .1)
setDT(t202h_fo); setDT(t202h_fp);
t202h_fo = merge(t202h_fo, newhra[, c('id', 'name'), drop = T], all.x = T, by.x = 'target_id', by.y = 'id')
t202h_fp = merge(t202h_fp, newhra[, c('id', 'name'), drop = T], all.x = T, by.x = 'target_id', by.y = 'id')
setnames(t202h_fo, c('target_id', 'source_id', 'name'), c('hra20_id', 'GEOID20', 'hra_name'))
setnames(t202h_fp, c('target_id', 'source_id', 'name'), c('hra20_id', 'GEOID20', 'hra_name'))
t202h_fo[, c('source_id', 'target_id') := list(GEOID20, hra20_id)][, method := 'geographic overlap']
t202h_fp[, c('source_id', 'target_id') := list(GEOID20, hra20_id)][, method := 'point population']

t202h_fo[, creation_date := Sys.Date()]
t202h_fp[, creation_date := Sys.Date()]
spatial_tract20_to_hra20_geog = t202h_fo
spatial_tract20_to_hra20_pop = t202h_fp

setcolorder(spatial_tract20_to_hra20_geog, c('GEOID20', 'hra20_id', 's2t_fraction'))
setcolorder(spatial_tract20_to_hra20_pop, c('GEOID20', 'hra20_id', 's2t_fraction'))

usethis::use_data(spatial_tract20_to_hra20_geog, overwrite = T)
usethis::use_data(spatial_tract20_to_hra20_pop,overwrite = T)


# 2020 blocks to HRAs to Regions
# stored on HHSAW by clean_up_hras.R
con <- DBI::dbConnect(odbc::odbc(),
                      driver = "ODBC Driver 18 for SQL Server",
                      server = keyring::key_list(service = 'azure_server')$username[1],
                      database = keyring::key_get('azure_server', keyring::key_list(service = 'azure_server')$username[1]),
                      uid = keyring::key_list('hhsaw')[["username"]],
                      pwd = keyring::key_get('hhsaw', keyring::key_list('hhsaw')[["username"]]),
                      Encrypt = 'yes',
                      TrustServerCertificate = 'yes',
                      Authentication = 'ActiveDirectoryPassword')
spatial_block20_to_hra20_to_region20 = setDT(dbGetQuery(con, 'Select * from ref.block2020_hra20'))
setnames(spatial_block20_to_hra20_to_region20, c('id', 'name', 'reg_id', 'reg_nm'), c('hra20_id', 'hra20_name', 'region_id', 'region_name'))
spatial_block20_to_hra20_to_region20 = spatial_block20_to_hra20_to_region20[, .(GEOID20, hra20_id, hra20_name, region_id, region_name, creation_date = Sys.Date())]
usethis::use_data(spatial_block20_to_hra20_to_region20, overwrite = TRUE)

# 2010 blocks to HRAs to Regions
b102hra = spatagg::create_xwalk(blk10, newhra, 'GEOID10', 'id')
b102hra = which_max_olap(b102hra)
spatial_block10_to_hra20_to_region20 = b102hra[,.(GEOID10 = source_id, hra20_id = target_id)]
labs = unique(spatial_block20_to_hra20_to_region20[,.(hra20_id, hra20_name, region_id, region_name)])
spatial_block10_to_hra20_to_region20 = merge(spatial_block10_to_hra20_to_region20, labs, by = 'hra20_id', all.x = T)
spatial_block10_to_hra20_to_region20[, creation_date := Sys.Date()]
usethis::use_data(spatial_block10_to_hra20_to_region20, overwrite = TRUE)

# HRA to region
spatial_hra20_to_region20 = labs
usethis::use_data(spatial_hra20_to_region20, overwrite = T)

#save things to csv
objs = ls()
objs = objs[substr(objs, 1,8) == 'spatial_']

for(ooo in objs){
  ootfile = file.path(getwd(), 'inst', 'extdata', 'spatial_data', paste0(substr(ooo, 9, nchar(ooo)), '.csv'))
  write.csv(get(ooo), file = ootfile, row.names = FALSE)
}

# # 2020 HRA to A&I HRA combos
# hracombo = st_transform(hracombo, st_crs(newhra))
# h2hc = create_xwalk(newhra, hracombo, source_id = 'id', 'HRA2010v2_')
# h2hc = which_max_olap(h2hc)
# hracombonew = merge(newhra, h2hc[,.(id = source_id, combo_name = target_id)], all.x = T)
# hracombonew = st_intersection(hracombonew, summarize(hracombonew))
# st_write(hracombonew, file.path('hracombo2020_draft.gpkg'))
