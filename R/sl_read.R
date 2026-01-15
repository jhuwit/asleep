#' Read a Data Set for `asleep`
#'
#' @param file path to the file for reading
#' @param resample_hz Target frequency (Hz) to resample the signal. If
#' "uniform", use the implied frequency (use this option to fix any device
#' sampling errors). Pass `NULL` to disable. Defaults to "uniform".
#' @param keep_pandas do not convert the data to a `data.frame` and keep
#' as a `pandas` `data.frame`
#'
#' @return A list of the data and information about the data
#' @export
#'
#' @note The data `P30_wrist100` is from
#' \url{https://ora.ox.ac.uk/objects/uuid:19d3cb34-e2b3-4177-91b6-1bad0e0163e7},
#' where we took the first 180,000 rows, the first 30 minutes of data
#' from that participant as an example.
#'
#' @examples
#'
#' file = system.file("extdata/example_sleep.csv.gz", package = "asleep")
#' if (asleep_check()) {
#'   out = sl_read(file)
#' }
sl_read = function(
    file,
    resample_hz = "uniform",
    keep_pandas = FALSE
) {

  if (keep_pandas) {
    sc = asleep_base_noconvert()
  } else {
    sc = asleep_base()
  }
  if ("read" %in% names(sc)) {
    func = sc$read
  } else if ("utils" %in% names(sc) && "read" %in% names(sc$utils)) {
    func = sc$utils$read
  } else {
    warning("No function for reading found, using asleep.read as default")
    func = sc$read
  }
  assertthat::assert_that(
    assertthat::is.readable(file),
    is.null(resample_hz) ||
      assertthat::is.count(resample_hz) ||
      (assertthat::is.string(resample_hz) && resample_hz == "uniform")
  )
  file = normalizePath(path.expand(file))
  out = func(filepath = file,
             resample_hz = resample_hz
  )
  if (keep_pandas) {
    out = list(
      data = out[[0]],
      info = reticulate::py_to_r(out[1])
    )
  }
  names(out) = c("data", "info")
  out
}
