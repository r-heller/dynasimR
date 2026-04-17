#' dynasimR: Dynamic Agent-Node Simulation Analysis
#'
#' Analysis and visualisation layer for discrete-event, agent-based and
#' node-actor simulation outputs. Primary application is the
#' MEDTACS-SIM military medical simulation (chain of resuscitation,
#' doctrine effects, autonomy trade-offs) and the REHASIM rehabilitation
#' flow simulation (FIM trajectories, waiting-gap index, supply-demand).
#'
#' The package is schema-harmonised so that both simulations can be
#' analysed with the same API. See the vignettes for worked examples.
#'
#' @section Key functions:
#' \describe{
#'   \item{Data I/O}{[read_simulation()], [load_example_data()],
#'     [validate_dynasimR_data()]}
#'   \item{Survival}{[km_estimate()], [cox_model()]}
#'   \item{Doctrine}{[doctrine_effect()]}
#'   \item{Autonomy}{[al_efficiency()]}
#'   \item{IHL}{[compute_ihl_index()]}
#'   \item{Patient flow}{[role_throughput()], [detect_bottlenecks()]}
#'   \item{UAV}{[uav_comparison()]}
#'   \item{Sensitivity}{[morris_screening()], [tornado_data()]}
#'   \item{REHASIM}{[fim_trajectory_analysis()],
#'     [compute_waiting_gap_index()], [mil_civil_effect()],
#'     [spatial_supply_demand()], [compute_rtd_analysis()]}
#'   \item{Plots}{[plot_km()], [plot_forest()], [plot_al_tradeoff()],
#'     [plot_scenario_heatmap()], [plot_doctrine()], [plot_timeline()],
#'     [plot_map()], [plot_fim_curves()], [plot_sdi_map()],
#'     [plot_cost_effectiveness()]}
#'   \item{Export}{[export_figure()], [export_latex_table()],
#'     [fill_placeholders()]}
#'   \item{Shiny}{[launch_app()], [check_app_dependencies()]}
#' }
#'
#' @keywords internal
#' @name dynasimR-package
#' @aliases dynasimR
#' @importFrom rlang .data
"_PACKAGE"

## --- Silence R CMD check notes about NSE bare names ---------------------
utils::globalVariables(c(
  # scenario_meta columns
  "id", "label", "rq", "doctrine", "uav", "al", "simulation",
  # summary/casualties columns
  "scenario", "replication", "simulation_type", "kia_rate",
  "ihl_compliance_index", "identity", "injury_severity", "injury_category",
  "time_to_role2", "reached_role2", "survival_time", "died",
  "time_to_first_care", "received_care", "waiting_days_to_min",
  "fim_gain", "fim_admission", "fim_discharge",
  "waiting_days", "region", "cohort",
  # tidy/survfit fields
  "time", "estimate", "conf.low", "conf.high", "strata", "term",
  "HR", "CI_low", "CI_high", "p.value",
  "kia_median", "kia_ci_lo", "kia_ci_hi",
  "kia_reduction_pct", "ihl_index", "above_threshold", "al_ratio",
  "n_total", "n_treated_in_window", "ici",
  "ihl_critical", "window_min",
  # plot-internal vars
  "n_reps",
  # mil_civil vars
  "mil_count", "civ_count", "cost", "rtd_rate"
))
