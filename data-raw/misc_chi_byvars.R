# Author: Danny Colombara
# R version: 4.2.1
# Date: March 15, 2023
# Purpose: Refresh standard CHI cat/varname/group/group_alias from SharePoint
# Source: SharePoint >> Community Health Indicators >> CHI-Vizes >> CHI-Standards-TableauReady Output.xlsx
# Notes:

# Set up ----
rm(list=ls())
library(data.table)
library(Microsoft365R)
library(stringi)

# Import data from SharePoint ----
    team <- get_team("Community Health Indicators")

    drv <- team$get_drive("CHI-Vizes")

    tempy <- tempfile(fileext = ".xlsx")

    drv$download_file(src = 'CHI-Standards-TableauReady Output.xlsx',
                      dest = tempy,
                      overwrite = FALSE)

    misc_chi_byvars <- setDT(openxlsx::read.xlsx(tempy, sheet = "Standard-Varname_Groups"))

    rads::sql_clean(misc_chi_byvars) # get rid of misc whitespace

    setorder(misc_chi_byvars, cat, varname, group)
    misc_chi_byvars <- rbind(misc_chi_byvars[cat == 'King County'], misc_chi_byvars[cat == "Washington State"], misc_chi_byvars[!cat %in% c("King County", "Washington State")])
    misc_chi_byvars[, creation_date := Sys.Date()]

    misc_chi_byvars[, notes := gsub('"', "`", notes)] # Replace all quotation marks with tick marks

# Tidy irregular whitespaces ----
    rads::sql_clean(misc_chi_byvars)
    string.columns <- names(misc_chi_byvars) # all are strings
    misc_chi_byvars[, (string.columns) := lapply(.SD, function(x){stringi::stri_replace_all_charclass(x, "\\p{WHITE_SPACE}", " ")}), .SDcols = string.columns] # replace irregular whitespaces with true whitespaces (' ')

# Identify differences since the previous run ----
  existing <- fread('https://raw.githubusercontent.com/PHSKC-APDE/rads.data/main/inst/extdata/misc_data/chi_byvars.csv')
  setorder(existing, cat, varname, group)
  misc_chi_byvars <- rbind(misc_chi_byvars[cat == 'King County'],
                           misc_chi_byvars[cat == "Washington State"],
                           misc_chi_byvars[!cat %in% c("King County", "Washington State")]) # to force KC and Wa to be at the top


  if(nrow(fsetdiff(misc_chi_byvars[, 1:5], existing[,1:5])) == 0 && nrow(fsetdiff(existing[,1:5], misc_chi_byvars[, 1:5])) == 0){
    message('There reference table has not been updated so rads.data will not be updated.')
  } else {
    message("The following rows are not in the pre-existing data and will be added:")
    print(fsetdiff(misc_chi_byvars[, 1:5], existing[, 1:5]))

    message("The following rows are in the pre-existing data but not in the new data ... they will be dropped:")
    print(fsetdiff(existing[, 1:5], misc_chi_byvars[, 1:5]))

    answer <- readline(prompt = "Are you ABSOLUTELY POSITIVE you want to continue? (y/n) ")
    if(answer == 'y'){
      # Save as RDA file ----
      usethis::use_data(misc_chi_byvars, compress = "bzip2", version = 3, overwrite = TRUE)

      # Save as CSV file -----
      write.csv(misc_chi_byvars, file = "inst/extdata/misc_data/chi_byvars.csv", row.names = FALSE)

      message('The updated data was written to rads.data.\n Update the helpfile if needed.')
    }
    if(answer == 'n'){
      message("There were changes compared to the last run, but you have decided not to update the data.")
    }
  }

# The end ----

