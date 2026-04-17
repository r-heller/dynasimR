#' IHL-Compliance Index
#'
#' Fraction of casualties (irrespective of identity) that receive
#' first care within a defined time window post-injury. A value
#' below `0.80` is treated as a critical IHL violation in the
#' MEDTACS-SIM ethics analysis.
#'
#' For REHASIM data the analogous metric uses `waiting_days` with a
#' 14-day window (`window_unit = "days"`).
#'
#' @param casualties A `dynasimR_data` object, or a casualty-level
#'   tibble/data.frame with a `time_to_first_care` column
#'   (MEDTACS) or `waiting_days_to_min` column (REHASIM).
#' @param window_min Numeric. Window size, expressed in the unit given
#'   by `window_unit`. Default `60`.
#' @param window_unit Character. One of `"min"`, `"hours"`, `"days"`.
#'   Values are internally normalised to minutes.
#' @param by_scenario Logical. Compute per scenario. Default `TRUE`.
#' @param by_identity Logical. Stratify by `identity` if the column
#'   is present. Default `TRUE`.
#' @param n_bootstrap Integer. Bootstrap replicates for CIs.
#'   Default `1000`.
#'
#' @return A tibble with columns `scenario` (if stratified),
#'   `identity` (if stratified), `ici`, `ici_ci_lo`, `ici_ci_hi`,
#'   `n_total`, `n_treated_in_window`, `ihl_critical`, `window_min`.
#' @export
#' @examples
#' \dontrun{
#' sim <- load_example_data()
#' ihl <- compute_ihl_index(sim)
#' }
compute_ihl_index <- function(casualties,
                              window_min  = 60,
                              window_unit = c("min", "hours", "days"),
                              by_scenario = TRUE,
                              by_identity = TRUE,
                              n_bootstrap = 1000) {

  window_unit <- match.arg(window_unit)
  window_min_norm <- switch(window_unit,
    "min"   = window_min,
    "hours" = window_min * 60,
    "days"  = window_min * 1440
  )

  d <- if (inherits(casualties, "dynasimR_data")) casualties$casualties
       else casualties

  if (nrow(d) == 0)
    return(tibble::tibble())

  time_col <- if ("time_to_first_care" %in% names(d))
    "time_to_first_care" else if ("waiting_days_to_min" %in% names(d))
    "waiting_days_to_min" else NA_character_
  if (is.na(time_col))
    cli::cli_abort(
      "Casualty table needs 'time_to_first_care' or ",
      "'waiting_days_to_min'."
    )

  group_vars <- character(0)
  if (by_scenario) group_vars <- c(group_vars, "scenario")
  if (by_identity && "identity" %in% names(d))
    group_vars <- c(group_vars, "identity")

  compute_group <- function(sub) {
    t <- sub[[time_col]]
    in_win <- !is.na(t) & t <= window_min_norm
    n_total <- length(t)
    n_in    <- sum(in_win)
    ici <- if (n_total > 0) n_in / n_total else NA_real_
    ci <- if (n_total > 1 && n_bootstrap > 0)
      .boot_quantile_ci(as.integer(in_win), n_bootstrap,
                        fun = mean)
    else c(NA_real_, NA_real_)
    tibble::tibble(
      n_total             = n_total,
      n_treated_in_window = n_in,
      ici                 = ici,
      ici_ci_lo           = ci[1],
      ici_ci_hi           = ci[2]
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

  result$ihl_critical <- !is.na(result$ici) & result$ici < 0.80
  result$window_min   <- window_min_norm
  result$window_unit  <- window_unit
  result
}

# Re-export alias used inside compute_ihl_index's caption
.bootstrap_ici <- function(d, group_vars, window_min, n_boot) {
  # Kept for API compatibility with older call sites; delegates
  # to inline bootstrap in compute_ihl_index().
  invisible(NULL)
}
