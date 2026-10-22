#' Rename data for `asleep`
#'
#' @param data a `data.frame` of raw accelerometry
#'
#' @return A `data.frame` of renamed columns
#' @export
sl_rename_data = function(data) {
  HEADER_TIMESTAMP = TIME = HEADER_TIME_STAMP = X = Y = Z = NULL
  rm(list = c("HEADER_TIMESTAMP", "HEADER_TIME_STAMP", "X", "Y", "Z",
              "TIME"))
  assertthat::assert_that(
    is.data.frame(data)
  )
  # uppercase
  colnames(data) = toupper(colnames(data))
  cn = colnames(data)
  if ("TIME" %in% cn && !"HEADER_TIMESTAMP" %in% cn) {
    data = renamer(data, old = "TIME", new = "HEADER_TIMESTAMP")
  }
  if ("HEADER_TIME_STAMP" %in% cn && !"HEADER_TIMESTAMP" %in% cn) {
    data = renamer(data, old = "HEADER_TIME_STAMP", new = "HEADER_TIMESTAMP")
  }
  stopifnot(all(c("X", "Y", "Z", "HEADER_TIMESTAMP") %in% colnames(data)))
  data = renamer(data, old = "HEADER_TIMESTAMP", new = "time")
  colnames(data) = tolower(colnames(data))
  data
}

#' @export
#' @param path path to the CSV output file
#' @param chunk_size number of rows formatted and written at a time, which
#' bounds the memory used for long recordings. The file is the same for any
#' `chunk_size`.
#' @rdname sl_rename_data
sl_write_csv = function(data, path = tempfile(fileext = ".csv"),
                        chunk_size = 1e6) {
  data = sl_rename_data(data = data)
  opts = options()
  on.exit(options(opts), add = TRUE)
  # Microsecond precision: millisecond rounding of e.g. 85.7 Hz data makes the
  # sample interval irregular and biases sample-rate inference in asleep
  options(digits.secs = 6)
  n = nrow(data)
  if (n == 0) {
    data$time = format(data$time, "%Y-%m-%d %H:%M:%OS6")
    readr::write_csv(x = data, file = path, progress = FALSE)
    return(path)
  }
  for (start in seq(1, n, by = chunk_size)) {
    rows = seq.int(start, min(n, start + chunk_size - 1))
    chunk = data[rows, , drop = FALSE]
    # identical to format(chunk$time, "%Y-%m-%d %H:%M:%OS6")
    chunk$time = format_time_fast(chunk$time, digits = 6L)
    readr::write_csv(x = chunk, file = path, progress = FALSE,
                     append = start > 1)
  }
  return(path)
}


renamer = function(data, old, new) {
  stopifnot(length(old) == length(new))
  cn = colnames(data)
  cn[cn %in% old] = new
  colnames(data) = cn
  data
}


# Time zone of a data.frame input's time column, or NULL if unknown (files,
# or a non-POSIXct time column). No tzone means the session time zone, which
# is what sl_write_csv() formats the clock times in.
sl_input_tz = function(file) {
  if (is.data.frame(file)) {
    data = sl_rename_data(file)
    if (inherits(data$time, "POSIXt")) {
      tzone = attr(data$time, "tzone")
      return(if (is.null(tzone) || !nzchar(tzone[1])) Sys.timezone() else tzone[1])
    }
  }
  NULL
}

# asleep returns local clock times without a time zone. reticulate stores
# them as if they were UTC but without a tzone attribute, so they print in the
# system time zone. Format in UTC to recover the clock time; relabelling with
# force_tz() would give NA for clock times in a daylight-saving gap (e.g. 01:30
# on spring-forward day in London).
sl_format_time = function(x) {
  if (is.character(x) || is.null(x)) {
    return(x)
  }
  format(x, "%Y-%m-%d %H:%M:%S", tz = "UTC")
}
