#' Between-group prioritisation effect (Profile B)
#'
#' Compares two Profile B scenarios that differ only in inclusion
#' rules for which groups are prioritised, and returns completion
#' rates, cost per completion and the difference (delta) with
#' bootstrap CIs.
#'
#' @param data A `dynasimR_data` object or summary tibble.
#' @param group_a_scenario Character. Scenario ID for group A
#'   priority.
#' @param group_b_scenario Character. Scenario ID for group B
#'   priority.
#' @param outcome_col Character. Column name for the completion
#'   outcome. Default `"completion_rate"`.
#' @param cost_col Character. Column name for cost metric.
#'   Default `"cost"`.
#' @param alpha Numeric. Significance level. Default `0.05`.
#' @param n_bootstrap Integer. Bootstrap replicates. Default `1000`.
#'
#' @return An S3 object of class `dynasimR_group_effect` with slots
#'   `completion`, `cost`, `delta_completion`, `delta_cost`,
#'   `params`.
#' @export
group_effect <- function(data,
                         group_a_scenario,
                         group_b_scenario,
                         outcome_col = "completion_rate",
                         cost_col    = "cost",
                         alpha       = 0.05,
                         n_bootstrap = 1000) {

  if (missing(group_a_scenario) || missing(group_b_scenario))
    cli::cli_abort(
      "Both {.arg group_a_scenario} and ",
      "{.arg group_b_scenario} required."
    )

  d <- if (inherits(data, "dynasimR_data")) data$summary else data
  .require_cols(d, c("scenario", outcome_col),
                where = "summary")
  has_cost <- cost_col %in% names(d)

  ga <- dplyr::filter(d, .data$scenario == group_a_scenario)
  gb <- dplyr::filter(d, .data$scenario == group_b_scenario)
  if (nrow(ga) == 0 || nrow(gb) == 0)
    cli::cli_abort(
      "Scenario {.val {group_a_scenario}} or ",
      "{.val {group_b_scenario}} not found."
    )

  a <- ga[[outcome_col]]
  b <- gb[[outcome_col]]

  completion <- tibble::tibble(
    scenario = c(group_a_scenario, group_b_scenario),
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

  d_ci <- if (length(a) > 1 && length(b) > 1)
    .boot_diff_ci(a, b, n_bootstrap, fun = stats::median,
                  probs = c(alpha / 2, 1 - alpha / 2))
  else c(NA_real_, NA_real_)

  delta_completion <- tibble::tibble(
    delta_median = stats::median(a, na.rm = TRUE) -
                   stats::median(b, na.rm = TRUE),
    ci_lo        = d_ci[1],
    ci_hi        = d_ci[2]
  )

  cost_out <- NULL
  delta_cost <- NULL
  if (has_cost) {
    ca <- ga[[cost_col]]
    cb <- gb[[cost_col]]
    cost_out <- tibble::tibble(
      scenario    = c(group_a_scenario, group_b_scenario),
      median_cost = c(stats::median(ca, na.rm = TRUE),
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
      completion       = completion,
      cost             = cost_out,
      delta_completion = delta_completion,
      delta_cost       = delta_cost,
      params           = list(
        group_a_scenario = group_a_scenario,
        group_b_scenario = group_b_scenario,
        outcome_col      = outcome_col,
        cost_col         = cost_col,
        alpha            = alpha,
        n_bootstrap      = n_bootstrap
      )
    ),
    class = c("dynasimR_group_effect", "list")
  )
}

#' Completion-outcome analysis (multinomial)
#'
#' Fits a multinomial logistic regression of completion outcome
#' (categorical) on scenario + covariates. Returns the model, tidied
#' coefficients, and class-level proportions.
#'
#' @param data A `dynasimR_data` object or entity tibble with a
#'   `completion_outcome` column (factor).
#' @param covariates Character vector. Additional predictors.
#'   Default `c("scenario", "severity")`.
#' @return An S3 object of class `dynasimR_completion` with slots
#'   `fit`, `tidy`, `proportions`, `params`.
#' @export
compute_completion_analysis <- function(data,
                                        covariates = c("scenario",
                                                       "severity")) {

  d <- if (inherits(data, "dynasimR_data")) data$entities else data
  if (!"completion_outcome" %in% names(d))
    cli::cli_abort("Entity table needs 'completion_outcome' column.")

  covariates <- intersect(covariates, names(d))
  if (length(covariates) == 0)
    cli::cli_abort("No valid covariates in data.")

  props <- d |>
    dplyr::group_by(.data$scenario, .data$completion_outcome) |>
    dplyr::summarise(n = dplyr::n(), .groups = "drop_last") |>
    dplyr::mutate(prop = .data$n / sum(.data$n)) |>
    dplyr::ungroup()

  fit <- NULL
  tidy_out <- NULL
  if (requireNamespace("nnet", quietly = TRUE)) {
    form <- stats::as.formula(paste(
      "completion_outcome ~", paste(covariates, collapse = " + ")))
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
    class = c("dynasimR_completion", "list")
  )
}
