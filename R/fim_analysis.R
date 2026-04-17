#' FIM trajectory analysis (REHASIM)
#'
#' Summarises longitudinal Functional Independence Measure (FIM)
#' trajectories by scenario and (optionally) cohort. Returns both a
#' per-replication summary (admission, discharge, gain) and a
#' longitudinal tidy table suitable for [plot_fim_curves()].
#'
#' @param data A `dynasimR_data` object or casualty/summary tibble
#'   that contains at least `fim_admission` and `fim_discharge`.
#' @param group_by Character. Grouping columns. Default
#'   `c("scenario")`.
#' @param longitudinal Logical. If `TRUE`, returns the per-timepoint
#'   trajectories if a `fim_timeseries` slot is present in `data`.
#'
#' @return An S3 object of class `dynasimR_fim` with slots `summary`,
#'   `longitudinal` (if available) and `params`.
#' @export
fim_trajectory_analysis <- function(data,
                                    group_by      = c("scenario"),
                                    longitudinal  = FALSE) {

  src <- if (inherits(data, "dynasimR_data")) data$casualties else data
  if (nrow(src) == 0)
    cli::cli_abort("No casualty rows in input.")

  req <- c("fim_admission", "fim_discharge", group_by)
  .require_cols(src, req, where = "casualties")

  summ <- src |>
    dplyr::group_by(dplyr::across(dplyr::all_of(group_by))) |>
    dplyr::summarise(
      n                  = dplyr::n(),
      fim_adm_median     = stats::median(.data$fim_admission,
                                         na.rm = TRUE),
      fim_dis_median     = stats::median(.data$fim_discharge,
                                         na.rm = TRUE),
      fim_gain_median    = stats::median(
        .data$fim_discharge - .data$fim_admission,
        na.rm = TRUE),
      fim_gain_q025      = stats::quantile(
        .data$fim_discharge - .data$fim_admission,
        0.025, na.rm = TRUE, names = FALSE),
      fim_gain_q975      = stats::quantile(
        .data$fim_discharge - .data$fim_admission,
        0.975, na.rm = TRUE, names = FALSE),
      .groups = "drop"
    )

  long <- NULL
  if (longitudinal && inherits(data, "dynasimR_data") &&
      "fim_timeseries" %in% names(data)) {
    long <- data$fim_timeseries
  } else if (longitudinal && "fim_timeseries" %in% names(src)) {
    long <- src$fim_timeseries
  } else if (longitudinal &&
             inherits(data, "dynasimR_data") &&
             "fim" %in% names(data$timeseries)) {
    long <- data$timeseries |>
      dplyr::group_by(dplyr::across(dplyr::all_of(
        c(group_by, "time_step")))) |>
      dplyr::summarise(
        fim_median = stats::median(.data$fim, na.rm = TRUE),
        fim_q025   = stats::quantile(.data$fim, 0.025,
                                     na.rm = TRUE, names = FALSE),
        fim_q975   = stats::quantile(.data$fim, 0.975,
                                     na.rm = TRUE, names = FALSE),
        .groups    = "drop"
      )
  }

  structure(
    list(
      summary      = summ,
      longitudinal = long,
      params       = list(
        group_by     = group_by,
        longitudinal = longitudinal
      )
    ),
    class = c("dynasimR_fim", "list")
  )
}

#' @export
print.dynasimR_fim <- function(x, ...) {
  cli::cli_h1("dynasimR_fim")
  print(x$summary)
  invisible(x)
}
