# Load `asleep` Model for Sleep Window Detector

Load `asleep` Model for Sleep Window Detector

## Usage

``` r
sl_load_model(model_path = NULL, force_download = FALSE, as_python = TRUE)

sl_download_model(model_path, ...)
```

## Arguments

- model_path:

  the file path to the model. If on disk, this can be re-used and not
  re-downloaded. If `NULL`, will download to the temporary directory

- force_download:

  force a dof the model, even if it already exists at `model_path`

- as_python:

  Keep model object as a python object

- ...:

  for `sl_download_model`, additional arguments to pass to
  [`curl::curl_download()`](https://jeroen.r-universe.dev/curl/reference/curl_download.html)

## Value

A model from Python. `sl_download_model` returns a model file path.
