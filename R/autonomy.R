#' Compute AL-Efficiency ratio (event reduction vs. compliance)
#'
#' Quantifies the trade-off between event-rate reduction and the
#' Compliance Index across autonomy levels AL0-AL5. Returns the
#' trade-off table, the optimal AL level (highest event reduction
#' still above the compliance threshold) and compliance violations.
#'
#' @param data A `dynasimR_data` object or summary tibble.
#' @param al_scenarios Named character vector. Mapping AL level (as
#'   a string) to scenario ID. Default assumes the Profile A
#'   scenarios (with the "A-" prefix).
#' @param compliance_threshold Numeric. Minimum Compliance Index for
#'   an AL level to be considered acceptable. Default `0.80`.
#' @param reference_al Integer. AL level used as reference for delta
#'   calculation. Default `0`.
#' @param n_bootstrap Integer. Bootstrap replicates for CIs.
#'   Default `1000`.
#'
#' @return An S3 object of class `dynasimR_al_analysis` with slots
#'   `tradeoff_table`, `optimal_al`, `compliance_violations` and
#'   `params`.
#' @export
#' @examples
#' \dontrun{
#' sim <- load_example_data()
#' al  <- al_efficiency(sim)
#' plot_al_tradeoff(al)
#' }
al_efficiency <- function(data,
                          al_scenarios  = c(
                            "0" = "A-S00", "1" = "A-S05",
                            "2" = "A-S09", "3" = "A-S10",
                            "4" = "A-S11", "5" = "A-S12"
                          ),
                          compliance_threshold = 0.80,
                          reference_al         = 0,
                          n_bootstrap          = 1000) {

  d <- if (inherits(data, "dynasimR_data")) data$summary else data

  ref_id <- al_scenarios[[as.character(reference_al)]]
  if (is.null(ref_id) || !ref_id %in% d$scenario)
    cli::cli_abort(
      "Reference AL{reference_al} scenario {.val {ref_id}} not in data."
    )

  ref_event <- stats::median(d$event_rate[d$scenario == ref_id],
                             na.rm = TRUE)

  tradeoff <- purrr::map_dfr(names(al_scenarios), function(al_str) {
    sc <- al_scenarios[[al_str]]
    sc_data <- dplyr::filter(d, .data$scenario == sc)
    if (nrow(sc_data) == 0) return(NULL)

    event_med <- stats::median(sc_data$event_rate, na.rm = TRUE)
    event_ci  <- if (nrow(sc_data) > 1)
      .boot_quantile_ci(sc_data$event_rate, n_bootstrap)
    else c(NA_real_, NA_real_)

    comp_med <- if ("compliance_index" %in% names(sc_data))
      stats::median(sc_data$compliance_index, na.rm = TRUE)
    else NA_real_

    event_red <- (ref_event - event_med) * 100
    above     <- !is.na(comp_med) &&
                 comp_med >= compliance_threshold

    tibble::tibble(
      al                   = as.integer(al_str),
      scenario             = sc,
      event_median         = event_med,
      event_ci_lo          = event_ci[1],
      event_ci_hi          = event_ci[2],
      event_reduction_pct  = event_red,
      compliance           = comp_med,
      above_threshold      = above,
      al_ratio             = if (above)
                                event_red /
                                (1 - comp_med + 0.001)
                              else NA_real_,
      n_reps               = nrow(sc_data)
    )
  })

  optimal <- tradeoff |>
    dplyr::filter(.data$above_threshold) |>
    dplyr::slice_max(.data$event_reduction_pct, n = 1,
                     with_ties = FALSE) |>
    dplyr::pull(.data$al)
  if (length(optimal) == 0) optimal <- NA_integer_

  violations <- tradeoff |>
    dplyr::filter(!.data$above_threshold) |>
    dplyr::mutate(compliance_deficit =
                    compliance_threshold - .data$compliance)

  structure(
    list(
      tradeoff_table         = tradeoff,
      optimal_al             = optimal,
      compliance_violations  = violations,
      compliance_threshold   = compliance_threshold,
      params                 = list(
        al_scenarios         = al_scenarios,
        compliance_threshold = compliance_threshold,
        reference_al         = reference_al,
        n_bootstrap          = n_bootstrap
      )
    ),
    class = c("dynasimR_al_analysis", "list")
  )
}

#' @export
print.dynasimR_al_analysis <- function(x, ...) {
  cli::cli_h1("dynasimR_al_analysis")
  cli::cli_bullets(c(
    "*" = "Compliance threshold: {.val {x$compliance_threshold}}",
    "*" = "Optimal AL: {.val {x$optimal_al}}",
    "*" = "Compliance violations: {.val {nrow(x$compliance_violations)}}"
  ))
  print(x$tradeoff_table)
  invisible(x)
}
