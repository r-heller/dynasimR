# Changelog

## dynasimR 0.1.0

Initial release.

### Features

- Load and validate simulation outputs for two interchangeable profiles
  via
  [`read_simulation()`](https://rabanheller.github.io/dynasimR/reference/read_simulation.md)
  /
  [`load_example_data()`](https://rabanheller.github.io/dynasimR/reference/load_example_data.md).
- Time-to-event analysis with
  [`km_estimate()`](https://rabanheller.github.io/dynasimR/reference/km_estimate.md),
  [`cox_model()`](https://rabanheller.github.io/dynasimR/reference/cox_model.md),
  [`plot_km()`](https://rabanheller.github.io/dynasimR/reference/plot_km.md),
  [`plot_forest()`](https://rabanheller.github.io/dynasimR/reference/plot_forest.md).
- Policy-effect quantification via `policy_effect()` with auto-generated
  LaTeX-ready narrative.
- Autonomy-level trade-off analysis via
  [`al_efficiency()`](https://rabanheller.github.io/dynasimR/reference/al_efficiency.md)
  and
  [`plot_al_tradeoff()`](https://rabanheller.github.io/dynasimR/reference/plot_al_tradeoff.md).
- Compliance Index via `compute_compliance_index()` with bootstrap
  confidence intervals.
- Profile B helpers: `progress_trajectory()`,
  `compute_wait_gap_index()`, `group_effect()`,
  [`spatial_supply_demand()`](https://rabanheller.github.io/dynasimR/reference/spatial_supply_demand.md),
  `compute_completion_analysis()`.
- Manuscript export:
  [`export_figure()`](https://rabanheller.github.io/dynasimR/reference/export_figure.md),
  [`export_latex_table()`](https://rabanheller.github.io/dynasimR/reference/export_latex_table.md),
  [`fill_placeholders()`](https://rabanheller.github.io/dynasimR/reference/fill_placeholders.md)
  (publisher-template compatible).
- Embedded Shiny dashboard via
  [`launch_app()`](https://rabanheller.github.io/dynasimR/reference/launch_app.md).
- Example data shipped for reproducible demos and tests.
