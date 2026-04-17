# Kaplan-Meier survival curves

Plots a `dynasimR_km` object. Use the options to control
confidence-interval ribbons, log-rank p-value annotation and the colour
grouping.

## Usage

``` r
plot_km(
  km_result,
  show_ci = TRUE,
  show_risktable = FALSE,
  show_pval = TRUE,
  show_median = TRUE,
  color_by = "scenario",
  title = NULL,
  subtitle = NULL,
  xlab = "Time post-injury [min]",
  ylab = "Survival probability",
  xlim = NULL,
  manuscript_width = 174,
  ...
)
```

## Arguments

- km_result:

  A `dynasimR_km` object.

- show_ci:

  Logical. Show CI ribbon. Default `TRUE`.

- show_risktable:

  Logical. Show risk table (requires survminer). Default `FALSE` (for
  simpler output without survminer).

- show_pval:

  Logical. Annotate log-rank p-value. Default `TRUE`.

- show_median:

  Logical. Draw horizontal 50% reference line. Default `TRUE`.

- color_by:

  Character. Aesthetic grouping. One of `"scenario"`, `"identity"`,
  `"doctrine"`. Default `"scenario"`.

- title, subtitle, xlab, ylab:

  Character overrides.

- xlim:

  Numeric length-2. Restrict x range. Default `NULL`.

- manuscript_width:

  Numeric. mm width hint (not directly used here, kept for API
  symmetry). Default `174`.

- ...:

  Unused.

## Value

A ggplot2 object.
