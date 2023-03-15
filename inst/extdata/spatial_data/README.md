# reference-data/spatial_data

## Notes
These files are used for cross-walking between different levels of geography. In August 2019, there was an attempt to reduce reduancy and combine files. However, some redudancy continues to exist, so the user will have to examine the files to ensure they are using the file best suited to their needs.  

All but one of the CSVs were originally created from tabs in '[composition of places-HRA.xlsx](https://kc1.sharepoint.com/:x:/r/teams/PHc/datareq/_layouts/15/Doc.aspx?sourcedoc=%7BB791BD4F-1554-49F9-8E12-29F132764949%7D&file=composition%20of%20places-HRA.xlsx)' on SharePoint. The exception is [geocomp_blk10_kps.csv](https://github.com/PHSKC-APDE/rads.data/blob/main/inst/extdata/spatial_data/geocomp_blk10_kps.csv), which was copied from [PH_APDEStore].[dbo].[geocomp_blk10_kps] on server 51 on 8/19/2019. It was prepared by Mike Smyser and is the most complete set of cross-walks that we have available. 

The complete commit history for these files is visible in GitHub Bash and GitHub Desktop. Unfortunately, GitHub online does not display commits prior to renaming this folder. You can view a synopsis of this commit [online](https://github.com/PHSKC-APDE/reference-data/commit/d86c4ccaa6b02c41e2f06cb485d9efa11cb73ec4). Individual commits can still be viewed online using the commit id from your log. 

## Table of Contents
### The new best! Based on census 2020 stuff
* **Consider [spatagg](https://github.com/PHSKC-APDE/spatagg) for your spatial crosswalking needs**
* **[spatial_block10_to_hra20](spatial_block10_to_hra20.csv)**: Convert between 2010 Census blocks and 2020 HRAs and regions
* **[spatial_block20_to_hra20](spatial_block20_to_hra20.csv)**: convert between 2020 Census blocks and 2020 HRAs and regions
* **[spatial_hra20_to_region20](spatial_hra20_to_region20.csv)**: Convert between 2020 HRAs and regions
* **[spatial_tract10_to_hra20_geog](spatial_tract10_to_hra20_geog.csv)**: spatagg geographic crosswalk between 2010 tracts and 2020 HRAs
* **[spatial_tract10_to_hra20_pop](spatial_tract10_to_hra20_pop.csv)**: spatagg population crosswalk between 2010 tracts and 2020 HRAs 
* **[spatial_tract20_to_hra20_geog](spatial_tract20_to_hra20_geog.csv)**: spatagg geographic crosswalk between 2020 tracts and 2020 HRAs 
* **[spatial_tract20_to_hra20_pop](spatial_tract20_to_hra20_pop.csv)**: spatagg population crosswalk between 2020 tracts and 2020 HRAs 
* **[spatial_zip_to_hra20_geog](spatial_zip_to_hra20_geog.csv)**: spatagg geographic crosswalk between ZIPs and 2020 HRAs
* **[spatial_zip_to_hra20_pop](spatial_zip_to_hra20_pop.csv)**: spatagg population crosswalk between ZIP and 2020 HRAs

### The best!
* **[geocomp_blk10_kps.csv](https://github.com/PHSKC-APDE/rads.data/blob/main/inst/extdata/spatial_data/geocomp_blk10_kps.csv)** = Mike Smyser's extensive cross-walking file for King, Pierce, and Snomhomis counties. It starts with 2010 census block ids and cross walks to HRAs, KC regions, Seattle/Non-Seattle, Communities Count regions, school districts, legislative districts, KC Council Districts and Seattle City Council Districts.

### The rest
* **[acs_council_districts.csv](https://github.com/PHSKC-APDE/rads.data/blob/main/inst/extdata/spatial_data/acs_council_districts.csv)** = Cross-walk from 2010 census geoid / tract to King County and Seattle City Council districts
* **[acs_hra_region_place_etc.csv](https://github.com/PHSKC-APDE/rads.data/blob/main/inst/extdata/spatial_data/acs_hra_region_place_etc.csv)** = Cross-walk between HRA names, KC regions, COO places, 2010 census geoids, places, tracts, and block groups
* **[blocks10_to_city_council_dist.csv](https://github.com/PHSKC-APDE/rads.data/blob/main/inst/extdata/spatial_data/blocks10_to_city_council_dist.csv)** = Cross-walk between 2010 census blocks and council districts; includes acreage of land and and water
* **[blocks10_to_hra_to_region.csv](https://github.com/PHSKC-APDE/rads.data/blob/main/inst/extdata/spatial_data/blocks10_to_hra_to_region.csv)** = Crosswalk between 2010 census blocks, HRAs, and KC regions
* **[chi_blocks10_xwalk.csv](https://github.com/PHSKC-APDE/rads.data/blob/main/inst/extdata/spatial_data/chi_blocks10_xwalk.csv)** = Crosswalk between 2010 block groups and HRA names, regions, and other RADS/CHI standard geographies
* **[county_codes.csv](https://github.com/PHSKC-APDE/rads.data/blob/main/inst/extdata/spatial_data/county_codes.csv)** = Crosswalk between WA county names (e.g., King), long and short fips county codes (e.g., 53033 & 33), alternate county codes (e.g., 17), gnis county codes, and tiger county codes
* **[county_codes_to_names.csv](https://github.com/PHSKC-APDE/rads.data/blob/main/inst/extdata/spatial_data/county_codes_to_names.csv)** = Crosswalk between WA county names (e.g., King), fips county code (e.g., 33), and the alternate county code (e.g., 17)
* **[hra_shortname_to_CHIname.csv](https://github.com/PHSKC-APDE/rads.data/blob/main/inst/extdata/spatial_data/hra_shortname_to_CHIname.csv)** = Crosswalk between official CHI short names (cat1_group) and long names (cat1_group_alias). All spatial files with HRA names should use the standard short names
* **[hra_vid_region.csv](https://github.com/PHSKC-APDE/rads.data/blob/main/inst/extdata/spatial_data/hra_vid_region.csv)** = Crosswalk between HRAs, vids, and KC regions
* **[legislative_codes_to_names.csv](https://github.com/PHSKC-APDE/rads.data/blob/main/inst/extdata/spatial_data/legislative_codes_to_names.csv)** = Crosswalk between legistlative district codes, legislative district names, and corresponding counties
* **[school_dist_to_region.csv](https://github.com/PHSKC-APDE/rads.data/blob/main/inst/extdata/spatial_data/school_dist_to_region.csv)** = Crosswalk between King County school districts and KC regions
* **[school_codes_to_names.csv](https://github.com/PHSKC-APDE/rads.data/blob/main/inst/extdata/spatial_data/school_codes_to_names.csv)** = Crosswalk between school district names and school district codes
* **[tract_to_county_council_dist.csv](https://github.com/PHSKC-APDE/rads.data/blob/main/inst/extdata/spatial_data/tract_to_county_council_dist.csv)** = Crosswalk between 2010 census tracts and King County Council Districts.
* **[tract10_to_puma.csv](https://github.com/PHSKC-APDE/rads.data/blob/main/inst/extdata/spatial_data/tract10_to_puma.csv)** = Crosswalk between 2010 census tracts and PUMAs (Public Use Microdata Areas) 
* **[zip_city_region_scc.csv](https://github.com/PHSKC-APDE/rads.data/blob/main/inst/extdata/spatial_data/zip_city_region_scc.csv)** = Crosswalk between 126 zip codes (with cities) to KC regions 
* **[zip_hca.csv](https://github.com/PHSKC-APDE/rads.data/blob/main/inst/extdata/spatial_data/zip_hca.csv)** = 133 zip codes, with zip type, city, primary_city, used to define King County in HCA Medicaid data extracts. Includes 98354 and 98422, 
which barely cross into south KC). ZIPs spanning county lines are noted in the two_counties field.


### Legacy
* **[blocks00_to_hra.csv](https://github.com/PHSKC-APDE/rads.data/blob/main/inst/extdata/spatial_data/blocks00_to_hra.csv)** = Cross-walk between 2000 (?) census blocks and HRA names ... legacy, no longer used

