test_that("compute_ihl_index values are in [0,1]", {
  sim <- load_example_data()
  ihl <- compute_ihl_index(sim, n_bootstrap = 200)
  expect_true(all(ihl$ici >= 0 & ihl$ici <= 1, na.rm = TRUE))
  expect_true(is.logical(ihl$ihl_critical))
})

test_that("compute_ihl_index respects window_unit", {
  sim <- load_example_data()
  ihl_min  <- compute_ihl_index(sim, window_min = 60,
                                window_unit = "min",
                                n_bootstrap = 100)
  ihl_hrs  <- compute_ihl_index(sim, window_min = 1,
                                window_unit = "hours",
                                n_bootstrap = 100)
  # 60 minutes and 1 hour should produce identical index
  expect_equal(ihl_min$ici, ihl_hrs$ici)
})
