# Read a Data Set for `asleep`

Read a Data Set for `asleep`

## Usage

``` r
sl_read(file, resample_hz = "uniform", keep_pandas = FALSE)
```

## Arguments

- file:

  path to the file for reading

- resample_hz:

  Target frequency (Hz) to resample the signal. If "uniform", use the
  implied frequency (use this option to fix any device sampling errors).
  Pass `NULL` to disable. Defaults to "uniform".

- keep_pandas:

  do not convert the data to a `data.frame` and keep as a `pandas`
  `data.frame`

## Value

A list of the data and information about the data

## Note

The data `P30_wrist100` is from
<https://ora.ox.ac.uk/objects/uuid:19d3cb34-e2b3-4177-91b6-1bad0e0163e7>,
where we took the first 180,000 rows, the first 30 minutes of data from
that participant as an example.

## Examples

``` r
# \donttest{
file = system.file("extdata/example_sleep.csv.gz", package = "asleep")
if (asleep_check()) {
  out = sl_read(file, resample_hz = FALSE)
}
# }
```
