# Return-to-Duty outcome analysis (multinomial)

Fits a multinomial logistic regression of RTD outcome (categorical) on
scenario + covariates. Returns the model, tidied coefficients, and
class-level proportions.

## Usage

``` r
compute_rtd_analysis(data, covariates = c("scenario", "injury_severity"))
```

## Arguments

- data:

  A `dynasimR_data` object or casualty tibble with an `rtd_outcome`
  column (factor).

- covariates:

  Character vector. Additional predictors. Default
  `c("scenario", "injury_severity")`.

## Value

An S3 object of class `dynasimR_rtd` with slots `fit`, `tidy`,
`proportions`, `params`.
