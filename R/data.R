# icd_nchs113causes_raw ----
#' NCHS 113 Selected Causes of Death (raw)
#'
#' NCHS 113 Selected Causes of Death (raw). Used to create `icd_nchs113causes`
#' with `/data-raw/icd_nchs113causes.R`
#'
#' @note Per CDC guidance, our cause list contains COVID-19 (U07.1) in cause id 17 ("Other and unspecified
#'     infectious and parasitic diseases and their sequelae")
#'
#'     Cause id 95 ("All other diseases (Residual)") uses codings discovered on a PHSKC
#'     network drive. They were probably created by Mike Smyser, who has retired. These
#'     are being used instead of the CDC codes due to better alignment with WA DOH.
#'
#'     The official CDC coding for Cause id 95 is now saved as cause id 114 "CDC version of cause id 95 (Residual)".
#'
#' @format A data.table with 114 rows and 11 variables: `causeid`, `cause.of.death`, `icd10`,
#' `cause.category`, `leading.cause.group.num`, `leading.cause.group`, `leading.cause.group.alias`, `level1`,
#' `level2`, `level3`, & `level4`. Each of the first 113 rows is for one of the 113 NCHS causes of death,
#' with the `icd10` column summarizing all the relevant codes for the given cause of death.
#'
#' @source Downloaded from <https://ibis.health.utah.gov/ibisph-view/query/NCHS113.html> on 9/22/2021. It is a machine readable version of
#' <https://secureaccess.wa.gov/doh/chat/Content/FilesForDownload/CodeSetDefinitions/NCHS113CausesOfDeath.pdf>
#'
#' @references <https://www.cdc.gov/nchs/data/dvs/Part9InstructionManual2020-508.pdf>
#' @name icd_nchs113causes_raw
"icd_nchs113causes_raw"


# icd_nchs113causes ----
#' NCHS 113 Selected Causes of Death (long)
#'
#' NCHS 113 Selected Causes of Death (long).
#'
#' Tidied long version of `icd_nchs113causes_raw`. Converted by `/data-raw/icd_nchs113causes.R`.
#'
#' @note Per CDC guidance, our cause list contains COVID-19 (U07.1) in cause id 17 ("Other and unspecified
#'     infectious and parasitic diseases and their sequelae")
#'
#'     Cause id 95 ("All other diseases (Residual)") uses codings discovered on a PHSKC
#'     network drive. They were probably created by Mike Smyser, who has retired. These
#'     are being used instead of the CDC codes due to better alignment with WA DOH.
#'
#'     The official CDC coding for Cause id 95 is now saved as cause id 114 "CDC version of cause id 95 (Residual)".
#'
#' @format A data.table with 28,127 rows and four variables: `causeid`, `cause.of.death`, `orig.coding`,
#'   `icd10`. Each row maps one ICD-10 code to one of the 113 causes of death.
#'
#' @source Downloaded from <https://ibis.health.utah.gov/ibisph-view/query/NCHS113.html> on 9/22/2021. It is a machine readable version of
#' <https://secureaccess.wa.gov/doh/chat/Content/FilesForDownload/CodeSetDefinitions/NCHS113CausesOfDeath.pdf>
#'
#' @references <https://www.cdc.gov/nchs/data/dvs/Part9InstructionManual2020-508.pdf>
#' @name icd_nchs113causes
"icd_nchs113causes"

# icd_nchs130causes_raw ----
#' NCHS 130 Selected Causes of Infant Death (raw)
#'
#' NCHS 130 Selected Causes of Infant Death (raw). Used to create `icd_nchs130causes`
#' with `/data-raw/icd_nchs130causes.R`
#'
#' @note This table is based on a download from WA DOH (see sources below). The PDF was exported to an Excel file and the Excel
#' file was manually cleaned to make it machine readable. The `Levels` based on the hierarchy shown in the CHAT infant
#' mortality module's 'NCHS130 Groupings' code set. The `leading.cause.group` information is from the CHAT infant mortality
#' module's 'Leading Infant Causes' code set. The `leading.cause.group.alias` are from Danny's imagination and should not be assumed
#' to match any standard.
#'
#' @format A data.table with 130 rows and 11 variables: `causeid`, `cause.of.death`, `icd10`,
#' `cause.category`, `leading.cause.group.num`, `leading.cause.group`, `leading.cause.group.alias`, `level1`,
#' `level2`, `level3`, & `level4`. Each row is for one of the 130 NCHS causes of infant death,
#' with the `icd10` column summarizing all the relevant codes for the given cause of death.
#'
#' @source Downloaded from
#' <https://secureaccess.wa.gov/doh/chat/Content/FilesForDownload/TechnicalNotes.pdf>
#' on 2/15/2023. It should represent table in
#' <https://www.cdc.gov/nchs/data/dvs/Part9InstructionManual2020-508.pdf>, on pages 18-20.
#'
#' @references <https://www.cdc.gov/nchs/data/dvs/Part9InstructionManual2020-508.pdf>
#' @name icd_nchs130causes_raw
"icd_nchs130causes_raw"

# icd_nchs130causes ----
#' NCHS 130 Selected Causes of Infant Death (long)
#'
#' NCHS 130 Selected Causes of Infant Death (long).
#'
#' Tidied long version of `icd_nchs130causes_raw`. Converted by `/data-raw/icd_nchs130causes.R`.
#'
#' @format A data.table with 18,936 rows and four variables: `causeid`, `cause.of.death`, `orig.coding`,
#'   `icd10`. Each row maps one ICD-10 code to one of the 130 causes of death.
#'
#' @source Downloaded from
#' <https://secureaccess.wa.gov/doh/chat/Content/FilesForDownload/TechnicalNotes.pdf>
#' on 2/15/2023. It should represent table in
#' <https://www.cdc.gov/nchs/data/dvs/Part9InstructionManual2020-508.pdf>, on pages 18-20.
#'
#' @references <https://www.cdc.gov/nchs/data/dvs/Part9InstructionManual2020-508.pdf>
#' @name icd_nchs130causes
"icd_nchs130causes"

# icd_other_causes_of_death ----
#' Other Causes of Death (long)
#'
#' @description
#' This table contains ICD 10 definitions of causes of death that are of
#' interest for systematic analyses, but are not included in the CDC 113
#' Causes of Death ([icd_nchs113causes]) or the injury
#' matrix ([icd10_death_injury_matrix]). It includes causes such
#' as carbon monoxide deaths, drug related deaths, heat stress deaths, etc.
#'
#' @note
#' Tidied long version of `/data-raw/icd_other_causes_of_death_raw` PLUS
#' an Excel workbook downloaded from DOH/CHAT and saved to SharePoint.
#' Created by `/data-raw/icd_other_causes_of_death.R`.
#'
#' @format A data.table with 3,063 rows and four variables: `cause.of.death`,
#'   `orig.coding`, `icd10`, and `source`. Each row maps one
#'   specific ICD 10 code to a given cause of death.
#'
#' @source
#' CDC PDF:
#' <https://www.cdc.gov/nchs/data/nvsr/nvsr70/nvsr70-08-508.pdf>.
#'
#' DOH CHAT (User Guides >> Definition of "Special Code Sets")
#' <https://secureaccess.wa.gov/doh/chat/Entry.mvc>
#'
#' @references <https://www.cdc.gov/nchs/data/nvsr/nvsr70/nvsr70-08-508.pdf>
#' @name icd_other_causes_of_death
"icd_other_causes_of_death"


# icd10_death_injury_matrix ----
#' ICD10 Death Injury Matrix
#'
#' ICD10 Death Injury Matrix (ICE: International Collaborative Effort on Injury Statistics)
#'
#' @format a 'long' data.table with 8,400 rows and four columns: `intent`, `mechanism`, `orig.coding`, & `icd10`.
#'
#' @note This function uses ICD10 mortality codes and should not be used with ICD10-CM hospitalization data.
#'
#' Also note that terrorism codes (U01.#, U02.#, & U03.#) are not included
#' because they are not included in the coding used by WA DOH. If they are
#' needed, they can be obtained from <https://www.cdc.gov/nchs/data/ice/icd10_transcode.pdf>.
#'
#' @source WA DOH CHAT: <https://secureaccess.wa.gov/doh/chat/Content/FilesForDownload/CodeSetDefinitions/CHATInjury(ICE)codes.pdf>.
#' Converted to XLSX with Adobe Acrobat and then used Excel to convert to CSV.
#'
#' @references <https://www.cdc.gov/nchs/data/ice/icd10_transcode.pdf>
#' @name icd10_death_injury_matrix
"icd10_death_injury_matrix"

# icd10_multicause ----
#' ICD-10 Multicause Death Definitions
#'
#' ICD-10 definitions for deaths requiring both underlying and contributing causes.
#' Used for identifying deaths such as opioid-related mortality where both the
#' underlying cause (e.g., poisoning) and contributing cause (e.g., specific substance)
#' must be present.
#'
#' @format A data.table with rows mapping cause names to ICD-10 codes with three columns:
#'   `cause_name`, `underlying_contributing`, and `icd10`.
#'   Each row maps one ICD-10 code to either an underlying or contributing cause
#'   for a specific multicause death definition.
#'
#' @note Currently includes definitions for opioid-related deaths. Additional
#'   multicause definitions can be added as needed.
#'
#' @source CDC National Vital Statistics System guidance on drug overdose deaths
#'   and ICD-10 coding standards for mortality data.
#'
#' @references
#' [CDC Provisional Drug Overdose Death Counts](https://www.cdc.gov/nchs/nvss/vsrr/drug-overdose-data.htm)
#'
#' @name icd10_multicause
"icd10_multicause"

# icd_icd10pcs_codes_2022 ----
#' CMS 2022 ICD-10-PCS
#'
#' CMS (Centers for Medicare & Medicaid Services) 2022 ICD-10-PCS
#'
#' @format a data.table with 79,124 rows and five columns: `order`, `icd10`, `header`, `short`, `long`.
#'
#' @note These are procedure codes, not diagnosis codes.
#'
#' `header` == 0 == not valid for HIPAA-covered transactions.
#'
#' @source `icd10pcs_order_2022.txt` in <https://www.cms.gov/files/zip/errata-january-12-2022.zip>
#'
#' @references `icd10pcsOrderFile.pdf` in <https://www.cms.gov/files/zip/2022-icd-10-pcs-codes-file-updated-december-1-2021.zip>
#' @name icd_icd10pcs_codes_2022
"icd_icd10pcs_codes_2022"

# misc_chi_byvars ----
#' The definitive reference table for CHI cat/varname/group/group_alias values
#'
#' The definitive reference table for CHI cat/varname/group/group_alias values.
#' Used in CHI analyses as the by-variables (cat1 & cat1 in CHI parlance).
#'
#' @format a data.table with a flexible number of rows and six columns:
#' `cat`, `varname`, `group`, `keepme`,
#' `notes` & `creation_date`.
#'
#' @note This replaces any and all old standards found in documentation or in
#' existing SQL databases.
#'
#' @source A version controlled copy of the data in SharePoint >>
#' Community Health Indicators >> CHI-Vizes >> CHI-Standards-TableauReady Output.xlsx
#'
#' @name misc_chi_byvars
"misc_chi_byvars"

# misc_poverty_groups ----
#' Poverty groupings based on 200 percent FPL
#'
#' Tract and ZCTA level poverty groupings based on the proportion of the population below 200 percent of the Federal Poverty Level (FPL)
#'
#' @format a data.table with 578 rows and six columns: `geo_type`, `geo_id`, `census_vintage`, `pov200grp`,
#' `source`, `creation_date`.
#'
#' @note These replace the previous poverty groups (low, medium, high) that were based on 100 percent FPL from 2008-2012 ACS data.
#'
#' @source ACS 2017-2021 tabular estimates processed by <https://github.com/PHSKC-APDE/chi/blob/main/acs/2021_2017/03_calculations_5_year_tabular_data.R>
#' with results saved in "//dphcifs/APDE-CDIP/ACS/2021_2017_5_year/Analysis/03_ACS_Calculations/output_ACS_data_2021_2017_by_geography.xlsx"
#'
#' @references Code based on <https://github.com/PHSKC-APDE/pers_dvc/blob/main/R/2020_poverty_groupings_v2.qmd>
#'
#' @name misc_poverty_groups
"misc_poverty_groups"


# occupation_soc_2010_definitions ----
#' 2010 BLS Standard Occupational Classification (SOC) definitions.
#'
#' 2010 BLS Standard Occupational Classification (SOC) definitions.
#'
#' Detailed definitions for each 2010 BLS SOC code / title
#'
#' @format A data.table with 840 rows and four variables: `'SOC.Code'`, `'SOC.Title'`,
#'   `'SOC.Definition'`, `'uploaded'`.
#'
#' @source <https://www.bls.gov/soc/soc_2010_definitions.xls>
#' @name occupation_soc_2010_definitions
"occupation_soc_2010_definitions"

# occupation_soc_2010_structure ----
#' 2010 BLS Standard Occupational Classification (SOC) structure.
#'
#' 2010 BLS Standard Occupational Classification (SOC) structure.
#'     SOC codes with hierarchy information.
#'
#' @format A data.table with 1421 rows and thirteen variables: `group`, `code`,
#'   `major`, `minor`, `broad`, `detailed`, `title`,
#'   `major.title`, `minor.title`, `broad.title`,
#'   `detailed.title`, `notes`, `'uploaded'`.
#'
#' @source <https://www.bls.gov/soc/2010/2010_major_groups.htm>
#' @name occupation_soc_2010_structure
"occupation_soc_2010_structure"

# occupation_soc_2018_definitions ----
#' 2018 BLS Standard Occupational Classification (SOC) definitions.
#'
#' 2018 BLS Standard Occupational Classification (SOC) definitions.
#'
#' Detailed definitions for each 2018 BLS SOC code / title
#'
#' @format A data.table with 1447 rows and five variables: `'SOC.Group'`,
#' `'SOC.Code'`, `'SOC.Title'`, `'SOC.Definition'`, `'uploaded'`.
#'
#' @source <https://www.bls.gov/soc/soc_2018_definitions.xls>
#' @name occupation_soc_2018_definitions
"occupation_soc_2018_definitions"

# occupation_soc_2018_structure ----
#' 2018 BLS Standard Occupational Classification (SOC) structure.
#'
#' 2018 BLS Standard Occupational Classification (SOC) structure.
#'
#' Detailed definitions for each 2018 BLS SOC code / title
#'
#' @format A data.table with 1447 rows and twelve variables: `group`, `code`,
#'   `major`, `minor`, `broad`, `detailed`, `title`,
#'   `major.title`, `minor.title`, `broad.title`, `detailed.title`,
#'   `'uploaded'`.
#'
#' @source <https://www.bls.gov/soc/2018/2018_major_groups.htm>
#' @name occupation_soc_2018_structure
"occupation_soc_2018_structure"

# occupation_soc_2018_essential_workers_key ----
#' 'Essential Worker' definitions using 2018 BLS Standard Occupational Classification (SOC) codes.
#'
#' 'Essential Worker' definitions using 2018 BLS Standard Occupational Classification (SOC) codes.
#'     One of many essential worker definitions circulating early in the COVID-19 pandemic.
#'
#' @format A data.table with 1447 rows and six variables: `essential`, `group`,
#'   `code`, `title`, `notes`, `'uploaded'`.
#'
#' @source <https://www.lmiontheweb.org/more-than-half-of-u-s-workers-in-critical-occupations-in-the-fight-against-covid-19/>
#' @name occupation_soc_2018_essential_workers_key
"occupation_soc_2018_essential_workers_key"


# population_reference_pop_11_age_groups ----
#' Standard reference populations with 11 age categories.
#'
#' One standard reference populations with 11 non-overlapping age categories.
#' 2000 US Standard Population with 11 age categories is used by WA DOH CHAT
#' as of August 26, 2022.
#'
#' @format A data.table with 11 rows and 6 variables: `standard`, `agecat`,
#'   `age_start`, `age_end`, `pop`, `source`.
#'
#' @source <https://www.cdc.gov/nchs/data/statnt/statnt20.pdf>
#' @name population_reference_pop_11_age_groups
"population_reference_pop_11_age_groups"

# population_reference_pop_18_age_groups ----
#' Standard reference populations with 18 age categories.
#'
#' Fifteen standard reference populations with 18 non-overlapping age categories.
#'
#' @format A data.table with 270 rows and 7 variables: `standard`, `agecat`,
#'   `age_start`, `age_end`, `pop`, `source`, `uploaded`.
#'
#' @source <https://seer.cancer.gov/stdpopulations>
#' @name population_reference_pop_18_age_groups
"population_reference_pop_18_age_groups"

# population_reference_pop_19_age_groups ----
#' Standard reference populations with 19 age categories.
#'
#' Fifteen standard reference populations with 19 non-overlapping age categories.
#'
#' @format A data.table with 285 rows and 7 variables: `standard`, `agecat`,
#'   `age_start`, `age_end`, `pop`, `source`, `uploaded`.
#'
#' @source <https://seer.cancer.gov/stdpopulations>
#' @name population_reference_pop_19_age_groups
"population_reference_pop_19_age_groups"

# population_reference_pop_single_age_to_84 ----
#' Standard population for single ages through 84.
#'
#' Standard population for single ages through 84.
#' After 84, binned into 85-120. Three standards.
#'
#' @format A data.table with 258 rows and 7 variables: `standard`, `agecat`,
#'   `age_start`, `age_end`, `pop`, `source`, `uploaded`.
#'
#' @source <https://seer.cancer.gov/stdpopulations>
#' @name population_reference_pop_single_age_to_84
"population_reference_pop_single_age_to_84"

# population_reference_pop_single_age_to_99 ----
#' Standard population for single ages through 99.
#'
#' Standard population for single ages through 99.
#' After 99, binned into 99-120. Two standards.
#'
#' @format A data.table with 202 rows and 7 variables: `standard`, `agecat`,
#'   `age_start`, `age_end`, `pop`, `source`, `uploaded`.
#'
#' @source <https://seer.cancer.gov/stdpopulations>
#' @name population_reference_pop_single_age_to_99
"population_reference_pop_single_age_to_99"

# population_wapop_codebook_values ----
#' Codebook for WA OFM population demographics.
#'
#' Codebook for WA OFM population demographics.
#'    Translation of OFM population variables into standard demographic terms.
#'    Most likely to be used with raw data in SQL.
#'
#' @format A data.table with 117 rows and 7 variables: `varname`, `code`,
#'   `code_label`, `code_label_long`, `code_label_long2`.
#'
#' @references  `[hhs_analytics_workspace].[ref].[pop_labels]`
#' @name population_wapop_codebook_values
"population_wapop_codebook_values"

# spatial_acs_council_districts ----
#' Crosswalk from Census tracts to political districts.
#'
#' Crosswalk from Census tracts to political districts.
#' Census/ACS tracts mapped to King County and Seattle districts.
#'
#' @format A data.table with 397 rows and 6 variables: `geo_id`, `name`,
#'   `tract`, `kccd`, `sea_ccd`, , `uploaded`.
#'
#' @source <https://www.mysterydata.com>
#' @name spatial_acs_council_districts
"spatial_acs_council_districts"

# spatial_acs_hra_region_place_etc ----
#' Crosswalk hra > region > coo place > geoid > place > tract > block group
#'
#' Crosswalk hra > region > coo place > geoid > place > tract > block group
#'
#' @format A data.table with 276 rows and 9 variables: `hraname`, `region`,
#'   `coo.place`, `geoid`, `name`, `place`, `tract`,
#'   `blkgrp`, `notes`.
#'
#' @source <https://www.mysterydata.com>
#' @name spatial_acs_hra_region_place_etc
"spatial_acs_hra_region_place_etc"

# spatial_blocks10_to_city_council_dist ----
#' Census 2010 crosswalk blocks > city council districts
#'
#' Census 2010 crosswalk blocks > city council districts
#'
#' @format A data.table with 11,475 rows and 11 variables: `council_district`, `geoid10`,
#'   `tract_10`, `block_10`, `trbl_10`, `trbg_10`, `acres_total`, `acres_land`,
#'   `acres_water`, `water`, `uploaded`.
#'
#' @source <https://www.mysterydata.com>
#' @name spatial_blocks10_to_city_council_dist
"spatial_blocks10_to_city_council_dist"

# spatial_blocks10_to_hra_to_region ----
#' Census 2010 crosswalk blocks >> hra >> region
#'
#' Census 2010 crosswalk blocks >> hra >> region
#'
#' @format A data.table with 35,837 rows and 8 variables: `geo_id_blk`, `hra`,
#'   `vid`, `region`, `region_id`, `region_id_old`, `svc`,
#'   `svcid`.
#'
#' @source <https://www.mysterydata.com>
#' @name spatial_blocks10_to_hra_to_region
"spatial_blocks10_to_hra_to_region"

# spatial_chi_blocks10_xwalk ----
#' Crosswalk between 2010 block groups and HRA names, regions, and other RADS/CHI standard geographies
#'
#' Crosswalk between 2010 block groups and HRA names, regions, and other RADS/CHI standard geographies
#'
#' @format A data.table with 35,838 rows and 12 variables: `geo_id_blk10`, `chi_geo_hra_short`,
#'   `chi_geo_hra_long`, `chi_geo_regions_4`, `chi_geo_seattle`, `chi_geo_big_cities`,
#'   `chi_geo_coo_places`, `chi_geo_con_dist`, `chi_geo_leg_dist`, `chi_geo_scc_dist`,
#'   `chi_geo_sch_dist`, `vid`.
#'
#' @source <https://www.mysterydata.com>
#' @name spatial_chi_blocks10_xwalk
"spatial_chi_blocks10_xwalk"

# spatial_county_codes ----
#' Crosswalk between 2010 county id, code, fips code and name
#'
#' Crosswalk between 2010 county id, code, fips code and name
#'
#' @format A data.table with 39 rows and 7 variables: `geo_county_name`,
#' `geo_county_code_fips `, `geo_county_fips_long`,
#' `geo_county_code_order`, `geo_county_code_gnis`.
#' `geo_county_code_tiger`, `geo_county_code_aff`.
#'
#' @source ???
#' @name spatial_county_codes
"spatial_county_codes"

# spatial_county_codes_to_names ----
#' Crosswalk between 2010 county id, code, fips code and name
#'
#' Crosswalk between 2010 county id, code, fips code and name
#'
#' @format A data.table with 39 rows and 5 variables: `cou_id`,
#' `geo_year`, `cou_name`, `cou_code`, `fips_co`.
#'
#' @source kcitazrhpasqlprp16.azds.kingcounty.gov `[ref].[pop_cou_crosswalk]`
#' @name spatial_county_codes_to_names
"spatial_county_codes_to_names"


# spatial_geocomp_blk10_kps ----
#' Census 2010 ... most extensive crosswalk file ... the best
#'
#' Census 2010 ... APDE's most extensive crosswalk file.
#' Mike Smyser's extensive cross-walking file for King, Pierce, and Snomhomish
#' counties. It starts with 2010 census block ids and cross walks to HRAs,
#' KC regions, Seattle/Non-Seattle, Communities Count regions, school districts,
#' legislative districts, KC Council Districts and Seattle City Council
#' Districts.
#'
#' @format A data.table with 61,692 rows and 51 variables:
#' `geo_id_blk10`, `geo_id_tra10`, `hra_id`, `hra_name`,
#' `rgn_id`, `rgn_name`, `svc_id`, `svc_name`,
#' `ccreg`, `rgn_ads`, `hracode_brfss`, `hracode_name`,
#' `hracity_vid`, `hracity_id`, `hracity_ads`,
#' `hracity_brfss`, `hracity_name`, `hracity2_id`,
#' `hracity2_name`, `hrac_id`, `hrac_name`, `hrac2_id`,
#' `hrac2_name`, `pvt_id`, `pvt_name`, `geo_id_scd10`,
#' `scd_id`, `scd_name`, `scd_fipsco`, `scd_coname`,
#' `scd`, `scd_ccddd`, `scd_esd`, `kc_scd`,
#' `kc_scd_name`, `geo_id_cou10`, `cou_vid`, `cou_id`,
#' `cou`, `wa_cou`, `fips_co`, `cou_name`, `kingco`,
#' `tra_id`, `tra_name`, `leg_id`, `leg_name`,
#' `con_id`, `con_name`, `scc_id`, `scc_name`.
#'
#' @source <https://www.mysterydata.com>
#' @name spatial_geocomp_blk10_kps
"spatial_geocomp_blk10_kps"

# spatial_hra_shortname_to_CHIname ----
#' Crosswalk HRA short names to long names for CHI standards
#'
#' Crosswalk HRA short names to long names for CHI standards
#'
#' @format A data.table with 48 rows and 3 variables:
#' `cat1_group`, `cat1_group_alias`,
#' `uploaded`.
#'
#' @source <https://kc1.sharepoint.com/:x:/r/teams/DPH-CommunityHealthIndicators/>
#' @name spatial_hra_shortname_to_CHIname
"spatial_hra_shortname_to_CHIname"

# spatial_hra_vid_region ----
#' Crosswalk HRA's to regions
#'
#' Crosswalk HRA's to regions
#'
#' @format A data.table with 48 rows and 5 variables:
#' `hra`, `vid`, `region`, `region_id`, `region_id_old`.
#'
#' @source <https://www.mysterydata.com>
#' @name spatial_hra_vid_region
"spatial_hra_vid_region"

# spatial_legislative_codes_to_names ----
#' Crosswalk between 2010 legislative district id, name, county, and url
#'
#' Crosswalk between 2010 legislative district id, name, county, and url
#'
#' @format A data.table with 49 rows and 5 variables: `lgd_id`, `geo_year`,
#'   `lgd_name`, `lgd_counties`, `lgd_url`.
#'
#' @source kcitazrhpasqlprp16.azds.kingcounty.gov `[ref].[pop_lgd_crosswalk]`
#' @name spatial_legislative_codes_to_names
"spatial_legislative_codes_to_names"

# spatial_school_codes_to_names ----
#' Crosswalk between 2010 school district id, name, state id, county code, and esd name
#'
#' Crosswalk between 2010 school district id, name, state id, county code, and esd name
#'
#' @format A data.table with 295 rows and 3 variables: `geo_year`, `scd_id`,
#'  and `scd_name`.
#'
#' @source <https://secureaccess.wa.gov/doh/chat/Entry.mvc>
#' @name spatial_school_codes_to_names
"spatial_school_codes_to_names"

# spatial_school_dist_to_region ----
#' Crosswalk between King County school districts and KC regions
#'
#' Crosswalk between King County school districts and KC regions
#'
#' @format A data.table with 19 rows and 4 variables:
#' `school_district`, `geo_id`, `region`, `region_id`.
#'
#' @source <https://www.mysterydata.com>
#' @name spatial_school_dist_to_region
"spatial_school_dist_to_region"

# spatial_tract_to_county_council_dist ----
#' Crosswalk between 2010 census tracts and King County Council Districts
#'
#' Crosswalk between 2010 census tracts and King County Council Districts
#'
#' @format A data.table with 538 rows and 32 variables: `tract`,
#' `kccdst_assigned`, `fid`, `objectid`, `fid_kccdst`,
#' `kccdst`, `councilmem`, `fid_tracts`, `geo_id_trt`,
#' `feature_id`, `tract_lbl`, `tract_str`, `tract_int`,
#' `tract_flt`, `tract_del`, `trtlabel_f`, `trtlabel_c`,
#' `trtlabel_t`, `county_str`, `county_int`, `state_str`,
#' `state_int`, `level_1`, `level_2`, `level_3`,
#' `tract_area`, `tract_peri`, `logrecno17`, `shape_area`,
#' `shape_leng`, `shape_ar_1`, `tract_perc`.
#'
#' @source <https://www.mysterydata.com>
#' @name spatial_tract_to_county_council_dist
"spatial_tract_to_county_council_dist"

# spatial_tract10_to_puma ----
#' Census 2010 crosswalk tracts to PUMAS
#'
#' Census 2010 crosswalk tracts to PUMAS
#'
#' @format A data.table with 398 rows and 5 variables:
#' `wa`, `kingco`, `tract10`, `puma`, `uploaded`.
#'
#' @source <https://www.mysterydata.com>
#' @name spatial_tract10_to_puma
"spatial_tract10_to_puma"

# spatial_zip_city_region_scc ----
#' Crosswalk zip codes >> cities >> regions (& SCC)
#'
#' Crosswalk zip codes >> cities >> regions (& SCC)
#'
#' @format A data.table with 126 rows and 11 variables:
#' `zip`, `zip_type`, `city`, `city_primary`, `region`,
#' `region_id`, `region_vid`, `scc`, `multi_county`,
#' `office_building`, `notes`.
#'
#' @source combined spatial_zip_admin, spatial_zip_to_city_council_dist,
#' spatial_zip_to_region, & spatial_zip_city_region_vid & then deleted the
#' originals
#'
#' @name spatial_zip_city_region_scc
"spatial_zip_city_region_scc"


# spatial_zip_hca ----
#' Crosswalk FOR HCA MEDICAID KC definition ... zip >> city
#'
#' 133 zip codes, with zip type, city, primary_city, used to define King County
#' in Health Care Authority Medicaid data extracts. Includes 98354 and 98422,
#' which barely cross into south KC). ZIPs spanning county lines are noted in
#' the geo_multi_county field.
#'
#' @format A data.table with 133 rows and 5 variables:
#'   `zip`, `zip_type`, `city`, `primary_city`, `two_counties`.
#'
#' @source <https://www.mysterydata.com>
#' @name spatial_zip_hca
"spatial_zip_hca"
