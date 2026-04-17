# FIM trajectory plot (REHASIM)

Plots longitudinal FIM trajectories from the output of
[`fim_trajectory_analysis()`](https://rabanheller.github.io/dynasimR/reference/fim_trajectory_analysis.md)
(with `longitudinal = TRUE`).

## Usage

``` r
plot_fim_curves(fim_result, show_ci = TRUE)
```

## Arguments

- fim_result:

  A `dynasimR_fim` object.

- show_ci:

  Logical. Show 95% CI ribbon. Default `TRUE`.

## Value

A ggplot2 object.
