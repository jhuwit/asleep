testthat::test_that("sl_rename_data accepts known timestamp spellings", {
  dat = data.frame(
    time = as.POSIXct("2024-01-01 00:00:00", tz = "UTC"),
    x = 1,
    y = 2,
    z = 3
  )

  out = sl_rename_data(dat)
  testthat::expect_named(out, c("time", "x", "y", "z"))
  testthat::expect_equal(out$x, 1)

  names(dat)[1] = "HEADER_TIME_STAMP"
  out = sl_rename_data(dat)
  testthat::expect_named(out, c("time", "x", "y", "z"))
})

testthat::test_that("sl_rename_data rejects data without required columns", {
  testthat::expect_error(
    sl_rename_data(data.frame(time = Sys.time(), x = 1, y = 2)),
    "all\\(c\\(\"X\", \"Y\", \"Z\", \"HEADER_TIMESTAMP\"\\)"
  )
  testthat::expect_error(
    sl_rename_data(list(x = 1)),
    "data is not a data frame"
  )
})

testthat::test_that("sl_write_csv normalizes columns and writes millisecond timestamps", {
  path = tempfile(fileext = ".csv")
  dat = data.frame(
    HEADER_TIMESTAMP = as.POSIXct("2024-01-01 00:00:00.123", tz = "UTC"),
    X = 1,
    Y = 2,
    Z = 3
  )

  out = sl_write_csv(dat, path = path)

  testthat::expect_equal(out, path)
  testthat::expect_true(file.exists(path))
  lines = readLines(path)
  testthat::expect_equal(lines[[1]], "time,x,y,z")
  testthat::expect_match(lines[[2]], "2024-01-01 00:00:00\\.12[0-9]")
})

testthat::test_that("transform_data_to_files writes data frames and keeps file inputs", {
  dat = data.frame(
    time = as.POSIXct("2024-01-01 00:00:00", tz = "UTC"),
    x = 1,
    y = 2,
    z = 3
  )

  out = asleep:::transform_data_to_files(dat, verbose = FALSE)
  testthat::expect_type(out, "list")
  testthat::expect_length(out, 1)
  testthat::expect_true(file.exists(out[[1]]))

  existing = tempfile(fileext = ".csv")
  writeLines("time,x,y,z\n2024-01-01 00:00:00,1,2,3", existing)
  out = asleep:::transform_data_to_files(existing, verbose = FALSE)
  testthat::expect_type(out, "list")
  testthat::expect_equal(unname(unlist(out)), existing)
  testthat::expect_equal(names(out), existing)

  out = asleep:::transform_data_to_files(list(dat), verbose = FALSE)
  testthat::expect_type(out, "list")
  testthat::expect_true(file.exists(out[[1]]))
  testthat::expect_true(isTRUE(attr(out[[1]], "remove_file")))
})

testthat::test_that("renamer replaces only exact column names", {
  dat = data.frame(old = 1, older = 2, keep = 3)
  out = asleep:::renamer(dat, old = "old", new = "new")

  testthat::expect_named(out, c("new", "older", "keep"))
  testthat::expect_error(
    asleep:::renamer(dat, old = c("old", "older"), new = "new")
  )
})
