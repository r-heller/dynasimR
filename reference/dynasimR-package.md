# dynasimR: Dynamic Agent-Node Simulation Analysis

Analysis and visualisation layer for discrete-event, agent-based and
node-actor simulation outputs. Primary application is the MEDTACS-SIM
military medical simulation (chain of resuscitation, doctrine effects,
autonomy trade-offs) and the REHASIM rehabilitation flow simulation (FIM
trajectories, waiting-gap index, supply-demand).

## Details

The package is schema-harmonised so that both simulations can be
analysed with the same API. See the vignettes for worked examples.

## Key functions

- Data I/O:

  [`read_simulation()`](https://rabanheller.github.io/dynasimR/reference/read_simulation.md),
  [`load_example_data()`](https://rabanheller.github.io/dynasimR/reference/load_example_data.md),
  [`validate_dynasimR_data()`](https://rabanheller.github.io/dynasimR/reference/validate_dynasimR_data.md)

- Survival:

  [`km_estimate()`](https://rabanheller.github.io/dynasimR/reference/km_estimate.md),
  [`cox_model()`](https://rabanheller.github.io/dynasimR/reference/cox_model.md)

- Doctrine:

  [`doctrine_effect()`](https://rabanheller.github.io/dynasimR/reference/doctrine_effect.md)

- Autonomy:

  [`al_efficiency()`](https://rabanheller.github.io/dynasimR/reference/al_efficiency.md)

- IHL:

  [`compute_ihl_index()`](https://rabanheller.github.io/dynasimR/reference/compute_ihl_index.md)

- Patient flow:

  [`role_throughput()`](https://rabanheller.github.io/dynasimR/reference/role_throughput.md),
  [`detect_bottlenecks()`](https://rabanheller.github.io/dynasimR/reference/detect_bottlenecks.md)

- UAV:

  [`uav_comparison()`](https://rabanheller.github.io/dynasimR/reference/uav_comparison.md)

- Sensitivity:

  [`morris_screening()`](https://rabanheller.github.io/dynasimR/reference/morris_screening.md),
  [`tornado_data()`](https://rabanheller.github.io/dynasimR/reference/tornado_data.md)

- REHASIM:

  [`fim_trajectory_analysis()`](https://rabanheller.github.io/dynasimR/reference/fim_trajectory_analysis.md),
  [`compute_waiting_gap_index()`](https://rabanheller.github.io/dynasimR/reference/compute_waiting_gap_index.md),
  [`mil_civil_effect()`](https://rabanheller.github.io/dynasimR/reference/mil_civil_effect.md),
  [`spatial_supply_demand()`](https://rabanheller.github.io/dynasimR/reference/spatial_supply_demand.md),
  [`compute_rtd_analysis()`](https://rabanheller.github.io/dynasimR/reference/compute_rtd_analysis.md)

- Plots:

  [`plot_km()`](https://rabanheller.github.io/dynasimR/reference/plot_km.md),
  [`plot_forest()`](https://rabanheller.github.io/dynasimR/reference/plot_forest.md),
  [`plot_al_tradeoff()`](https://rabanheller.github.io/dynasimR/reference/plot_al_tradeoff.md),
  [`plot_scenario_heatmap()`](https://rabanheller.github.io/dynasimR/reference/plot_scenario_heatmap.md),
  [`plot_doctrine()`](https://rabanheller.github.io/dynasimR/reference/plot_doctrine.md),
  [`plot_timeline()`](https://rabanheller.github.io/dynasimR/reference/plot_timeline.md),
  [`plot_map()`](https://rabanheller.github.io/dynasimR/reference/plot_map.md),
  [`plot_fim_curves()`](https://rabanheller.github.io/dynasimR/reference/plot_fim_curves.md),
  [`plot_sdi_map()`](https://rabanheller.github.io/dynasimR/reference/plot_sdi_map.md),
  [`plot_cost_effectiveness()`](https://rabanheller.github.io/dynasimR/reference/plot_cost_effectiveness.md)

- Export:

  [`export_figure()`](https://rabanheller.github.io/dynasimR/reference/export_figure.md),
  [`export_latex_table()`](https://rabanheller.github.io/dynasimR/reference/export_latex_table.md),
  [`fill_placeholders()`](https://rabanheller.github.io/dynasimR/reference/fill_placeholders.md)

- Shiny:

  [`launch_app()`](https://rabanheller.github.io/dynasimR/reference/launch_app.md),
  [`check_app_dependencies()`](https://rabanheller.github.io/dynasimR/reference/check_app_dependencies.md)

## See also

Useful links:

- <https://github.com/rabanheller/dynasimR>

- Report bugs at <https://github.com/rabanheller/dynasimR/issues>

## Author

**Maintainer**: Raban A. Heller <rabanheller@bundeswehr.org>
