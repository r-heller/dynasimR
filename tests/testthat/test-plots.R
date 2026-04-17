test_that("plot_km returns a ggplot object", {
  sim <- load_example_data()
  km <- km_estimate(sim, endpoint = "role2")
  p <- plot_km(km)
  expect_s3_class(p, "ggplot")
})

test_that("plot_forest returns a ggplot object", {
  sim <- load_example_data()
  cx <- cox_model(sim, endpoint = "role2",
                  reference_scenario = "M-S00")
  p <- plot_forest(cx)
  expect_s3_class(p, "ggplot")
})

test_that("plot_al_tradeoff returns a ggplot object", {
  sim <- load_example_data()
  al <- al_efficiency(sim,
    al_scenarios = c("0" = "M-S00", "1" = "M-S01"),
    n_bootstrap = 100)
  p <- plot_al_tradeoff(al)
  expect_s3_class(p, "ggplot")
})

test_that("plot_scenario_heatmap returns a ggplot object", {
  sim <- load_example_data()
  p <- plot_scenario_heatmap(sim)
  expect_s3_class(p, "ggplot")
})

test_that("plot_doctrine returns a ggplot object", {
  sim <- load_example_data()
  doc <- doctrine_effect(sim,
    muf_scenario    = "M-S08",
    milnec_scenario = "M-S07",
    n_bootstrap     = 100)
  p <- plot_doctrine(doc)
  expect_s3_class(p, "ggplot")
})

test_that("plot_map returns a ggplot object", {
  sim <- load_example_data()
  p <- plot_map(sim, scenarios = "M-S00")
  expect_s3_class(p, "ggplot")
})
