test_that("export_figure writes a file", {
  skip_if_not_installed("ggplot2")
  p <- ggplot2::ggplot(mtcars,
    ggplot2::aes(x = mpg, y = hp)) +
    ggplot2::geom_point()
  tmp <- tempfile(fileext = ".pdf")
  on.exit(unlink(tmp), add = TRUE)
  export_figure(p, tmp, width_mm = 100, height_mm = 80)
  expect_true(file.exists(tmp))
  expect_gt(file.info(tmp)$size, 0)
})

test_that("export_latex_table writes tex with \\botrule", {
  skip_if_not_installed("xtable")
  tmp <- tempfile(fileext = ".tex")
  on.exit(unlink(tmp), add = TRUE)
  export_latex_table(
    data     = head(iris),
    filename = tmp,
    caption  = "Iris sample.",
    label    = "iris-test"
  )
  tex <- paste(readLines(tmp), collapse = "\n")
  expect_true(grepl("botrule", tex))
  expect_false(grepl("bottomrule", tex))
  expect_true(grepl("tab:iris-test", tex))
})
