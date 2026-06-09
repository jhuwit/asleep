testthat::test_that("sl_url constructs the release asset URL", {
  testthat::expect_equal(
    asleep:::sl_url("1.2.3"),
    paste0(
      "https://github.com/OxWearables/asleep/",
      "releases/download/1.2.3/ssl.joblib.lzma"
    )
  )
})

testthat::test_that("sl_load_model delegates to the selected reticulate wrapper", {
  calls = new.env(parent = emptyenv())
  fake_asleep = list(
    get_sleep = list(
      load_model = function(model_path, force_download) {
        calls$model_path = model_path
        calls$force_download = force_download
        list(path = model_path, force = force_download)
      }
    )
  )

  testthat::local_mocked_bindings(
    asleep_base_noconvert = function() {
      calls$wrapper = "noconvert"
      fake_asleep
    },
    asleep_base = function() {
      calls$wrapper = "convert"
      fake_asleep
    },
    .package = "asleep"
  )

  path = tempfile()
  out = asleep:::sl_load_model(
    model_path = path,
    force_download = TRUE,
    as_python = TRUE
  )
  testthat::expect_equal(calls$wrapper, "noconvert")
  testthat::expect_equal(calls$model_path, path)
  testthat::expect_true(calls$force_download)
  testthat::expect_equal(out$path, path)

  out = asleep:::sl_load_model(model_path = path, as_python = FALSE)
  testthat::expect_equal(calls$wrapper, "convert")
  testthat::expect_equal(out$force, FALSE)
})

testthat::test_that("sl_load_model uses tempdir when no path is supplied", {
  calls = new.env(parent = emptyenv())
  fake_asleep = list(
    get_sleep = list(
      load_model = function(model_path, force_download) {
        calls$model_path = model_path
        model_path
      }
    )
  )

  testthat::local_mocked_bindings(
    asleep_base_noconvert = function() fake_asleep,
    .package = "asleep"
  )

  out = asleep:::sl_load_model(model_path = NULL)
  testthat::expect_equal(out, file.path(tempdir(), "ssl.joblib.lzma"))
  testthat::expect_equal(calls$model_path, out)
})

testthat::test_that("sl_download_model can download from a local URL", {
  source = tempfile()
  dest = tempfile()
  writeLines("model-bytes", source)

  testthat::local_mocked_bindings(
    sl_url = function(version = "unused") {
      paste0("file://", normalizePath(source, winslash = "/"))
    },
    .package = "asleep"
  )

  out = asleep:::sl_download_model(dest)
  testthat::expect_equal(out, dest)
  testthat::expect_equal(readLines(dest), "model-bytes")
})

testthat::test_that("sl_read uses top-level and nested read functions", {
  input = tempfile(fileext = ".csv")
  writeLines("time,x,y,z\n2024-01-01 00:00:00,1,2,3", input)
  calls = new.env(parent = emptyenv())
  fake_read = function(filepath, resample_hz) {
    calls$filepath = filepath
    calls$resample_hz = resample_hz
    list(data.frame(x = 1), list(sample_rate = resample_hz))
  }

  testthat::local_mocked_bindings(
    asleep_base = function() list(read = fake_read),
    .package = "asleep"
  )
  out = sl_read(input, resample_hz = NULL)
  testthat::expect_named(out, c("data", "info"))
  testthat::expect_s3_class(out$data, "data.frame")
  testthat::expect_null(calls$resample_hz)

  testthat::local_mocked_bindings(
    asleep_base = function() list(utils = list(read = fake_read)),
    .package = "asleep"
  )
  out = sl_read(input, resample_hz = "uniform")
  testthat::expect_named(out, c("data", "info"))
  testthat::expect_equal(calls$filepath, normalizePath(input))
  testthat::expect_equal(calls$resample_hz, "uniform")
})

testthat::test_that("sl_read validates file and resampling inputs", {
  input = tempfile(fileext = ".csv")
  writeLines("time,x,y,z\n2024-01-01 00:00:00,1,2,3", input)

  testthat::local_mocked_bindings(
    asleep_base = function() {
      list(read = function(filepath, resample_hz) list(data.frame(), list()))
    },
    .package = "asleep"
  )

  testthat::expect_error(sl_read(tempfile()), "file")
  testthat::expect_error(sl_read(input, resample_hz = "30"), "resample_hz")
})
