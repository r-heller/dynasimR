test_that("dynasimR_colors returns a named list", {
  cols <- dynasimR_colors()
  expect_type(cols, "list")
  expect_true(all(c("FRIEND", "FOE", "CIVILIAN", "SAVED", "KIA",
                    "NEUTRAL", "ACCENT", "BG") %in% names(cols)))
})

test_that("theme_dynasimR returns a ggplot theme", {
  th <- theme_dynasimR()
  expect_s3_class(th, "theme")
})

test_that("scenario_meta is shipped", {
  expect_true(exists("scenario_meta",
                     where = asNamespace("dynasimR")))
  expect_true(nrow(dynasimR::scenario_meta) > 0)
})
