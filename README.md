
<!-- README.md is generated from README.Rmd. Please edit that file -->

# stepcount

<!-- badges: start -->

[![R-CMD-check](https://github.com/jhuwit/asleep/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/jhuwit/asleep/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/jhuwit/asleep/graph/badge.svg)](https://app.codecov.io/gh/jhuwit/asleep)
<!-- badges: end -->

The goal of `asleep` is to wrap up the
<https://github.com/OxWearables/asleep> algorithm.

# Installation

## Install `asleep` Python Module

See <https://github.com/OxWearables/asleep?tab=readme-ov-file#install>
for how to install the `asleep` python module.

In `R`, you can do this via:

``` r
envname = "asleep"
reticulate::conda_create(envname = envname, 
                         python_version = "3.8")
reticulate::use_condaenv(envname)
reticulate::py_install(c("asleep", "argparse", "numpy", "pandas"), 
                       envname = envname,
                       method = "conda",
                       python_version = "3.8",
                       pip = TRUE)
```

Once this is finished, you should be able to check this via:

``` r
envname = "asleep"
reticulate::use_condaenv(envname)
asleep::have_asleep()
```

# Usage

## Running `asleep` (file)

The main function is `asleep::asleep`, which takes can take in a file
directly:

``` r
library(asleep)
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
library(ggplot2)
#> Warning: package 'ggplot2' was built under R version 4.4.1
library(tidyr)
file = system.file("extdata/example_sleep.csv.gz", package = "asleep")
if (asleep_check()) {
  out = asleep(file = file)
}
#> Checking Data
#> Parsing raw data
#> Lowpass filter...Skipping lowpass filter: data sample rate 30 too low for cutoff rate 20
#> Lowpass filter... Done! (0.00s)
#> Gravity calibration...Gravity calibration... Done! (0.06s)
#> Resampling...Resampling... Done! (0.16s)
#> {'WearTime(days)': 0.1666662808564815, 'NonwearTime(days)': 0.0, 'NumNonwearEpisodes': 0}
#> Time shift applied: 0 hours
#> Raw data file saved to: /private/var/folders/1s/wrtqcpxn685_zk570bnx9_rr0000gr/T/Rtmpxfoupg/file1336f44ac26c8/raw.csv
#> Info data file saved to: /private/var/folders/1s/wrtqcpxn685_zk570bnx9_rr0000gr/T/Rtmpxfoupg/file1336f44ac26c8/info.json
#>                            time         x         y         z  non_wear
#> 0 2000-01-04 20:00:00.000000000 -0.704000  0.413000 -0.540000     False
#> 1 2000-01-04 20:00:00.033333333 -0.720795  0.419000 -0.561667     False
#> 2 2000-01-04 20:00:00.066666666 -0.665154  0.428846 -0.578590     False
#> 3 2000-01-04 20:00:00.100000000 -0.698000  0.434000 -0.525000     False
#> 4 2000-01-04 20:00:00.133333333 -0.674051  0.417308 -0.575385     False
#> Transforming data for model input
#> Data2model file saved to: /private/var/folders/1s/wrtqcpxn685_zk570bnx9_rr0000gr/T/Rtmpxfoupg/file1336f44ac26c8/data2model.npy
#> Times file saved to: /private/var/folders/1s/wrtqcpxn685_zk570bnx9_rr0000gr/T/Rtmpxfoupg/file1336f44ac26c8/times.npy
#> Non-wear file saved to: /private/var/folders/1s/wrtqcpxn685_zk570bnx9_rr0000gr/T/Rtmpxfoupg/file1336f44ac26c8/non_wear.npy
#> Data shape for data2model: (480, 3, 900)
#> Data shape for times: (480,)
#> Data shape for nonwear: (480,)
#> Detecting sleep windows
#> prediction set sample count: 480
#> Using local /Users/johnmuschelli/Library/Caches/org.R-project.R/R/reticulate/uv/cache/archive-v0/sIQv86OXvoD56R67KvlDd/lib/python3.8/site-packages/asleep/torch_hub_cache/OxWearables_ssl-wearables_v1.0.0
#> (480,)
#> (array([0., 2., 3.]), array([ 79,  45, 356]))
#> Running SleepNet
#> pytorch device defaulting to 'cpu'
#> setting up cnn
#> access remote repo
#> 1
#> Total sample count : 355
#> Save predictions to /private/var/folders/1s/wrtqcpxn685_zk570bnx9_rr0000gr/T/Rtmpxfoupg/file1336f44ac26c8/y_pred.npy
#> Save prediction probs to /private/var/folders/1s/wrtqcpxn685_zk570bnx9_rr0000gr/T/Rtmpxfoupg/file1336f44ac26c8/pred_prob.npy
#> Time used 8.065661191940308
#> Mapping SleepNet predictions back to original time series
#> Generating predictions dataframe
#> Generating sleep block df and indicate the longest block per day
#> Generating daily summary statistics
#> Summary saved to: /private/var/folders/1s/wrtqcpxn685_zk570bnx9_rr0000gr/T/Rtmpxfoupg/file1336f44ac26c8/summary.json
#> Creating outputs
```

Let’s see inside the output, which is a list of values, namely a
`data.frame` of outputs:

``` r
names(out)
#>  [1] "predictions"        "sleep_windows"      "sleep_windows_long"
#>  [4] "day_summary"        "summary"            "paths"             
#>  [7] "output_data"        "output_model"       "output_windows"    
#> [10] "output_sleep"
str(out)
#> List of 10
#>  $ predictions       :'data.frame':  480 obs. of  4 variables:
#>   ..$ time       : POSIXct[1:480], format: "2000-01-04 15:00:00" "2000-01-04 15:00:30" ...
#>   ..$ sleep_wake : chr [1:480] "wake" "wake" "wake" "wake" ...
#>   ..$ sleep_stage: chr [1:480] "wake" "wake" "wake" "wake" ...
#>   ..$ raw_label  : num [1:480] 0 0 0 0 0 0 0 0 0 0 ...
#>  $ sleep_windows     :'data.frame':  1 obs. of  6 variables:
#>   ..$ start           : POSIXct[1:1], format: "2000-01-04 16:02:00"
#>   ..$ end             : POSIXct[1:1], format: "2000-01-04 18:59:30"
#>   ..$ interval_start  : POSIXct[1:1], format: "2000-01-04 07:00:00"
#>   ..$ interval_end    : POSIXct[1:1], format: "2000-01-05 06:59:59"
#>   ..$ wear_duration_H : num 4
#>   ..$ is_longest_block: logi TRUE
#>   ..- attr(*, "pandas.index")=RangeIndex(start=0, stop=1, step=1)
#>  $ sleep_windows_long:'data.frame':  1 obs. of  2 variables:
#>   ..$ start: POSIXct[1:1], format: "2000-01-04 16:02:00"
#>   ..$ end  : POSIXct[1:1], format: "2000-01-04 18:59:30"
#>   ..- attr(*, "pandas.index")=RangeIndex(start=0, stop=1, step=1)
#>  $ day_summary       :'data.frame':  1 obs. of  183 variables:
#>   ..$ start_day       : chr "2000-01-04"
#>   ..$ day_of_week     : num 1
#>   ..$ wear_duration_H : num 4
#>   ..$ is_weekend      : logi FALSE
#>   ..$ sol_min         : num 9
#>   ..$ tst_min         : num 156
#>   ..$ waso_min        : num 14
#>   ..$ reml_min        : num 31.5
#>   ..$ se_perc         : num 0.874
#>   ..$ wake_min        : num 22.5
#>   ..$ n1_min          : num 26.5
#>   ..$ n2_min          : num 50
#>   ..$ n3_min          : num 75
#>   ..$ nrem_min        : num 152
#>   ..$ rem_min         : num 4
#>   ..$ 0_hour_wake_min : num 0
#>   ..$ 0_hour_n1_min   : num 0
#>   ..$ 0_hour_n2_min   : num 0
#>   ..$ 0_hour_n3_min   : num 0
#>   ..$ 0_hour_nrem_min : num 0
#>   ..$ 0_hour_rem_min  : num 0
#>   ..$ 0_hour_tst_min  : num 0
#>   ..$ 1_hour_wake_min : num 0
#>   ..$ 1_hour_n1_min   : num 0
#>   ..$ 1_hour_n2_min   : num 0
#>   ..$ 1_hour_n3_min   : num 0
#>   ..$ 1_hour_nrem_min : num 0
#>   ..$ 1_hour_rem_min  : num 0
#>   ..$ 1_hour_tst_min  : num 0
#>   ..$ 2_hour_wake_min : num 0
#>   ..$ 2_hour_n1_min   : num 0
#>   ..$ 2_hour_n2_min   : num 0
#>   ..$ 2_hour_n3_min   : num 0
#>   ..$ 2_hour_nrem_min : num 0
#>   ..$ 2_hour_rem_min  : num 0
#>   ..$ 2_hour_tst_min  : num 0
#>   ..$ 3_hour_wake_min : num 0
#>   ..$ 3_hour_n1_min   : num 0
#>   ..$ 3_hour_n2_min   : num 0
#>   ..$ 3_hour_n3_min   : num 0
#>   ..$ 3_hour_nrem_min : num 0
#>   ..$ 3_hour_rem_min  : num 0
#>   ..$ 3_hour_tst_min  : num 0
#>   ..$ 4_hour_wake_min : num 0
#>   ..$ 4_hour_n1_min   : num 0
#>   ..$ 4_hour_n2_min   : num 0
#>   ..$ 4_hour_n3_min   : num 0
#>   ..$ 4_hour_nrem_min : num 0
#>   ..$ 4_hour_rem_min  : num 0
#>   ..$ 4_hour_tst_min  : num 0
#>   ..$ 5_hour_wake_min : num 0
#>   ..$ 5_hour_n1_min   : num 0
#>   ..$ 5_hour_n2_min   : num 0
#>   ..$ 5_hour_n3_min   : num 0
#>   ..$ 5_hour_nrem_min : num 0
#>   ..$ 5_hour_rem_min  : num 0
#>   ..$ 5_hour_tst_min  : num 0
#>   ..$ 6_hour_wake_min : num 0
#>   ..$ 6_hour_n1_min   : num 0
#>   ..$ 6_hour_n2_min   : num 0
#>   ..$ 6_hour_n3_min   : num 0
#>   ..$ 6_hour_nrem_min : num 0
#>   ..$ 6_hour_rem_min  : num 0
#>   ..$ 6_hour_tst_min  : num 0
#>   ..$ 7_hour_wake_min : num 0
#>   ..$ 7_hour_n1_min   : num 0
#>   ..$ 7_hour_n2_min   : num 0
#>   ..$ 7_hour_n3_min   : num 0
#>   ..$ 7_hour_nrem_min : num 0
#>   ..$ 7_hour_rem_min  : num 0
#>   ..$ 7_hour_tst_min  : num 0
#>   ..$ 8_hour_wake_min : num 0
#>   ..$ 8_hour_n1_min   : num 0
#>   ..$ 8_hour_n2_min   : num 0
#>   ..$ 8_hour_n3_min   : num 0
#>   ..$ 8_hour_nrem_min : num 0
#>   ..$ 8_hour_rem_min  : num 0
#>   ..$ 8_hour_tst_min  : num 0
#>   ..$ 9_hour_wake_min : num 0
#>   ..$ 9_hour_n1_min   : num 0
#>   ..$ 9_hour_n2_min   : num 0
#>   ..$ 9_hour_n3_min   : num 0
#>   ..$ 9_hour_nrem_min : num 0
#>   ..$ 9_hour_rem_min  : num 0
#>   ..$ 9_hour_tst_min  : num 0
#>   ..$ 10_hour_wake_min: num 0
#>   ..$ 10_hour_n1_min  : num 0
#>   ..$ 10_hour_n2_min  : num 0
#>   ..$ 10_hour_n3_min  : num 0
#>   ..$ 10_hour_nrem_min: num 0
#>   ..$ 10_hour_rem_min : num 0
#>   ..$ 10_hour_tst_min : num 0
#>   ..$ 11_hour_wake_min: num 0
#>   ..$ 11_hour_n1_min  : num 0
#>   ..$ 11_hour_n2_min  : num 0
#>   ..$ 11_hour_n3_min  : num 0
#>   ..$ 11_hour_nrem_min: num 0
#>   ..$ 11_hour_rem_min : num 0
#>   ..$ 11_hour_tst_min : num 0
#>   .. [list output truncated]
#>   ..- attr(*, "pandas.index")=RangeIndex(start=0, stop=1, step=1)
#>  $ summary           : NULL
#>  $ paths             :List of 7
#>   ..$ raw_data_path   : chr "/private/var/folders/1s/wrtqcpxn685_zk570bnx9_rr0000gr/T/Rtmpxfoupg/file1336f44ac26c8/raw.csv"
#>   ..$ info_data_path  : chr "/private/var/folders/1s/wrtqcpxn685_zk570bnx9_rr0000gr/T/Rtmpxfoupg/file1336f44ac26c8/info.json"
#>   ..$ data2model_path : chr "/private/var/folders/1s/wrtqcpxn685_zk570bnx9_rr0000gr/T/Rtmpxfoupg/file1336f44ac26c8/data2model.npy"
#>   ..$ times_path      : chr "/private/var/folders/1s/wrtqcpxn685_zk570bnx9_rr0000gr/T/Rtmpxfoupg/file1336f44ac26c8/times.npy"
#>   ..$ non_wear_path   : chr "/private/var/folders/1s/wrtqcpxn685_zk570bnx9_rr0000gr/T/Rtmpxfoupg/file1336f44ac26c8/non_wear.npy"
#>   ..$ day_summary_path: chr "/private/var/folders/1s/wrtqcpxn685_zk570bnx9_rr0000gr/T/Rtmpxfoupg/file1336f44ac26c8/day_summary.csv"
#>   ..$ output_json_path: chr "/private/var/folders/1s/wrtqcpxn685_zk570bnx9_rr0000gr/T/Rtmpxfoupg/file1336f44ac26c8/summary.json"
#>  $ output_data       :List of 2
#>   ..$ :'data.frame': 432000 obs. of  5 variables:
#>   .. ..$ time    : POSIXct[1:432000], format: "2000-01-04 15:00:00.000" "2000-01-04 15:00:00.033" ...
#>   .. ..$ x       : num [1:432000] -0.704 -0.721 -0.665 -0.698 -0.674 ...
#>   .. ..$ y       : num [1:432000] 0.413 0.419 0.429 0.434 0.417 ...
#>   .. ..$ z       : num [1:432000] -0.54 -0.562 -0.579 -0.525 -0.575 ...
#>   .. ..$ non_wear: logi [1:432000] FALSE FALSE FALSE FALSE FALSE FALSE ...
#>   .. ..- attr(*, "pandas.index")=RangeIndex(start=0, stop=432000, step=1)
#>   ..$ :List of 17
#>   .. ..$ Filename             : chr "/Library/Frameworks/R.framework/Versions/4.4-x86_64/Resources/library/asleep/extdata/example_sleep.csv.gz"
#>   .. ..$ Device               : chr ".csv"
#>   .. ..$ Filesize(MB)         : num 3
#>   .. ..$ SampleRate           : int 30
#>   .. ..$ LowpassOK            : int 0
#>   .. ..$ CalibNumSamples      : int 1061
#>   .. ..$ CalibErrorBefore(mg) : num 15.1
#>   .. ..$ CalibErrorAfter(mg)  : num 15.1
#>   .. ..$ CalibNumIters        : int 0
#>   .. ..$ CalibOK              : int 0
#>   .. ..$ ResampleRate         : int 30
#>   .. ..$ NumTicksAfterResample: int 432000
#>   .. ..$ WearTime(days)       : num 0.167
#>   .. ..$ NonwearTime(days)    : num 0
#>   .. ..$ NumNonwearEpisodes   : int 0
#>   .. ..$ StartTime            : chr "2000-01-04 20:00:00"
#>   .. ..$ EndTime              : chr "2000-01-04 23:59:59"
#>  $ output_model      :List of 3
#>   ..$ : num [1:480, 1:3, 1:900] -0.704 -0.689 -0.625 -0.736 -0.663 -0.83 -0.569 -0.408 0.331 0.367 ...
#>   ..$ : POSIXct[1:480], format: "2000-01-04 15:00:00" "2000-01-04 15:00:30" ...
#>   ..$ : logi [1:480(1d)] FALSE FALSE FALSE FALSE FALSE FALSE ...
#>  $ output_windows    :List of 5
#>   ..$ : num [1:480(1d)] 0 0 0 0 0 0 0 0 0 0 ...
#>   ..$ :'data.frame': 1 obs. of  5 variables:
#>   .. ..$ start          : POSIXct[1:1], format: "2000-01-04 16:02:00"
#>   .. ..$ end            : POSIXct[1:1], format: "2000-01-04 18:59:30"
#>   .. ..$ interval_start : POSIXct[1:1], format: "2000-01-04 07:00:00"
#>   .. ..$ interval_end   : POSIXct[1:1], format: "2000-01-05 06:59:59"
#>   .. ..$ wear_duration_H: num 4
#>   .. ..- attr(*, "pandas.index")=RangeIndex(start=0, stop=1, step=1)
#>   ..$ :'data.frame': 1 obs. of  2 variables:
#>   .. ..$ start: POSIXct[1:1], format: "2000-01-04 16:02:00"
#>   .. ..$ end  : POSIXct[1:1], format: "2000-01-04 18:59:30"
#>   .. ..- attr(*, "pandas.index")=RangeIndex(start=0, stop=1, step=1)
#>   ..$ : num [1:355, 1:3, 1:900] 0.683 0.009 0.009 0.009 0.009 0.009 0.009 0.009 0.009 0.009 ...
#>   ..$ : num [1:355(1d)] 0 0 0 0 0 0 0 0 0 0 ...
#>  $ output_sleep      :List of 2
#>   ..$ : num [1:355(1d)] 0 0 0 0 0 0 0 0 0 0 ...
#>   ..$ : num [1:355(1d)] 0 0 0 0 0 0 0 0 0 0 ...
head(out$predictions)
#>                  time sleep_wake sleep_stage raw_label
#> 1 2000-01-04 15:00:00       wake        wake         0
#> 2 2000-01-04 15:00:30       wake        wake         0
#> 3 2000-01-04 15:01:00       wake        wake         0
#> 4 2000-01-04 15:01:30       wake        wake         0
#> 5 2000-01-04 15:02:00       wake        wake         0
#> 6 2000-01-04 15:02:30       wake        wake         0
head(out$summary)
#> NULL
head(out$day_summary)
#>    start_day day_of_week wear_duration_H is_weekend sol_min tst_min waso_min
#> 1 2000-01-04           1               4      FALSE       9   155.5       14
#>   reml_min   se_perc wake_min n1_min n2_min n3_min nrem_min rem_min
#> 1     31.5 0.8735955     22.5   26.5     50     75    151.5       4
#>   0_hour_wake_min 0_hour_n1_min 0_hour_n2_min 0_hour_n3_min 0_hour_nrem_min
#> 1               0             0             0             0               0
#>   0_hour_rem_min 0_hour_tst_min 1_hour_wake_min 1_hour_n1_min 1_hour_n2_min
#> 1              0              0               0             0             0
#>   1_hour_n3_min 1_hour_nrem_min 1_hour_rem_min 1_hour_tst_min 2_hour_wake_min
#> 1             0               0              0              0               0
#>   2_hour_n1_min 2_hour_n2_min 2_hour_n3_min 2_hour_nrem_min 2_hour_rem_min
#> 1             0             0             0               0              0
#>   2_hour_tst_min 3_hour_wake_min 3_hour_n1_min 3_hour_n2_min 3_hour_n3_min
#> 1              0               0             0             0             0
#>   3_hour_nrem_min 3_hour_rem_min 3_hour_tst_min 4_hour_wake_min 4_hour_n1_min
#> 1               0              0              0               0             0
#>   4_hour_n2_min 4_hour_n3_min 4_hour_nrem_min 4_hour_rem_min 4_hour_tst_min
#> 1             0             0               0              0              0
#>   5_hour_wake_min 5_hour_n1_min 5_hour_n2_min 5_hour_n3_min 5_hour_nrem_min
#> 1               0             0             0             0               0
#>   5_hour_rem_min 5_hour_tst_min 6_hour_wake_min 6_hour_n1_min 6_hour_n2_min
#> 1              0              0               0             0             0
#>   6_hour_n3_min 6_hour_nrem_min 6_hour_rem_min 6_hour_tst_min 7_hour_wake_min
#> 1             0               0              0              0               0
#>   7_hour_n1_min 7_hour_n2_min 7_hour_n3_min 7_hour_nrem_min 7_hour_rem_min
#> 1             0             0             0               0              0
#>   7_hour_tst_min 8_hour_wake_min 8_hour_n1_min 8_hour_n2_min 8_hour_n3_min
#> 1              0               0             0             0             0
#>   8_hour_nrem_min 8_hour_rem_min 8_hour_tst_min 9_hour_wake_min 9_hour_n1_min
#> 1               0              0              0               0             0
#>   9_hour_n2_min 9_hour_n3_min 9_hour_nrem_min 9_hour_rem_min 9_hour_tst_min
#> 1             0             0               0              0              0
#>   10_hour_wake_min 10_hour_n1_min 10_hour_n2_min 10_hour_n3_min
#> 1                0              0              0              0
#>   10_hour_nrem_min 10_hour_rem_min 10_hour_tst_min 11_hour_wake_min
#> 1                0               0               0                0
#>   11_hour_n1_min 11_hour_n2_min 11_hour_n3_min 11_hour_nrem_min 11_hour_rem_min
#> 1              0              0              0                0               0
#>   11_hour_tst_min 12_hour_wake_min 12_hour_n1_min 12_hour_n2_min 12_hour_n3_min
#> 1               0                0              0              0              0
#>   12_hour_nrem_min 12_hour_rem_min 12_hour_tst_min 13_hour_wake_min
#> 1                0               0               0                0
#>   13_hour_n1_min 13_hour_n2_min 13_hour_n3_min 13_hour_nrem_min 13_hour_rem_min
#> 1              0              0              0                0               0
#>   13_hour_tst_min 14_hour_wake_min 14_hour_n1_min 14_hour_n2_min 14_hour_n3_min
#> 1               0                0              0              0              0
#>   14_hour_nrem_min 14_hour_rem_min 14_hour_tst_min 15_hour_wake_min
#> 1                0               0               0                0
#>   15_hour_n1_min 15_hour_n2_min 15_hour_n3_min 15_hour_nrem_min 15_hour_rem_min
#> 1              0              0              0                0               0
#>   15_hour_tst_min 16_hour_wake_min 16_hour_n1_min 16_hour_n2_min 16_hour_n3_min
#> 1               0                0              0              0              0
#>   16_hour_nrem_min 16_hour_rem_min 16_hour_tst_min 17_hour_wake_min
#> 1                0               0               0                0
#>   17_hour_n1_min 17_hour_n2_min 17_hour_n3_min 17_hour_nrem_min 17_hour_rem_min
#> 1              0              0              0                0               0
#>   17_hour_tst_min 18_hour_wake_min 18_hour_n1_min 18_hour_n2_min 18_hour_n3_min
#> 1               0                0              0              0              0
#>   18_hour_nrem_min 18_hour_rem_min 18_hour_tst_min 19_hour_wake_min
#> 1                0               0               0                0
#>   19_hour_n1_min 19_hour_n2_min 19_hour_n3_min 19_hour_nrem_min 19_hour_rem_min
#> 1              0              0              0                0               0
#>   19_hour_tst_min 20_hour_wake_min 20_hour_n1_min 20_hour_n2_min 20_hour_n3_min
#> 1               0                0              0              0              0
#>   20_hour_nrem_min 20_hour_rem_min 20_hour_tst_min 21_hour_wake_min
#> 1                0               0               0               11
#>   21_hour_n1_min 21_hour_n2_min 21_hour_n3_min 21_hour_nrem_min 21_hour_rem_min
#> 1           12.5           24.5            8.5             45.5             1.5
#>   21_hour_tst_min 22_hour_wake_min 22_hour_n1_min 22_hour_n2_min 22_hour_n3_min
#> 1              47               11           12.5           12.5           21.5
#>   22_hour_nrem_min 22_hour_rem_min 22_hour_tst_min 23_hour_wake_min
#> 1             46.5             2.5              49              0.5
#>   23_hour_n1_min 23_hour_n2_min 23_hour_n3_min 23_hour_nrem_min 23_hour_rem_min
#> 1            1.5             13             45             59.5               0
#>   23_hour_tst_min
#> 1            59.5
```

The main caveat is that `asleep` is very precise in the format of the
data, primarily it must have the columns `time`, `x`, `y`, and `z` in
the data.

## Running `asleep` (data frame)

Alternatively, you can pass out a `data.frame`, rename the columns to
what you need them to be and then run `asleep` on that:

``` r
df = readr::read_csv(file)
#> Rows: 432000 Columns: 4
#> ── Column specification ────────────────────────────────────────────────────────
#> Delimiter: ","
#> dbl  (3): x, y, z
#> dttm (1): time
#> 
#> ℹ Use `spec()` to retrieve the full column specification for this data.
#> ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.
head(df)
#> # A tibble: 6 × 4
#>   time                         x     y      z
#>   <dttm>                   <dbl> <dbl>  <dbl>
#> 1 2000-01-04 20:00:00.000 -0.704 0.413 -0.54 
#> 2 2000-01-04 20:00:00.031 -0.721 0.419 -0.562
#> 3 2000-01-04 20:00:00.067 -0.665 0.429 -0.579
#> 4 2000-01-04 20:00:00.100 -0.698 0.434 -0.525
#> 5 2000-01-04 20:00:00.133 -0.674 0.417 -0.575
#> 6 2000-01-04 20:00:00.167 -0.707 0.412 -0.538
out_df = asleep(file = df)
#> Checking Data
#> Writing file to CSV...
#> Parsing raw data
#> Lowpass filter...Skipping lowpass filter: data sample rate 30 too low for cutoff rate 20
#> Lowpass filter... Done! (0.00s)
#> Gravity calibration...Gravity calibration... Done! (0.07s)
#> Resampling...Resampling... Done! (0.19s)
#> {'WearTime(days)': 0.1666662808564815, 'NonwearTime(days)': 0.0, 'NumNonwearEpisodes': 0}
#> Time shift applied: 0 hours
#> Raw data file saved to: /private/var/folders/1s/wrtqcpxn685_zk570bnx9_rr0000gr/T/Rtmp7U210K/file1345d256ad843/raw.csv
#> Info data file saved to: /private/var/folders/1s/wrtqcpxn685_zk570bnx9_rr0000gr/T/Rtmp7U210K/file1345d256ad843/info.json
#>                            time         x         y         z  non_wear
#> 0 2000-01-04 20:00:00.000000000 -0.704000  0.413000 -0.540000     False
#> 1 2000-01-04 20:00:00.033333333 -0.720795  0.419000 -0.561667     False
#> 2 2000-01-04 20:00:00.066666666 -0.665154  0.428846 -0.578590     False
#> 3 2000-01-04 20:00:00.100000000 -0.698000  0.434000 -0.525000     False
#> 4 2000-01-04 20:00:00.133333333 -0.674051  0.417308 -0.575385     False
#> Transforming data for model input
#> Data2model file saved to: /private/var/folders/1s/wrtqcpxn685_zk570bnx9_rr0000gr/T/Rtmp7U210K/file1345d256ad843/data2model.npy
#> Times file saved to: /private/var/folders/1s/wrtqcpxn685_zk570bnx9_rr0000gr/T/Rtmp7U210K/file1345d256ad843/times.npy
#> Non-wear file saved to: /private/var/folders/1s/wrtqcpxn685_zk570bnx9_rr0000gr/T/Rtmp7U210K/file1345d256ad843/non_wear.npy
#> Data shape for data2model: (480, 3, 900)
#> Data shape for times: (480,)
#> Data shape for nonwear: (480,)
#> Detecting sleep windows
#> prediction set sample count: 480
#> Using local /Users/johnmuschelli/Library/Caches/org.R-project.R/R/reticulate/uv/cache/archive-v0/sIQv86OXvoD56R67KvlDd/lib/python3.8/site-packages/asleep/torch_hub_cache/OxWearables_ssl-wearables_v1.0.0
#> (480,)
#> (array([0., 2., 3.]), array([ 79,  45, 356]))
#> Running SleepNet
#> pytorch device defaulting to 'cpu'
#> setting up cnn
#> access remote repo
#> 1
#> Total sample count : 355
#> Save predictions to /private/var/folders/1s/wrtqcpxn685_zk570bnx9_rr0000gr/T/Rtmp7U210K/file1345d256ad843/y_pred.npy
#> Save prediction probs to /private/var/folders/1s/wrtqcpxn685_zk570bnx9_rr0000gr/T/Rtmp7U210K/file1345d256ad843/pred_prob.npy
#> Time used 7.724024057388306
#> Mapping SleepNet predictions back to original time series
#> Generating predictions dataframe
#> Generating sleep block df and indicate the longest block per day
#> Generating daily summary statistics
#> Summary saved to: /private/var/folders/1s/wrtqcpxn685_zk570bnx9_rr0000gr/T/Rtmp7U210K/file1345d256ad843/summary.json
#> Creating outputs
```

Which gives same output for this data:

``` r
all.equal(out[c("predictions", "summary", "day_summary")],
          out_df[c("predictions", "summary", "day_summary")])
#> [1] TRUE
```
