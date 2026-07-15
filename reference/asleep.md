# Run `asleep` Model on Data

Run `asleep` Model on Data

## Usage

``` r
asleep(
  file,
  outdir = NULL,
  min_wear_hours = 22L,
  time_shift = "0",
  report_light_and_temp = FALSE,
  pytorch_device = c("cpu", "cuda:0"),
  verbose = TRUE,
  force_download = FALSE
)
```

## Arguments

- file:

  accelerometry file to process, including CSV, CWA, GT3X, and
  `GENEActiv` bin files

- outdir:

  output directory for CSVs and outputs

- min_wear_hours:

  Min wear time in hours to be eligible for summary statistics
  computation. The sleepnet paper uses 22

- time_shift:

  The number hours to shift forward or backward from the current device
  time. e.g. +1 or -1

- report_light_and_temp:

  If true, it adds mean temp, and light columns to the predictions

- pytorch_device:

  device to use for prediction for PyTorch.

- verbose:

  print diagnostic messages

- force_download:

  force a download of the model, passed to
  [`sl_download_models()`](https://jhuwit.github.io/asleep/reference/sl_download_models.md)

## Value

A list of outputs, including summaries, paths, and dataframes.

## Examples

``` r
# \donttest{
  file = system.file("extdata/example_sleep.csv.gz", package = "asleep")
  stopifnot(file.exists(file))
  if (asleep_check()) {
    sl_download_models()
    out = try({asleep(file = file, verbose = 2L)})
    if (inherits(out, "try-error")) {
      message(out)
      reticulate::py_last_error()
    } else {
      pred = out$predictions
    }
  }
#> Downloading uv...
#> Done!
#> Checking Data
#> File is:/home/runner/work/_temp/Library/asleep/extdata/example_sleep.csv.gz
#> Downloading models if not already present
#> Error in asleep(file = file, verbose = 2L) : 
#>   environments cannot be coerced to other types
#> Error in asleep(file = file, verbose = 2L) : 
#>   environments cannot be coerced to other types
#> NULL
# }
if (FALSE) { # \dontrun{
  file = system.file("extdata/example_sleep.csv.gz", package = "asleep")
  df = readr::read_csv(file)
  if (asleep_check()) {
    out = asleep(file = df)
    st = out$predictions
  }
  if (requireNamespace("ggplot2", quietly = TRUE) &&
      requireNamespace("tidyr", quietly = TRUE) &&
      requireNamespace("dplyr", quietly = TRUE)) {
    d = st[1:250,] %>% dplyr::mutate(time = lubridate::as_datetime(time))
    raw = df %>% dplyr::filter(time >= min(d$time) & time <= max(d$time))
    dat = raw %>%
      tidyr::gather(axis, value, -time)
    #dat %>%
    #   ggplot2::ggplot(ggplot2::aes(x = time, y = value, colour = axis)) +
    #   ggplot2::geom_line() +
    #   ggplot2::geom_segment(data = d, ggplot2::aes(xintercept = time))
  }

} # }
```
