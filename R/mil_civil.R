#' Military vs. civilian prioritisation effect (REHASIM)
#'
#' Compares two REHASIM scenarios that differ only in
#' mil/civil prioritisation and returns Return-to-Duty (RTD) rates,
#' cost per RTD and the difference (delta) with bootstrap CIs.
#'
#' @param data A `dynasimR_data` object or summary tibble.
#' @param mil_scenario Character. Scenario ID with military priority.
#' @param civ_scenario Character. Scenario ID with civilian-inclusive
#'   priority.
#' @param outcome_col Character. Column name for RTD outcome.
#'   Default `"rtd_rate"`.
#' @param cost_col Character. Column name for cost metric.
#'   Default `"cost"`.
#' @param alpha Numeric. Significance level. Default `0.05`.
#' @param n_bootstrap Integer. Bootstrap replicates. Default `1000`.
#'
#' @return An S3 object of class `dynasimR_mil_civil` with slots
#'   `rtd`, `cost`, `delta_rtd`, `delta_cost`, `params`.
#' @export
mil_civil_effect <- function(data,
                             mil_scenario,
                             civ_scenario,
                             outcome_col = "rtd_rate",
                             cost_col    = "cost",
                             alpha       = 0.05,
                             n_bootstrap = 1000) {

  if (missing(mil_scenario) || missing(civ_scenario))
    cli::cli_abort(
      "Both {.arg mil_scenario} and {.arg civ_scenario} required."
    )

  d <- if (inherits(data, "dynasimR_data")) data$summary else data
  .require_cols(d, c("scenario", outcome_col),
                where = "summary")
  has_cost <- cost_col %in% names(d)

  mil <- dplyr::filter(d, .data$scenario == mil_scenario)
  civ <- dplyr::filter(d, .data$scenario == civ_scenario)
  if (nrow(mil) == 0 || nrow(civ) == 0)
    cli::cli_abort(
      "Scenario {.val {mil_scenario}} or {.val {civ_scenario}} not found."
    )

  a <- mil[[outcome_col]]
  b <- civ[[outcome_col]]

  rtd <- tibble::tibble(
    scenario = c(mil_scenario, civ_scenario),
    n        = c(length(a), length(b)),
    median   = c(stats::median(a, na.rm = TRUE),
                 stats::median(b, na.rm = TRUE)),
    q025     = c(stats::quantile(a, 0.025, na.rm = TRUE,
                                 names = FALSE),
                 stats::quantile(b, 0.025, na.rm = TRUE,
                                 names = FALSE)),
    q975     = c(stats::quantile(a, 0.975, na.rm = TRUE,
                                 names = FALSE),
                 stats::quantile(b, 0.975, na.rm = TRUE,
                                 names = FALSE))
  )

  delta_rtd_ci <- if (length(a) > 1 && length(b) > 1)
    .boot_diff_ci(a, b, n_bootstrap, fun = stats::median,
                  probs = c(alpha / 2, 1 - alpha / 2))
  else c(NA_real_, NA_real_)

  delta_rtd <- tibble::tibble(
    delta_median = stats::median(a, na.rm = TRUE) -
                   stats::median(b, na.rm = TRUE),
    ci_lo        = delta_rtd_ci[1],
    ci_hi        = delta_rtd_ci[2]
  )

  cost_out <- NULL
  delta_cost <- NULL
  if (has_cost) {
    ca <- mil[[cost_col]]
    cb <- civ[[cost_col]]
    cost_out <- tibble::tibble(
      scenario     = c(mil_scenario, civ_scenario),
      median_cost  = c(stats::median(ca, na.rm = TRUE),
                       stats::median(cb, na.rm = TRUE))
    )
    dc_ci <- if (length(ca) > 1 && length(cb) > 1)
      .boot_diff_ci(ca, cb, n_bootstrap, fun = stats::median,
                    probs = c(alpha / 2, 1 - alpha / 2))
    else c(NA_real_, NA_real_)
    delta_cost <- tibble::tibble(
      delta_median = stats::median(ca, na.rm = TRUE) -
                     stats::median(cb, na.rm = TRUE),
      ci_lo        = dc_ci[1],
      ci_hi        = dc_ci[2]
    )
  }

  structure(
    list(
      rtd         = rtd,
      cost        = cost_out,
      delta_rtd   = delta_rtd,
      delta_cost  = delta_cost,
      params      = list(
        mil_scenario = mil_scenario,
        civ_scenario = civ_scenario,
        outcome_col  = outcome_col,
        cost_col     = cost_col,
        alpha        = alpha,
        n_bootstrap  = n_bootstrap
      )
    ),
    class = c("dynasimR_mil_civil", "list")
  )
}

#' Return-to-Duty outcome analysis (multinomial)
#'
#' Fits a multinomial logistic regression of RTD outcome
#' (categorical) on scenario + covariates. Returns the model, tidied
#' coefficients, and class-level proportions.
#'
#' @param data A `dynasimR_data` object or casualty tibble with an
#'   `rtd_outcome` column (factor).
#' @param covariates Character vector. Additional predictors.
#'   Default `c("scenario", "injury_severity")`.
#' @return An S3 object of class `dynasimR_rtd` with slots `fit`,
#'   `tidy`, `proportions`, `params`.
#' @export
compute_rtd_analysis <- function(data,
                                 covariates = c("scenario",
                                                "injury_severity")) {

  d <- if (inherits(data, "dynasimR_data")) data$casualties else data
  if (!"rtd_outcome" %in% names(d))
    cli::cli_abort("Casualty table needs 'rtd_outcome' column.")

  covariates <- intersect(covariates, names(d))
  if (length(covariates) == 0)
    cli::cli_abort("No valid covariates in data.")

  props <- d |>
    dplyr::group_by(.data$scenario, .data$rtd_outcome) |>
    dplyr::summarise(n = dplyr::n(), .groups = "drop_last") |>
    dplyr::mutate(prop = .data$n / sum(.data$n)) |>
    dplyr::ungroup()

  fit <- NULL
  tidy_out <- NULL
  if (requireNamespace("nnet", quietly = TRUE)) {
    form <- stats::as.formula(paste(
      "rtd_outcome ~", paste(covariates, collapse = " + ")))
    fit <- nnet::multinom(form, data = d, trace = FALSE)
    coefs <- stats::coef(fit)
    if (is.null(dim(coefs))) coefs <- t(as.matrix(coefs))
    tidy_out <- tibble::as_tibble(
      as.data.frame(coefs), rownames = "class"
    )
  } else {
    cli::cli_warn(
      "Package {.pkg nnet} not available; returning proportions only."
    )
  }

  structure(
    list(
      fit         = fit,
      tidy        = tidy_out,
      proportions = props,
      params      = list(covariates = covariates)
    ),
    class = c("dynasimR_rtd", "list")
  )
}
