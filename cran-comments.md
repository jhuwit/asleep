## R CMD check results

0 errors | 0 warnings | 1 note

* checking for future file timestamps ... NOTE
  unable to verify current time

  This note is due to the time server being unreachable during the local check.

## Changes in this version

* `sl_write_csv()` formats time stamps about five times faster and with much
  less memory, and writes the CSV in chunks (new `chunk_size` argument,
  default 1e6 rows). The file written is identical to the previous version.

## Reverse dependencies

We checked 1 reverse dependency (actisomni) with R CMD check --as-cran
against this version.

 * We saw 0 new problems
 * We failed to check 0 packages
