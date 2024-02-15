# spatial_block10_to_hra20_to_region20 ----
#' Spatial crosswalk for Census 2010 blocks to 2020 HRAs and 2020 regions
#'
#'
#' @format A data.table with 35830 rows and 6 variables:
#'
#'   \code{hra20_id}: Numeric id for the HRA,
#'
#'   \code{GEOID10}: 2010 Census block id ,
#'
#'   \code{hra20_name}: Name of the HRA,
#'
#'   \code{region_id}: numeric id for the region,
#'
#'   \code{region_name}: Name of the region
#'
#'   \code{creation_date}: Date the file was created
#'
#' @name spatial_block10_to_hra20_to_region20
"spatial_block10_to_hra20_to_region20"



# spatial_block20_to_hra20_to_region20 ----
#' Spatial crosswalk for Census 2010 blocks to 2020 HRAs and 2020 regions
#'
#'
#' @format A data.table with 27686 rows and 6 variables:
#'
#'   \code{hra20_id}: Numeric id for the HRA,
#'
#'   \code{GEOID20}: 2020 Census block id ,
#'
#'   \code{hra20_name}: Name of the HRA,
#'
#'   \code{region_id}: numeric id for the region,
#'
#'   \code{region_name}: Name of the region
#'
#'   \code{creation_date}: Date the file was created
#'
#' @name spatial_block20_to_hra20_to_region20
"spatial_block20_to_hra20_to_region20"



# spatial_geoid20_to_hra20_acs ----
#' Spatial crosswalk for ACS Census 2020 geographies to 2020 HRAs ----
#'
#' @description Different American Community Survey (ACS) estimates are released
#' at a variety of geographic levels: block groups, tracts, places (cities,
#' towns, and Census Designated Places (CDPs)), etc. Since HRAs are properly
#' defined by blocks and block level estimates are not available, this
#' crosswalk represents a best attempt to create a crosswalk using the largest
#' possible sub-HRA geographies so as to prevent unnecessary inflation in the
#' standard error during calculation of ACS HRA and Region level estimates.
#'
#' @format A data.table with 547 rows and 6 variables:
#'
#'   \code{hra20_id}: Numeric id for the 2020 HRA,
#'
#'   \code{hra20_name}: Official name for the 2020 HRA,
#'
#'   \code{place20}: place 2020 GEOID,
#'
#'   \code{tract20}: tract 2020 GEOID,
#'
#'   \code{bg20}: bg 2020 GEOID,
#'
#'   \code{creation}: Date the file was created
#'
#' @name spatial_geoid20_to_hra20_acs
"spatial_geoid20_to_hra20_acs"

# spatial_geoid20_to_kccd20_acs ----
#' Spatial crosswalk for ACS Census 2020 geographies to 2013 King County Council Districts
#'
#' @description Different American Community Survey (ACS) estimates are released
#' at a variety of geographic levels: block groups, tracts, places (cities,
#' towns, and Census Designated Places (CDPs)), etc. This
#' crosswalk represents a best attempt to create a crosswalk using the largest
#' possible sub-district geographies so as to prevent unnecessary inflation in the
#' standard error during calculation of ACS King County Council level estimates.
#'
#' @format A data.table with 506 rows and 6 variables:
#'
#'   \code{kccd20_id}: King County Council district number,
#'
#'   \code{kccd20_name}: King County Council district name,
#'
#'   \code{place20}: place 2020 GEOID,
#'
#'   \code{tract20}: tract 2020 GEOID,
#'
#'   \code{bg20}: bg 2020 GEOID,
#'
#'   \code{creation}: Date the file was created
#'
#' @name spatial_geoid20_to_kccd20_acs
"spatial_geoid20_to_kccd20_acs"


# spatial_geoid20_to_sccd13_acs ----
#' Spatial crosswalk for ACS Census 2020 geographies to 2013 Seattle City Council Districts
#'
#' @description Different American Community Survey (ACS) estimates are released
#' at a variety of geographic levels: block groups, tracts, places (cities,
#' towns, and Census Designated Places (CDPs)), etc. This
#' crosswalk represents a best attempt to create a crosswalk using the largest
#' possible sub-district geographies so as to prevent unnecessary inflation in the
#' standard error during calculation of ACS Seattle City Council level estimates.
#'
#' @format A data.table with 177 rows and 6 variables:
#'
#'   \code{sccd13_id}: Seattle City Council district number,
#'
#'   \code{sccd13_name}: Seattle City Council district name,
#'
#'   \code{place20}: place 2020 GEOID,
#'
#'   \code{tract20}: tract 2020 GEOID,
#'
#'   \code{bg20}: bg 2020 GEOID,
#'
#'   \code{creation}: Date the file was created
#'
#' @name spatial_geoid20_to_sccd13_acs
"spatial_geoid20_to_sccd13_acs"


# spatial_hra20_to_coo20 ----
#' Spatial crosswalk between 2020 HRAs and 2020 Communities of Opportunity areas
#'
#' @description A simple crosswalk of which individual 2020 HRAs map to specific
#' COO areas.
#'
#' @format A data.table with 19 rows and 3 variables:
#'
#'   \code{hra20_id}: Numeric id for the HRA,
#'
#'   \code{hra20_name}: Name of the HRA,
#'
#'   \code{coo20_name}: numeric id for the COO area
#'
#' @name spatial_hra20_to_coo20
"spatial_hra20_to_coo20"


# spatial_hra20_to_bigcities ----
#' Spatial crosswalk between 2020 HRAs and King County's eight 'big cities'.
#'
#' @description A simple 1:1 crosswalk of which individual 2020 HRAs map to
#' King County's 'big cities'.
#'
#' @format A data.table with 34 rows and 3 variables:
#'
#'   \code{hra20_id}: Numeric id for the HRA,
#'
#'   \code{hra20_name}: Name of the HRA,
#'
#'   \code{bigcity}: Name of the big city
#' @name spatial_hra20_to_bigcities
"spatial_hra20_to_bigcities"

# spatial_hra20_to_region20 ----
#' Spatial crosswalk between 2020 HRAs and 2020 regions.
#'
#' @description A simple 1:1 crosswalk of which individual 2020 HRAs map to
#' specific COO areas.
#'
#' @format A data.table with 61 rows and 4 variables:
#'
#'   \code{hra20_id}: Numeric id for the HRA,
#'
#'   \code{hra20_name}: Name of the HRA,
#'
#'   \code{region_id}: numeric id for the region,
#'
#'   \code{region_name}: Name of the region
#' @name spatial_hra20_to_region20
"spatial_hra20_to_region20"



# spatial_tract10_to_hra20_geog ----
#' Spatial crosswalk between 2010 census tract and 2020 HRAs. There is
#' one row between each tract and HRA that intersects geographically
#'
#' The are based on the fractional overlap approach in spatagg::create_xwalk and broadly
#' follow that file structure.
#'
#'
#' @format A data.table with 964 rows and 11 variables:
#'
#'   \code{GEOID10}: tract id,
#'
#'   \code{hra20_id}: HRA numeric id,
#'
#'   \code{s2t_fraction}: Percent of the area in ZIP that is also in hra20_id,
#'
#'   \code{isect_amount}: # of square survey feet in the intersection of tract and hra20_id,
#'
#'   \code{tcoverage_amount}: Area of the hra20_id in any tract code,
#'
#'   \code{target_amount}: Total area of  the HRA (including areas not covered by tracts),
#'
#'   \code{hra_name}: Name of the HRA,
#'
#'   \code{source_id}: tract,
#'
#'   \code{target_id}: hra20_id,
#'
#'   \code{method}: method to produce intersections
#'
#'   \code{creation_date}: Date file created
#'
#' @name spatial_tract10_to_hra20_geog
"spatial_tract10_to_hra20_geog"

# spatial_tract10_to_hra20_pop ----
#' Spatial crosswalk between 2010 census tracts and 2020 HRAs. There is
#' one row between each tract and HRA that shares population.
#'
#' The are based on the point pop approach in spatagg::create_xwalk and broadly
#' follow that file structure.
#'
#'
#' @format A data.table with 559 rows and 11 variables:
#'
#'   \code{GEOID10}: Census 2010 id,
#'
#'   \code{hra20_id}: HRA numeric id,
#'
#'   \code{s2t_fraction}: Percent of the population in tract that is also in hra20_id,
#'
#'   \code{isect_amount}: # of people who live in the intersection of tract and hra20_id,
#'
#'   \code{tcoverage_amount}: Population of the hra20_id in any tract code,
#'
#'   \code{target_amount}: Total number of people within the HRA (including areas not covered by tracts),
#'
#'   \code{hra_name}: Name of the HRA,
#'
#'   \code{source_id}: tract,
#'
#'   \code{target_id}: hra20_id,
#'
#'   \code{method}: method to produce intersections
#'
#'   \code{creation_date}: Date file created
#'
#' @name spatial_tract10_to_hra20_pop
"spatial_tract10_to_hra20_pop"


# spatial_tract20_to_hra20_geog ----
#' Spatial crosswalk between 2020 census tracts and 2020 HRAs. There is
#' one row between each tract and HRA that intersects geographically
#'
#' The are based on the fractional overlap approach in spatagg::create_xwalk and broadly
#' follow that file structure.
#'
#'
#' @format A data.table with 1083 rows and 11 variables:
#'
#'   \code{GEOID20}: tract id,
#'
#'   \code{hra20_id}: HRA numeric id,
#'
#'   \code{s2t_fraction}: Percent of the area in ZIP that is also in hra20_id,
#'
#'   \code{isect_amount}: # of square survey feet in the intersection of tract and hra20_id,
#'
#'   \code{tcoverage_amount}: Area of the hra20_id in any tract code,
#'
#'   \code{target_amount}: Total area of  the HRA (including areas not covered by tracts),
#'
#'   \code{hra_name}: Name of the HRA,
#'
#'   \code{source_id}: tract,
#'
#'   \code{target_id}: hra20_id,
#'
#'   \code{method}: method to produce intersections
#'
#'   \code{creation_date}: Date file created
#'
#' @name spatial_tract20_to_hra20_geog
"spatial_tract20_to_hra20_geog"

# spatial_tract20_to_hra20_pop ----
#' Spatial crosswalk between 2020 census tracts and 2020 HRAs. There is
#' one row between each tract and HRA that shares population.
#'
#' The are based on the point pop approach in spatagg::create_xwalk and broadly
#' follow that file structure.
#'
#'
#' @format A data.table with 666 rows and 111 variables:
#'
#'   \code{GEOID20}: Census 2020 id,
#'
#'   \code{hra20_id}: HRA numeric id,
#'
#'   \code{s2t_fraction}: Percent of the population in tract that is also in hra20_id,
#'
#'   \code{isect_amount}: # of people who live in the intersection of tract and hra20_id,
#'
#'   \code{tcoverage_amount}: Population of the hra20_id in any tract code,
#'
#'   \code{target_amount}: Total number of people within the HRA (including areas not covered by tracts),
#'
#'   \code{hra_name}: Name of the HRA,
#'
#'   \code{source_id}: tract,
#'
#'   \code{target_id}: hra20_id,
#'
#'   \code{method}: method to produce intersections
#'
#'   \code{creation_date}: Date file created
#'
#' @name spatial_tract20_to_hra20_pop
"spatial_tract20_to_hra20_pop"

# spatial_zip_to_hra20_pop ----
#' Spatial crosswalk between ZIP codes and  2020 HRAs
#'
#' There is one row between each ZIP and HRA that shares population.
#'
#' The are based on the point pop approach in spatagg::create_xwalk and broadly
#' follow that file structure.
#'
#' Note: ZIP codes are not completely nested within King County. As such, end users
#' may want to further process this file to handle edge effects
#'
#'
#' @format A data.table with 233 rows and 11 variables:
#'
#'   \code{ZIP}: ZIP code,
#'
#'   \code{hra20_id}: HRA numeric id,
#'
#'   \code{s2t_fraction}: Percent of the population in ZIP that is also in hra20_id,
#'
#'   \code{isect_amount}: # of people who live in the intersection of ZIP and hra20_id,
#'
#'   \code{tcoverage_amount}: Population of the hra20_id in any ZIP code,
#'
#'   \code{target_amount}: Total number of people within the HRA (including areas not covered by ZIPs),
#'
#'   \code{hra_name}: Name of the HRA,
#'
#'   \code{source_id}: ZIP,
#'
#'   \code{target_id}: hra20_id,
#'
#'   \code{method}: method to produce intersections,
#'
#'   \code{creation_date}: Date file created
#'
#' @name spatial_zip_to_hra20_pop
"spatial_zip_to_hra20_pop"

# spatial_zip_to_hra20_geog ----
#' Spatial crosswalk between ZIP codes and 2020 HRAs. There is
#' one row between each ZIP and HRA that intersects geographically
#'
#' The are based on the fractional overlap approach in spatagg::create_xwalk and broadly
#' follow that file structure.
#'
#' Note: ZIP codes are not completely nested within King County. As such, end users
#' may want to further process this file to handle edge effects
#'
#'
#' @format A data.table with 409 rows and 11 variables:
#'
#'   \code{ZIP}: ZIP code,
#'
#'   \code{hra20_id}: HRA numeric id,
#'
#'   \code{s2t_fraction}: Percent of the area in ZIP that is also in hra20_id,
#'
#'   \code{isect_amount}: # of square survey feet in the intersection of ZIP and hra20_id,
#'
#'   \code{tcoverage_amount}: Area of the hra20_id in any ZIP code,
#'
#'   \code{target_amount}: Total area of  the HRA (including areas not covered by ZIPs),
#'
#'   \code{hra_name}: Name of the HRA,
#'
#'   \code{source_id}: ZIP,
#'
#'   \code{target_id}: hra20_id,
#'
#'   \code{method}: method to produce intersections,
#'
#'   \code{creation_date}: Date file created
#'
#' @name spatial_zip_to_hra20_geog
"spatial_zip_to_hra20_geog"
