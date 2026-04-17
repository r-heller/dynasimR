test_that("compute_compliance_index values are in [0,1]", {
  sim <- load_example_data()
  ci <- compute_compliance_index(sim, n_bootstrap = 200)
  expect_true(all(ci$ci >= 0 & ci$ci <= 1, na.rm = TRUE))
  expect_true(is.logical(ci$compliance_critical))
})

test_that("compute_compliance_index respects window_unit", {
  sim <- load_example_data()
  ci_min  <- compute_compliance_index(sim, window_min = 60,
                                      window_unit = "min",
                                      n_bootstrap = 100)
  ci_hrs  <- compute_compliance_index(sim, window_min = 1,
                                      window_unit = "hours",
                                      n_bootstrap = 100)
  # 60 minutes and 1 hour should produce identical index
  expect_equal(ci_min$ci, ci_hrs$ci)
})
