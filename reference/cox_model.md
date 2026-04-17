# Cox proportional-hazards model for simulation data

Cox proportional-hazards model for simulation data

## Usage

``` r
cox_model(
  data,
  endpoint = c("role2", "overall", "ttd"),
  covariates = c("scenario", "injury_severity", "identity"),
  reference_scenario = "M-S00"
)
```

## Arguments

- data:

  A `dynasimR_data` object or casualty tibble.

- endpoint:

  See
  [`km_estimate()`](https://rabanheller.github.io/dynasimR/reference/km_estimate.md).

- covariates:

  Character vector. Covariates entering the Cox model. Default
  `c("scenario","injury_severity","identity")`.

- reference_scenario:

  Character. Reference level for the `scenario` factor. Default
  `"M-S00"`. Use `"R-S00"` for REHASIM.

## Value

An S3 object of class `dynasimR_cox` with slots `fit`, `tidy`,
`ph_test`, `forest_data` and `params`.
