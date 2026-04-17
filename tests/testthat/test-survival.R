test_that("km_estimate returns a dynasimR_km object", {
  sim <- load_example_data()
  km <- km_estimate(sim, endpoint = "role2",
                    stratify_by = "scenario")
  expect_s3_class(km, "dynasimR_km")
  expect_true("tidy" %in% names(km))
  expect_gt(nrow(km$tidy), 0)
  expect_s3_class(km$fit, "survfit")
})

test_that("km_estimate ttd endpoint works", {
  sim <- load_example_data()
  km <- km_estimate(sim, endpoint = "ttd",
                    stratify_by = "scenario")
  expect_s3_class(km, "dynasimR_km")
})

test_that("cox_model returns a dynasimR_cox object", {
  sim <- load_example_data()
  cx <- cox_model(sim, endpoint = "role2",
                  reference_scenario = "M-S00")
  expect_s3_class(cx, "dynasimR_cox")
  expect_true("tidy" %in% names(cx))
  expect_true("forest_data" %in% names(cx))
})
