# Validate a dynasimR_data object

Checks that the required columns are present in each table and reports
out-of-range values. Does not modify the data; returns it unchanged
(with warnings when problems are found).

## Usage

``` r
validate_dynasimR_data(x, strict = FALSE)
```

## Arguments

- x:

  A `dynasimR_data` object (list with `summary`, `casualties`,
  `timeseries`).

- strict:

  Logical. If `TRUE`, missing required columns abort; if `FALSE`
  (default), they produce a warning and the function still returns `x`.

## Value

The input `x`, invisibly, possibly with attribute `validation_issues`
attached.
