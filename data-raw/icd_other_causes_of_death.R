# Header ----
# Author: Danny Colombara
# Date: August 29, 2022
# Purpose: Create machine usable long form of Other Causes of Death ICD 10 codes
# Notes: This is for causes of death that are not part of the CDC 113 Causes of death
#        and are not covered by the death injury matrix, but that are still of interest
#        for systematic analyses. DOH refers to these as "Special Codes"

# Set up ----
library(data.table)
library(Microsoft365R)

# Function to clean / prep imported data to fix random white spaces (sql_clean) ----
    source("https://raw.githubusercontent.com/PHSKC-APDE/rads/main/R/utilities.R") # pull in rads utilities, particularly sql_clean()


# Function to enumerator all ICD per other cause of death (split.dash) ----
  # E.g., split.dash("X0-X04, X17-X19") >> "X00, X01, X02, X03, X04, X17, X18, X19"
    source("https://raw.githubusercontent.com/PHSKC-APDE/rads.data/main/data-raw/icd_utility_split.dash.R")

# Read in raw Other Causes of Death ICD codes ----
  # Pull in data downloaded from CDC ----
    icd_other_causes_of_death <- fread("data-raw/icd_other_causes_of_death_raw.csv")
    icd_other_causes_of_death[, source := NULL]
    cdc <- copy(icd_other_causes_of_death)
    sql_clean(cdc)
    cdc[, source := "CDC"]

  # Pull in data downloaded from DOH ----
    # get file from SharePoint ----
      team <- get_team("Community Health Indicators")
      drv <- team$get_drive("CHI-Vizes")
      tempy <- tempfile(fileext = ".xlsx")
      drv$download_file(src = 'Death/DOH_definitions/CHAT_SpecialCodeSets_20221006.xlsx',
                        dest = tempy,
                        overwrite = TRUE)
    # load & append worksheets from SharePoint ----
      doh.sheetnames <- grep("Death", openxlsx::getSheetNames(tempy), value = T, ignore.case = T)
      doh <- rbindlist(lapply(X = as.list(1:length(doh.sheetnames)),
                              FUN = function(X){
                                print(doh.sheetnames[X])
                                # import
                                doh.temp <- setDT(openxlsx::read.xlsx(tempy, sheet = doh.sheetnames[X]))
                                # generic tidy
                                doh.temp <- doh.temp[, grepl("^ICD-10", names(doh.temp)), with = FALSE]
                                setnames(doh.temp, "raw")
                                doh.temp[, cod := doh.sheetnames[X]]
                                sql_clean(doh.temp)
                                doh.temp[, icd10 := gsub("^(.*?) .*", "\\1", raw)] # string before the first space
                                doh.temp[, desc := gsub("^[^ ]+ ", "", raw)] # string after the first space
                                doh.temp[, raw := NULL]
                                doh.temp <- doh.temp[!is.na(icd10)]
                                doh.temp <- doh.temp[!grepl("^[a-z][a-z]", icd10, ignore.case = T)] # eliminates some rows where not ICD codes
                                doh.temp[, source := "DOH"]
                              }))
    # tidy specific imported worksheet data ----
      doh <- doh[!(cod == "Drug_Death" &
                   icd10 %in% c("E24", "F11.0", "F12.0", "F13.0", "F14.0",
                           "F15.0", "F16.0", "F17.0", "F18.0", "F19.0"))] # strike through on DOH worksheet

  # Append DOH codes to CDC codes ----
      othercod <- rbind(cdc, doh)

# Format other causes of death ----
    # convert dashes to enumerated ICD codes
    othercod[, icd := split.dash(icd10), by = 1:nrow(othercod)]
    setnames(othercod, "icd10", "orig.coding")

    # split icds so there is one per column
    splits <- max(lengths(strsplit(othercod$icd, ", ")))
    wide <- copy(othercod)[, paste0("icd", 1:splits) := tstrsplit(icd, ", ", fixed=T)]
    wide[, icd := NULL]

    # wide to long
    icd_other_causes_of_death <- melt(wide, id.vars = c("cod", "orig.coding", "desc", "source"), value.name = "icd10")
    icd_other_causes_of_death[, variable := NULL]
    icd_other_causes_of_death <- icd_other_causes_of_death[!is.na(icd10)]
    icd_other_causes_of_death <- icd_other_causes_of_death[, .(cause.of.death = cod, orig.coding, icd10, source)]
    setorder(icd_other_causes_of_death, cause.of.death, icd10)

    # Make sure didn't loose any orig coding when reshaping and cleaning
    if(identical(sort(unique(wide$orig.coding)), sort(unique(icd_other_causes_of_death$orig.coding)))){
      message("Kept all original codings")
    } else {stop("The original codings do not match those present at the start. Stop and check for errors.")}

    # drop rows where a parent (F10) was identified but there are children (e.g., F10.1, F10.3)
    icd_other_causes_of_death[!grepl("\\.", orig.coding), header := orig.coding] # header does not have a decimal
    icd_other_causes_of_death[grepl("\\.", orig.coding), stem := gsub("\\..*$", "", orig.coding)] # keep part before period
    stems.used <- unique(icd_other_causes_of_death[!is.na(stem), .(cause.of.death, header = stem, drop = 1)])
    icd_other_causes_of_death = merge(icd_other_causes_of_death, stems.used, by = c("cause.of.death", "header"), all.x = T, all.y = F)
    icd_other_causes_of_death <- icd_other_causes_of_death[is.na(drop)]
    icd_other_causes_of_death <- icd_other_causes_of_death[, .(cause.of.death, orig.coding, icd10, source)]

    # keep unique rows
    icd_other_causes_of_death <- unique(icd_other_causes_of_death)

    setorder(icd_other_causes_of_death, cause.of.death, icd10, -orig.coding)

# Add new summary categories from CDC 113 COD ----
    x113 <- copy(rads.data::icd_nchs113causes)

    xliver <- x113[cause.of.death %in% c("Alcoholic liver disease", "Other chronic liver disease and cirrhosis")]
    xliver <- unique(xliver[, .(cause.of.death = "Chronic liver disease and cirrhosis", orig.coding, icd10, source = "CDC 113 COD")])

    xresp <- x113[cause.of.death %in% c("Asthma", "Bronchitis, chronic and unspecified", "Emphysema", "Other chronic lower respiratory diseases")]
    xresp <- unique(xresp[, .(cause.of.death = "Chronic lower respiratory disease", orig.coding, icd10, source = "CDC 113 COD")])

    xflu <- x113[cause.of.death %in% c("Influenza", "Pneumonia")]
    xflu <- unique(xflu[, .(cause.of.death = "Influenza/pneumonia", orig.coding, icd10, source = "CDC 113 COD")])

    xnew <- rbind(xliver, xresp, xflu)
    xnew[, .N, cause.of.death]

    icd_other_causes_of_death <- icd_other_causes_of_death[!cause.of.death %in% c("Chronic liver disease and cirrhosis", "Chronic lower respiratory disease", "Influenza/pneumonia")] # drop if exists
    icd_other_causes_of_death <- rbind(icd_other_causes_of_death, xnew)

    setorder(icd_other_causes_of_death, cause.of.death, icd10, -orig.coding)
    icd_other_causes_of_death[, .N, cause.of.death]

# Write to package ----
    usethis::use_data(icd_other_causes_of_death, overwrite = TRUE)
    write.csv(icd_other_causes_of_death, "inst/extdata/icd_data/icd_other_causes_of_death.csv", row.names = F)
