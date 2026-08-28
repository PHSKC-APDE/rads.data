# Creating Reproducible Examples

When you're stuck on a coding problem and need help, following these guidelines will help us understand and solve your issue more quickly. Plus, you might even solve it yourself while putting together the example! Here's what we need to help you effectively.

> **Filing a feature request or documentation issue instead of a bug?** You can skip the reproducible example specific guidance below (Attempted Solutions, Expected Output, Minimal Code, Environment Information) — just describe what you'd like to see and why.

This package is maintained by PHSKC-APDE staff on a best-effort basis. Both PHSKC staff and outside users are welcome to file issues; the "Data Access" note below is only relevant if you have access to our shared network drives.

## Before You File

* :arrow_right: Search [existing issues](https://github.com/PHSKC-APDE/rads.data/issues?q=is%3Aissue) (open and closed) to check whether it's already been reported
* :arrow_right: Check the dataset help (`?dataset_name`) for existing guidance on the reference table you're using

## Help Us Help You

* **Problem Synopsis**: What exactly is the problem? 
  * If possible, please copy and paste the actual error message.

* **Attempted Solutions**: What have you already tried to fix this problem?

* **Expected Output**: What exactly did you expect as the output? A list? A data.frame? A vector? A new column in a data.frame? etc. 

* **Minimal Code**: Include only the code necessary to reproduce the issue. While you may have a complex pipeline, isolate the specific components related to the problem. This makes it easier for others to understand and solve the issue quickly.

* **Data Access**: If your issue uses data outside of rads.data, be sure we can access it! In that case you should also strive for a minimal dataset and might consider using [reprex](https://reprex.tidyverse.org/) or [datapasta](https://milesmcbain.github.io/datapasta/index.html).

* **File Paths**: Think carefully whether others can use your filepaths. Remove all references to your `C:\` drive

* **Environment Information**: Always include:
  * R version
  * Package versions for relevant dependencies
  * Random seeds if your code involves stochastic processes

## Benefits of Creating Minimal Examples

* **Faster Problem Resolution**: By providing focused code, others can quickly understand and address the issue
* **Self-Troubleshooting**: Often, the process of creating a minimal example helps identify the problem's source
* **Skill Development**: Learning to isolate issues and create minimal examples improves your debugging and programming skills

## Examples

### :cry: Bad Example
```r
# Can you help with the following code? 
# It doesn't work. I don't know why. 

library(rads.data)
library(rads)
library(data.table)
library(dplyr)

# Loading many reference tables and merging in a long pipeline
icd <- rads.data::icd10_death_injury_matrix
occ <- rads.data::occupation_soc_codes_2018
geo <- rads.data::spatial_king_county_2020

merged <- merge(icd, occ, by = "some_col", all.x = TRUE)
# ... (80 more lines of unrelated joins and filters)

# The actual issue is here somewhere, buried under unrelated code
for (yr in c(2018, 2019, 2020, 2021)) {
  message(yr)
  subset(icd, mechanism == "Firearm")
}
```

### :grin: Good Example
```r
# Can you help me with the following code?
# I am trying to filter icd10_death_injury_matrix to just 
# firearm-related mechanisms, but I get zero rows back.

# I checked unique(icd10_death_injury_matrix$mechanism) and 
# the value is actually "Firearm" (capital F), not "firearm" 
# like I was using, but I'm not sure if that's the intended 
# spelling or a bug in the table.

# R version 4.3.2
# rads.data 1.0.21
library(rads.data)

# The specific issue
result <- icd10_death_injury_matrix[mechanism == "firearm"]

# Expected output:
# a data.table with rows for mechanism == "Firearm" and 
# their associated icd10 codes
```

## Additional Resources

For more detailed information about creating reproducible examples:
* [How to make a great R reproducible example](https://stackoverflow.com/questions/5963269/how-to-make-a-great-r-reproducible-example)
* [How to create a Minimal, Reproducible Example](https://stackoverflow.com/help/minimal-reproducible-example)

See also our [Contributing guide](../../CONTRIBUTING.md) if you'd like to submit a fix yourself rather than just filing an issue.
