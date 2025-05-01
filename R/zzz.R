#' @title Package Attachment Hook
#' @description This function runs when the package is attached via `library()`
#'   or `require()`. It checks if a newer version of the package is available on
#'   GitHub and notifies the user if an update is needed.
#' @param libname The library where the package is installed
#' @param pkgname The name of the package
#' @keywords internal
#' @noRd
.onAttach <- function(libname, pkgname) {
  tryCatch({
    if (!requireNamespace("httr", quietly = TRUE)) {
      packageStartupMessage("Installing httr package to check for updates...")
      install.packages("httr", quiet = TRUE)
    }

    url <- "https://raw.githubusercontent.com/PHSKC-APDE/rads.data/main/DESCRIPTION"
    resp <- httr::GET(url)

    if (httr::status_code(resp) == 200) {
      desc_text <- httr::content(resp, "text")
      tmp <- tempfile()
      writeLines(desc_text, tmp)
      desc_vals <- read.dcf(tmp)
      remote_version <- package_version(desc_vals[1, "Version"])

      local_version <- utils::packageVersion("rads.data")

      if (remote_version > local_version) {
        packageStartupMessage("-----------------------------------------------------")
        packageStartupMessage("\u26A0\ufe0f A newer version of rads.data is available: ", remote_version)
        packageStartupMessage("Your version: ", local_version)
        packageStartupMessage("\U0001f504 To update, run: devtools::install_github('PHSKC-APDE/rads.data')")
        packageStartupMessage("-----------------------------------------------------")
      }
    } else {
      message("Could not retrieve version info from GitHub (status: ", httr::status_code(resp), ")")
    }
  }, error = function(e) {
    invisible()
  })
}

