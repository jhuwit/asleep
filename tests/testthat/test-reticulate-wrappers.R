testthat::test_that("reticulate base helpers import asleep with expected conversion", {
  calls = list()
  testthat::local_mocked_bindings(
    import = function(module, convert = TRUE) {
      calls[[length(calls) + 1]] <<- list(module = module, convert = convert)
      list(get_sleep = list())
    },
    .package = "reticulate"
  )

  asleep:::asleep_base()
  asleep:::asleep_base_noconvert()

  testthat::expect_equal(calls[[1]], list(module = "asleep", convert = TRUE))
  testthat::expect_equal(calls[[2]], list(module = "asleep", convert = FALSE))
})

testthat::test_that("get_sslnet delegates to the asleep sslmodel", {
  testthat::local_mocked_bindings(
    asleep_base_noconvert = function() {
      list(sslmodel = list(get_sslnet = function() "ssl-net"))
    },
    .package = "asleep"
  )

  testthat::expect_equal(get_sslnet(), "ssl-net")
  testthat::expect_equal(sl_get_sslnet(), "ssl-net")
})

testthat::test_that(".onLoad declares Python requirements through reticulate", {
  calls = new.env(parent = emptyenv())
  testthat::local_mocked_bindings(
    py_require = function(packages, python_version) {
      calls$packages = packages
      calls$python_version = python_version
      TRUE
    },
    .package = "reticulate"
  )

  out = asleep:::.onLoad("lib", "asleep")

  testthat::expect_true(out)
  testthat::expect_equal(
    calls$packages,
    c("asleep==0.4.18", "argparse", "numpy", "pandas")
  )
  testthat::expect_equal(calls$python_version, "3.8")
})

testthat::test_that("module version helpers report installed packages", {
  testthat::local_mocked_bindings(
    py_module_available = function(module) module == "asleep",
    py_list_packages = function() {
      data.frame(package = c("asleep", "numpy"), version = c("0.4.16", "2.0.0"))
    },
    .package = "reticulate"
  )

  testthat::expect_true(have_asleep())
  testthat::expect_equal(asleep_version(), "0.4.16")
  testthat::expect_equal(asleep:::module_version("asleep"), "0.4.16")
  testthat::expect_error(asleep:::module_version("missing"), "missing is not installed")
})

testthat::test_that("read_summary_json returns JSON metrics as a data frame", {
  fake_file = new.env(parent = emptyenv())
  fake_file$close = function() {
    fake_file$closed = TRUE
  }

  testthat::local_mocked_bindings(
    import_builtins = function() {
      list(open = function(path, mode) {
        fake_file$path = path
        fake_file$mode = mode
        fake_file
      })
    },
    import = function(module, convert = TRUE) {
      testthat::expect_equal(module, "json")
      list(load = function(file) list(total_sleep = 8, efficiency = 0.9))
    },
    .package = "reticulate"
  )

  out = asleep:::read_summary_json("summary.json")

  testthat::expect_s3_class(out, "data.frame")
  testthat::expect_named(out, c("metric", "value"))
  testthat::expect_equal(out$metric, c("total_sleep", "efficiency"))
  testthat::expect_equal(out$value, c(8, 0.9))
  testthat::expect_equal(fake_file$path, "summary.json")
  testthat::expect_equal(fake_file$mode, "r")
  testthat::expect_true(fake_file$closed)
})
