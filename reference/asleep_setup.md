# Check the `asleep` Python Module

Check the `asleep` Python Module

## Usage

``` r
have_asleep()

asleep_check(...)

asleep_version(...)
```

## Arguments

- ...:

  additional arguments to pass to
  [reticulate::py_list_packages](https://rstudio.github.io/reticulate/reference/py_list_packages.html)

## Value

A logical value indicating whether the `asleep` Python module is
available.

## Examples

``` r
# \donttest{
  if (have_asleep()) {
     asleep_version()
  }
#> [1] "0.5.0"
# }
```
