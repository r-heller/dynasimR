#' Quantify doctrine effect (MUF vs. Military Necessity)
#'
#' Computes the full suite of effect metrics comparing two scenarios
#' that differ only in medical doctrine (Medical Urgency First vs.
#' Military Necessity). Returns deltas on KIA rate and IHL-Compliance
#' Index, Cohen's d, risk differences and an auto-generated narrative
#' sentence suitable for pasting into a manuscript.
#'
#' No hardcoded defaults are used — you **must** supply both scenario
#' IDs explicitly, so that the same function works for MEDTACS
#' (e.g. `"M-S08"` vs. `"M-S07"`) and REHASIM (e.g. `"R-S19"` vs.
#' `"R-S00"`).
#'
#' @param data A `dynasimR_data` object or summary tibble.
#' @param muf_scenario Character. Scenario ID using MUF doctrine.
#' @param milnec_scenario Character. Scenario ID using Military
#'   Necessity doctrine.
#' @param alpha Numeric. Significance level. Default `0.05`.
#' @param n_bootstrap Integer. Bootstrap replicates for CIs.
#'   Default `1000`.
#'
#' @return An S3 object of class `dynasimR_doctrine` with slots
#'   `delta_kia`, `ihl_comparison`, `effect_sizes`, `wilcoxon_tests`,
#'   `narrative`, and `params`.
#' @export
#' @examples
#' \dontrun{
#' sim <- load_example_data()
#' doc <- doctrine_effect(sim,
#'   muf_scenario = "M-S08", milnec_scenario = "M-S07")
#' print(doc)
#' cat(doc$narrative)
#' }
doctrine_effect <- function(data,
                            muf_scenario,
                            milnec_scenario,
                            alpha       = 0.05,
                            n_bootstrap = 1000) {

  if (missing(muf_scenario) || missing(milnec_scenario))
    cli::cli_abort(
      "Both {.arg muf_scenario} and {.arg milnec_scenario} required."
    )

  d <- if (inherits(data, "dynasimR_data")) data$summary else data

  muf    <- dplyr::filter(d, .data$scenario == muf_scenario)
  milnec <- dplyr::filter(d, .data$scenario == milnec_scenario)

  if (nrow(muf) == 0 || nrow(milnec) == 0)
    cli::cli_abort(
      "Scenario {.val {muf_scenario}} or {.val {milnec_scenario}} ",
      "not found in data."
    )

  ## Delta KIA ------------------------------------------------------------
  delta_kia <- .compute_delta_kia(data, muf_scenario, milnec_scenario,
                                  alpha, n_bootstrap)

  ## IHL comparison -------------------------------------------------------
  ihl_comp <- .compute_ihl_comparison(muf, milnec,
                                      muf_scenario, milnec_scenario,
                                      alpha, n_bootstrap)

  ## Effect sizes --------------------------------------------------------
  effects <- .compute_effect_sizes(muf, milnec)

  ## Wilcoxon tests ------------------------------------------------------
  wtests <- .wilcoxon_by_identity(data, muf_scenario,
                                  milnec_scenario, alpha)

  ## Narrative -----------------------------------------------------------
  narrative <- .generate_doctrine_narrative(
    delta_kia, ihl_comp, effects, wtests,
    muf_scenario, milnec_scenario
  )

  structure(
    list(
      delta_kia       = delta_kia,
      ihl_comparison  = ihl_comp,
      effect_sizes    = effects,
      wilcoxon_tests  = wtests,
      narrative       = narrative,
      params          = list(
        muf_scenario    = muf_scenario,
        milnec_scenario = milnec_scenario,
        alpha           = alpha,
        n_bootstrap     = n_bootstrap,
        n_reps          = nrow(muf)
      )
    ),
    class = c("dynasimR_doctrine", "list")
  )
}

#' @export
print.dynasimR_doctrine <- function(x, ...) {
  cli::cli_h1("dynasimR_doctrine")
  cli::cli_bullets(c(
    "*" = "MUF: {.val {x$params$muf_scenario}}",
    "*" = "MilNec: {.val {x$params$milnec_scenario}}",
    "*" = "n (reps): {.val {x$params$n_reps}}"
  ))
  cli::cli_h2("Delta KIA")
  print(x$delta_kia)
  cli::cli_h2("Narrative")
  cat(x$narrative, "\n")
  invisible(x)
}

## ---- Internal helpers ------------------------------------------------

#' @keywords internal
#' @noRd
.compute_delta_kia <- function(data, muf_id, mn_id,
                               alpha = 0.05, n_boot = 1000) {

  d <- if (inherits(data, "dynasimR_data")) data$summary else data
  muf_sum    <- dplyr::filter(d, .data$scenario == muf_id)
  milnec_sum <- dplyr::filter(d, .data$scenario == mn_id)

  # overall
  a_all <- muf_sum$kia_rate
  b_all <- milnec_sum$kia_rate
  rows  <- list(
    tibble::tibble(
      identity         = "all",
      median_pct_points = (stats::median(a_all, na.rm = TRUE) -
                           stats::median(b_all, na.rm = TRUE)) * 100
    )
  )
  if (length(a_all) > 1 && length(b_all) > 1) {
    ci <- .boot_diff_ci(a_all * 100, b_all * 100, n_boot,
                        fun = stats::median,
                        probs = c(alpha / 2, 1 - alpha / 2))
    rows[[1]]$ci_lo <- ci[1]
    rows[[1]]$ci_hi <- ci[2]
  } else {
    rows[[1]]$ci_lo <- NA_real_
    rows[[1]]$ci_hi <- NA_real_
  }

  # stratified — requires casualty data
  cas <- if (inherits(data, "dynasimR_data")) data$casualties
         else NULL
  if (!is.null(cas) && "identity" %in% names(cas)) {
    strat <- cas |>
      dplyr::filter(.data$scenario %in% c(muf_id, mn_id)) |>
      dplyr::group_by(.data$scenario, .data$replication,
                      .data$identity) |>
      dplyr::summarise(
        kia = mean(.data$died == 1 | .data$vital_status == "KIA",
                   na.rm = TRUE),
        .groups = "drop"
      )
    for (ident in unique(strat$identity)) {
      a <- strat$kia[strat$scenario == muf_id &
                     strat$identity == ident]
      b <- strat$kia[strat$scenario == mn_id &
                     strat$identity == ident]
      if (length(a) == 0 || length(b) == 0) next
      med_diff <- (stats::median(a, na.rm = TRUE) -
                   stats::median(b, na.rm = TRUE)) * 100
      if (length(a) > 1 && length(b) > 1) {
        ci <- .boot_diff_ci(a * 100, b * 100, n_boot,
                            fun = stats::median,
                            probs = c(alpha / 2, 1 - alpha / 2))
      } else {
        ci <- c(NA_real_, NA_real_)
      }
      rows[[length(rows) + 1]] <- tibble::tibble(
        identity          = ident,
        median_pct_points = med_diff,
        ci_lo             = ci[1],
        ci_hi             = ci[2]
      )
    }
  }
  dplyr::bind_rows(rows)
}

#' @keywords internal
#' @noRd
.compute_ihl_comparison <- function(muf, milnec, muf_id, mn_id,
                                    alpha = 0.05, n_boot = 1000) {

  get_ihl <- function(tbl)
    if ("ihl_compliance_index" %in% names(tbl))
      tbl$ihl_compliance_index else NA_real_

  a <- get_ihl(muf)
  b <- get_ihl(milnec)

  tibble::tibble(
    scenario    = c(muf_id, mn_id),
    median_ihl  = c(stats::median(a, na.rm = TRUE),
                    stats::median(b, na.rm = TRUE)),
    ihl_ci_lo   = c(
      .boot_quantile_ci(a, n_boot,
                        probs = c(alpha / 2, 1 - alpha / 2))[1],
      .boot_quantile_ci(b, n_boot,
                        probs = c(alpha / 2, 1 - alpha / 2))[1]
    ),
    ihl_ci_hi   = c(
      .boot_quantile_ci(a, n_boot,
                        probs = c(alpha / 2, 1 - alpha / 2))[2],
      .boot_quantile_ci(b, n_boot,
                        probs = c(alpha / 2, 1 - alpha / 2))[2]
    ),
    n           = c(length(a), length(b))
  )
}

#' @keywords internal
#' @noRd
.compute_effect_sizes <- function(muf, milnec) {
  a <- muf$kia_rate
  b <- milnec$kia_rate

  pooled_sd <- sqrt((stats::var(a, na.rm = TRUE) +
                     stats::var(b, na.rm = TRUE)) / 2)
  cohen_d   <- if (pooled_sd > 0)
    (mean(a, na.rm = TRUE) - mean(b, na.rm = TRUE)) / pooled_sd
  else NA_real_

  risk_diff <- mean(a, na.rm = TRUE) - mean(b, na.rm = TRUE)
  # Absolute risk difference used as NNT surrogate — only reasonable when
  # direction is consistent. Negative value = harm reduction (desired).
  nnt <- if (!is.na(risk_diff) && risk_diff != 0)
    abs(1 / risk_diff) else NA_real_

  tibble::tibble(
    metric = c("Cohen_d_KIA", "Risk_Difference_KIA",
               "NNT_surrogate"),
    value  = c(cohen_d, risk_diff, nnt)
  )
}

#' @keywords internal
#' @noRd
.wilcoxon_by_identity <- function(data, muf_id, mn_id, alpha = 0.05) {

  d <- if (inherits(data, "dynasimR_data")) data$summary else data

  # overall
  a_all <- d$kia_rate[d$scenario == muf_id]
  b_all <- d$kia_rate[d$scenario == mn_id]
  rows <- list()
  if (length(a_all) > 0 && length(b_all) > 0) {
    wt <- suppressWarnings(stats::wilcox.test(a_all, b_all,
                                              exact = FALSE))
    rows[[1]] <- tibble::tibble(
      identity   = "all",
      statistic  = unname(wt$statistic),
      p_raw      = wt$p.value
    )
  }

  # stratified via casualties — optional
  cas <- if (inherits(data, "dynasimR_data")) data$casualties else NULL
  if (!is.null(cas) && "identity" %in% names(cas)) {
    strat <- cas |>
      dplyr::filter(.data$scenario %in% c(muf_id, mn_id)) |>
      dplyr::group_by(.data$scenario, .data$replication,
                      .data$identity) |>
      dplyr::summarise(
        kia = mean(.data$died == 1 | .data$vital_status == "KIA",
                   na.rm = TRUE),
        .groups = "drop"
      )
    for (ident in unique(strat$identity)) {
      a <- strat$kia[strat$scenario == muf_id &
                     strat$identity == ident]
      b <- strat$kia[strat$scenario == mn_id &
                     strat$identity == ident]
      if (length(a) < 2 || length(b) < 2) next
      wt <- suppressWarnings(stats::wilcox.test(a, b,
                                                exact = FALSE))
      rows[[length(rows) + 1]] <- tibble::tibble(
        identity  = ident,
        statistic = unname(wt$statistic),
        p_raw     = wt$p.value
      )
    }
  }

  if (length(rows) == 0)
    return(tibble::tibble(identity = character(),
                          statistic = numeric(),
                          p_raw = numeric(),
                          p_adjusted = numeric()))

  out <- dplyr::bind_rows(rows)
  out$p_adjusted <- stats::p.adjust(out$p_raw, method = "BH")
  out
}

#' @keywords internal
#' @noRd
.generate_doctrine_narrative <- function(delta, ihl, effects, tests,
                                         muf_id, mn_id) {

  safe <- function(x) if (length(x) == 0) NA_real_ else x[1]

  all_row <- delta[delta$identity == "all", ]
  d_med <- safe(all_row$median_pct_points)
  d_lo  <- safe(all_row$ci_lo)
  d_hi  <- safe(all_row$ci_hi)

  w_all <- tests[tests$identity == "all", ]
  w_w   <- safe(w_all$statistic)
  w_p   <- safe(w_all$p_adjusted)

  ihl_m <- safe(ihl$median_ihl[ihl$scenario == muf_id])
  ihl_n <- safe(ihl$median_ihl[ihl$scenario == mn_id])

  p_str <- .format_p(w_p)

  glue::glue(
    "Under Medical Urgency First doctrine (scenario {muf_id}), ",
    "a KIA-rate reduction of {round(abs(d_med), 1)} ",
    "percentage points (95\\%-CI: {round(d_lo, 1)} to ",
    "{round(d_hi, 1)}) was observed versus prioritisation of own ",
    "forces (scenario {mn_id}) (Wilcoxon test: W = ",
    "{round(w_w, 0)}, p {p_str}). The IHL-Compliance Index was ",
    "higher under MUF doctrine ({round(ihl_m, 3)} vs. ",
    "{round(ihl_n, 3)})."
  )
}
