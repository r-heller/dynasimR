#' Kaplan-Meier estimator for simulation data
#'
#' Estimates survival functions from simulated entity outcomes.
#' Supports several endpoints for both output profiles.
#'
#' @param data A `dynasimR_data` object or a tibble/data.frame
#'   containing entity-level columns.
#' @param scenarios Character vector. Restrict to these scenario IDs.
#'   Default `NULL` = all.
#' @param endpoint Character. One of `"stage2"`, `"overall"`,
#'   `"service"`, `"regression"`, `"completion"`, `"phase_c"`.
#'   The latter three are Profile-B-only endpoints.
#' @param stratify_by Character vector. Strata variables, e.g.
#'   `"scenario"` or `c("scenario", "group")`.
#' @param ci_method Character. Passed to [survival::survfit()] as
#'   `conf.type`. Default `"log"`.
#' @param n_bootstrap Integer. Bootstrap replicates for KM CIs
#'   (0 = disabled). Default `0`.
#' @param seed Integer. RNG seed for bootstrap. Default `42`.
#'
#' @return An S3 object of class `dynasimR_km` (list) with slots
#'   `fit`, `tidy`, `logrank`, `median_survival`, `boot_ci` and
#'   `params`.
#' @export
#' @examples
#' \dontrun{
#' sim <- load_example_data()
#' km <- km_estimate(sim, endpoint = "stage2",
#'                   stratify_by = "scenario")
#' print(km)
#' plot_km(km)
#' }
km_estimate <- function(data,
                        scenarios   = NULL,
                        endpoint    = c("stage2", "overall", "service",
                                        "regression", "completion",
                                        "phase_c"),
                        stratify_by = "scenario",
                        ci_method   = "log",
                        n_bootstrap = 0,
                        seed        = 42) {

  endpoint <- match.arg(endpoint)

  d <- if (inherits(data, "dynasimR_data")) data$entities else data

  if (!is.null(scenarios))
    d <- dplyr::filter(d, .data$scenario %in% scenarios)

  if (nrow(d) == 0)
    cli::cli_abort("No entity rows after filtering.")

  ## Endpoint -> column names --------------------------------------------
  time_col <- switch(endpoint,
    "stage2"     = "time_to_stage2",
    "overall"    = "event_time",
    "service"    = "time_to_first_service",
    "regression" = "time_to_regression",
    "completion" = "time_to_completion",
    "phase_c"    = "time_to_phase_c"
  )
  event_col <- switch(endpoint,
    "stage2"     = "reached_stage2",
    "overall"    = "event",
    "service"    = "received_service",
    "regression" = "regressed",
    "completion" = "completed",
    "phase_c"    = "reached_phase_c"
  )

  .require_cols(d, c(time_col, event_col, stratify_by),
                where = "entities")

  strat_str <- paste(stratify_by, collapse = " + ")
  f <- stats::as.formula(
    glue::glue("survival::Surv({time_col}, {event_col}) ~ {strat_str}")
  )

  fit <- survival::survfit(f, data = d, conf.type = ci_method)

  tidy_df <- .km_tidy(fit)
  lr      <- .logrank_test(f, d)
  meds    <- .extract_medians(fit)

  boot_ci <- NULL
  if (n_bootstrap > 0)
    boot_ci <- .bootstrap_km_ci(d, f, n_bootstrap, seed)

  structure(
    list(
      fit             = fit,
      tidy            = tidy_df,
      logrank         = lr,
      median_survival = meds,
      boot_ci         = boot_ci,
      params          = list(
        endpoint    = endpoint,
        stratify_by = stratify_by,
        ci_method   = ci_method,
        n_scenarios = length(unique(d$scenario)),
        n_obs       = nrow(d),
        seed        = seed
      )
    ),
    class = c("dynasimR_km", "list")
  )
}

#' @export
print.dynasimR_km <- function(x, ...) {
  cli::cli_h1("dynasimR_km")
  cli::cli_bullets(c(
    "*" = "Endpoint: {.val {x$params$endpoint}}",
    "*" = "Stratify by: {.val {x$params$stratify_by}}",
    "*" = "N scenarios: {.val {x$params$n_scenarios}}",
    "*" = "N observations: {.val {x$params$n_obs}}",
    "*" = "Log-rank p: {.val {signif(x$logrank$p_value, 3)}}"
  ))
  invisible(x)
}

#' @export
plot.dynasimR_km <- function(x, ...) plot_km(x, ...)

#' Cox proportional-hazards model for simulation data
#'
#' @param data A `dynasimR_data` object or entity tibble.
#' @param endpoint See [km_estimate()].
#' @param covariates Character vector. Covariates entering the Cox
#'   model. Default `c("scenario","severity","group")`.
#' @param reference_scenario Character. Reference level for the
#'   `scenario` factor. Default `"A-S00"`. Use `"B-S00"` for Profile B.
#' @return An S3 object of class `dynasimR_cox` with slots `fit`,
#'   `tidy`, `ph_test`, `forest_data` and `params`.
#' @export
cox_model <- function(data,
                      endpoint           = c("stage2", "overall",
                                             "service"),
                      covariates         = c("scenario",
                                             "severity",
                                             "group"),
                      reference_scenario = "A-S00") {

  endpoint <- match.arg(endpoint)
  d <- if (inherits(data, "dynasimR_data")) data$entities else data

  ## keep only existing covariates (drops "group" for Profile B) ---------
  covariates <- intersect(covariates, names(d))
  if (length(covariates) == 0)
    cli::cli_abort("None of the requested covariates are in data.")

  if ("scenario" %in% covariates &&
      reference_scenario %in% d$scenario)
    d$scenario <- stats::relevel(factor(d$scenario),
                                 ref = reference_scenario)

  time_col <- switch(endpoint,
    "stage2"  = "time_to_stage2",
    "overall" = "event_time",
    "service" = "time_to_first_service"
  )
  event_col <- switch(endpoint,
    "stage2"  = "reached_stage2",
    "overall" = "event",
    "service" = "received_service"
  )

  .require_cols(d, c(time_col, event_col), where = "entities")

  cov_str <- paste(covariates, collapse = " + ")
  f <- stats::as.formula(
    glue::glue("survival::Surv({time_col}, {event_col}) ~ {cov_str}")
  )

  fit    <- survival::coxph(f, data = d)
  ph_res <- survival::cox.zph(fit)

  tidy_hr <- .cox_tidy(fit)
  forest  <- dplyr::filter(tidy_hr, grepl("scenario", .data$term)) |>
    dplyr::mutate(term = sub("scenario", "", .data$term))

  structure(
    list(
      fit         = fit,
      tidy        = tidy_hr,
      ph_test     = .phtest_tidy(ph_res),
      forest_data = forest,
      params      = list(
        endpoint           = endpoint,
        covariates         = covariates,
        reference_scenario = reference_scenario,
        n_obs              = nrow(d)
      )
    ),
    class = c("dynasimR_cox", "list")
  )
}

#' @export
print.dynasimR_cox <- function(x, ...) {
  cli::cli_h1("dynasimR_cox")
  cli::cli_bullets(c(
    "*" = "Endpoint: {.val {x$params$endpoint}}",
    "*" = "Covariates: {.val {x$params$covariates}}",
    "*" = "Reference: {.val {x$params$reference_scenario}}",
    "*" = "N: {.val {x$params$n_obs}}"
  ))
  print(x$tidy)
  invisible(x)
}

## ---- Internal helpers ------------------------------------------------

#' @keywords internal
#' @noRd
.km_tidy <- function(fit) {
  if (requireNamespace("broom", quietly = TRUE))
    return(tibble::as_tibble(broom::tidy(fit)))

  # Manual fallback -------------------------------------------------------
  s <- summary(fit, censored = TRUE)
  strata <- if (is.null(s$strata)) rep("all", length(s$time))
            else as.character(s$strata)
  tibble::tibble(
    time      = s$time,
    n.risk    = s$n.risk,
    n.event   = s$n.event,
    n.censor  = s$n.censor,
    estimate  = s$surv,
    conf.low  = if (is.null(s$lower)) NA_real_ else s$lower,
    conf.high = if (is.null(s$upper)) NA_real_ else s$upper,
    strata    = strata
  )
}

#' @keywords internal
#' @noRd
.cox_tidy <- function(fit) {
  if (requireNamespace("broom", quietly = TRUE)) {
    out <- broom::tidy(fit, exponentiate = TRUE, conf.int = TRUE)
  } else {
    coefs <- summary(fit)$coefficients
    ci    <- summary(fit)$conf.int
    out <- tibble::tibble(
      term      = rownames(coefs),
      estimate  = ci[, 1],
      std.error = coefs[, 3],
      statistic = coefs[, 4],
      p.value   = coefs[, 5],
      conf.low  = ci[, 3],
      conf.high = ci[, 4]
    )
  }
  dplyr::rename(out, HR = "estimate",
                CI_low = "conf.low", CI_high = "conf.high") |>
    dplyr::mutate(sig = dplyr::case_when(
      p.value < 0.001 ~ "***",
      p.value < 0.01  ~ "**",
      p.value < 0.05  ~ "*",
      TRUE            ~ "ns"
    ))
}

#' @keywords internal
#' @noRd
.phtest_tidy <- function(ph_res) {
  tab <- ph_res$table
  tibble::tibble(
    term        = rownames(tab),
    chisq       = tab[, "chisq"],
    df          = tab[, "df"],
    p.value     = tab[, "p"]
  )
}

#' @keywords internal
#' @noRd
.logrank_test <- function(formula, data) {
  res <- survival::survdiff(formula, data = data)
  pval <- stats::pchisq(res$chisq, length(res$n) - 1, lower.tail = FALSE)
  tibble::tibble(
    chisq   = res$chisq,
    df      = length(res$n) - 1,
    p_value = pval
  )
}

#' @keywords internal
#' @noRd
.extract_medians <- function(fit) {
  s <- summary(fit)$table
  if (is.null(dim(s))) {
    med <- unname(s["median"])
    return(tibble::tibble(strata = "all", median = med))
  }
  tibble::tibble(
    strata = rownames(s),
    median = s[, "median"]
  )
}

#' @keywords internal
#' @noRd
.bootstrap_km_ci <- function(data, formula, n_boot, seed = 42) {
  set.seed(seed)
  ids <- seq_len(nrow(data))
  boots <- purrr::map(seq_len(n_boot), function(i) {
    idx <- sample(ids, length(ids), replace = TRUE)
    fit <- tryCatch(
      survival::survfit(formula, data = data[idx, , drop = FALSE]),
      error = function(e) NULL
    )
    if (is.null(fit)) return(NULL)
    tibble::tibble(
      rep      = i,
      time     = summary(fit, censored = TRUE)$time,
      estimate = summary(fit, censored = TRUE)$surv
    )
  })
  dplyr::bind_rows(purrr::compact(boots))
}

#' @keywords internal
#' @noRd
.km_caption <- function(km_result, show_pval = TRUE) {
  base <- glue::glue(
    "n = {km_result$params$n_obs}, ",
    "scenarios = {km_result$params$n_scenarios}, ",
    "endpoint = {km_result$params$endpoint}"
  )
  if (show_pval && !is.null(km_result$logrank)) {
    pv <- km_result$logrank$p_value
    pvt <- .format_p(pv)
    base <- paste0(base, "; log-rank p ", pvt)
  }
  base
}
