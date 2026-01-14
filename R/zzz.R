.onLoad <- function(libname, pkgname) {
  reticulate::py_require(
    c("asleep", "argparse", "numpy", "pandas"),
    python_version = "3.8")
}
