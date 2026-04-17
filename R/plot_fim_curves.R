#' FIM trajectory plot (REHASIM)
#'
#' Plots longitudinal FIM trajectories from the output of
#' [fim_trajectory_analysis()] (with `longitudinal = TRUE`).
#'
#' @param fim_result A `dynasimR_fim` object.
#' @param show_ci Logical. Show 95% CI ribbon. Default `TRUE`.
#' @return A ggplot2 object.
#' @export
plot_fim_curves <- function(fim_result, show_ci = TRUE) {
  if (!inherits(fim_result, "dynasimR_fim"))
    cli::cli_abort("{.arg fim_result} must be a dynasimR_fim object.")

  long <- fim_result$longitudinal
  if (is.null(long) || nrow(long) == 0) {
    # fallback: plot summary as bar chart
    d <- fim_result$summary
    return(
      ggplot2::ggplot(d,
        ggplot2::aes(x = .data$scenario,
                     y = .data$fim_gain_median)) +
        ggplot2::geom_col(fill = dynasimR_colors()$FRIEND) +
        ggplot2::geom_errorbar(
          ggplot2::aes(ymin = .data$fim_gain_q025,
                       ymax = .data$fim_gain_q975),
          width = 0.3, color = dynasimR_colors()$NEUTRAL
        ) +
        ggplot2::labs(x = "Scenario", y = "Median FIM gain") +
        theme_dynasimR()
    )
  }

  p <- ggplot2::ggplot(long,
    ggplot2::aes(x = .data$time_step, y = .data$fim_median,
                 color = .data$scenario, fill = .data$scenario)
  )
  if (show_ci && all(c("fim_q025", "fim_q975") %in% names(long)))
    p <- p +
      ggplot2::geom_ribbon(
        ggplot2::aes(ymin = .data$fim_q025,
                     ymax = .data$fim_q975),
        alpha = 0.15, color = NA
      )
  p +
    ggplot2::geom_line(linewidth = 0.8) +
    ggplot2::scale_color_viridis_d(option = "D",
                                   begin = 0.1, end = 0.9) +
    ggplot2::scale_fill_viridis_d(option = "D",
                                  begin = 0.1, end = 0.9) +
    ggplot2::labs(x = "Time [days]", y = "FIM score") +
    theme_dynasimR()
}
