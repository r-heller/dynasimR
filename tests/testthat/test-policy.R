test_that("policy_effect produces correct delta direction", {
  sim <- load_example_data()
  pol <- policy_effect(sim,
    policy_a_scenario = "A-S08",
    policy_b_scenario = "A-S07",
    n_bootstrap       = 200)

  expect_s3_class(pol, "dynasimR_policy")

  # Policy A should have lower median event rate than Policy B
  ev_a <- stats::median(
    sim$summary$event_rate[sim$summary$scenario == "A-S08"])
  ev_b <- stats::median(
    sim$summary$event_rate[sim$summary$scenario == "A-S07"])
  expect_lt(ev_a, ev_b)

  # Compliance under policy A >= policy B
  c_a <- stats::median(
    sim$summary$compliance_index[sim$summary$scenario == "A-S08"])
  c_b <- stats::median(
    sim$summary$compliance_index[sim$summary$scenario == "A-S07"])
  expect_gte(c_a, c_b)

  # Narrative non-empty
  expect_gt(nchar(pol$narrative), 50)
})

test_that("policy_effect errors without scenarios", {
  sim <- load_example_data()
  expect_error(policy_effect(sim))
})
