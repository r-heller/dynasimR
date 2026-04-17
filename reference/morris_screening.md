# Morris-style sensitivity screening from simulation replicates

Uses per-replicate variation to screen the most influential input
parameters on an outcome metric. The implementation is a simple
variance-based screening; for a full Morris design use the `sensitivity`
package directly and pass the results here for visualisation.

## Usage

``` r
morris_screening(data, outcome = "event_rate", inputs)
```

## Arguments

- data:

  A `dynasimR_data` object or summary tibble.

- outcome:

  Character. Column name of the outcome to screen. Default
  `"event_rate"`.

- inputs:

  Character vector. Column names of simulation inputs (must be numeric)
  to assess.

## Value

A tibble with columns `input`, `mu_star` (mean absolute change),
`sigma`, `rank`.
