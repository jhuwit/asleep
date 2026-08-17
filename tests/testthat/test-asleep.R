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

`$.asleep_fake_array` = function(x, name) {
  if (identical(name, "shape")) {
    return(attr(x, "shape"))
  }
  NULL
}

asleep_fake_array = function(x) {
  base::registerS3method(
    "$", "asleep_fake_array", `$.asleep_fake_array`,
    envir = asNamespace("asleep")
  )
  structure(x, class = c("asleep_fake_array", class(x)), shape = length(x))
}

`[[.asleep_fake_tuple` = function(x, index, ...) {
  unclass(x)[[index + 1L]]
}

asleep_fake_tuple = function(...) {
  base::registerS3method(
    "[[", "asleep_fake_tuple", `[[.asleep_fake_tuple`,
    envir = asNamespace("asleep")
  )
  structure(list(...), class = "asleep_fake_tuple")
}

`[[.asleep_fake_index` = function(x, index, ...) {
  unclass(x)[[index + 1L]]
}

`$.asleep_fake_dataframe` = function(x, name) {
  structure(unclass(x)[[name]], class = "asleep_fake_index")
}

asleep_fake_dataframe = function(x) {
  base::registerS3method(
    "[[", "asleep_fake_index", `[[.asleep_fake_index`,
    envir = asNamespace("asleep")
  )
  base::registerS3method(
    "$", "asleep_fake_dataframe", `$.asleep_fake_dataframe`,
    envir = asNamespace("asleep")
  )
  class(x) = c("asleep_fake_dataframe", class(x))
  x
}

skip_if_model_download_failed = function(result) {
  if (!inherits(result, "try-error")) {
    return(invisible())
  }

  network_error = grepl(
    paste0(
      "Unable to download|urllib|download|timed out|timeout|Could not resolve|",
      "HTTP Error|connection|network|SSL"
    ),
    as.character(result),
    ignore.case = TRUE
  )
  if (network_error) {
    testthat::skip(paste("Model download unavailable:", result))
  }
  invisible()
}

skip_if_memory_limited = function(result) {
  if (!inherits(result, "try-error")) {
    return(invisible())
  }

  error_message = paste(as.character(result), collapse = "\n")
  if (grepl(
    "out of memory|MPS backend|CUDA.*memory|memory allocation",
    error_message,
    ignore.case = TRUE
  )) {
    testthat::skip(paste("Insufficient accelerator memory:", error_message))
  }
  invisible()
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
    skip_if_model_download_failed(res)
    skip_if_memory_limited(res)
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

testthat::test_that("asleep completes with cached model assets without internet access", {
  times = asleep_fake_array(as.POSIXct(
    c("2024-01-01 22:00:00", "2024-01-01 22:01:00"), tz = "UTC"
  ))
  windows = asleep_fake_dataframe(data.frame(
    start = times[[1]], end = times[[2]] + 60,
    interval_start = times[[1]], interval_end = times[[2]] + 60
  ))
  day_summary = data.frame(
    wear_duration_H = 23, day_of_week = 0, is_weekend = FALSE,
    sleep_duration_H = 8
  )
  sleep_module = list(
    get_parsed_data = function(...) {
      asleep_fake_tuple(data.frame(time = times), list(device = "test"))
    },
    transform_data2model_input = function(...) {
      asleep_fake_tuple(
        asleep_fake_array(c(1, 2)), times, asleep_fake_array(c(FALSE, FALSE))
      )
    },
    get_sleep_windows = function(...) {
      asleep_fake_tuple(c(0L, 1L), windows, windows, c(1, 2), c(0L, 0L))
    },
    start_sleep_net = function(...) asleep_fake_tuple(c(0L, 1L), c(0L, 0L))
  )
  asleep_module = list(
    get_sleep = sleep_module,
    macros = list(
      SLEEPNET_BINARY_LABELS = list(get = function(x) c("wake", "sleep")[[x + 1L]]),
      SLEEPNET_LABELS = list(),
      SLEEPNET_THRE_CLASS_LABELS = list(get = function(x) c("wake", "sleep")[[x + 1L]])
    ),
    summary = list(
      generate_sleep_parameters = function(...) day_summary,
      summarize_daily_sleep = function(...) NULL
    ),
    `__path__` = asleep_fake_tuple(tempdir())
  )
  numpy = list(
    save = function(...) NULL,
    vectorize = function(fun) function(x) vapply(x, fun, character(1))
  )

  testthat::local_mocked_bindings(
    sl_download_models = function(force_download = FALSE) NULL,
    .package = "asleep"
  )
  testthat::local_mocked_bindings(
    import = function(module, convert = TRUE) {
      switch(module,
        "hydra.core" = list(global_hydra = list(
          GlobalHydra = list(instance = function() list(clear = function() NULL))
        )),
        "argparse" = list(Namespace = list()),
        "asleep" = asleep_module,
        "numpy" = numpy,
        "pandas" = list(),
        stop("unexpected module: ", module)
      )
    },
    py_to_r = function(x) {
      convert = function(x) {
        if (inherits(x, "asleep_fake_tuple")) {
          x = unclass(x)
        }
        if (inherits(x, "asleep_fake_dataframe")) {
          class(x) = setdiff(class(x), "asleep_fake_dataframe")
        }
        if (is.list(x) && !is.data.frame(x)) {
          x = lapply(x, convert)
        }
        x
      }
      convert(x)
    },
    .package = "reticulate"
  )

  input = tempfile(fileext = ".csv")
  writeLines("time,x,y,z\n2024-01-01 22:00:00,1,2,3", input)
  result = suppressMessages(asleep(input, outdir = tempfile(), verbose = 2L))

  testthat::expect_named(result, c(
    "predictions", "times", "times_utc", "sleep_windows", "sleep_windows_long",
    "day_summary", "summary", "paths", "output_data", "output_model",
    "output_windows", "output_sleep"
  ))
  testthat::expect_equal(result$predictions$sleep_wake, c("wake", "sleep"))
  testthat::expect_true(result$sleep_windows$is_longest_block[[1]])
  testthat::expect_equal(result$summary$prefix, c("overall", "Monday", "weekday"))
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
