# dynasimR 0.1.0

Initial release.

## Features

- Load and validate MEDTACS-SIM and REHASIM simulation outputs via
  `read_simulation()` / `load_example_data()`.
- Survival analysis with `km_estimate()`, `cox_model()`, `plot_km()`,
  `plot_forest()`.
- Doctrine-effect quantification via `doctrine_effect()` with
  auto-generated LaTeX-ready narrative.
- Autonomy trade-off analysis via `al_efficiency()` and
  `plot_al_tradeoff()`.
- IHL-Compliance-Index via `compute_ihl_index()` with bootstrap CIs.
- REHASIM extensions: `fim_trajectory_analysis()`,
  `compute_waiting_gap_index()`, `mil_civil_effect()`,
  `spatial_supply_demand()`, `compute_rtd_analysis()`.
- Manuscript export: `export_figure()`, `export_latex_table()`,
  `fill_placeholders()` (Springer Nature `sn-jnl.cls` compatible).
- Embedded Shiny dashboard via `launch_app()`.
- Example data shipped for reproducible demos and tests.
