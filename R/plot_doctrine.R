#' Doctrine effect bar chart with CI whiskers
#'
#' Plots the `delta_kia` table from a `dynasimR_doctrine` object as a
#' horizontal bar chart with bootstrap CI whiskers.
#'
#' @param doctrine_result A `dynasimR_doctrine` object.
#' @return A ggplot2 object.
#' @export
plot_doctrine <- function(doctrine_result) {

  if (!inherits(doctrine_result, "dynasimR_doctrine"))
    cli::cli_abort(
      "{.arg doctrine_result} must be a dynasimR_doctrine object."
    )

  d <- doctrine_result$delta_kia

  ggplot2::ggplot(d,
    ggplot2::aes(x = .data$median_pct_points,
                 y = stats::reorder(.data$identity,
                                    .data$median_pct_points),
                 xmin = .data$ci_lo, xmax = .data$ci_hi)
  ) +
    ggplot2::geom_vline(xintercept = 0, linetype = "dashed",
                        color = "gray60", linewidth = 0.5) +
    ggplot2::geom_errorbarh(height = 0.2, linewidth = 0.6,
                            color = dynasimR_colors()$NEUTRAL) +
    ggplot2::geom_point(size = 3,
                        color = dynasimR_colors()$FRIEND) +
    ggplot2::labs(
      x = "Delta KIA rate (MUF - MilNec) [pp]",
      y = NULL,
      title = "Doctrine effect",
      subtitle = glue::glue(
        "{doctrine_result$params$muf_scenario} vs. ",
        "{doctrine_result$params$milnec_scenario}"
      )
    ) +
    theme_dynasimR()
}
