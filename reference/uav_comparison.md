# Compare outcomes across UAV configurations

Aggregates primary outcome metrics (KIA rate, IHL-Compliance Index and —
if present — median time-to-first-care) by the `uav` column of the
joined scenario metadata.

## Usage

``` r
uav_comparison(
  data,
  scenarios = NULL,
  metrics = c("kia_rate", "ihl_compliance_index")
)
```

## Arguments

- data:

  A `dynasimR_data` object or summary tibble.

- scenarios:

  Character vector. Restrict to these IDs. Default `NULL` = all.

- metrics:

  Character vector. Which metrics to report. Default
  `c("kia_rate", "ihl_compliance_index")`.

## Value

A tibble with one row per UAV configuration and columns `uav`,
`n_scenarios`, `n_reps`, and for each metric the median and 2.5%/97.5%
quantile.

## Examples

``` r
if (FALSE) { # \dontrun{
sim <- load_example_data()
uav_comparison(sim)
} # }
```
