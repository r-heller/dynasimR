#' Scenario metadata for MEDTACS-SIM and REHASIM
#'
#' Describes all simulation scenarios (MEDTACS M-S00..M-S14 and REHASIM
#' R-S00..R-S20) with their research-question mapping, doctrine
#' principle, UAV configuration and autonomy level.
#'
#' @format A tibble with 35 rows and the following columns:
#' \describe{
#'   \item{id}{Character. Scenario identifier with prefix
#'     (`"M-"` for MEDTACS, `"R-"` for REHASIM).}
#'   \item{simulation}{Character. `"MEDTACS"` or `"REHASIM"`.}
#'   \item{label}{Character. Human-readable scenario name.}
#'   \item{rq}{Character. Associated research question
#'     (`"RQ1"`..`"RQ4"`, `"SENS"`, `"PIPE"`).}
#'   \item{doctrine}{Character. Doctrine principle
#'     (`"MUF"`, `"MIL_NEC"`, `"MIXED"`, `"NA"`).}
#'   \item{uav}{Character. UAV configuration
#'     (`"NONE"`, `"ISR"`, `"CASEVAC"`, `"ARMED"`, `"MIXED"`).}
#'   \item{al}{Integer. Autonomy level (0-5) or NA.}
#' }
#' @source MEDTACS-SIM and REHASIM concept papers (Heller 2026).
"scenario_meta"

#' Weibull survival parameters by triage category
#'
#' Literature-derived Weibull shape and scale parameters for modelling
#' time-to-death in combat casualties, stratified by Triage category
#' (T1-T4).
#'
#' @format A tibble with 4 rows and the following columns:
#' \describe{
#'   \item{category}{Character. Triage category (`"T1"`..`"T4"`).}
#'   \item{k}{Numeric. Weibull shape parameter.}
#'   \item{lambda}{Numeric. Weibull scale parameter in minutes.}
#'   \item{source}{Character. Primary literature source.}
#' }
#' @source Eastridge et al. (2012) J Trauma 73:S431; Kotwal et al.
#'   (2016) JAMA Surg 151:15.
"survival_params"
