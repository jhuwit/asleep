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
  verbose = TRUE
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

## Value

A list of outputs, including summaries, paths, and dataframes.

## Examples

``` r
# \donttest{
  file = system.file("extdata/example_sleep.csv.gz", package = "asleep")
  if (asleep_check()) {
    sl_download_models()
    out = asleep(file = file, verbose = 2L)
    pred = out$predictions
  }
#> Downloading uv...
#> Done!
#> Checking Data
#> Parsing raw data
#> Transforming data for model input
#> Data shape for data2model: (480, 3, 900)
#> Data shape for times: (480,)
#> Data shape for nonwear: (480,)
#> Detecting sleep windows
#> Running SleepNet
#> Mapping SleepNet predictions back to original time series
#> Generating predictions dataframe
#> Generating sleep block df and indicate the longest block per day
#> Generating daily summary statistics
#> Creating outputs
# }
if (FALSE) { # \dontrun{
  file = system.file("extdata/example_sleep.csv.gz", package = "asleep")
  df = readr::read_csv(file)
  if (asleep_check()) {
    out = asleep(file = df)
    st = out$step_times
  }
  if (requireNamespace("ggplot2", quietly = TRUE) &&
      requireNamespace("tidyr", quietly = TRUE) &&
      requireNamespace("dplyr", quietly = TRUE)) {
    dat = df[10000:12000,] %>%
      dplyr::select(-annotation) %>%
      tidyr::gather(axis, value, -time)
    st = st %>%
      dplyr::mutate(time = lubridate::as_datetime(time)) %>%
      dplyr::as_tibble()
    st = st %>%
      dplyr::filter(time >= min(dat$time) & time <= max(dat$time))
    dat %>%
      ggplot2::ggplot(ggplot2::aes(x = time, y = value, colour = axis)) +
      ggplot2::geom_line() +
      ggplot2::geom_vline(data = st, ggplot2::aes(xintercept = time))
  }

} # }
```
