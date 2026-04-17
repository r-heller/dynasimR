test_that("load_example_data returns a dynasimR_data object", {
  sim <- load_example_data()
  expect_s3_class(sim, "dynasimR_data")
  expect_true("summary" %in% names(sim))
  expect_true("casualties" %in% names(sim))
  expect_gt(nrow(sim$summary), 0)
})

test_that("read_simulation aborts on missing directory", {
  expect_error(read_simulation("nonexistent-directory-xyz"))
})

test_that("validate_dynasimR_data runs cleanly on example data", {
  sim <- load_example_data()
  expect_silent(validate_dynasimR_data(sim))
})

test_that("print method does not error", {
  sim <- load_example_data()
  expect_invisible(print(sim))
})
