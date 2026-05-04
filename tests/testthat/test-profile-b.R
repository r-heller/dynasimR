test_that("Profile B helpers do not error on a synthetic input", {
  set.seed(1)
  n <- 40
  ent <- tibble::tibble(
    scenario            = rep(c("B-S00", "B-S19"), each = n),
    replication         = rep(1:n, 2),
    entity_id           = 1:(2 * n),
    cohort              = sample(c("A", "B"), 2 * n, replace = TRUE),
    progress_start      = stats::rnorm(2 * n, 60, 10),
    progress_end        = stats::rnorm(2 * n, 95, 8),
    wait_days           = stats::rgamma(2 * n, shape = 2, rate = 0.2),
    severity            = stats::runif(2 * n, 0.2, 0.8),
    completion_outcome  = factor(sample(c("FULL", "PARTIAL", "NONE"),
                                        2 * n, replace = TRUE))
  )
  summ <- ent |>
    dplyr::group_by(.data$scenario, .data$replication) |>
    dplyr::summarise(
      progress_gain   = mean(.data$progress_end -
                             .data$progress_start),
      completion_rate = mean(.data$completion_outcome == "FULL"),
      cost            = stats::runif(1, 1000, 5000),
      supply          = stats::runif(1, 80, 120),
      demand          = stats::runif(1, 80, 120),
      region          = sample(c("RegA", "RegB"), 1),
      .groups         = "drop"
    )

  sim <- structure(
    list(summary = summ, entities = ent,
         timeseries = tibble::tibble(),
         metadata = tibble::tibble(id = unique(summ$scenario)),
         load_info = list(profile_type = "Profile_B",
                          scenarios = unique(summ$scenario))),
    class = c("dynasimR_data", "list")
  )

  pr <- progress_trajectory(sim)
  expect_s3_class(pr, "dynasimR_progress")

  wgi <- compute_wait_gap_index(sim, n_bootstrap = 100)
  expect_true("wgi" %in% names(wgi))
  expect_true(all(wgi$wgi >= 0 & wgi$wgi <= 1, na.rm = TRUE))

  ge <- group_effect(sim,
    group_a_scenario = "B-S00", group_b_scenario = "B-S19",
    n_bootstrap      = 100)
  expect_s3_class(ge, "dynasimR_group_effect")

  sdi <- spatial_supply_demand(sim)
  expect_true("sdi_median" %in% names(sdi))
})
