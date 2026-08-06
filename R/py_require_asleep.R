#' Command for `py_require` for `asleep`
#'
#' @param ... arguments to pass to [reticulate::py_require()]
#'
#' @returns A logical value indicating whether the package is available.
#' @export
py_require_asleep = function(...) {
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
