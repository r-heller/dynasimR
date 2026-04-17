# Compute AL-Efficiency ratio (event reduction vs. compliance)

Quantifies the trade-off between event-rate reduction and the Compliance
Index across autonomy levels AL0-AL5. Returns the trade-off table, the
optimal AL level (highest event reduction still above the compliance
threshold) and compliance violations.

## Usage

``` r
al_efficiency(
  data,
  al_scenarios = c(`0` = "A-S00", `1` = "A-S05", `2` = "A-S09", `3` = "A-S10", `4` =
    "A-S11", `5` = "A-S12"),
  compliance_threshold = 0.8,
  reference_al = 0,
  n_bootstrap = 1000
)
```

## Arguments

- data:

  A `dynasimR_data` object or summary tibble.

- al_scenarios:

  Named character vector. Mapping AL level (as a string) to scenario ID.
  Default assumes the Profile A scenarios (with the "A-" prefix).

- compliance_threshold:

  Numeric. Minimum Compliance Index for an AL level to be considered
  acceptable. Default `0.80`.

- reference_al:

  Integer. AL level used as reference for delta calculation. Default
  `0`.

- n_bootstrap:

  Integer. Bootstrap replicates for CIs. Default `1000`.

## Value

An S3 object of class `dynasimR_al_analysis` with slots
`tradeoff_table`, `optimal_al`, `compliance_violations` and `params`.

## Examples

``` r
if (FALSE) { # \dontrun{
sim <- load_example_data()
al  <- al_efficiency(sim)
plot_al_tradeoff(al)
} # }
```
