# Compute AL-Efficiency ratio (survival advantage vs. IHL compliance)

Quantifies the trade-off between KIA-rate reduction and IHL compliance
across UAV autonomy levels AL0-AL5. Returns the trade-off table, the
optimal AL level (highest KIA reduction still above the IHL threshold),
IHL violations and a detection-bias summary if available.

## Usage

``` r
al_efficiency(
  data,
  al_scenarios = c(`0` = "M-S00", `1` = "M-S05", `2` = "M-S09", `3` = "M-S10", `4` =
    "M-S11", `5` = "M-S12"),
  ihl_threshold = 0.8,
  reference_al = 0,
  n_bootstrap = 1000
)
```

## Arguments

- data:

  A `dynasimR_data` object or summary tibble.

- al_scenarios:

  Named character vector. Mapping AL level (as a string) to scenario ID.
  Default assumes the MEDTACS scenarios (with the "M-" prefix).

- ihl_threshold:

  Numeric. Minimum IHL compliance index for an AL level to be considered
  "ethically acceptable". Default `0.80`.

- reference_al:

  Integer. AL level used as reference for delta calculation. Default
  `0`.

- n_bootstrap:

  Integer. Bootstrap replicates for CIs. Default `1000`.

## Value

An S3 object of class `dynasimR_al_analysis` with slots
`tradeoff_table`, `optimal_al`, `ihl_violations` and `params`.

## Examples

``` r
if (FALSE) { # \dontrun{
sim <- load_example_data()
al  <- al_efficiency(sim)
plot_al_tradeoff(al)
} # }
```
