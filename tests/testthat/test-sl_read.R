testthat::test_that("reading in a file works", {
  file = system.file("extdata/P30_wrist100.csv.gz", package = "stepcount")
  if (asleep_check()) {
    out = sl_read(file)
    testthat::expect_true(is.list(out))
    testthat::expect_named(out, c("data", "info"))
    testthat::expect_true(is.data.frame(out$data))
  }
})
