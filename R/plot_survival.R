#' Kaplan-Meier curves
#'
#' Plots a `dynasimR_km` object.
#'
#' @param km_result A `dynasimR_km` object.
#' @param show_ci Logical. Show CI ribbon. Default `TRUE`.
#' @param show_risktable Logical. Show risk table (requires survminer).
#'   Default `FALSE`.
#' @param show_pval Logical. Annotate log-rank p-value. Default `TRUE`.
#' @param show_median Logical. Draw horizontal 50% reference line.
#'   Default `TRUE`.
#' @param color_by Character. Aesthetic grouping. One of `"scenario"`,
#'   `"group"`, `"policy"`. Default `"scenario"`.
#' @param title,subtitle,xlab,ylab Character overrides.
#' @param xlim Numeric length-2. Restrict x range. Default `NULL`.
#' @param manuscript_width Numeric. mm width hint. Default `174`.
#' @param ... Unused.
#'
#' @return A ggplot2 object.
#' @export
plot_km <- function(km_result,
                    show_ci          = TRUE,
                    show_risktable   = FALSE,
                    show_pval        = TRUE,
                    show_median      = TRUE,
                    color_by         = "scenario",
                    title            = NULL,
                    subtitle         = NULL,
                    xlab             = "Time",
                    ylab             = "Survival probability",
                    xlim             = NULL,
                    manuscript_width = 174,
                    ...) {

  if (!inherits(km_result, "dynasimR_km"))
    cli::cli_abort("{.arg km_result} must be a dynasimR_km object.")

  d <- km_result$tidy
  if (nrow(d) == 0) {
    return(ggplot2::ggplot() +
             ggplot2::annotate("text", x = 1, y = 1,
                               label = "No survival data") +
             theme_dynasimR())
  }

  n_strata <- length(unique(d$strata))
  palette <- if (identical(color_by, "policy"))
    c(dynasimR_colors()$GROUP_A, dynasimR_colors()$GROUP_B)
  else
    .safe_viridis(max(1, n_strata))

  p <- ggplot2::ggplot(
    d,
    ggplot2::aes(x = .data$time, y = .data$estimate,
                 color = .data$strata, fill = .data$strata)
  ) +
    ggplot2::geom_step(linewidth = 0.8)

  if (show_ci && all(c("conf.low", "conf.high") %in% names(d)))
    p <- p +
      ggplot2::geom_ribbon(
        ggplot2::aes(ymin = .data$conf.low,
                     ymax = .data$conf.high),
        alpha = 0.15, color = NA
      )

  if (show_median)
    p <- p +
      ggplot2::geom_hline(yintercept = 0.5, linetype = "dashed",
                          color = "gray60", linewidth = 0.4)

  if (!is.null(xlim))
    p <- p + ggplot2::coord_cartesian(xlim = xlim)

  p <- p +
    ggplot2::scale_color_manual(values = palette) +
    ggplot2::scale_fill_manual(values  = palette) +
    ggplot2::scale_y_continuous(
      limits = c(0, 1),
      labels = function(x) paste0(round(x * 100), "%")
    ) +
    ggplot2::labs(
      title    = title,
      subtitle = subtitle,
      x        = xlab,
      y        = ylab,
      color    = NULL,
      fill     = NULL,
      caption  = .km_caption(km_result, show_pval)
    ) +
    theme_dynasimR()

  if (show_pval && !is.null(km_result$logrank)) {
    pv  <- km_result$logrank$p_value
    pvt <- paste0("Log-rank p ", .format_p(pv))
    p <- p +
      ggplot2::annotate(
        "text",
        x = max(d$time, na.rm = TRUE) * 0.05,
        y = 0.08,
        label = pvt,
        hjust = 0, size = 3, color = "#444444"
      )
  }

  p
}

#' Forest plot of Cox hazard ratios
#'
#' @param cox_result A `dynasimR_cox` object.
#' @param reference_label Character. Label for HR = 1 reference line.
#'   Default `"No effect (HR = 1)"`.
#' @param ... Unused.
#' @return A ggplot2 object.
#' @export
plot_forest <- function(cox_result,
                        reference_label = "No effect (HR = 1)",
                        ...) {

  if (!inherits(cox_result, "dynasimR_cox"))
    cli::cli_abort(
      "{.arg cox_result} must be a dynasimR_cox object."
    )

  d <- cox_result$forest_data
  if (nrow(d) == 0)
    cli::cli_abort("No scenario terms in forest data.")

  ggplot2::ggplot(
    d,
    ggplot2::aes(x = .data$HR,
                 y = stats::reorder(.data$term, .data$HR),
                 xmin = .data$CI_low, xmax = .data$CI_high)
  ) +
    ggplot2::geom_vline(xintercept = 1, linetype = "dashed",
                        color = "gray60", linewidth = 0.5) +
    ggplot2::geom_errorbarh(height = 0.2, linewidth = 0.6,
                            color = dynasimR_colors()$NEUTRAL) +
    ggplot2::geom_point(
      ggplot2::aes(color = .data$p.value < 0.05),
      size = 3
    ) +
    ggplot2::scale_color_manual(
      values = c("TRUE"  = dynasimR_colors()$GROUP_A,
                 "FALSE" = dynasimR_colors()$NEUTRAL),
      labels = c("TRUE" = "p < 0.05", "FALSE" = "n.s."),
      name   = NULL
    ) +
    ggplot2::scale_x_log10() +
    ggplot2::labs(
      x = "Hazard ratio (log scale)",
      y = NULL,
      caption = glue::glue(
        "Reference: {cox_result$params$reference_scenario}"
      )
    ) +
    theme_dynasimR()
}
