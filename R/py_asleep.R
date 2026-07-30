#' Run `asleep` with Python
#'
#' @param ... arguments to pass to [asleep::asleep]
#' @param pyenv_function function that loads the forest Python package.
#' By default, it uses reticulate::py_import("asleep") to import
#' the package. If this function has an args argument, the output of
#' pyenv_function will be re-assigned to args.
#' @param show Logical, whether to show the standard output on the
#' screen while the child process is running, passed to [callr::r()]
#'
#' @rdname asleep
#' @export
py_asleep = function(
    ...,
    pyenv_function = function() {
      reticulate::py_require(
        c(
          "asleep @ git+https://github.com/muschellij2/asleep.git",
          "argparse", "numpy", "pandas", "importlib"
        ),
        python_version = "3.8")
      reticulate::import("asleep")
    },
    show = FALSE
) {
  rlang::check_installed("callr")
  steps <- callr::r(
    show = show,
    func = function(..., pyenv_function) {
      args = list(...)
      if ("args" %in% methods::formalArgs(pyenv_function)) {
        args = pyenv_function(args)
      } else {
        pyenv_function()
      }
      res = do.call(asleep::asleep, args = args)
    },
    args = list(...,
                pyenv_function = pyenv_function)
  ) # Safely injects data into the process
}
