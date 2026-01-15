#' Get SSL Net -
#'
#' @returns A `keras` model representing the SSL Net.
#' @export
get_sslnet = function() {
  asleep = asleep_base_noconvert()
  asleep$sslmodel$get_sslnet()
}


#' @export
#' @rdname get_sslnet
sl_get_sslnet = get_sslnet
