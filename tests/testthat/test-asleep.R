remove_file_info = function(result) {
  result$info$Filename = result$info$`Filesize(MB)` = NULL
  result
}
sleep_check_result = function() {
  res = try({suppressWarnings(asleep_check())})
  if (inherits(res, "try-error")) {
    res = FALSE
  }
  res
}

# model_path = file.path(
#   tempdir(),
#   "ssl.joblib.lzma")

testthat::test_that("asleep model works", {
  testthat::skip_if_offline()
  # testthat::skip_if_not(
  #   identical(Sys.getenv("ASLEEP_RUN_INTEGRATION_TESTS"), "true")
  # )
  file = system.file("extdata/example_sleep.csv.gz", package = "asleep")
  testthat::skip_if_not(sleep_check_result())
  if (sleep_check_result()) {
    # asleep::sl_download_model(
    #   model_path = model_path
    # )
    res = try({asleep(file = file, verbose = 2L, force_download = TRUE)})
    if (inherits(res, "try-error") &&
        grepl("urllib.error", res)) {
      testthat::skip("Python urllib error, skipping test")
    }
    if (inherits(res, "try-error") &&
        grepl("out of memory", res)) {
      testthat::skip("Out of Memory, skipping test")
    }
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
    testthat::expect_s3_class(res$predictions, "data.frame")
    testthat::expect_gt(nrow(res$predictions), 0)
    testthat::expect_s3_class(res$sleep_windows, "data.frame")
    testthat::expect_s3_class(res$day_summary, "data.frame")

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
