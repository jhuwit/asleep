#' Check the `asleep` Python Module
#'
#'
#' @return A logical value indicating whether the `asleep` Python module is available.
#' @export
#' @rdname asleep_setup
#' @examples
#' if (have_asleep()) {
#'    asleep_version()
#' }
have_asleep = function() {
  reticulate::py_module_available("asleep")
}

#' @export
#' @rdname asleep_setup
asleep_check = function() {
  step_version = try({
    asleep_version()
  }, silent = TRUE)
  have_asleep() && !inherits(step_version, "try-error") &&
    length(step_version) > 0
}


module_version = function(module = "numpy") {
  assertthat::is.scalar(module)
  if (!reticulate::py_module_available(module)) {
    stop(paste0(module, " is not installed!"))
  }
  df = reticulate::py_list_packages()
  df$version[df$package == module]
}


#' @export
#' @rdname asleep_setup
asleep_version = function() {
  module_version("asleep")
}
