# Changelog

## asleep 0.4.0

- Now requires the `asleep` Python module version 0.5.0 or higher (from
  PyPI).
- [`asleep()`](https://jhuwit.github.io/asleep/reference/asleep.md) now
  passes `sample_rate` to `asleep`. If not specified, it uses
  `attr(file, "sample_rate")`; if neither is set, the sample rate is
  inferred.
- Added `tzone` argument to
  [`asleep()`](https://jhuwit.github.io/asleep/reference/asleep.md).

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
