# Completion-outcome analysis (multinomial)

Fits a multinomial logistic regression of completion outcome
(categorical) on scenario + covariates. Returns the model, tidied
coefficients, and class-level proportions.

## Usage

``` r
compute_completion_analysis(data, covariates = c("scenario", "severity"))
```

## Arguments

- data:

  A `dynasimR_data` object or entity tibble with a `completion_outcome`
  column (factor).

- covariates:

  Character vector. Additional predictors. Default
  `c("scenario", "severity")`.

## Value

An S3 object of class `dynasimR_completion` with slots `fit`, `tidy`,
`proportions`, `params`.
