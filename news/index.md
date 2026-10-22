# Changelog

## asleep 0.4.0

- Now requires the `asleep` Python module version 0.5.0 or higher (from
  PyPI).
- [`asleep()`](https://jhuwit.github.io/asleep/reference/asleep.md) now
  passes `sample_rate` to `asleep`. If not specified, it uses
  `attr(file, "sample_rate")`; if neither is set, the sample rate is
  inferred.
- Times returned by
  [`asleep()`](https://jhuwit.github.io/asleep/reference/asleep.md) are
  the recorded clock times without a time zone; they are no longer
  shifted for non-UTC data or by the system time zone, and clock times
  in a daylight-saving gap are kept. For `data.frame` input,
  `attr(result, "tzone")` gives the time zone of `file$time`. `times`,
  `sleep_windows` and `sleep_windows_long` are now character clock times
  too; they were `POSIXct` that displayed in the system time zone.
- `dplyr` (\>= 1.2.0) is now in Imports;
  [`asleep()`](https://jhuwit.github.io/asleep/reference/asleep.md)
  always uses it. `lubridate` moved to Suggests.
- `sample_rate` no longer has to be an integer (e.g. GENEActiv 85.7 Hz).
- [`sl_write_csv()`](https://jhuwit.github.io/asleep/reference/sl_rename_data.md)
  writes time stamps to the microsecond; rounding to the millisecond
  made the sample interval of non-integer-rate data irregular.

## asleep 0.3.0

CRAN release: 2026-08-21

- Failing gracefully for asleep tests with internet and python out of
  memory.
- Added `py_require_asleep`.
- Removed pipe requirement.

## asleep 0.2.0

- Added `py_asleep` for python calling and execution inside environment.

## asleep 0.1.0

CRAN release: 2026-08-04

- Initial submission.
- Added all the functions and tests.
