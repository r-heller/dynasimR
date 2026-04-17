test_that("REHASIM analyses do not error on a synthetic input", {
  set.seed(1)
  n <- 40
  cas <- tibble::tibble(
    scenario         = rep(c("R-S00", "R-S19"), each = n),
    replication      = rep(1:n, 2),
    patient_id       = 1:(2 * n),
    cohort           = sample(c("A", "B"), 2 * n, replace = TRUE),
    fim_admission    = stats::rnorm(2 * n, 60, 10),
    fim_discharge    = stats::rnorm(2 * n, 95, 8),
    waiting_days     = stats::rgamma(2 * n, shape = 2, rate = 0.2),
    injury_severity  = stats::runif(2 * n, 0.2, 0.8),
    rtd_outcome      = factor(sample(c("RTD", "PARTIAL", "NONE"),
                                     2 * n, replace = TRUE))
  )
  summ <- cas |>
    dplyr::group_by(.data$scenario, .data$replication) |>
    dplyr::summarise(
      fim_gain = mean(.data$fim_discharge - .data$fim_admission),
      rtd_rate = mean(.data$rtd_outcome == "RTD"),
      cost     = stats::runif(1, 1000, 5000),
      supply   = stats::runif(1, 80, 120),
      demand   = stats::runif(1, 80, 120),
      region   = sample(c("RegA", "RegB"), 1),
      .groups  = "drop"
    )

  sim <- structure(
    list(summary = summ, casualties = cas,
         timeseries = tibble::tibble(),
         metadata = tibble::tibble(id = unique(summ$scenario)),
         load_info = list(simulation_type = "REHASIM",
                          scenarios = unique(summ$scenario))),
    class = c("dynasimR_data", "list")
  )

  fim <- fim_trajectory_analysis(sim)
  expect_s3_class(fim, "dynasimR_fim")

  wgi <- compute_waiting_gap_index(sim, n_bootstrap = 100)
  expect_true("wgi" %in% names(wgi))
  expect_true(all(wgi$wgi >= 0 & wgi$wgi <= 1, na.rm = TRUE))

  mc <- mil_civil_effect(sim,
    mil_scenario = "R-S00", civ_scenario = "R-S19",
    n_bootstrap  = 100)
  expect_s3_class(mc, "dynasimR_mil_civil")

  sdi <- spatial_supply_demand(sim)
  expect_true("sdi_median" %in% names(sdi))
})
