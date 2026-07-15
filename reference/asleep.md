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
#> Parsing raw data
#> Transforming data for model input
#> Data shape for data2model: (480, 3, 900)
#> Data shape for times: (480,)
#> Data shape for nonwear: (480,)
#> Detecting sleep windows
#> args$outdir/tmp/RtmpYg51w0/file199a844be4e
#> ssl_sleep_path: /tmp/RtmpYg51w0/file199a844be4e/ssl_sleep.npy, exists:FALSE
#> data2model
#> array([[[-0.704     , -0.72079488, -0.66515385, ..., -0.69130774,
#>          -0.69115383, -0.6903333 ],
#>         [ 0.413     ,  0.419     ,  0.42884615, ...,  0.42430774,
#>           0.42807678,  0.44416667],
#>         [-0.54      , -0.56166666, -0.57858971, ..., -0.55976925,
#>          -0.59274354, -0.61691666]],
#> 
#>        [[-0.689     , -0.61469231, -0.58484615, ..., -0.62961541,
#>          -0.62735884, -0.62341669],
#>         [ 0.469     ,  0.42923077,  0.43343586, ...,  0.466     ,
#>           0.46      ,  0.45547223],
#>         [-0.648     , -0.55720514, -0.58207693, ..., -0.57223075,
#>          -0.57330765, -0.56950002]],
#> 
#>        [[-0.625     , -0.62246154, -0.63430771, ..., -0.73707666,
#>          -0.73812797, -0.74825001],
#>         [ 0.457     ,  0.45953846,  0.46923078, ...,  0.18476925,
#>           0.19420501,  0.20291666],
#>         [-0.56      , -0.548     , -0.56430771, ..., -0.64523075,
#>          -0.6363847 , -0.65150002]],
#> 
#>        ...,
#> 
#>        [[-0.032     , -0.032     , -0.032     , ..., -0.032     ,
#>          -0.032     , -0.032     ],
#>         [-0.123     , -0.123     , -0.123     , ..., -0.123     ,
#>          -0.123     , -0.123     ],
#>         [-0.988     , -0.988     , -0.988     , ..., -0.988     ,
#>          -0.988     , -0.988     ]],
#> 
#>        [[-0.032     , -0.032     , -0.032     , ..., -0.032     ,
#>          -0.032     , -0.032     ],
#>         [-0.123     , -0.123     , -0.123     , ..., -0.123     ,
#>          -0.123     , -0.123     ],
#>         [-0.988     , -0.988     , -0.988     , ..., -0.988     ,
#>          -0.988     , -0.988     ]],
#> 
#>        [[-0.032     , -0.032     , -0.032     , ..., -0.032     ,
#>          -0.032     , -0.032     ],
#>         [-0.123     , -0.123     , -0.123     , ..., -0.123     ,
#>          -0.123     , -0.123     ],
#>         [-0.988     , -0.988     , -0.988     , ..., -0.988     ,
#>          -0.988     , -0.988     ]]])
#> non_wear
#> array([False, False, False, False, False, False, False, False, False,
#>        False, False, False, False, False, False, False, False, False,
#>        False, False, False, False, False, False, False, False, False,
#>        False, False, False, False, False, False, False, False, False,
#>        False, False, False, False, False, False, False, False, False,
#>        False, False, False, False, False, False, False, False, False,
#>        False, False, False, False, False, False, False, False, False,
#>        False, False, False, False, False, False, False, False, False,
#>        False, False, False, False, False, False, False, False, False,
#>        False, False, False, False, False, False, False, False, False,
#>        False, False, False, False, False, False, False, False, False,
#>        False, False, False, False, False, False, False, False, False,
#>        False, False, False, False, False, False, False, False, False,
#>        False, False, False, False, False, False, False, False, False,
#>        False, False, False, False, False, False, False, False, False,
#>        False, False, False, False, False, False, False, False, False,
#>        False, False, False, False, False, False, False, False, False,
#>        False, False, False, False, False, False, False, False, False,
#>        False, False, False, False, False, False, False, False, False,
#>        False, False, False, False, False, False, False, False, False,
#>        False, False, False, False, False, False, False, False, False,
#>        False, False, False, False, False, False, False, False, False,
#>        False, False, False, False, False, False, False, False, False,
#>        False, False, False, False, False, False, False, False, False,
#>        False, False, False, False, False, False, False, False, False,
#>        False, False, False, False, False, False, False, False, False,
#>        False, False, False, False, False, False, False, False, False,
#>        False, False, False, False, False, False, False, False, False,
#>        False, False, False, False, False, False, False, False, False,
#>        False, False, False, False, False, False, False, False, False,
#>        False, False, False, False, False, False, False, False, False,
#>        False, False, False, False, False, False, False, False, False,
#>        False, False, False, False, False, False, False, False, False,
#>        False, False, False, False, False, False, False, False, False,
#>        False, False, False, False, False, False, False, False, False,
#>        False, False, False, False, False, False, False, False, False,
#>        False, False, False, False, False, False, False, False, False,
#>        False, False, False, False, False, False, False, False, False,
#>        False, False, False, False, False, False, False, False, False,
#>        False, False, False, False, False, False, False, False, False,
#>        False, False, False, False, False, False, False, False, False,
#>        False, False, False, False, False, False, False, False, False,
#>        False, False, False, False, False, False, False, False, False,
#>        False, False, False, False, False, False, False, False, False,
#>        False, False, False, False, False, False, False, False, False,
#>        False, False, False, False, False, False, False, False, False,
#>        False, False, False, False, False, False, False, False, False,
#>        False, False, False, False, False, False, False, False, False,
#>        False, False, False, False, False, False, False, False, False,
#>        False, False, False, False, False, False, False, False, False,
#>        False, False, False, False, False, False, False, False, False,
#>        False, False, False, False, False, False, False, False, False,
#>        False, False, False, False, False, False, False, False, False,
#>        False, False, False])
#> Running SleepNet
#> SleepNet outdir: /tmp/RtmpYg51w0/file199a844be4e
#> Upstream ssl model path: /home/runner/.cache/R/reticulate/uv/cache/archive-v0/cCxhAOvN3LShT5oy/lib/python3.8/site-packages/asleep/ssl.joblib.lzma, exists: TRUE
#> SleepNet weight URL: https://github.com/OxWearables/asleep/releases/download/0.4.9/sleepnet_apr_16_2024.mdl
#> SleepNet artifact ssl_sleep: /tmp/RtmpYg51w0/file199a844be4e/ssl_sleep.npy, exists: TRUE
#> SleepNet artifact y_pred: /tmp/RtmpYg51w0/file199a844be4e/y_pred.npy, exists: FALSE
#> SleepNet artifact pred_prob: /tmp/RtmpYg51w0/file199a844be4e/pred_prob.npy, exists: FALSE
#> SleepNet artifact x_npy: /tmp/RtmpYg51w0/file199a844be4e/X.npy, exists: FALSE
#> SleepNet artifact x_npy_gz: /tmp/RtmpYg51w0/file199a844be4e/X.npy.gz, exists: FALSE
#> SleepNet artifact npid: /tmp/RtmpYg51w0/file199a844be4e/npid.npy, exists: FALSE
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
