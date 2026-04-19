.onLoad <- function(libname, pkgname) {
  # Register S7 methods
  S7::methods_register()
}
