test_that("doctrine_effect produces correct delta direction", {
  sim <- load_example_data()
  doc <- doctrine_effect(sim,
    muf_scenario    = "M-S08",
    milnec_scenario = "M-S07",
    n_bootstrap     = 200)

  expect_s3_class(doc, "dynasimR_doctrine")

  # MUF should have lower median KIA rate than MilNec
  kia_muf    <- stats::median(
    sim$summary$kia_rate[sim$summary$scenario == "M-S08"])
  kia_milnec <- stats::median(
    sim$summary$kia_rate[sim$summary$scenario == "M-S07"])
  expect_lt(kia_muf, kia_milnec)

  # IHL index under MUF >= under MilNec
  ihl_muf    <- stats::median(
    sim$summary$ihl_compliance_index[sim$summary$scenario == "M-S08"])
  ihl_milnec <- stats::median(
    sim$summary$ihl_compliance_index[sim$summary$scenario == "M-S07"])
  expect_gte(ihl_muf, ihl_milnec)

  # Narrative non-empty
  expect_gt(nchar(doc$narrative), 50)
})

test_that("doctrine_effect errors without scenarios", {
  sim <- load_example_data()
  expect_error(doctrine_effect(sim))
})
