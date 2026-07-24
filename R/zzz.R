.onLoad <- function(libname, pkgname) {
  # reticulate::py_require(
  #   c("asleep==0.4.18", "argparse", "numpy", "pandas", "importlib"),
  #   python_version = "3.8")
  reticulate::py_require(
    c(
      "asleep @ git+https://github.com/muschellij2/asleep.git",
      "argparse", "numpy", "pandas", "importlib"
    ),
    python_version = "3.8")
}
