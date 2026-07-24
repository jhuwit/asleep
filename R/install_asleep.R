#' Check the `asleep` Python Module
#'
#'
#' @return A logical value indicating whether the `asleep` Python module is available.
#' @export
#' @rdname asleep_setup
#' @examples
#' \donttest{
#'   if (have_asleep()) {
#'      asleep_version()
#'   }
#' }
have_asleep = function() {
  reticulate::py_module_available("asleep")
}

#' @export
#' @rdname asleep_setup
asleep_check = function(...) {
  step_version = try({
    asleep_version(...)
  }, silent = TRUE)
  have_asleep() && !inherits(step_version, "try-error") &&
    length(step_version) > 0
}


module_version = function(module = "numpy", ...) {
  assertthat::is.scalar(module)
  if (!reticulate::py_module_available(module)) {
    stop(paste0(module, " is not installed!"))
  }
  df = reticulate::py_list_packages(...)
  if (module %in% df$package) {
    res = df$version[df$package == module]
  } else {
    ver = reticulate::import("importlib")
    res = ver$metadata$version(module)
  }
  res
}


#' @export
#' @param ... additional arguments to pass to [reticulate::py_list_packages]
#' @rdname asleep_setup
asleep_version = function(...) {
  module_version("asleep", ...)
}
