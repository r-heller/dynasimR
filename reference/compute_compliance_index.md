# Compliance Index

Fraction of entities (irrespective of group) that receive service within
a defined time window. A value below `0.80` is treated as a critical
compliance violation.

## Usage

``` r
compute_compliance_index(
  entities,
  window_min = 60,
  window_unit = c("min", "hours", "days"),
  by_scenario = TRUE,
  by_group = TRUE,
  n_bootstrap = 1000
)
```

## Arguments

- entities:

  A `dynasimR_data` object, or an entity-level tibble/data.frame with a
  `time_to_first_service` column (Profile A) or `wait_days_to_min`
  column (Profile B).

- window_min:

  Numeric. Window size, expressed in the unit given by `window_unit`.
  Default `60`.

- window_unit:

  Character. One of `"min"`, `"hours"`, `"days"`. Values are internally
  normalised to minutes.

- by_scenario:

  Logical. Compute per scenario. Default `TRUE`.

- by_group:

  Logical. Stratify by `group` if the column is present. Default `TRUE`.

- n_bootstrap:

  Integer. Bootstrap replicates for CIs. Default `1000`.

## Value

A tibble with columns `scenario` (if stratified), `group` (if
stratified), `ci`, `ci_ci_lo`, `ci_ci_hi`, `n_total`, `n_in_window`,
`compliance_critical`, `window_min`.

## Details

For Profile B data the analogous metric uses `wait_days` with a 14-day
window (`window_unit = "days"`).

## Examples

``` r
if (FALSE) { # \dontrun{
sim <- load_example_data()
ci  <- compute_compliance_index(sim)
} # }
```
