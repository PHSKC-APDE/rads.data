## Header ----
# Author: Danny Colombara
# Date: March 13, 2023
# R version: 4.2.1
# Purpose: Create new crosswalk files from Census 2020 Geographies to King County
#          Council Districts (KCCDs) adopted December 8, 2021
#          # https://kingcounty.gov/council/councilmembers/find_district.aspx
#
# What I did:
#       I identified the intersections of all places, tracts, and block groups
#       with KCCDs. I preferentially kept the largest geography that intersected
#       with the KCCD in order to reduce standard error inflation when
#       aggregating ACS tabular data. This means that tracts or block groups
#       that were nested in places that were themselves in a KCCD were ignored.
#       Similarly, block groups nested in tracts which were already nested were
#       ignored. NOTE! Since 'places' can be large, they can have a bigger
#       impact on the estimates so the have a different threshold.
#
#       The QA maps and table are produced at the bottom of this code. They are
#       not saved in this repo because they can be easily reproduced.
#
# Remember!
#       1) KCCDs are properly defined by blocks, but ACS only has blocks for a
#          limited number of tables, which is why we have this miserable
#          situation.
#       2) There is a set hierarchy for blocks >> block groups >> tracts >>
#          counties. We can take advantage of this because of the nesting of
#          geoids.
#       3) Places do NOT fit into the hierarchy; they can spill across county
#          lines but are always contained within a single state.


## Set up ----
  rm(list = ls())
  pacman::p_load(data.table, rads, ggplot2, sf, leaflet)
  options(scipen = 999) # turn off scientific notation

  cutpoint = 0.85 # keep if > XX% of a geography's area intersects with the HRA
  excludepoint = 0.5 # keep if > XX% of a geography's area intersects with the HRA
  place.cutpoint = 0.95 # keep if > XX% of a geography's area intersects with the HRA
  export.dir <- "c:/temp/acs_hras"
  shapefile.dir <- "//dphcifs/APDE-CDIP/Shapefiles/"

## Get shapefiles ----
  # Load and standardize shapefiles ----
    kccds <- st_read(paste0(shapefile.dir,
                           "Political_Districts/2022_Metropolitan_King_County_Council_Districts.shp"))
    kccds$kccds.area.start = as.numeric(st_area(kccds)) # get initial area of each bg
    kccds$id <- kccds$kccdst

    water = st_read("//Kcitfsrprpgdw01/kclib/Plibrary2/hydro/shapes/polygon/wtrbdy.shp")
    water <- st_make_valid(st_transform(water, st_crs(kccds)))
    water <- subset(water, SUBSET == 'Bigwater waterbody')
    water <- st_make_valid(subset(water, FEATURE_ID %in% st_make_valid(st_intersection(water, kccds))$FEATURE_ID)) # just bigwaters that intersect KC

    bgs <- st_read(paste0(shapefile.dir, "/Census_2020/block_group/kc_block_group.shp"), stringsAsFactors = F)
    bgs <- st_transform(bgs, st_crs(kccds))
    bgs <- st_make_valid(bgs)

    tracts <- st_read(paste0(shapefile.dir, "/Census_2020/tract/kc_tract.shp"), stringsAsFactors = F)
    tracts <- st_transform(tracts, st_crs(kccds))
    tracts <- st_make_valid(tracts)

    places <- st_read(paste0(shapefile.dir, "/Census_2020/places/kc_places.shp"), stringsAsFactors = F)
    places <- st_transform(places, st_crs(kccds))
    places <- st_make_valid(places)
    places$area.start = as.numeric(st_area(places)) # get initial area of each place

  # erase big waters ----
    kccds <- rmapshaper::ms_erase(kccds, st_crop(water, kccds))
    bgs <- rmapshaper::ms_erase(bgs, st_crop(water, bgs))
    tracts <- rmapshaper::ms_erase(tracts, st_crop(water, tracts))
    places <- rmapshaper::ms_erase(places, st_crop(water, places))

  # create copies of shapefiles before manipulation below ----
    orig.kccds <- copy(kccds)
    orig.bgs <- copy(bgs)
    orig.tracts <- copy(tracts)
    orig.places <- copy(places)

## STEP 1: Identify places and kccds that define the same geography ----
  # Compute area intersection (didn't use spatagg:: because needed fraction in both directions)
    tempi <- st_make_valid(st_intersection(places, kccds))
    tempi$prop = as.numeric(st_area(tempi)) / tempi$area.start
    tempi$kccd.prop = as.numeric(st_area(tempi)) / tempi$kccds.area.start

    pairs.1 <- setDT(copy(tempi))[kccd.prop > place.cutpoint & prop > place.cutpoint, .(place = GEOID, kccd = id)]

  # drop bg geographies that are nested within these places and kccds
    tempi <- st_make_valid(st_intersection(bgs, subset(places, GEOID %in% pairs.1$place)))
    tempi$prop = as.numeric(st_area(tempi)) / tempi$area.start
    tempi <- setDT(tempi)[prop >= cutpoint, .(bgGEOID = GEOID, prop)]
    bgs <- subset(bgs, !GEOID %in% tempi$bgGEOID)

  # drop tract geographies that are nested within these places and kccds
    tempi <- st_make_valid(st_intersection(tracts, subset(places, GEOID %in% pairs.1$place)))
    tempi$prop = as.numeric(st_area(tempi)) / tempi$area.start
    tempi <- setDT(tempi)[prop >= cutpoint, .(tractGEOID = GEOID, prop)]
    tracts <- subset(tracts, !GEOID %in% tempi$tractGEOID)

  # drop places & kccds that are already matched
    places <- subset(places, !GEOID %in% pairs.1$place )
    kccds <- subset(kccds, !id %in% pairs.1$kccd)

## STEP 2: Identify remaining places that are nested within remaining kccds ----
  # Compute area of intersection
    tempi = spatagg::create_xwalk(source = places, target = kccds,
                               source_id = 'GEOID', target_id = 'id', min_overlap = 0.1)
    pairs.2 <- setDT(copy(tempi))[s2t_fraction >= place.cutpoint, .(place = source_id, kccd = target_id)]

    unioned <- st_cast(st_as_sf(st_union(subset(places, GEOID %in% pairs.2$place))), 'POLYGON')
    unioned$ID <- 1:nrow(unioned)

  # drop bg geographies that are nested within the places in pairs.2
    tempi = spatagg::create_xwalk(source = bgs, target = unioned,
                                  source_id = 'GEOID', target_id = 'ID', min_overlap = 0.1)
    tempi <- setDT(copy(tempi))[s2t_fraction >= excludepoint,]
    bgs <- subset(bgs, !GEOID %in% tempi$source_id)

  # drop tract geographies that are nested within the places in pairs.2
    tempi = spatagg::create_xwalk(source = tracts, target = unioned,
                                  source_id = 'GEOID', target_id = 'ID', min_overlap = 0.1)
    tempi <- setDT(copy(tempi))[s2t_fraction >= excludepoint,]
    tracts <- subset(tracts, !GEOID %in% tempi$source_id)

## STEP 3: Identify remaining tracts that are nested within remaining kccds ----
  # Compute area of intersection
    tempi = spatagg::create_xwalk(source = tracts, target = kccds,
                                  source_id = 'GEOID', target_id = 'id', min_overlap = 0.1)
    pairs.3 <- setDT(copy(tempi))[s2t_fraction >= cutpoint, .(tract = source_id, kccd = target_id)]

    unioned <- st_cast(st_as_sf(st_union(subset(tracts, GEOID %in% pairs.3$tract))), 'POLYGON')
    unioned$ID <- 1:nrow(unioned)

  # drop bg geographies that are nested within the tracts in pairs.3
    tempi = spatagg::create_xwalk(source = bgs, target = unioned,
                                  source_id = 'GEOID', target_id = 'ID', min_overlap = 0.1)
    tempi <- setDT(copy(tempi))[s2t_fraction >= excludepoint,]
    bgs <- subset(bgs, !GEOID %in% tempi$source_id)


## STEP 4: Identify remaining blockgroups that are nested withing remaining kccds ----
  # Compute area of intersection
    tempi = spatagg::create_xwalk(source = bgs, target = kccds,
                                  source_id = 'GEOID', target_id = 'id', min_overlap = 0.1)
    pairs.4 <- setDT(copy(tempi))[s2t_fraction >= 0.51, .(bg = source_id, kccd = target_id)]

  # remove bg geographies that are nested within the tracts in pairs.4
    bgs <- subset(bgs, !GEOID %in% pairs.4$bg)

## STEP 5: Create initial complete GEOID20-kccd20 crosswalk ----
    # append pairs ----
    xwalk <- rbind(pairs.1, pairs.2, pairs.3, pairs.4, fill = T)

    # manual tweaks based on visual inspection ----

    # final table structure ----
    xwalk <- unique(merge(xwalk, setDT(copy(orig.kccds))[, .(kccd = id)], all.x = T, all.y = F))
    xwalk <- xwalk[, .(kccd20 = kccd, place20 = place, tract20 = tract, bg20 = bg)]

## STEP 6: Map all crosswalks ----
  # Create plot.tidy function (places/tracts/bgs cropped to kccd borders) ----
      plot.tidy <- function(mygeo){
        message(paste0("Mapping ", mygeo, " (tidy)"))
        myxwalks <- xwalk[kccd20 == mygeo]
        mykccds = subset(orig.kccds, id == mygeo) # select just one kccd
        myplaces = suppressWarnings(subset(st_intersection(orig.places, mykccds), GEOID %in% myxwalks$place20)) # only tracts that intersect the kccd of interest
        mytracts = suppressWarnings(subset(st_intersection(orig.tracts, mykccds), GEOID %in% myxwalks$tract20)) # only tracts that intersect the kccd of interest
        mybgs = suppressWarnings(subset(st_intersection(orig.bgs, mykccds), GEOID %in% myxwalks$bg20)) # only bgs that intersect the kccd of interest
        ggplot() +
          geom_sf(data = mykccds, fill = 'white', color = "black") +
          geom_sf(data = myplaces, fill = "yellow", color = "yellow", alpha = 0.2) +
          geom_sf(data = mytracts, fill = "red", color = "red", alpha = 0.2) +
          geom_sf(data = mybgs, fill = "blue", color = "black", alpha = 0.2) +
          labs(title = mygeo, subtitle = "Tidy version == places, tracts, & block groups cropped to kccd borders." , caption = "yellow = place; red = tract; blue = block group")
      }

  # Create plot.messy function ----
      plot.messy <- function(mygeo){
        message(paste0("Mapping ", mygeo, " (messy)"))
        myxwalks <- xwalk[kccd20 == mygeo]
        mykccds = subset(kccds, id == mygeo) # select just one kccd
        myplaces = suppressWarnings(subset(orig.places, GEOID %in% myxwalks$place20)) # only tracts that intersect the kccd of interest
        mytracts = suppressWarnings(subset(orig.tracts, GEOID %in% myxwalks$tract20)) # only tracts that intersect the kccd of interest
        mybgs = suppressWarnings(subset(orig.bgs, GEOID %in% myxwalks$bg20)) # only bgs that intersect the kccd of interest
        ggplot() +
          geom_sf(data = myplaces, fill = "yellow", color = "white", alpha = 0.5) +
          geom_sf(data = mytracts, fill = "red", color = "white", alpha = 0.2) +
          geom_sf(data = mybgs, fill = "blue", color = "white", alpha = 0.2) +
          geom_sf(data = mykccds, fill = 'white', color = "black", alpha = 0.2) +
          theme(panel.grid.major = element_line(colour = "transparent"),
                panel.background = element_rect(fill = 'transparent', colour = 'transparent')) +
          labs(title = mygeo, subtitle = "Messy version == places, tracts, & block groups allowed to show spilling over kccd borders." ,
               caption = "black line = kccd border; yellow = place; red = tract; blue = block group")

      }

  # Apply mapping functions and save as PDFs ----
      pdf(paste0(export.dir, "/xwalk_maps_GEOID20_kccd20_tidy", ".pdf"), height=8.5, width=11) # open the PDF into which I will append all the files
      for(single.kccd in sort(unique(xwalk$kccd20))){
        my.plot <- plot.tidy(single.kccd)
        print(my.plot) # force R to produce plot so it will save into PDF
      }
      dev.off() # close the PDF

      pdf(paste0(export.dir, "/xwalk_maps_GEOID20_kccd20_messy", ".pdf"), height=8.5, width=11) # open the PDF into which I will append all the files
      for(single.kccd in sort(unique(xwalk$kccd20))){
        my.plot <- plot.messy(single.kccd)
        print(my.plot) # force R to produce plot so it will save into PDF
      }
      dev.off() # close the PDF

# STEP 7: Save crosswalk (after visually confirming it is reasonable) ----
      # tidy table for export ----
        spatial_geoid20_to_kccd20_acs <- copy(xwalk)
        spatial_geoid20_to_kccd20_acs[, creation_date := Sys.Date()]
        spatial_geoid20_to_kccd20_acs <- spatial_geoid20_to_kccd20_acs[, .(kccd20_id = kccd20, kccd20_name = paste("District ", kccd20), place20, tract20, bg20, creation_date)]
        setorder(spatial_geoid20_to_kccd20_acs, kccd20_id, bg20, tract20, place20)

      # Save as RDA file ----
        usethis::use_data(spatial_geoid20_to_kccd20_acs, compress = "bzip2", version = 3, overwrite = TRUE)

      # Save as CSV file -----
        write.csv(spatial_geoid20_to_kccd20_acs, file = paste0(here::here(), "/inst/extdata/spatial_data/geoid20_to_kccd20_acs.csv"), row.names = FALSE)



# The end ----

