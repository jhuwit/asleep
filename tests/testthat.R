# This file is part of the standard setup for testthat.
# It is recommended that you do not modify it.
#
# Where should you do additional test configuration?
# Learn more about the roles of various files in:
# * https://r-pkgs.org/testing-design.html#sec-tests-files-overview
# * https://testthat.r-lib.org/articles/special-files.html
library(testthat)
library(asleep)

testthat::test_check("asleep")

cleanup_uv_lock_files = function(paths = c(".", tempdir(), dirname(tempdir()))) {
  paths = unique(normalizePath(paths, winslash = "/", mustWork = FALSE))
  paths = paths[dir.exists(paths)]

  lock_files = unlist(lapply(paths, function(path) {
    c(
      list.files(
        path = path,
        pattern = "^uv.*[.]lock$",
        full.names = TRUE,
        recursive = TRUE,
        include.dirs = FALSE
      ),
      list.files(
        path = path,
        pattern = "^torch-shm-dir.*",
        full.names = TRUE,
        recursive = TRUE,
        include.dirs = FALSE
      ),
    )
  }))
  lock_files = unique(lock_files[file.exists(lock_files)])

  if (length(lock_files) > 0) {
    invisible(file.remove(lock_files))
  } else {
    invisible(logical())
  }
}
cleanup_uv_lock_files()
