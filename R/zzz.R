.onAttach <- function(libname, pkgname) {
  if (interactive()) {
    getNamespace("rads.data")$check_version()
  }
}
