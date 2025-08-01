% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/data.R
\docType{data}
\name{icd_nchs113causes}
\alias{icd_nchs113causes}
\title{NCHS 113 Selected Causes of Death (long)}
\format{
A data.table with 28,127 rows and four variables: \code{causeid}, \code{cause.of.death}, \code{orig.coding},
\code{icd10}. Each row maps one ICD-10 code to one of the 113 causes of death.
}
\source{
Downloaded from \url{https://ibis.health.utah.gov/ibisph-view/query/NCHS113.html} on 9/22/2021. It is a machine readable version of
\url{https://secureaccess.wa.gov/doh/chat/Content/FilesForDownload/CodeSetDefinitions/NCHS113CausesOfDeath.pdf}
}
\usage{
icd_nchs113causes
}
\description{
NCHS 113 Selected Causes of Death (long).
}
\details{
Tidied long version of \code{icd_nchs113causes_raw}. Converted by \verb{/data-raw/icd_nchs113causes.R}.
}
\note{
Per CDC guidance, our cause list contains COVID-19 (U07.1) in cause id 17 ("Other and unspecified
infectious and parasitic diseases and their sequelae")

\if{html}{\out{<div class="sourceCode">}}\preformatted{Cause id 95 ("All other diseases (Residual)") uses codings discovered on a PHSKC
network drive. They were probably created by Mike Smyser, who has retired. These
are being used instead of the CDC codes due to better alignment with WA DOH.

The official CDC coding for Cause id 95 is now saved as cause id 114 "CDC version of cause id 95 (Residual)".
}\if{html}{\out{</div>}}
}
\references{
\url{https://www.cdc.gov/nchs/data/dvs/Part9InstructionManual2020-508.pdf}
}
\keyword{datasets}
