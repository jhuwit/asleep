remove_file_info = function(result) {
  result$info$Filename = result$info$`Filesize(MB)` = NULL
  result
}

# model_path = file.path(
#   tempdir(),
#   "ssl.joblib.lzma")

testthat::test_that("asleep model works", {
  file = system.file("extdata/example_sleep.csv.gz", package = "asleep")
  testthat::skip_if_not(suppressWarnings(asleep_check()))
  if (suppressWarnings(asleep_check())) {
    # asleep::sl_download_model(
    #   model_path = model_path
    # )
    res = asleep(file = file, verbose = 2L)
    testthat::expect_named(
      res,
      c("predictions", "times", "times_utc", "sleep_windows", "sleep_windows_long",
        "day_summary", "summary", "paths", "output_data", "output_model",
        "output_windows", "output_sleep")
    )
    testthat::expect_named(
      res$predictions,
      c("time", "sleep_wake", "sleep_stage", "raw_label")
    )
    # testthat::expect_true(is.null(res))

    # model = sl_load_model(model_path = model_path,
    #                       as_python = TRUE)
  }
})

testthat::test_that("asleep validates simple scalar arguments before running", {
  testthat::expect_error(
    suppressWarnings(asleep(file = tempfile(), time_shift = 0, verbose = FALSE)),
    "time_shift"
  )
  testthat::expect_error(
    suppressWarnings(asleep(file = tempfile(), min_wear_hours = -1, verbose = FALSE)),
    "min_wear_hours"
  )
})

testthat::test_that("summarize_daily_sleep creates overall and grouped summaries", {
  sdf = data.frame(
    day_of_week = c(0, 5),
    is_weekend = c(FALSE, TRUE),
    sleep_duration_H = c(7, 9),
    wear_duration_H = c(23, 24),
    awakenings = c(1, 3)
  )

  out = asleep:::summarize_daily_sleep(sdf)

  testthat::expect_s3_class(out, "data.frame")
  testthat::expect_true(all(
    c("overall", "Monday", "Saturday", "weekday", "weekend") %in% out$prefix
  ))
  testthat::expect_equal(
    out$sleep_duration_H_mean[out$prefix == "overall"],
    8
  )
  testthat::expect_false(any(grepl("wear_duration_H", names(out))))
})
