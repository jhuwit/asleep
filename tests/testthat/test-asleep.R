remove_file_info = function(result) {
  result$info$Filename = result$info$`Filesize(MB)` = NULL
  result
}

model_path = file.path(
  tempdir(),
  "ssl.joblib.lzma")
asleep::sl_download_model(
  model_path = model_path
)

testthat::test_that("asleep model works", {
  file = system.file("extdata/P30_wrist100.csv.gz", package = "stepcount")
  testthat::skip_if_not(asleep_check())
  if (asleep_check()) {
    res = asleep(file = file, model_path = model_path)
    testthat::expect_true(is.null(res))

    model = sl_load_model(model_path = model_path,
                          as_python = TRUE)
  }
})


