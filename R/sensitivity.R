#' Morris-style sensitivity screening from simulation replicates
#'
#' Uses per-replicate variation to screen the most influential input
#' parameters on an outcome metric. The implementation is a simple
#' variance-based screening; for a full Morris design use the
#' `sensitivity` package directly and pass the results here for
#' visualisation.
#'
#' @param data A `dynasimR_data` object or summary tibble.
#' @param outcome Character. Column name of the outcome to screen.
#'   Default `"event_rate"`.
#' @param inputs Character vector. Column names of simulation inputs
#'   (must be numeric) to assess.
#'
#' @return A tibble with columns `input`, `mu_star` (mean absolute
#'   change), `sigma`, `rank`.
#' @export
morris_screening <- function(data,
                             outcome = "event_rate",
                             inputs) {

  d <- if (inherits(data, "dynasimR_data")) data$summary else data
  .require_cols(d, c(outcome, inputs), where = "summary")

  y <- scale(d[[outcome]])[, 1]
  out <- purrr::map_dfr(inputs, function(nm) {
    x <- scale(d[[nm]])[, 1]
    if (all(is.na(x))) return(NULL)
    fit <- stats::lm(y ~ x)
    s <- summary(fit)
    tibble::tibble(
      input   = nm,
      mu_star = abs(stats::coef(fit)[2]),
      sigma   = s$sigma,
      r2      = s$r.squared
    )
  })
  out |>
    dplyr::arrange(dplyr::desc(.data$mu_star)) |>
    dplyr::mutate(rank = dplyr::row_number())
}

#' Tornado-diagram data from one-at-a-time perturbation
#'
#' Given a baseline scenario and perturbation scenarios, computes the
#' change in the outcome metric for each perturbation relative to the
#' baseline.
#'
#' @param data A `dynasimR_data` object or summary tibble.
#' @param baseline Character. Scenario ID of the baseline.
#' @param perturbations Character vector. Scenario IDs of
#'   one-at-a-time perturbations.
#' @param outcome Character. Column name of the outcome to measure.
#'   Default `"event_rate"`.
#'
#' @return A tibble suitable for a tornado plot with columns
#'   `scenario`, `delta`, `lo`, `hi`, sorted by absolute delta.
#' @export
tornado_data <- function(data,
                         baseline,
                         perturbations,
                         outcome = "event_rate") {

  d <- if (inherits(data, "dynasimR_data")) data$summary else data
  .require_cols(d, c("scenario", outcome), where = "summary")

  base <- d[[outcome]][d$scenario == baseline]
  if (length(base) == 0)
    cli::cli_abort("Baseline {.val {baseline}} not in data.")
  base_med <- stats::median(base, na.rm = TRUE)

  purrr::map_dfr(perturbations, function(sc) {
    vals <- d[[outcome]][d$scenario == sc]
    if (length(vals) == 0) return(NULL)
    med <- stats::median(vals, na.rm = TRUE)
    q <- stats::quantile(vals, c(0.025, 0.975),
                         na.rm = TRUE, names = FALSE)
    tibble::tibble(
      scenario = sc,
      delta    = med - base_med,
      lo       = q[1] - base_med,
      hi       = q[2] - base_med
    )
  }) |>
    dplyr::arrange(dplyr::desc(abs(.data$delta)))
}
