#' Quantify policy effect (policy A vs. policy B)
#'
#' Computes the full suite of effect metrics comparing two scenarios
#' that differ only in the allocation policy. Returns deltas on the
#' event rate and the Compliance Index, Cohen's d, risk differences
#' and an auto-generated narrative suitable for pasting into a
#' report.
#'
#' No hardcoded defaults are used - you **must** supply both scenario
#' IDs explicitly, so that the same function works for Profile A
#' (e.g. `"A-S08"` vs. `"A-S07"`) and Profile B (e.g. `"B-S19"` vs.
#' `"B-S00"`).
#'
#' @param data A `dynasimR_data` object or summary tibble.
#' @param policy_a_scenario Character. Scenario ID for policy A.
#' @param policy_b_scenario Character. Scenario ID for policy B
#'   (the comparator).
#' @param alpha Numeric. Significance level. Default `0.05`.
#' @param n_bootstrap Integer. Bootstrap replicates for CIs.
#'   Default `1000`.
#'
#' @return An S3 object of class `dynasimR_policy` with slots
#'   `delta_event`, `compliance_comparison`, `effect_sizes`,
#'   `wilcoxon_tests`, `narrative`, and `params`.
#' @export
#' @examples
#' \dontrun{
#' sim <- load_example_data()
#' pol <- policy_effect(sim,
#'   policy_a_scenario = "A-S08", policy_b_scenario = "A-S07")
#' print(pol)
#' cat(pol$narrative)
#' }
policy_effect <- function(data,
                          policy_a_scenario,
                          policy_b_scenario,
                          alpha       = 0.05,
                          n_bootstrap = 1000) {

  if (missing(policy_a_scenario) || missing(policy_b_scenario))
    cli::cli_abort(
      "Both {.arg policy_a_scenario} and ",
      "{.arg policy_b_scenario} required."
    )

  d <- if (inherits(data, "dynasimR_data")) data$summary else data

  a <- dplyr::filter(d, .data$scenario == policy_a_scenario)
  b <- dplyr::filter(d, .data$scenario == policy_b_scenario)

  if (nrow(a) == 0 || nrow(b) == 0)
    cli::cli_abort(
      "Scenario {.val {policy_a_scenario}} or ",
      "{.val {policy_b_scenario}} not found in data."
    )

  delta_event <- .compute_delta_event(data,
    policy_a_scenario, policy_b_scenario, alpha, n_bootstrap)

  comp_cmp <- .compute_compliance_comparison(a, b,
    policy_a_scenario, policy_b_scenario, alpha, n_bootstrap)

  effects <- .compute_effect_sizes(a, b)

  wtests <- .wilcoxon_by_group(data,
    policy_a_scenario, policy_b_scenario, alpha)

  narrative <- .generate_policy_narrative(
    delta_event, comp_cmp, effects, wtests,
    policy_a_scenario, policy_b_scenario
  )

  structure(
    list(
      delta_event            = delta_event,
      compliance_comparison  = comp_cmp,
      effect_sizes           = effects,
      wilcoxon_tests         = wtests,
      narrative              = narrative,
      params                 = list(
        policy_a_scenario = policy_a_scenario,
        policy_b_scenario = policy_b_scenario,
        alpha             = alpha,
        n_bootstrap       = n_bootstrap,
        n_reps            = nrow(a)
      )
    ),
    class = c("dynasimR_policy", "list")
  )
}

#' @export
print.dynasimR_policy <- function(x, ...) {
  cli::cli_h1("dynasimR_policy")
  cli::cli_bullets(c(
    "*" = "Policy A: {.val {x$params$policy_a_scenario}}",
    "*" = "Policy B: {.val {x$params$policy_b_scenario}}",
    "*" = "n (reps): {.val {x$params$n_reps}}"
  ))
  cli::cli_h2("Delta event rate")
  print(x$delta_event)
  cli::cli_h2("Narrative")
  cat(x$narrative, "\n")
  invisible(x)
}

## ---- Internal helpers ------------------------------------------------

#' @keywords internal
#' @noRd
.compute_delta_event <- function(data, a_id, b_id,
                                 alpha = 0.05, n_boot = 1000) {

  d <- if (inherits(data, "dynasimR_data")) data$summary else data
  a_sum <- dplyr::filter(d, .data$scenario == a_id)
  b_sum <- dplyr::filter(d, .data$scenario == b_id)

  # overall
  a_all <- a_sum$event_rate
  b_all <- b_sum$event_rate
  rows  <- list(
    tibble::tibble(
      group             = "all",
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

  # stratified - requires entity-level data
  ent <- if (inherits(data, "dynasimR_data")) data$entities else NULL
  if (!is.null(ent) && "group" %in% names(ent)) {
    strat <- ent |>
      dplyr::filter(.data$scenario %in% c(a_id, b_id)) |>
      dplyr::group_by(.data$scenario, .data$replication,
                      .data$group) |>
      dplyr::summarise(
        rate = mean(.data$event == 1 |
                    .data$status == "TERMINATED",
                    na.rm = TRUE),
        .groups = "drop"
      )
    for (g in unique(strat$group)) {
      aa <- strat$rate[strat$scenario == a_id &
                       strat$group == g]
      bb <- strat$rate[strat$scenario == b_id &
                       strat$group == g]
      if (length(aa) == 0 || length(bb) == 0) next
      med_diff <- (stats::median(aa, na.rm = TRUE) -
                   stats::median(bb, na.rm = TRUE)) * 100
      if (length(aa) > 1 && length(bb) > 1) {
        ci <- .boot_diff_ci(aa * 100, bb * 100, n_boot,
                            fun = stats::median,
                            probs = c(alpha / 2, 1 - alpha / 2))
      } else {
        ci <- c(NA_real_, NA_real_)
      }
      rows[[length(rows) + 1]] <- tibble::tibble(
        group             = g,
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
.compute_compliance_comparison <- function(a, b, a_id, b_id,
                                           alpha = 0.05,
                                           n_boot = 1000) {

  get_ci <- function(tbl)
    if ("compliance_index" %in% names(tbl))
      tbl$compliance_index else NA_real_

  ca <- get_ci(a)
  cb <- get_ci(b)

  tibble::tibble(
    scenario           = c(a_id, b_id),
    median_compliance  = c(stats::median(ca, na.rm = TRUE),
                           stats::median(cb, na.rm = TRUE)),
    ci_lo              = c(
      .boot_quantile_ci(ca, n_boot,
                        probs = c(alpha / 2, 1 - alpha / 2))[1],
      .boot_quantile_ci(cb, n_boot,
                        probs = c(alpha / 2, 1 - alpha / 2))[1]
    ),
    ci_hi              = c(
      .boot_quantile_ci(ca, n_boot,
                        probs = c(alpha / 2, 1 - alpha / 2))[2],
      .boot_quantile_ci(cb, n_boot,
                        probs = c(alpha / 2, 1 - alpha / 2))[2]
    ),
    n                  = c(length(ca), length(cb))
  )
}

#' @keywords internal
#' @noRd
.compute_effect_sizes <- function(a, b) {
  aa <- a$event_rate
  bb <- b$event_rate

  pooled_sd <- sqrt((stats::var(aa, na.rm = TRUE) +
                     stats::var(bb, na.rm = TRUE)) / 2)
  cohen_d   <- if (pooled_sd > 0)
    (mean(aa, na.rm = TRUE) - mean(bb, na.rm = TRUE)) / pooled_sd
  else NA_real_

  risk_diff <- mean(aa, na.rm = TRUE) - mean(bb, na.rm = TRUE)
  nnt <- if (!is.na(risk_diff) && risk_diff != 0)
    abs(1 / risk_diff) else NA_real_

  tibble::tibble(
    metric = c("Cohen_d_event", "Risk_Difference_event",
               "NNT_surrogate"),
    value  = c(cohen_d, risk_diff, nnt)
  )
}

#' @keywords internal
#' @noRd
.wilcoxon_by_group <- function(data, a_id, b_id, alpha = 0.05) {

  d <- if (inherits(data, "dynasimR_data")) data$summary else data

  # overall
  a_all <- d$event_rate[d$scenario == a_id]
  b_all <- d$event_rate[d$scenario == b_id]
  rows <- list()
  if (length(a_all) > 0 && length(b_all) > 0) {
    wt <- suppressWarnings(stats::wilcox.test(a_all, b_all,
                                              exact = FALSE))
    rows[[1]] <- tibble::tibble(
      group      = "all",
      statistic  = unname(wt$statistic),
      p_raw      = wt$p.value
    )
  }

  # stratified via entities - optional
  ent <- if (inherits(data, "dynasimR_data")) data$entities else NULL
  if (!is.null(ent) && "group" %in% names(ent)) {
    strat <- ent |>
      dplyr::filter(.data$scenario %in% c(a_id, b_id)) |>
      dplyr::group_by(.data$scenario, .data$replication,
                      .data$group) |>
      dplyr::summarise(
        rate = mean(.data$event == 1 |
                    .data$status == "TERMINATED",
                    na.rm = TRUE),
        .groups = "drop"
      )
    for (g in unique(strat$group)) {
      aa <- strat$rate[strat$scenario == a_id &
                       strat$group == g]
      bb <- strat$rate[strat$scenario == b_id &
                       strat$group == g]
      if (length(aa) < 2 || length(bb) < 2) next
      wt <- suppressWarnings(stats::wilcox.test(aa, bb,
                                                exact = FALSE))
      rows[[length(rows) + 1]] <- tibble::tibble(
        group     = g,
        statistic = unname(wt$statistic),
        p_raw     = wt$p.value
      )
    }
  }

  if (length(rows) == 0)
    return(tibble::tibble(group = character(),
                          statistic = numeric(),
                          p_raw = numeric(),
                          p_adjusted = numeric()))

  out <- dplyr::bind_rows(rows)
  out$p_adjusted <- stats::p.adjust(out$p_raw, method = "BH")
  out
}

#' @keywords internal
#' @noRd
.generate_policy_narrative <- function(delta, comp, effects, tests,
                                       a_id, b_id) {

  safe <- function(x) if (length(x) == 0) NA_real_ else x[1]

  all_row <- delta[delta$group == "all", ]
  d_med <- safe(all_row$median_pct_points)
  d_lo  <- safe(all_row$ci_lo)
  d_hi  <- safe(all_row$ci_hi)

  w_all <- tests[tests$group == "all", ]
  w_w   <- safe(w_all$statistic)
  w_p   <- safe(w_all$p_adjusted)

  c_a <- safe(comp$median_compliance[comp$scenario == a_id])
  c_b <- safe(comp$median_compliance[comp$scenario == b_id])

  p_str <- .format_p(w_p)

  glue::glue(
    "Under policy A (scenario {a_id}), an event-rate reduction of ",
    "{round(abs(d_med), 1)} percentage points (95\\%-CI: ",
    "{round(d_lo, 1)} to {round(d_hi, 1)}) was observed versus ",
    "policy B (scenario {b_id}) (Wilcoxon test: W = ",
    "{round(w_w, 0)}, p {p_str}). The Compliance Index was higher ",
    "under policy A ({round(c_a, 3)} vs. {round(c_b, 3)})."
  )
}
