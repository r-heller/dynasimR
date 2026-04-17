#' Compute AL-Efficiency ratio (survival advantage vs. IHL compliance)
#'
#' Quantifies the trade-off between KIA-rate reduction and IHL compliance
#' across UAV autonomy levels AL0-AL5. Returns the trade-off table, the
#' optimal AL level (highest KIA reduction still above the IHL
#' threshold), IHL violations and a detection-bias summary if
#' available.
#'
#' @param data A `dynasimR_data` object or summary tibble.
#' @param al_scenarios Named character vector. Mapping AL level (as
#'   a string) to scenario ID. Default assumes the MEDTACS scenarios
#'   (with the "M-" prefix).
#' @param ihl_threshold Numeric. Minimum IHL compliance index for an
#'   AL level to be considered "ethically acceptable". Default `0.80`.
#' @param reference_al Integer. AL level used as reference for delta
#'   calculation. Default `0`.
#' @param n_bootstrap Integer. Bootstrap replicates for CIs.
#'   Default `1000`.
#'
#' @return An S3 object of class `dynasimR_al_analysis` with slots
#'   `tradeoff_table`, `optimal_al`, `ihl_violations` and `params`.
#' @export
#' @examples
#' \dontrun{
#' sim <- load_example_data()
#' al  <- al_efficiency(sim)
#' plot_al_tradeoff(al)
#' }
al_efficiency <- function(data,
                          al_scenarios  = c(
                            "0" = "M-S00", "1" = "M-S05",
                            "2" = "M-S09", "3" = "M-S10",
                            "4" = "M-S11", "5" = "M-S12"
                          ),
                          ihl_threshold = 0.80,
                          reference_al  = 0,
                          n_bootstrap   = 1000) {

  d <- if (inherits(data, "dynasimR_data")) data$summary else data

  ref_id <- al_scenarios[[as.character(reference_al)]]
  if (is.null(ref_id) || !ref_id %in% d$scenario)
    cli::cli_abort(
      "Reference AL{reference_al} scenario {.val {ref_id}} not in data."
    )

  ref_kia <- stats::median(d$kia_rate[d$scenario == ref_id],
                           na.rm = TRUE)

  tradeoff <- purrr::map_dfr(names(al_scenarios), function(al_str) {
    sc <- al_scenarios[[al_str]]
    sc_data <- dplyr::filter(d, .data$scenario == sc)
    if (nrow(sc_data) == 0) return(NULL)

    kia_med <- stats::median(sc_data$kia_rate, na.rm = TRUE)
    kia_ci  <- if (nrow(sc_data) > 1)
      .boot_quantile_ci(sc_data$kia_rate, n_bootstrap)
    else c(NA_real_, NA_real_)

    ihl_med <- if ("ihl_compliance_index" %in% names(sc_data))
      stats::median(sc_data$ihl_compliance_index, na.rm = TRUE)
    else NA_real_

    kia_red <- (ref_kia - kia_med) * 100
    above   <- !is.na(ihl_med) && ihl_med >= ihl_threshold

    tibble::tibble(
      al                = as.integer(al_str),
      scenario          = sc,
      kia_median        = kia_med,
      kia_ci_lo         = kia_ci[1],
      kia_ci_hi         = kia_ci[2],
      kia_reduction_pct = kia_red,
      ihl_index         = ihl_med,
      above_threshold   = above,
      al_ratio          = if (above)
                            kia_red / (1 - ihl_med + 0.001)
                          else NA_real_,
      n_reps            = nrow(sc_data)
    )
  })

  optimal <- tradeoff |>
    dplyr::filter(.data$above_threshold) |>
    dplyr::slice_max(.data$kia_reduction_pct, n = 1,
                     with_ties = FALSE) |>
    dplyr::pull(.data$al)
  if (length(optimal) == 0) optimal <- NA_integer_

  violations <- tradeoff |>
    dplyr::filter(!.data$above_threshold) |>
    dplyr::mutate(ihl_deficit = ihl_threshold - .data$ihl_index)

  structure(
    list(
      tradeoff_table = tradeoff,
      optimal_al     = optimal,
      ihl_violations = violations,
      ihl_threshold  = ihl_threshold,
      params         = list(
        al_scenarios  = al_scenarios,
        ihl_threshold = ihl_threshold,
        reference_al  = reference_al,
        n_bootstrap   = n_bootstrap
      )
    ),
    class = c("dynasimR_al_analysis", "list")
  )
}

#' @export
print.dynasimR_al_analysis <- function(x, ...) {
  cli::cli_h1("dynasimR_al_analysis")
  cli::cli_bullets(c(
    "*" = "IHL threshold: {.val {x$ihl_threshold}}",
    "*" = "Optimal AL: {.val {x$optimal_al}}",
    "*" = "IHL violations: {.val {nrow(x$ihl_violations)}}"
  ))
  print(x$tradeoff_table)
  invisible(x)
}
