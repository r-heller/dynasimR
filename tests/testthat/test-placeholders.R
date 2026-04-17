test_that("fill_placeholders dry_run returns named replacements", {
  sim <- load_example_data()
  tmp <- tempfile(fileext = ".tex")
  on.exit(unlink(tmp), add = TRUE)
  writeLines("KIA: [XX_DOCTRINE_DELTA_KIA]%", tmp)

  reps <- fill_placeholders(sim, tmp, dry_run = TRUE,
                            muf_scenario      = "M-S08",
                            milnec_scenario   = "M-S07",
                            baseline_scenario = "M-S00")
  expect_true(is.character(reps))
  expect_true("[XX_DOCTRINE_DELTA_KIA]" %in% names(reps))
})

test_that("fill_placeholders writes a filled file", {
  sim <- load_example_data()
  in_tex  <- tempfile(fileext = ".tex")
  out_tex <- tempfile(fileext = ".tex")
  on.exit({ unlink(in_tex); unlink(out_tex) }, add = TRUE)
  writeLines(c("KIA baseline: [XX_KIA_BASELINE]%",
               "Best: [XX_KIA_BEST]%"), in_tex)

  fill_placeholders(sim, in_tex, output_file = out_tex,
                    muf_scenario      = "M-S08",
                    milnec_scenario   = "M-S07",
                    baseline_scenario = "M-S00")
  expect_true(file.exists(out_tex))
  filled <- paste(readLines(out_tex), collapse = "\n")
  expect_false(grepl("[XX_KIA_BASELINE]", filled, fixed = TRUE))
})
