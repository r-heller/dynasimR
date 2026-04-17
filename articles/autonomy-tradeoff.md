# Autonomy-level trade-off (AL0-AL5)

``` r
library(dynasimR)
sim <- load_example_data()
```

## AL-Efficiency ratio

We trade off event-rate reduction versus the Compliance Index. The
default AL scenario mapping requires the full sweep; here we demonstrate
with the two AL points in the shipped example data.

``` r
al <- al_efficiency(
  sim,
  al_scenarios         = c("0" = "A-S00", "1" = "A-S01"),
  compliance_threshold = 0.80,
  n_bootstrap          = 200
)
al$tradeoff_table
#> # A tibble: 2 × 10
#>      al scenario event_median event_ci_lo event_ci_hi event_reduction_pct
#>   <int> <chr>           <dbl>       <dbl>       <dbl>               <dbl>
#> 1     0 A-S00           0.341       0.328       0.353                0   
#> 2     1 A-S01           0.272       0.260       0.290                6.91
#> # ℹ 4 more variables: compliance <dbl>, above_threshold <lgl>, al_ratio <dbl>,
#> #   n_reps <int>
```

## Trade-off plot

``` r
plot_al_tradeoff(al)
#> `height` was translated to `width`.
```

![](autonomy-tradeoff_files/figure-html/unnamed-chunk-3-1.png)

## Interpretation

The `optimal_al` slot holds the AL level with the highest event-rate
reduction while staying above the compliance threshold:

``` r
al$optimal_al
#> [1] 1
```

Compliance violations (if any):

``` r
al$compliance_violations
#> # A tibble: 1 × 11
#>      al scenario event_median event_ci_lo event_ci_hi event_reduction_pct
#>   <int> <chr>           <dbl>       <dbl>       <dbl>               <dbl>
#> 1     0 A-S00           0.341       0.328       0.353                   0
#> # ℹ 5 more variables: compliance <dbl>, above_threshold <lgl>, al_ratio <dbl>,
#> #   n_reps <int>, compliance_deficit <dbl>
```
