# Changelog

## dynasimR 0.1.0

Initial release.

### Features

- Load and validate simulation outputs for two interchangeable profiles
  via
  [`read_simulation()`](https://r-heller.github.io/dynasimR/reference/read_simulation.md)
  /
  [`load_example_data()`](https://r-heller.github.io/dynasimR/reference/load_example_data.md).
- Time-to-event analysis with
  [`km_estimate()`](https://r-heller.github.io/dynasimR/reference/km_estimate.md),
  [`cox_model()`](https://r-heller.github.io/dynasimR/reference/cox_model.md),
  [`plot_km()`](https://r-heller.github.io/dynasimR/reference/plot_km.md),
  [`plot_forest()`](https://r-heller.github.io/dynasimR/reference/plot_forest.md).
- Policy-effect quantification via
  [`policy_effect()`](https://r-heller.github.io/dynasimR/reference/policy_effect.md)
  with auto-generated LaTeX-ready narrative.
- Autonomy-level trade-off analysis via
  [`al_efficiency()`](https://r-heller.github.io/dynasimR/reference/al_efficiency.md)
  and
  [`plot_al_tradeoff()`](https://r-heller.github.io/dynasimR/reference/plot_al_tradeoff.md).
- Compliance Index via
  [`compute_compliance_index()`](https://r-heller.github.io/dynasimR/reference/compute_compliance_index.md)
  with bootstrap confidence intervals.
- Profile B helpers:
  [`progress_trajectory()`](https://r-heller.github.io/dynasimR/reference/progress_trajectory.md),
  [`compute_wait_gap_index()`](https://r-heller.github.io/dynasimR/reference/compute_wait_gap_index.md),
  [`group_effect()`](https://r-heller.github.io/dynasimR/reference/group_effect.md),
  [`spatial_supply_demand()`](https://r-heller.github.io/dynasimR/reference/spatial_supply_demand.md),
  [`compute_completion_analysis()`](https://r-heller.github.io/dynasimR/reference/compute_completion_analysis.md).
- Manuscript export:
  [`export_figure()`](https://r-heller.github.io/dynasimR/reference/export_figure.md),
  [`export_latex_table()`](https://r-heller.github.io/dynasimR/reference/export_latex_table.md),
  [`fill_placeholders()`](https://r-heller.github.io/dynasimR/reference/fill_placeholders.md)
  (publisher-template compatible).
- Embedded Shiny dashboard via
  [`launch_app()`](https://r-heller.github.io/dynasimR/reference/launch_app.md).
- Example data shipped for reproducible demos and tests.
