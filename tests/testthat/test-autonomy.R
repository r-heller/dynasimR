test_that("al_efficiency returns a tradeoff table", {
  sim <- load_example_data()
  # Example data only has M-S00 and M-S01 in the AL-sweep; pass a
  # reduced mapping.
  al <- al_efficiency(
    sim,
    al_scenarios = c("0" = "M-S00", "1" = "M-S01"),
    ihl_threshold = 0.80,
    n_bootstrap   = 200
  )
  expect_s3_class(al, "dynasimR_al_analysis")
  expect_true(is.data.frame(al$tradeoff_table))
  expect_true(all(c("al", "scenario", "kia_reduction_pct",
                    "ihl_index") %in% names(al$tradeoff_table)))
})
