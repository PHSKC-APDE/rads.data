# Header ----
# Author: Danny Colombara
# Date: April 26, 2022
# Purpose: Create machine usable long form of WA DOH Death Injury Matrix
# Notes: Labeled "ICE", so based on International Collaborative Effort on Injury Statistics
#        Original is from WA DOH CHAT: https://secureaccess.wa.gov/doh/chat/Content/FilesForDownload/CodeSetDefinitions/CHATInjury(ICE)codes.pdf
#        Converted to XLSX with Adobe Acrobat and then used Excel to convert to a CSV

# Set-up ----
rm(list=ls())
library(data.table)

# Function to clean / prep imported data to fix random white spaces (sql_clean) ----
  source("https://raw.githubusercontent.com/PHSKC-APDE/rads/main/R/utilities.R") # pull in rads utilities, particularly sql_clean()

# Function to enumerator all ICD per 113 causes of death (split.dash) ----
  # E.g., split.dash("X0-X04, X17-X19") >> "X00, X01, X02, X03, X04, X17, X18, X19"
    source("https://raw.githubusercontent.com/PHSKC-APDE/rads.data/main/data-raw/icd_utility_split.dash.R")

# Read & tidy raw ICD10 death injury matrix ----
    # See notes above for origin details
    # read ----
    dt = fread("data-raw/icd_icd10_death_injury_matrix_raw.csv")

    # general text clean ----
    sql_clean(dt)

    # tidy columns and rows ----
    dt[, mechanism := mechanism[nafill(replace(.I, is.na(mechanism), NA), "locf")]] # fill downward, hacky way to get around limitation of nafill only working with numerics
    dt <- dt[, .(intent, mechanism, codes)]
    dt <- dt[!is.na(codes)]
    dt[, original.order := 1:.N]

    # tidy codes before splitting ----
    dt[, codes := gsub("\\\\n| ", "", codes)]
    dt[, codes := gsub("\\)", "\\]", codes)]
    dt[, codes := gsub("\\(", "\\[", codes)]
    dt[, codes := gsub("\\R", "", codes, fixed = T)]
    dt[, codes := toupper(codes)]
    dt[, codes := gsub("^ *|(?<= ) | *$", "", codes, perl = TRUE)] # remove multiple white spaces even if there is more than one

    # split each logical set of codes into a new column ----
    maxsplits <- max(lengths(strsplit(dt$codes, "\\,[A-Z][0-9]")))
    dt[, codes := gsub("(\\,[A-Z][0-9])", "~\\1", codes)] # added a ~before the commas where I want to split
    dt[, paste0("part", 1:maxsplits) := tstrsplit(codes, "~\\,", fixed = FALSE)]

    # create function to expand the ICD codes by ascribing the proper decimal to each stem (e.g., Y89 and [.0, .1] to Y89.0, Y89.1) ----
      expand.icds <- function(mydt = NULL, xcode){ # had a hard time doing this a legit data.table way, so will apply this to each row
        mydt[, paste0(xcode) := gsub("\\R", "", get(xcode), fixed = T)]
        for(i in 1:nrow(mydt)){
          print(paste(xcode, ": ", i))
          if(!is.na(mydt[i,][[xcode]])){ # if NA, no need for any of the followign code
            stem =  gsub("\\[.*$", "", mydt[i,][[xcode]]) # get the stem (e.g., V83-V86 from V83-V86[.0-.3] )
            first.stem = substr(stem, 1, 3) # get the final stem (e.g., V83 from V83-V86[.0-.3])
            final.stem = gsub("^.*-", "", stem) # get the final stem (e.g., V83 from V83-V86[.0-.3])
            decimals = gsub("\\[|\\]", "", gsub(stem, "", mydt[i,][[xcode]])) # isolate just the part with decimals (e.g., ".0-.1")
            decimals = unlist(strsplit(decimals, ",")) # isolate just the part with decimals (e.g., ".0" ".1")

            if(length(decimals) > 0 ){
              for(LL in 1:length(decimals)){
                ll.decimals <- unlist(strsplit(decimals[LL], "-"))
                ll.decimals <- as.character(seq(min(ll.decimals), max(ll.decimals), 0.1))
                ll.decimals <- paste0(".", gsub("0.", "", ll.decimals))
                ll.decimals <- paste(ll.decimals, collapse = ",")
                decimals[LL] <- ll.decimals
              }
              decimals <- paste(decimals, collapse = ",")

              if(first.stem == final.stem){
                expanded = paste(gsub("\\.", paste0(final.stem, "."), decimals), collapse = ",") # collapse with formatting (e.g., Y89.0,Y89.1)
              } else{
                if(substr(first.stem, 1, 1) == substr(final.stem, 1, 1)){
                  alpha = substr(first.stem, 1, 1)
                  ints = seq(as.integer(substr(first.stem, 2, 3)), as.integer(substr(final.stem, 2, 3)), 1) # full sequence of integers
                  ints = sprintf("%02i", ints) # make character and add preceding zero if necessary, e.g., 3 >> "03"
                  alphaints = paste0(alpha, ints)
                  expanded <- c()
                  for(ai in alphaints){
                    expanded <- c(expanded, paste(gsub("\\.", paste0(ai, "."), decimals))) # combined each alphaint (e.g., V30) with each decimal
                    expanded <- paste(expanded, collapse = ",")
                  } # close loop for creating combinations of stems and decimals
                } # close if statement for when the first letter of the first stem is the first letter of the final stem
              } # close else statement (meaning first.stem != final.stem)
              mydt[i, paste0(xcode) := expanded] # overwrite value in table
            } # close loop of things to do if there are decimals
          } # close if statement to run only if the cell value is not NA
        } # close loop that goes over each row
      } # close function

    # apply function to expand icd codes ----
      for(PP in paste0("part", 1:maxsplits)){
        expand.icds(mydt = dt, xcode = PP)
      }

    # combine the multiple code 'parts' back into one variable ----
    dt = dt[, .(original.order, intent, mechanism, orig.coding = gsub("~\\,", ", ", codes), codes = do.call(paste, c(replace(.SD, is.na(.SD), ""), sep = ","))),
              .SDcols = patterns("^part") ] # collapse without including NAs
    dt[, codes := gsub("([^0-9]+$)", "", codes)] # drop everything after the last number

# Use split_dash() to convert dashed to enumerated ICD codes & drop decimals b/c death icds have decimals removed ----
    sql_clean(dt)
    dt[, icd := split.dash(codes), by = 1:nrow(dt)]
    dt[, codes := NULL]

# split icds so there is one per column, making data.table truly 'wide' ----
    splits <- max(lengths(strsplit(dt$icd, ", ")))
    wide <- copy(dt)[, paste0("icd", 1:splits) := tstrsplit(icd, ", ", fixed=T)]
    wide[, icd := NULL]

# reshape wide to long ----
    icd10_death_injury_matrix <- melt(wide, id.vars = c("original.order", "intent", "mechanism", "orig.coding"), value.name = "icd10")
    icd10_death_injury_matrix[, variable := NULL]
    icd10_death_injury_matrix <- icd10_death_injury_matrix[!is.na(icd10)]
    setorder(icd10_death_injury_matrix, original.order, intent, mechanism, icd10)
    icd10_death_injury_matrix <- icd10_death_injury_matrix[, .(mechanism, intent, orig.coding, icd10)]

# Create summary category for all Motor Vehicle ----
    mv <- copy(icd10_death_injury_matrix)[mechanism %like% 'Moto']
    mv <- unique(mv[, mechanism:= "Motor vehicle traffic"])
    icd10_death_injury_matrix <- rbind(icd10_death_injury_matrix, mv)

# Write to package ----
    usethis::use_data(icd10_death_injury_matrix, overwrite = TRUE)
    write.csv(icd10_death_injury_matrix, "inst/extdata/icd_data/icd10_death_injury_matrix.csv", row.names = F)
