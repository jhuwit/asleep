## R CMD check results

0 errors | 0 warnings | 1 note

* checking for future file timestamps ... NOTE
  unable to verify current time

  This note is due to the time server being unreachable during the local check.

## Changes in this version

* Now requires the 'asleep' Python module (>= 0.5.0) from PyPI, declared
  through `reticulate::py_require()`.
* `asleep()` now passes a `sample_rate` to the Python module.

## Reverse dependencies

We checked 1 reverse dependency (actisomni) with R CMD check --as-cran
against this version.

 * We saw 0 new problems
 * We failed to check 0 packages
