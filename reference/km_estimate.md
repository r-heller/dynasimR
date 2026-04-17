# Kaplan-Meier estimator for simulation data

Estimates survival functions from simulated casualty outcomes. Supports
three endpoints (survival-to-Role-2, overall survival,
time-to-first-care) and arbitrary stratification.

## Usage

``` r
km_estimate(
  data,
  scenarios = NULL,
  endpoint = c("role2", "overall", "ttd", "ais_conversion", "discharge", "phase_c"),
  stratify_by = "scenario",
  ci_method = "log",
  n_bootstrap = 0,
  seed = 42
)
```

## Arguments

- data:

  A `dynasimR_data` object or a tibble/data.frame containing
  casualty-level columns.

- scenarios:

  Character vector. Restrict to these scenario IDs. Default `NULL` =
  all.

- endpoint:

  Character. One of `"role2"`, `"overall"`, `"ttd"`, `"ais_conversion"`,
  `"discharge"`, `"phase_c"`. The latter three are REHASIM-only.

- stratify_by:

  Character vector. Strata variables, e.g. `"scenario"` or
  `c("scenario", "identity")`.

- ci_method:

  Character. Passed to
  [`survival::survfit()`](https://rdrr.io/pkg/survival/man/survfit.html)
  as `conf.type`. Default `"log"`.

- n_bootstrap:

  Integer. Bootstrap replicates for KM CIs (0 = disabled). Default `0`.

- seed:

  Integer. RNG seed for bootstrap. Default `42`.

## Value

An S3 object of class `dynasimR_km` (list) with slots `fit`, `tidy`,
`logrank`, `median_survival`, `boot_ci` and `params`.

## Examples

``` r
if (FALSE) { # \dontrun{
sim <- load_example_data()
km <- km_estimate(sim, endpoint = "role2", stratify_by = "scenario")
print(km)
plot_km(km)
} # }
```
