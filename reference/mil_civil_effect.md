# Military vs. civilian prioritisation effect (REHASIM)

Compares two REHASIM scenarios that differ only in mil/civil
prioritisation and returns Return-to-Duty (RTD) rates, cost per RTD and
the difference (delta) with bootstrap CIs.

## Usage

``` r
mil_civil_effect(
  data,
  mil_scenario,
  civ_scenario,
  outcome_col = "rtd_rate",
  cost_col = "cost",
  alpha = 0.05,
  n_bootstrap = 1000
)
```

## Arguments

- data:

  A `dynasimR_data` object or summary tibble.

- mil_scenario:

  Character. Scenario ID with military priority.

- civ_scenario:

  Character. Scenario ID with civilian-inclusive priority.

- outcome_col:

  Character. Column name for RTD outcome. Default `"rtd_rate"`.

- cost_col:

  Character. Column name for cost metric. Default `"cost"`.

- alpha:

  Numeric. Significance level. Default `0.05`.

- n_bootstrap:

  Integer. Bootstrap replicates. Default `1000`.

## Value

An S3 object of class `dynasimR_mil_civil` with slots `rtd`, `cost`,
`delta_rtd`, `delta_cost`, `params`.
