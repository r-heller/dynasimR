test_that("plot_km returns a ggplot object", {
  sim <- load_example_data()
  km <- km_estimate(sim, endpoint = "stage2")
  p <- plot_km(km)
  expect_s3_class(p, "ggplot")
})

test_that("plot_forest returns a ggplot object", {
  sim <- load_example_data()
  cx <- cox_model(sim, endpoint = "stage2",
                  reference_scenario = "A-S00")
  p <- plot_forest(cx)
  expect_s3_class(p, "ggplot")
})

test_that("plot_al_tradeoff returns a ggplot object", {
  sim <- load_example_data()
  al <- al_efficiency(sim,
    al_scenarios = c("0" = "A-S00", "1" = "A-S01"),
    n_bootstrap = 100)
  p <- plot_al_tradeoff(al)
  expect_s3_class(p, "ggplot")
})

test_that("plot_scenario_heatmap returns a ggplot object", {
  sim <- load_example_data()
  p <- plot_scenario_heatmap(sim)
  expect_s3_class(p, "ggplot")
})

test_that("plot_policy returns a ggplot object", {
  sim <- load_example_data()
  pol <- policy_effect(sim,
    policy_a_scenario = "A-S08",
    policy_b_scenario = "A-S07",
    n_bootstrap       = 100)
  p <- plot_policy(pol)
  expect_s3_class(p, "ggplot")
})

test_that("plot_map returns a ggplot object", {
  sim <- load_example_data()
  p <- plot_map(sim, scenarios = "A-S00")
  expect_s3_class(p, "ggplot")
})
