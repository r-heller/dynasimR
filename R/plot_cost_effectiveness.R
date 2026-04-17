#' Cost-effectiveness plane and CEAC curve (REHASIM)
#'
#' Plots the cost-effectiveness plane (delta cost vs. delta outcome)
#' for a set of scenarios and, optionally, a cost-effectiveness
#' acceptability curve (CEAC) across willingness-to-pay thresholds.
#'
#' @param data A `dynasimR_data` object or summary tibble.
#' @param reference Character. Scenario ID treated as the comparator.
#' @param scenarios Character vector. Scenarios to evaluate against
#'   `reference`.
#' @param outcome_col Character. Outcome column. Default `"rtd_rate"`.
#' @param cost_col Character. Cost column. Default `"cost"`.
#' @param wtp Numeric vector. Willingness-to-pay thresholds for CEAC.
#'   Default `seq(0, 2e5, length.out = 40)`.
#' @param show_ceac Logical. If `TRUE`, return a CEAC plot instead of
#'   the CE plane. Default `FALSE`.
#' @return A ggplot2 object.
#' @export
plot_cost_effectiveness <- function(data,
                                    reference,
                                    scenarios,
                                    outcome_col = "rtd_rate",
                                    cost_col    = "cost",
                                    wtp         = seq(0, 2e5,
                                                      length.out = 40),
                                    show_ceac   = FALSE) {

  d <- if (inherits(data, "dynasimR_data")) data$summary else data
  .require_cols(d, c("scenario", outcome_col, cost_col),
                where = "summary")

  ref_out  <- d[[outcome_col]][d$scenario == reference]
  ref_cost <- d[[cost_col]][d$scenario == reference]
  if (length(ref_out) == 0)
    cli::cli_abort("Reference {.val {reference}} not in data.")

  ref_out_med  <- stats::median(ref_out,  na.rm = TRUE)
  ref_cost_med <- stats::median(ref_cost, na.rm = TRUE)

  points <- purrr::map_dfr(scenarios, function(sc) {
    so <- d[[outcome_col]][d$scenario == sc]
    sc_cost <- d[[cost_col]][d$scenario == sc]
    if (length(so) == 0) return(NULL)
    tibble::tibble(
      scenario     = sc,
      delta_effect = stats::median(so, na.rm = TRUE) - ref_out_med,
      delta_cost   = stats::median(sc_cost, na.rm = TRUE) -
                     ref_cost_med,
      icer         = (stats::median(sc_cost, na.rm = TRUE) -
                      ref_cost_med) /
                     (stats::median(so, na.rm = TRUE) - ref_out_med +
                      1e-9)
    )
  })

  if (!show_ceac) {
    return(
      ggplot2::ggplot(points,
        ggplot2::aes(x = .data$delta_effect,
                     y = .data$delta_cost,
                     color = .data$scenario,
                     label = .data$scenario)) +
        ggplot2::geom_hline(yintercept = 0, color = "gray60") +
        ggplot2::geom_vline(xintercept = 0, color = "gray60") +
        ggplot2::geom_point(size = 4) +
        ggplot2::geom_text(nudge_y = 0.02 * max(abs(points$delta_cost))) +
        ggplot2::labs(
          x = glue::glue("Delta effect ({outcome_col})"),
          y = glue::glue("Delta cost ({cost_col})"),
          title = "Cost-effectiveness plane"
        ) +
        theme_dynasimR()
    )
  }

  # CEAC across WTP thresholds ------------------------------------------
  wtp_curves <- purrr::map_dfr(scenarios, function(sc) {
    so      <- d[[outcome_col]][d$scenario == sc]
    sc_cost <- d[[cost_col]][d$scenario == sc]
    if (length(so) == 0) return(NULL)
    inb_prob <- vapply(wtp, function(w) {
      inb <- w * (so - ref_out_med) - (sc_cost - ref_cost_med)
      mean(inb > 0, na.rm = TRUE)
    }, numeric(1))
    tibble::tibble(scenario = sc, wtp = wtp, prob_ce = inb_prob)
  })
  ggplot2::ggplot(wtp_curves,
    ggplot2::aes(x = .data$wtp, y = .data$prob_ce,
                 color = .data$scenario)) +
    ggplot2::geom_line(linewidth = 0.8) +
    ggplot2::labs(
      x = "Willingness-to-pay",
      y = "Probability cost-effective",
      title = "Cost-effectiveness acceptability curve"
    ) +
    theme_dynasimR()
}
