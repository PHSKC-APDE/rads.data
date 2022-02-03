# rads.data

## Purpose
[RADS](https://github.com/PHSKC-APDE/rads), APDE’s ‘R Automated Data System, is a suite of tools written in R and designed to make standard public health analyses faster, more standardized, and less prone to error. The `rads.data` package contains public health data that is either used by `RADS` or that might be useful for pre- or post-processing `RADS` data. 


## Installation

If you haven’t yet installed [`rads.data`](https://github.com/PHSKC-APDE/rads.data), follow these steps:

1. Make sure devtools is installed … `install.packages("devtools")`.

2. Install [`rads.data`](https://github.com/PHSKC-APDE/rads.data) …
    `devtools::install_github("PHSKC-APDE/rads.data", auth_token = NULL)`

3. Load [`rads.data`](https://github.com/PHSKC-APDE/rads.data) … `library(rads.data)`

4. Exit RStudio and start it again. 

5. Confirm `rads.data` installed properly by typing `library(rads.data)` in the console.

## Getting started
As of February 3, 2022, this package contains data.tables from the following thematic areas:

1. **icd** << reference tables of ICD 10 codes for causes of death and hospitalizations.

2. **occupation** << [BLS Standard Occupational Classification (SOC) codes](https://www.bls.gov/soc/) for the 2010 and 2018 systems.

3. **population** << mostly reference standard populations used for age adjustment.

4. **spatial** << crosswalk files between different levels of WA, King County, and Seattle geographies. **Note:** this does not contain shape files.


All of the data.tables are prefixed by their thematic area, i.e., every table begins with `spatial_`, or `population_`, or `occupation_`, or `icd_`.

Once the package has been loaded, you can import the table of interest into memory by simply typing `data(table.name)`. For example, typing `data(spatial_zip_hca)` will import the 'spatial_zip_hca' data.table. If you want to know which tables are available, it easiest to type `rads.data::` and then the thematic area prefix (i.e, `rads.data::icd_`) into the console and scroll through the available options. If you scroll slowly, descriptions should pop up on in a small window. If you want to see the full documentation for a specific table, type `?table.name`. For example, `?icd_nchs113causes`.

Finally, if you need a CSV to share the data with non-R users, you can point them to [`inst/extdata`](https://github.com/PHSKC-APDE/rads.data/inst/extdata). This folder contains CSV copies of the R data files. When updating this package, all updates should be performed on the R data files followed by running the [copying code](https://github.com/PHSKC-APDE/rads.data/blob/main/data-raw/copy_rda_to_csv.R).

## Problems & suggestions?
If you notice something that is incorrect, know a data source that you'd like to add, or have a suggestion for improvement, please let us know. Click on ["Issues"](https://github.com/PHSKC-APDE/rads.data/issues) at the top of this page and then click ["New Issue"](https://github.com/PHSKC-APDE/rads.data/issues/new/choose) and provide the necessary details. 

