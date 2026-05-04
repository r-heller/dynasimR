#' Scenario metadata for Profile A and Profile B
#'
#' Describes all supported simulation scenarios
#' (Profile A: A-S00..A-S14; Profile B: B-S00..B-S20) with their
#' research-question mapping, policy, resource configuration and
#' autonomy level.
#'
#' @format A tibble with 36 rows and the following columns:
#' \describe{
#'   \item{id}{Character. Scenario identifier with prefix
#'     (`"A-"` for Profile A, `"B-"` for Profile B).}
#'   \item{profile}{Character. `"Profile_A"` or `"Profile_B"`.}
#'   \item{label}{Character. Human-readable scenario name.}
#'   \item{rq}{Character. Associated research question tag
#'     (`"RQ1"`..`"RQ4"`, `"SENS"`, `"PIPE"`).}
#'   \item{policy}{Character. Policy type
#'     (`"policy_a"`, `"policy_b"`, `"mixed"`, `"NA"`).}
#'   \item{resource}{Character. Auxiliary-resource configuration
#'     (`"none"`, `"observation"`, `"transport"`, `"active"`,
#'     `"mixed"`).}
#'   \item{al}{Integer. Autonomy level (0-5) or `NA`.}
#' }
#' @source Package example data.
"scenario_meta"

#' Example Weibull event-time parameters by priority category
#'
#' Illustrative Weibull shape and scale parameters for modelling
#' time-to-event trajectories, stratified by priority category
#' (P1-P4). Values are provided as a starting point and can be
#' replaced by domain-specific values for a particular application.
#'
#' @format A tibble with 4 rows and the following columns:
#' \describe{
#'   \item{category}{Character. Priority category
#'     (`"P1"`..`"P4"`).}
#'   \item{k}{Numeric. Weibull shape parameter.}
#'   \item{lambda}{Numeric. Weibull scale parameter (time units).}
#'   \item{source}{Character. Source note.}
#' }
#' @source Package example data.
"survival_params"
