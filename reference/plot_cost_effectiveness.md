# Cost-effectiveness plane and CEAC curve (REHASIM)

Plots the cost-effectiveness plane (delta cost vs. delta outcome) for a
set of scenarios and, optionally, a cost-effectiveness acceptability
curve (CEAC) across willingness-to-pay thresholds.

## Usage

``` r
plot_cost_effectiveness(
  data,
  reference,
  scenarios,
  outcome_col = "rtd_rate",
  cost_col = "cost",
  wtp = seq(0, 2e+05, length.out = 40),
  show_ceac = FALSE
)
```

## Arguments

- data:

  A `dynasimR_data` object or summary tibble.

- reference:

  Character. Scenario ID treated as the comparator.

- scenarios:

  Character vector. Scenarios to evaluate against `reference`.

- outcome_col:

  Character. Outcome column. Default `"rtd_rate"`.

- cost_col:

  Character. Cost column. Default `"cost"`.

- wtp:

  Numeric vector. Willingness-to-pay thresholds for CEAC. Default
  `seq(0, 2e5, length.out = 40)`.

- show_ceac:

  Logical. If `TRUE`, return a CEAC plot instead of the CE plane.
  Default `FALSE`.

## Value

A ggplot2 object.
