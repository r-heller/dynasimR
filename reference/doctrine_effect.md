# Quantify doctrine effect (MUF vs. Military Necessity)

Computes the full suite of effect metrics comparing two scenarios that
differ only in medical doctrine (Medical Urgency First vs. Military
Necessity). Returns deltas on KIA rate and IHL-Compliance Index, Cohen's
d, risk differences and an auto-generated narrative sentence suitable
for pasting into a manuscript.

## Usage

``` r
doctrine_effect(
  data,
  muf_scenario,
  milnec_scenario,
  alpha = 0.05,
  n_bootstrap = 1000
)
```

## Arguments

- data:

  A `dynasimR_data` object or summary tibble.

- muf_scenario:

  Character. Scenario ID using MUF doctrine.

- milnec_scenario:

  Character. Scenario ID using Military Necessity doctrine.

- alpha:

  Numeric. Significance level. Default `0.05`.

- n_bootstrap:

  Integer. Bootstrap replicates for CIs. Default `1000`.

## Value

An S3 object of class `dynasimR_doctrine` with slots `delta_kia`,
`ihl_comparison`, `effect_sizes`, `wilcoxon_tests`, `narrative`, and
`params`.

## Details

No hardcoded defaults are used — you **must** supply both scenario IDs
explicitly, so that the same function works for MEDTACS (e.g. `"M-S08"`
vs. `"M-S07"`) and REHASIM (e.g. `"R-S19"` vs. `"R-S00"`).

## Examples

``` r
if (FALSE) { # \dontrun{
sim <- load_example_data()
doc <- doctrine_effect(sim,
  muf_scenario = "M-S08", milnec_scenario = "M-S07")
print(doc)
cat(doc$narrative)
} # }
```
