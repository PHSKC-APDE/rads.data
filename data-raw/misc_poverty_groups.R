# Author: Danny Colombara
# R version: 4.2.1
# Date: February 1, 2023
# Purpose: Create new poverty groupings
# Source: ACS 2017-2020 tabular data that was extracted as part of CHI
# Notes: Based on https://github.com/PHSKC-APDE/pers_dvc/blob/main/R/2020_poverty_groupings_v2.qmd

# Set up ----
    rm(list=ls())
    library(data.table)
    library(rads)

    acs.filepath <- "//dphcifs/APDE-CDIP/ACS/2021_2017_5_year/Analysis/03_ACS_Calculations/output_ACS_data_2021_2017_by_geography.xlsx"

# Prep tract data ----
    tract.all <- setDT(openxlsx::read.xlsx(acs.filepath, sheet = 'tract'))

    tract.dt <- tract.all[variable == 'population', .(geo_id, name, population = estimate)]

    for(ii in c('pov200', 'lths', 'ui1864', 'snap')){
      tract.dt <- merge(tract.dt, setnames(tract.all[variable == ii, .(geo_id, name, percent)], 'percent', ii))
    }

    tract.dt[geo_id == '1400000US53033005303', pov200 := 0] # assume 0% poverty for UW tract

    tract.dt <- merge(tract.dt, tract.all[variable == 'medinc', .(geo_id, name, medinc = estimate)], all = TRUE)

# Create tract poverty groups and summarize data ----
    tract.dt[, pov200grp := cut(pov200,
                                breaks = c(-.01, 0.099999999, 0.149999999, 0.249999999, 1),
                                labels = c("<10%", "10 ≤ 15%", "15 ≤ 25%", "25%+"))]

    tract.summary <- setorder(tract.dt[, .(tracts = .N,
                                          `tracts.%` = paste0(round2(100*.N/nrow(tract.dt), 1), "%"),
                                          tract.pop = format(sum(population), big.mark = ','),
                                          `tract.pop.%` = paste0(round2(100*sum(population) / sum(tract.dt$population), 1), "%"),
                                          medinc = format(round2(weighted.mean(medinc, population, na.rm = T), 0), big.mark = ',' ),
                                          lths = paste0(round2(100*weighted.mean(lths, population), 1), "%"),
                                          snap = paste0(round2(100*weighted.mean(snap, population), 1), "%"),
                                          ui1864 = paste0(round2(100*weighted.mean(ui1864, population), 1), "%")),
                                       pov200grp], pov200grp)

# Prep zcta data ----
    zcta.all <- setDT(openxlsx::read.xlsx(acs.filepath, sheet = 'zcta'))

    zcta.dt <- zcta.all[variable == 'population', .(geo_id, name, population = estimate)]

    for(ii in c('pov200', 'lths', 'ui1864', 'snap')){
      zcta.dt <- merge(zcta.dt, setnames(zcta.all[variable == ii, .(geo_id, name, percent)], 'percent', ii))
    }

    zcta.dt[name %like% '98195', pov200 := 0] # assume 0% poverty for UW zipcode

    zcta.dt <- merge(zcta.dt, zcta.all[variable == 'medinc', .(geo_id, name, medinc = estimate)], all = T)

# Create ZCTA poverty groups and summarize data ----
    zcta.dt[, pov200grp := cut(pov200,
                               breaks = c(-.01, 0.099999999, 0.149999999, 0.249999999, 1),
                               labels = c("<10%", "10 ≤ 15%", "15 ≤ 25%", "25%+"))]

    zcta.summary <- setorder(zcta.dt[, .(zctas = .N,
                                        `zctas.%` = paste0(round2(100*.N/nrow(zcta.dt), 1), "%"),
                                        zcta.pop = format(sum(population), big.mark = ','),
                                        `zcta.pop.%` = paste0(round2(100*sum(population) / sum(zcta.dt$population), 1), "%"),
                                        medinc = format(round2(weighted.mean(medinc, population, na.rm = T), 0), big.mark = ',' ),
                                        lths = paste0(round2(100*weighted.mean(lths, population), 1), "%"),
                                        snap = paste0(round2(100*weighted.mean(snap, population), 1), "%"),
                                        ui1864 = paste0(round2(100*weighted.mean(ui1864, population), 1), "%")),
                                    pov200grp], pov200grp)
# Check tables of poverty groups ----
  print(tract.summary)
  print(zcta.summary)

# Combined Tract and ZCTA tables ----
  misc_poverty_groups <- rbind(
    tract.dt[, .(geo_type = 'Tract', geo_id = gsub("^1400000US", "", geo_id), census_vintage = 2020, pov200grp, source = "ACS 2017-2021", creation_date = Sys.Date())],
    zcta.dt[, .(geo_type = 'ZCTA', geo_id = gsub("ZCTA5 ", "", name), census_vintage = 2020, pov200grp, source = "ACS 2017-2021", creation_date = Sys.Date())]
    )
  misc_poverty_groups[, pov200grp := factor(pov200grp, levels = c("<10%", "10 ≤ 15%", "15 ≤ 25%", "25%+"))]

# Save as RDA file ----
  usethis::use_data(misc_poverty_groups, compress = "bzip2", version = 3, overwrite = TRUE)

# Save as CSV file -----
  write.csv(misc_poverty_groups, file = "inst/extdata/misc_data/poverty_groups.csv", row.names = FALSE)
