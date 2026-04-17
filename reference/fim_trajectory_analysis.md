# FIM trajectory analysis (REHASIM)

Summarises longitudinal Functional Independence Measure (FIM)
trajectories by scenario and (optionally) cohort. Returns both a
per-replication summary (admission, discharge, gain) and a longitudinal
tidy table suitable for
[`plot_fim_curves()`](https://rabanheller.github.io/dynasimR/reference/plot_fim_curves.md).

## Usage

``` r
fim_trajectory_analysis(data, group_by = c("scenario"), longitudinal = FALSE)
```

## Arguments

- data:

  A `dynasimR_data` object or casualty/summary tibble that contains at
  least `fim_admission` and `fim_discharge`.

- group_by:

  Character. Grouping columns. Default `c("scenario")`.

- longitudinal:

  Logical. If `TRUE`, returns the per-timepoint trajectories if a
  `fim_timeseries` slot is present in `data`.

## Value

An S3 object of class `dynasimR_fim` with slots `summary`,
`longitudinal` (if available) and `params`.
