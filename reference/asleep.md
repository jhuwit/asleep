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
    out = asleep(file = file, verbose = 2L)
    pred = out$predictions
  }
#> Downloading uv...
#> Done!
#> Checking Data
#> Resnet(
#>   (feature_extractor): Sequential(
#>     (layer1): Sequential(
#>       (0): Conv1d(3, 64, kernel_size=(5,), stride=(1,), padding=(2,), bias=False, padding_mode=circular)
#>       (1): ResBlock(
#>         (bn1): BatchNorm1d(64, eps=1e-05, momentum=0.1, affine=True, track_running_stats=True)
#>         (bn2): BatchNorm1d(64, eps=1e-05, momentum=0.1, affine=True, track_running_stats=True)
#>         (conv1): Conv1d(64, 64, kernel_size=(5,), stride=(1,), padding=(2,), bias=False, padding_mode=circular)
#>         (conv2): Conv1d(64, 64, kernel_size=(5,), stride=(1,), padding=(2,), bias=False, padding_mode=circular)
#>         (relu): ReLU(inplace=True)
#>       )
#>       (2): ResBlock(
#>         (bn1): BatchNorm1d(64, eps=1e-05, momentum=0.1, affine=True, track_running_stats=True)
#>         (bn2): BatchNorm1d(64, eps=1e-05, momentum=0.1, affine=True, track_running_stats=True)
#>         (conv1): Conv1d(64, 64, kernel_size=(5,), stride=(1,), padding=(2,), bias=False, padding_mode=circular)
#>         (conv2): Conv1d(64, 64, kernel_size=(5,), stride=(1,), padding=(2,), bias=False, padding_mode=circular)
#>         (relu): ReLU(inplace=True)
#>       )
#>       (3): BatchNorm1d(64, eps=1e-05, momentum=0.1, affine=True, track_running_stats=True)
#>       (4): ReLU(inplace=True)
#>       (5): Downsample()
#>     )
#>     (layer2): Sequential(
#>       (0): Conv1d(64, 128, kernel_size=(5,), stride=(1,), padding=(2,), bias=False, padding_mode=circular)
#>       (1): ResBlock(
#>         (bn1): BatchNorm1d(128, eps=1e-05, momentum=0.1, affine=True, track_running_stats=True)
#>         (bn2): BatchNorm1d(128, eps=1e-05, momentum=0.1, affine=True, track_running_stats=True)
#>         (conv1): Conv1d(128, 128, kernel_size=(5,), stride=(1,), padding=(2,), bias=False, padding_mode=circular)
#>         (conv2): Conv1d(128, 128, kernel_size=(5,), stride=(1,), padding=(2,), bias=False, padding_mode=circular)
#>         (relu): ReLU(inplace=True)
#>       )
#>       (2): ResBlock(
#>         (bn1): BatchNorm1d(128, eps=1e-05, momentum=0.1, affine=True, track_running_stats=True)
#>         (bn2): BatchNorm1d(128, eps=1e-05, momentum=0.1, affine=True, track_running_stats=True)
#>         (conv1): Conv1d(128, 128, kernel_size=(5,), stride=(1,), padding=(2,), bias=False, padding_mode=circular)
#>         (conv2): Conv1d(128, 128, kernel_size=(5,), stride=(1,), padding=(2,), bias=False, padding_mode=circular)
#>         (relu): ReLU(inplace=True)
#>       )
#>       (3): BatchNorm1d(128, eps=1e-05, momentum=0.1, affine=True, track_running_stats=True)
#>       (4): ReLU(inplace=True)
#>       (5): Downsample()
#>     )
#>     (layer3): Sequential(
#>       (0): Conv1d(128, 256, kernel_size=(5,), stride=(1,), padding=(2,), bias=False, padding_mode=circular)
#>       (1): ResBlock(
#>         (bn1): BatchNorm1d(256, eps=1e-05, momentum=0.1, affine=True, track_running_stats=True)
#>         (bn2): BatchNorm1d(256, eps=1e-05, momentum=0.1, affine=True, track_running_stats=True)
#>         (conv1): Conv1d(256, 256, kernel_size=(5,), stride=(1,), padding=(2,), bias=False, padding_mode=circular)
#>         (conv2): Conv1d(256, 256, kernel_size=(5,), stride=(1,), padding=(2,), bias=False, padding_mode=circular)
#>         (relu): ReLU(inplace=True)
#>       )
#>       (2): ResBlock(
#>         (bn1): BatchNorm1d(256, eps=1e-05, momentum=0.1, affine=True, track_running_stats=True)
#>         (bn2): BatchNorm1d(256, eps=1e-05, momentum=0.1, affine=True, track_running_stats=True)
#>         (conv1): Conv1d(256, 256, kernel_size=(5,), stride=(1,), padding=(2,), bias=False, padding_mode=circular)
#>         (conv2): Conv1d(256, 256, kernel_size=(5,), stride=(1,), padding=(2,), bias=False, padding_mode=circular)
#>         (relu): ReLU(inplace=True)
#>       )
#>       (3): BatchNorm1d(256, eps=1e-05, momentum=0.1, affine=True, track_running_stats=True)
#>       (4): ReLU(inplace=True)
#>       (5): Downsample()
#>     )
#>     (layer4): Sequential(
#>       (0): Conv1d(256, 512, kernel_size=(5,), stride=(1,), padding=(2,), bias=False, padding_mode=circular)
#>       (1): ResBlock(
#>         (bn1): BatchNorm1d(512, eps=1e-05, momentum=0.1, affine=True, track_running_stats=True)
#>         (bn2): BatchNorm1d(512, eps=1e-05, momentum=0.1, affine=True, track_running_stats=True)
#>         (conv1): Conv1d(512, 512, kernel_size=(5,), stride=(1,), padding=(2,), bias=False, padding_mode=circular)
#>         (conv2): Conv1d(512, 512, kernel_size=(5,), stride=(1,), padding=(2,), bias=False, padding_mode=circular)
#>         (relu): ReLU(inplace=True)
#>       )
#>       (2): ResBlock(
#>         (bn1): BatchNorm1d(512, eps=1e-05, momentum=0.1, affine=True, track_running_stats=True)
#>         (bn2): BatchNorm1d(512, eps=1e-05, momentum=0.1, affine=True, track_running_stats=True)
#>         (conv1): Conv1d(512, 512, kernel_size=(5,), stride=(1,), padding=(2,), bias=False, padding_mode=circular)
#>         (conv2): Conv1d(512, 512, kernel_size=(5,), stride=(1,), padding=(2,), bias=False, padding_mode=circular)
#>         (relu): ReLU(inplace=True)
#>       )
#>       (3): BatchNorm1d(512, eps=1e-05, momentum=0.1, affine=True, track_running_stats=True)
#>       (4): ReLU(inplace=True)
#>       (5): Downsample()
#>     )
#>     (layer5): Sequential(
#>       (0): Conv1d(512, 1024, kernel_size=(5,), stride=(1,), padding=(2,), bias=False, padding_mode=circular)
#>       (1): BatchNorm1d(1024, eps=1e-05, momentum=0.1, affine=True, track_running_stats=True)
#>       (2): ReLU(inplace=True)
#>       (3): Downsample()
#>     )
#>   )
#>   (classifier): EvaClassifier(
#>     (linear1): Linear(in_features=1024, out_features=512, bias=True)
#>     (linear2): Linear(in_features=512, out_features=4, bias=True)
#>   )
#> )
#>  signature: (*args, **kwargs)
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
