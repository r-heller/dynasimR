# Waiting-Gap Index (REHASIM)

Analogue of the IHL-Compliance Index for rehabilitation flow: fraction
of casualties who wait no longer than a threshold number of days
(default 14) between injury and rehabilitation start. A value below
`0.80` is flagged as a policy-relevant violation.

## Usage

``` r
compute_waiting_gap_index(
  data,
  window_days = 14,
  by_scenario = TRUE,
  by_cohort = TRUE,
  n_bootstrap = 1000
)
```

## Arguments

- data:

  A `dynasimR_data` object or casualty tibble with a `waiting_days`
  column (or `waiting_days_to_min` in minutes).

- window_days:

  Numeric. Allowed waiting time in days. Default `14`.

- by_scenario:

  Logical. Stratify by scenario. Default `TRUE`.

- by_cohort:

  Logical. Stratify by `cohort` (if present). Default `TRUE`.

- n_bootstrap:

  Integer. Bootstrap replicates for CIs. Default `1000`.

## Value

A tibble with columns `scenario` (if stratified), `cohort` (if
stratified), `wgi`, `wgi_ci_lo`, `wgi_ci_hi`, `n_total`, `n_in_window`,
`wgi_critical`, `window_days`.
