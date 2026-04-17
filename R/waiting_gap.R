#' Waiting-Gap Index (REHASIM)
#'
#' Analogue of the IHL-Compliance Index for rehabilitation flow:
#' fraction of casualties who wait no longer than a threshold number
#' of days (default 14) between injury and rehabilitation start.
#' A value below `0.80` is flagged as a policy-relevant violation.
#'
#' @param data A `dynasimR_data` object or casualty tibble with a
#'   `waiting_days` column (or `waiting_days_to_min` in minutes).
#' @param window_days Numeric. Allowed waiting time in days.
#'   Default `14`.
#' @param by_scenario Logical. Stratify by scenario. Default `TRUE`.
#' @param by_cohort Logical. Stratify by `cohort` (if present).
#'   Default `TRUE`.
#' @param n_bootstrap Integer. Bootstrap replicates for CIs.
#'   Default `1000`.
#'
#' @return A tibble with columns `scenario` (if stratified),
#'   `cohort` (if stratified), `wgi`, `wgi_ci_lo`, `wgi_ci_hi`,
#'   `n_total`, `n_in_window`, `wgi_critical`, `window_days`.
#' @export
compute_waiting_gap_index <- function(data,
                                      window_days  = 14,
                                      by_scenario  = TRUE,
                                      by_cohort    = TRUE,
                                      n_bootstrap  = 1000) {

  d <- if (inherits(data, "dynasimR_data")) data$casualties else data
  if (nrow(d) == 0) return(tibble::tibble())

  col <- if ("waiting_days" %in% names(d)) "waiting_days"
         else if ("waiting_days_to_min" %in% names(d))
           "waiting_days_to_min"
         else NA_character_
  if (is.na(col))
    cli::cli_abort(
      "Casualty table needs 'waiting_days' or 'waiting_days_to_min'."
    )

  # Normalise to days if column is in minutes
  vals <- if (col == "waiting_days_to_min")
    d[[col]] / 1440 else d[[col]]

  d <- dplyr::mutate(d, .__wait = vals)

  group_vars <- character(0)
  if (by_scenario) group_vars <- c(group_vars, "scenario")
  if (by_cohort && "cohort" %in% names(d))
    group_vars <- c(group_vars, "cohort")

  compute_group <- function(sub) {
    t <- sub$.__wait
    in_win <- !is.na(t) & t <= window_days
    n_total <- length(t)
    n_in    <- sum(in_win)
    wgi <- if (n_total > 0) n_in / n_total else NA_real_
    ci <- if (n_total > 1 && n_bootstrap > 0)
      .boot_quantile_ci(as.integer(in_win), n_bootstrap,
                        fun = mean)
    else c(NA_real_, NA_real_)
    tibble::tibble(
      n_total     = n_total,
      n_in_window = n_in,
      wgi         = wgi,
      wgi_ci_lo   = ci[1],
      wgi_ci_hi   = ci[2]
    )
  }

  if (length(group_vars) == 0) {
    result <- compute_group(d)
  } else {
    result <- d |>
      dplyr::group_by(dplyr::across(dplyr::all_of(group_vars))) |>
      dplyr::group_modify(~ compute_group(.x)) |>
      dplyr::ungroup()
  }

  result$wgi_critical <- !is.na(result$wgi) & result$wgi < 0.80
  result$window_days  <- window_days
  result
}
