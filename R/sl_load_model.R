sl_url = function(version = "0.4.12") {
  url = paste0("https://github.com/OxWearables/asleep/",
               "releases/download/", version, "/ssl.joblib.lzma")
}

#' Load `asleep` Model
#'
#' @param model_path the file path to the model.  If on disk, this can be
#' re-used and not re-downloaded.  If `NULL`, will download to the
#' temporary directory
#' @param as_python Keep model object as a python object
#'
#' @return A model from Python.  `sl_download_model` returns a model file path.
#' @export
sl_load_model = function(
    model_path = NULL,
    force_download = FALSE,
    as_python = TRUE
) {

  url = sl_url()
  if (as_python) {
    asleep = asleep_base_noconvert()
  } else {
    asleep = asleep_base()
  }
  if (is.null(model_path)) {
    model_path = file.path(
      tempdir(),
      basename(url)
    )
  } else {
    model_path = path.expand(model_path)
  }
  model = asleep$get_sleep$load_model(
    model_path = model_path,
    force_download = force_download)
  model
}

#' @export
#' @rdname sl_load_model
#' @param ... for `sl_download_model`, additional arguments to pass to
#' [curl::curl_download()]
sl_download_model = function(
    model_path,
    ...
) {
  base_url = sl_url()
  curl::curl_download(url = base_url, destfile = model_path, ...)
  return(model_path)
}
