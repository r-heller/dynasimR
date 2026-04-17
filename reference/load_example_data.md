# Load the package-bundled example dataset

Convenience wrapper around
[`read_simulation()`](https://rabanheller.github.io/dynasimR/reference/read_simulation.md)
pointing at the CSVs shipped in `inst/extdata/`.

## Usage

``` r
load_example_data()
```

## Value

A `dynasimR_data` object.

## Examples

``` r
sim <- load_example_data()
print(sim)
#> 
#> ── dynasimR_data ───────────────────────────────────────────────────────────────
#> • Scenarios: 4
#> • Simulation: "MEDTACS"
#> • Summary rows: 200
#> • Casualty events: 16000
#> • Loaded: "2026-04-17 13:37"
#> • Path: /home/runner/work/_temp/Library/dynasimR/extdata
```
