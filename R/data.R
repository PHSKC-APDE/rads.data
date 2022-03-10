#' NCHS 113 Selected Causes of Death (long).
#'
#' NCHS 113 Selected Causes of Death (long). Cause id 95 ("All other diseases (Residual)") uses codings discovered on a PHSKC
#'     network drive. They were propbably created by Mike Smyzer, who has retired. These
#'     are being used instead of the CDC codes due to better alignment with WA DOH. The
#'     official CDC coding is now saved as cause id 114 "CDC version of cause id 95 (Residual)".
#'
#' @note Per CDC guidance, our cause list contains COVID-19 (U07.1) in cause id 17 ("Other and unspecified
#'     infectious and parasitic diseases and their sequelae")
#'
#' @references https://secureaccess.wa.gov/doh/chat/Content/FilesForDownload/CodeSetDefinitions/NCHS113CausesOfDeath.pdf
#'
#' @format A data.table with 2975 rows and three variables: \code{causeid}, \code{cause.of.deaths},
#'   \code{icd10}. Each row maps one ICD 10 code to one of the 113 causes of death.
#'
#' @source \url{https://www.cdc.gov/nchs/data/dvs/Part9InstructionManual2020-508.pdf}
"icd_nchs113causes"


#' 2010 BLS Standard Occupational Classification (SOC) definitions.
#'
#' 2010 BLS Standard Occupational Classification (SOC) definitions.
#'
#' Detailed definitions for each 2010 BLS SOC code / title
#'
#' @format A data.table with 840 rows and three variables: \code{'SOC Code'}, \code{'SOC Title'},
#'   \code{'SOC Definition'}.
#'
#' @source \url{https://www.bls.gov/soc/soc_2010_definitions.xls}
"occupation_soc_2010_definitions"

#' 2010 BLS Standard Occupational Classification (SOC) structure.
#'
#' 2010 BLS Standard Occupational Classification (SOC) structure.
#'     SOC codes with hierarchy information.
#'
#' @format A data.table with 1421 rows and twelve variables: \code{group}, \code{code},
#'   \code{major}, \code{minor}, \code{broad}, \code{detailed}, \code{title},
#'   \code{major.title}, \code{minor.title}, \code{broad.title},
#'   \code{detailed.title}, \code{notes}.
#'
#' @source \url{https://www.bls.gov/soc/2010/2010_major_groups.htm}
"occupation_soc_2010_structure"

#' 2018 BLS Standard Occupational Classification (SOC) definitions.
#'
#' 2018 BLS Standard Occupational Classification (SOC) definitions.
#'
#' Detailed definitions for each 2018 BLS SOC code / title
#'
#' @format A data.table with 1447 rows and four variables: \code{'SOC Group'}, \code{'SOC Code'}, \code{'SOC Title'},
#'   \code{'SOC Definition'}.
#'
#' @source \url{https://www.bls.gov/soc/soc_2018_definitions.xls}
"occupation_soc_2018_definitions"

#' 2018 BLS Standard Occupational Classification (SOC) structure.
#'
#' 2018 BLS Standard Occupational Classification (SOC) structure.
#'
#' Detailed definitions for each 2018 BLS SOC code / title
#'
#' @format A data.table with 1447 rows and eleven variables: \code{group}, \code{code},
#'   \code{major}, \code{minor}, \code{broad}, \code{detailed}, \code{title},
#'   \code{major.title}, \code{minor.title}, \code{broad.title}, \code{detailed.title}.
#'
#' @source \url{https://www.bls.gov/soc/2018/2018_major_groups.htm}
"occupation_soc_2018_structure"

#' 'Essential Worker' definitions using 2018 BLS Standard Occupational Classification (SOC) codes.
#'
#' 'Essential Worker' definitions using 2018 BLS Standard Occupational Classification (SOC) codes.
#'     One of many essential worker definitions circulating early in the COVID-19 pandemic.
#'
#' @format A data.table with 1447 rows and five variables: \code{essential}, \code{group},
#'   \code{code}, \code{title}, \code{notes}.
#'
#' @source \url{https://www.lmiontheweb.org/more-than-half-of-u-s-workers-in-critical-occupations-in-the-fight-against-covid-19/}
"occupation_soc_2018_essential_workers_key"


#' 2018 Population by HRA.
#'
#' Health Reporting Area (HRA) 2018 population. Not clear why this was worth saving in GitHub.
#' Not stratified by demographics.
#'
#' @format A data.table with 48 rows and eight variables: \code{year}, \code{hra_id},
#'   \code{hra_name}, \code{age}, \code{gender}, \code{race}, \code{ethnicity},
#'   \code{population}.
#'
#' @source \url{https://www.mysterydata.com}
"population_hra_pop_18"

#' Standard reference populations with 18 age categories.
#'
#' Fifteen standard reference populations with 18 non-overlapping age categories.
#'
#' @format A data.table with 270 rows and 6 variables: \code{standard}, \code{agecat},
#'   \code{age_start}, \code{age_end}, \code{pop}, \code{source}.
#'
#' @source \url{https://seer.cancer.gov/stdpopulations}
"population_reference_pop_18_age_groups"

#' Standard reference populations with 19 age categories.
#'
#' Fifteen standard reference populations with 19 non-overlapping age categories.
#'
#' @format A data.table with 285 rows and 6 variables: \code{standard}, \code{agecat},
#'   \code{age_start}, \code{age_end}, \code{pop}, \code{source}.
#'
#' @source \url{https://seer.cancer.gov/stdpopulations}
"population_reference_pop_19_age_groups"

#' Standard population for single ages through 84.
#'
#' Standard population for single ages through 84.
#' After 84, binned into 85-120. Three standards.
#'
#' @format A data.table with 258 rows and 6 variables: \code{standard}, \code{agecat},
#'   \code{age_start}, \code{age_end}, \code{pop}, \code{source}.
#'
#' @source \url{https://seer.cancer.gov/stdpopulations}
"population_reference_pop_single_age_to_84"

#' Standard population for single ages through 99.
#'
#' Standard population for single ages through 99.
#' After 99, binned into 99-120. Two standards.
#'
#' @format A data.table with 202 rows and 6 variables: \code{standard}, \code{agecat},
#'   \code{age_start}, \code{age_end}, \code{pop}, \code{source}.
#'
#' @source \url{https://seer.cancer.gov/stdpopulations}
"population_reference_pop_single_age_to_99"

#' Codebook for WA OFM population demographics.
#'
#' Codebook for WA OFM population demographics.
#'    Translation of OFM population variables into standard demographic terms.
#'    Most likely to be used with raw data in SQL.
#'
#' @format A data.table with 117 rows and 7 variables: \code{varname}, \code{code},
#'   \code{code_label}, \code{code_label_long}, \code{code_label_long2}.
#'
#' @references  [hhs_analytics_workspace].[ref].[pop_labels]
"population_wapop_codebook_values"

#' Crosswalk from Census tracts to political districts.
#'
#' Crosswalk from Census tracts to political districts.
#' Census/ACS tracts mapped to King County and Seattle districts.
#'
#' @format A data.table with 397 rows and 5 variables: \code{geo_id}, \code{name},
#'   \code{tract}, \code{kccd}, \code{sea_ccd}.
#'
#' @source \url{https://www.mysterydata.com}
"spatial_acs_council_districts"

#' Crosswalk hra > region > coo place > geoid > place > tract > block group
#'
#' Crosswalk hra > region > coo place > geoid > place > tract > block group
#'
#' @format A data.table with 276 rows and 9 variables: \code{hraname}, \code{region},
#'   \code{coo.place}, \code{geoid}, \code{name}, \code{place}, \code{tract},
#'   \code{blkgrp}, \code{notes}.
#'
#' @source \url{https://www.mysterydata.com}
"spatial_acs_hra_region_place_etc"

#' Census 2000 crosswalk Block > Block Group > Tract > HRA.
#'
#' Census 2000 crosswalk Block > Block Group > Tract > HRA.
#'
#' @format A data.table with 24,475 rows and 4 variables: \code{btfid = block}, \code{gtfid = block group},
#'   \code{stfid = tract}, \code{hra}.
#'
#' @source \url{https://www.mysterydata.com}
"spatial_blocks00_to_hra"

#' Census 2010 crosswalk blocks > city council districts
#'
#' Census 2010 crosswalk blocks > city council districts
#'
#' @format A data.table with 11475 rows and 10 variables: \code{council_district}, \code{geoid10},
#'   \code{tract_10}, \code{block_10}, \code{trbl_10}, \code{trbg_10}, \code{acres_total}, \code{acres_land},
#'   \code{acres_water}, \code{water}.
#'
#' @source \url{https://www.mysterydata.com}
"spatial_blocks10_to_city_council_dist"

#' Census 2010 crosswalk blocks >> hras
#'
#' Census 2010 crosswalk blocks >> hras
#'
#' @format A data.table with 35838 rows and 3 variables: \code{geo_id_blk}, \code{hra},
#'   \code{vid}.
#'
#' @source \url{https://www.mysterydata.com}
"spatial_blocks10_to_hra"

#' Census 2010 crosswalk blocks >> region & blocks >> hra
#'
#' Census 2010 crosswalk blocks >> region & blocks >> hra
#'
#' @format A data.table with 35,837 rows and 7 variables: \code{geo_id_blk}, \code{region},
#'   \code{regionid}, \code{hra}, \code{vid}, \code{svc}, \code{svcid}.
#'
#' @source \url{https://www.mysterydata.com}
"spatial_blocks10_to_region"

#' Crosswalk between 2010 block groups and HRA names, regions, and other RADS/CHI standard geographies
#'
#' Crosswalk between 2010 block groups and HRA names, regions, and other RADS/CHI standard geographies
#'
#' @format A data.table with 35,838 rows and 12 variables: \code{geo_id_blk10}, \code{chi_geo_hra_short},
#'   \code{chi_geo_hra_long}, \code{chi_geo_regions_4}, \code{chi_geo_seattle}, \code{chi_geo_big_cities},
#'   \code{chi_geo_coo_places}, \code{chi_geo_con_dist}, \code{chi_geo_leg_dist}, \code{chi_geo_scc_dist},
#'   \code{chi_geo_sch_dist}, \code{vid}.
#'
#' @source \url{https://www.mysterydata.com}
"spatial_chi_blocks10_xwalk"

#' Crosswalk between 2010 county id, code, fips code and name
#'
#' Crosswalk between 2010 county id, code, fips code and name
#'
#' @format A data.table with 39 rows and 5 variables: \code{cou_id}, \code{geo_year},
#'   \code{cou_name}, \code{cou_code}, \code{fips_co}.
#'
#' @source kcitazrhpasqlprp16.azds.kingcounty.gov [ref].[pop_cou_crosswalk]
"spatial_county_codes_to_names"

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
#' \code{geo_id_blk10}, \code{geo_id_tra10}, \code{hra_id}, \code{hra_name},
#' \code{rgn_id}, \code{rgn_name}, \code{svc_id}, \code{svc_name},
#' \code{ccreg}, \code{rgn_ads}, \code{hracode_brfss}, \code{hracode_name},
#' \code{hracity_vid}, \code{hracity_id}, \code{hracity_ads},
#' \code{hracity_brfss}, \code{hracity_name}, \code{hracity2_id},
#' \code{hracity2_name}, \code{hrac_id}, \code{hrac_name}, \code{hrac2_id},
#' \code{hrac2_name}, \code{pvt_id}, \code{pvt_name}, \code{geo_id_scd10},
#' \code{scd_id}, \code{scd_name}, \code{scd_fipsco}, \code{scd_coname},
#' \code{scd}, \code{scd_ccddd}, \code{scd_esd}, \code{kc_scd},
#' \code{kc_scd_name}, \code{geo_id_cou10}, \code{cou_vid}, \code{cou_id},
#' \code{cou}, \code{wa_cou}, \code{fips_co}, \code{cou_name}, \code{kingco},
#' \code{tra_id}, \code{tra_name}, \code{leg_id}, \code{leg_name},
#' \code{con_id}, \code{con_name}, \code{scc_id}, \code{scc_name}.
#'
#' @source \url{https://www.mysterydata.com}
"spatial_geocomp_blk10_kps"

#' Crosswalk HRA short names to long names for CHI standards
#'
#' Crosswalk HRA short names to long names for CHI standards
#'
#' @format A data.table with 48 rows and 2 variables:
#' \code{cat1_group}, \code{cat1_group_alias}.
#'
#' @source \url{https://www.mysterydata.com}
"spatial_hra_shortname_to_CHIname"

#' Crosswalk HRA's to regions
#'
#' Crosswalk HRA's to regions
#'
#' @format A data.table with 48 rows and 4 variables:
#' \code{hra}, \code{vid}, \code{region}, \code{region_id}.
#'
#' @source \url{https://www.mysterydata.com}
"spatial_hra_vid_region"

#' Crosswalk between 2010 legislative district id, name, county, and url
#'
#' Crosswalk between 2010 legislative district id, name, county, and url
#'
#' @format A data.table with 49 rows and 5 variables: \code{lgd_id}, \code{geo_year},
#'   \code{lgd_name}, \code{lgd_counties}, \code{lgd_url}.
#'
#' @source kcitazrhpasqlprp16.azds.kingcounty.gov [ref].[pop_lgd_crosswalk]
"spatial_legislative_codes_to_names"

#' Crosswalk between 2010 school district id, name, state id, county code, and esd name
#'
#' Crosswalk between 2010 school district id, name, state id, county code, and esd name
#'
#' @format A data.table with 295 rows and 3 variables: \code{geo_year}, \code{scd_id},
#'  and  \code{scd_name}.
#'
#' @source \url{https://secureaccess.wa.gov/doh/chat/Entry.mvc}
"spatial_school_codes_to_names"

#' Crosswalk between King County school districts and KC regions
#'
#' Crosswalk between King County school districts and KC regions
#'
#' @format A data.table with 19 rows and 3 variables:
#' \code{school_district}, \code{geo_id}, \code{region}.
#'
#' @source \url{https://www.mysterydata.com}
"spatial_school_dist_to_region"

#' Crosswalk between 2010 census tracts and King County Council Districts
#'
#' Crosswalk between 2010 census tracts and King County Council Districts
#'
#' @format A data.table with 538 rows and 32 variables: \code{tract},
#' \code{kccdst_assigned}, \code{fid}, \code{objectid}, \code{fid_kccdst},
#' \code{kccdst}, \code{councilmem}, \code{fid_tracts}, \code{geo_id_trt},
#' \code{feature_id}, \code{tract_lbl}, \code{tract_str}, \code{tract_int},
#' \code{tract_flt}, \code{tract_del}, \code{trtlabel_f}, \code{trtlabel_c},
#' \code{trtlabel_t}, \code{county_str}, \code{county_int}, \code{state_str},
#' \code{state_int}, \code{level_1}, \code{level_2}, \code{level_3},
#' \code{tract_area}, \code{tract_peri}, \code{logrecno17}, \code{shape_area},
#' \code{shape_leng}, \code{shape_ar_1}, \code{tract_perc}.
#'
#' @source \url{https://www.mysterydata.com}
"spatial_tract_to_county_council_dist"

#' Census 2010 crosswalk tracts to PUMAS
#'
#' Census 2010 crosswalk tracts to PUMAS
#'
#' @format A data.table with 398 rows and 4 variables:
#' \code{wa}, \code{kingco}, \code{tract10}, \code{puma}.
#'
#' @source \url{https://www.mysterydata.com}
"spatial_tract10_to_puma"

#' Crosswalk zip codes to cities / towns
#'
#' Crosswalk zip codes to cities / towns
#'
#' @format A data.table with 122 rows and 3 variables:
#' \code{zip}, \code{zip_type},\code{city}.
#'
#' @source \url{https://www.mysterydata.com}
"spatial_zip_admin"

#' Crosswalk zip codes to cities and regions
#'
#' Crosswalk zip codes to cities and regions
#'
#' @format A data.table with 120 rows and 4 variables:
#'   \code{zip}, \code{city}, \code{region}, \code{region_vid}.
#'
#' @source \url{https://www.mysterydata.com}
"spatial_zip_city_region_vid"

#' Crosswalk FOR HCA MEDICAID KC definition ... zip >> city
#'
#' 133 zip codes, with zip type, city, primary_city, used to define King County
#' in Health Care Authority Medicaid data extracts. Includes 98354 and 98422,
#' which barely cross into south KC). ZIPs spanning county lines are noted in
#' the geo_multi_county field.
#'
#' @format A data.table with 133 rows and 5 variables:
#'   \code{zip}, \code{zip_type}, \code{city}, \code{primary_city}, \code{two_counties}.
#'
#' @source \url{https://www.mysterydata.com}
"spatial_zip_hca"

#' Crosswalk zip code to Seattle city council districts
#'
#' Crosswalk zip code to Seattle city council districts
#'
#' @format A data.table with 24 rows and 2 variables:
#' \code{zip}, \code{district}.
#'
#' @source \url{https://www.mysterydata.com}
"spatial_zip_to_city_council_dist"

#' Crosswalk zip codes to regions
#'
#' Crosswalk zip codes to regions
#'
#' @format A data.table with 120 rows and 6 variables:
#'   \code{zip}, \code{city}, \code{cc_region}, \code{po_box},
#'   \code{office_building}, \code{notes}.
#'
#' @source \url{https://www.mysterydata.com}
"spatial_zip_to_region"
