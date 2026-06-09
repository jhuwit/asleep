.onLoad <- function(libname, pkgname) {
  reticulate::py_require(
    c("asleep==0.4.16", "argparse", "numpy", "pandas"),
    python_version = "3.8")
}
