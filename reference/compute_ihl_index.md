# IHL-Compliance Index

Fraction of casualties (irrespective of identity) that receive first
care within a defined time window post-injury. A value below `0.80` is
treated as a critical IHL violation in the MEDTACS-SIM ethics analysis.

## Usage

``` r
compute_ihl_index(
  casualties,
  window_min = 60,
  window_unit = c("min", "hours", "days"),
  by_scenario = TRUE,
  by_identity = TRUE,
  n_bootstrap = 1000
)
```

## Arguments

- casualties:

  A `dynasimR_data` object, or a casualty-level tibble/data.frame with a
  `time_to_first_care` column (MEDTACS) or `waiting_days_to_min` column
  (REHASIM).

- window_min:

  Numeric. Window size, expressed in the unit given by `window_unit`.
  Default `60`.

- window_unit:

  Character. One of `"min"`, `"hours"`, `"days"`. Values are internally
  normalised to minutes.

- by_scenario:

  Logical. Compute per scenario. Default `TRUE`.

- by_identity:

  Logical. Stratify by `identity` if the column is present. Default
  `TRUE`.

- n_bootstrap:

  Integer. Bootstrap replicates for CIs. Default `1000`.

## Value

A tibble with columns `scenario` (if stratified), `identity` (if
stratified), `ici`, `ici_ci_lo`, `ici_ci_hi`, `n_total`,
`n_treated_in_window`, `ihl_critical`, `window_min`.

## Details

For REHASIM data the analogous metric uses `waiting_days` with a 14-day
window (`window_unit = "days"`).

## Examples

``` r
if (FALSE) { # \dontrun{
sim <- load_example_data()
ihl <- compute_ihl_index(sim)
} # }
```
