## Header ----
# Author: Danny Colombara
# Date: March 13, 2023
# R version: 4.2.1
# Purpose: Create new crosswalk files from Census 2020 Geographies to Seattle
#          City Council Districts (SCCDs) (vintage 2013)
#
# Note! New boundaries will take effect January 2024 so this process must be
#       be repeated
#
# What I did:
#       I identified the intersections of all places, tracts, and block groups
#       with SCCDs I preferentially kept the largest geography that intersected
#       with the SCCD in order to reduce standard error inflation when
#       aggregating ACS tabular data. This means that tracts or block groups
#       that were nested in places that were themselves in a SCCD were ignored.
#       Similarly, block groups nested in tracts which were already nested were
#       ignored. NOTE! Since 'places' can be large, they can have a bigger
#       impact on the estimates so the have a different threshold.
#
#       The QA maps and table are produced at the bottom of this code. They are
#       not saved in this repo because they can be easily reproduced.
#
# Remember!
#       1) SCCDs are properly defined by blocks, but ACS only has blocks for a
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
    sccds <- st_read(paste0(shapefile.dir, "Seattle/Council_Districts_2013.shp"))
    sccds$sccds.area.start = as.numeric(st_area(sccds)) # get initial area of each bg
    sccds <- spatagg::reduce_overlaps(sccds)
    sccds$id <- sccds$C_DISTRICT
    sccds <- st_make_valid(sccds)

    water = st_read("//Kcitfsrprpgdw01/kclib/Plibrary2/hydro/shapes/polygon/wtrbdy.shp")
    water <- st_make_valid(st_transform(water, st_crs(sccds)))
    water <- subset(water, SUBSET == 'Bigwater waterbody')
    water <- st_make_valid(subset(water, FEATURE_ID %in% st_make_valid(st_intersection(water, sccds))$FEATURE_ID)) # just places that intersect Seattle

    bgs <- st_read(paste0(shapefile.dir, "/Census_2020/block_group/kc_block_group.shp"), stringsAsFactors = F)
    bgs <- st_transform(bgs, st_crs(sccds))
    bgs <- st_make_valid(bgs)
    bgs <- st_make_valid(subset(bgs, GEOID %in% st_make_valid(st_intersection(bgs, sccds))$GEOID))

    tracts <- st_read(paste0(shapefile.dir, "/Census_2020/tract/kc_tract.shp"), stringsAsFactors = F)
    tracts <- st_transform(tracts, st_crs(sccds))
    tracts <- st_make_valid(tracts)
    tracts <- st_make_valid(subset(tracts, GEOID %in% st_make_valid(st_intersection(tracts, sccds))$GEOID))

    places <- st_read(paste0(shapefile.dir, "/Census_2020/places/kc_places.shp"), stringsAsFactors = F)
    places <- st_transform(places, st_crs(sccds))
    places <- st_make_valid(places)
    places$area.start = as.numeric(st_area(places)) # get initial area of each place
    places <- st_make_valid(subset(places, GEOID %in% st_make_valid(st_intersection(places, sccds))$GEOID))

  # erase big waters ----
    bgs <- rmapshaper::ms_erase(bgs, st_crop(water, bgs))
    tracts <- rmapshaper::ms_erase(tracts, st_crop(water, tracts))
    places <- rmapshaper::ms_erase(places, st_crop(water, places))

  # create copies of shapefiles before manipulation below ----
    orig.sccds <- copy(sccds)
    orig.bgs <- copy(bgs)
    orig.tracts <- copy(tracts)
    orig.places <- copy(places)

## STEP 1: Identify places and sccds that define the same geography (should be zero) ----
    # skip since all of Seattle is a single 'place', and districts are part of Seattle
    pairs.1 <- data.table()

## STEP 2: Identify remaining places that are nested within remaining sccds ----
    # skip since all of Seattle is a single 'place', and districts are part of Seattle
    pairs.2 <- data.table()

## STEP 3: Identify remaining tracts that are nested within remaining sccds ----
  # Compute area of intersection
    tempi = spatagg::create_xwalk(source = tracts, target = sccds,
                                  source_id = 'GEOID', target_id = 'id', min_overlap = 0.1)
    pairs.3 <- setDT(copy(tempi))[s2t_fraction >= .51, .(tract = source_id, sccd = target_id)]

    unioned <- st_cast(st_as_sf(st_union(subset(tracts, GEOID %in% pairs.3$tract))), 'POLYGON')
    unioned$ID <- 1:nrow(unioned)

  # drop bg geographies that are nested within the tracts in pairs.3
    tempi = spatagg::create_xwalk(source = bgs, target = unioned,
                                  source_id = 'GEOID', target_id = 'ID', min_overlap = 0.1)
    tempi <- setDT(copy(tempi))[s2t_fraction >= excludepoint,]
    bgs <- subset(bgs, !GEOID %in% tempi$source_id)


## STEP 4: Identify remaining blockgroups that are nested withing remaining sccds ----
  # Compute area of intersection
    tempi = spatagg::create_xwalk(source = bgs, target = sccds,
                                  source_id = 'GEOID', target_id = 'id', min_overlap = 0.1)
    pairs.4 <- setDT(copy(tempi))[s2t_fraction >= 0.51, .(bg = source_id, sccd = target_id)]

  # remove bg geographies that are nested within the tracts in pairs.4
    bgs <- subset(bgs, !GEOID %in% pairs.4$bg)

## STEP 5: Create initial complete GEOID20-sccd13 crosswalk ----
    # append pairs ----
    xwalk <- rbind(pairs.1, pairs.2, pairs.3, pairs.4, fill = T)

    # manual tweaks based on visual inspection ----

    # final table structure ----
    xwalk <- unique(merge(xwalk, setDT(copy(orig.sccds))[, .(sccd = id)], all.x = T, all.y = F))
    xwalk <- xwalk[, .(sccd13 = sccd, place20 = NA_character_, tract20 = tract, bg20 = bg)]

## STEP 6: Map all crosswalks ----
  # Create plot.tidy function (places/tracts/bgs cropped to sccd borders) ----
      plot.tidy <- function(mygeo){
        message(paste0("Mapping ", mygeo, " (tidy)"))
        myxwalks <- xwalk[sccd13 == mygeo]
        mysccds = subset(orig.sccds, id == mygeo) # select just one sccd
        # myplaces = suppressWarnings(subset(st_intersection(orig.places, mysccds), GEOID %in% myxwalks$place20)) # only tracts that intersect the sccd of interest
        mytracts = suppressWarnings(subset(st_intersection(orig.tracts, mysccds), GEOID %in% myxwalks$tract20)) # only tracts that intersect the sccd of interest
        mybgs = suppressWarnings(subset(st_intersection(orig.bgs, mysccds), GEOID %in% myxwalks$bg20)) # only bgs that intersect the sccd of interest
        ggplot() +
          geom_sf(data = mysccds, fill = 'white', color = "black") +
          # geom_sf(data = myplaces, fill = "yellow", color = "yellow", alpha = 0.2) +
          geom_sf(data = mytracts, fill = "red", color = "red", alpha = 0.2) +
          geom_sf(data = mybgs, fill = "blue", color = "black", alpha = 0.2) +
          labs(title = mygeo, subtitle = "Tidy version == places, tracts, & block groups cropped to sccd borders." , caption = "yellow = place; red = tract; blue = block group")
      }

  # Create plot.messy function ----
      plot.messy <- function(mygeo){
        message(paste0("Mapping ", mygeo, " (messy)"))
        myxwalks <- xwalk[sccd13 == mygeo]
        mysccds = subset(sccds, id == mygeo) # select just one sccd
        # myplaces = suppressWarnings(subset(orig.places, GEOID %in% myxwalks$place20)) # only tracts that intersect the sccd of interest
        mytracts = suppressWarnings(subset(orig.tracts, GEOID %in% myxwalks$tract20)) # only tracts that intersect the sccd of interest
        mybgs = suppressWarnings(subset(orig.bgs, GEOID %in% myxwalks$bg20)) # only bgs that intersect the sccd of interest
        ggplot() +
          # geom_sf(data = myplaces, fill = "yellow", color = "white", alpha = 0.5) +
          geom_sf(data = mytracts, fill = "red", color = "white", alpha = 0.2) +
          geom_sf(data = mybgs, fill = "blue", color = "white", alpha = 0.2) +
          geom_sf(data = mysccds, fill = 'white', color = "black", alpha = 0.2) +
          theme(panel.grid.major = element_line(colour = "transparent"),
                panel.background = element_rect(fill = 'transparent', colour = 'transparent')) +
          labs(title = mygeo, subtitle = "Messy version == places, tracts, & block groups allowed to show spilling over sccd borders." ,
               caption = "black line = sccd border; yellow = place; red = tract; blue = block group")

      }

  # Apply mapping functions and save as PDFs ----
      pdf(paste0(export.dir, "/xwalk_maps_GEOID20_sccd13_tidy", ".pdf"), height=8.5, width=11) # open the PDF into which I will append all the files
      for(single.sccd in sort(unique(xwalk$sccd13))){
        my.plot <- plot.tidy(single.sccd)
        print(my.plot) # force R to produce plot so it will save into PDF
      }
      dev.off() # close the PDF

      pdf(paste0(export.dir, "/xwalk_maps_GEOID20_sccd13_messy", ".pdf"), height=8.5, width=11) # open the PDF into which I will append all the files
      for(single.sccd in sort(unique(xwalk$sccd13))){
        my.plot <- plot.messy(single.sccd)
        print(my.plot) # force R to produce plot so it will save into PDF
      }
      dev.off() # close the PDF

# STEP 7: Save crosswalk (after visually confirming it is reasonable) ----
      # tidy table for export ----
        spatial_geoid20_to_sccd13_acs <- copy(xwalk)
        spatial_geoid20_to_sccd13_acs[, creation_date := Sys.Date()]
        spatial_geoid20_to_sccd13_acs <- spatial_geoid20_to_sccd13_acs[, .(sccd13_id = sccd13, sccd13_name = paste("District ", sccd13), place20, tract20, bg20, creation_date)]
        setorder(spatial_geoid20_to_sccd13_acs, sccd13_id, bg20, tract20, place20)

      # Save as RDA file ----
        usethis::use_data(spatial_geoid20_to_sccd13_acs, compress = "bzip2", version = 3, overwrite = TRUE)

      # Save as CSV file -----
        write.csv(spatial_geoid20_to_sccd13_acs, file = paste0(here::here(), "/inst/extdata/spatial_data/geoid20_to_sccd13_acs.csv"), row.names = FALSE)



# The end ----

