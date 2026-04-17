# Bottleneck detection across roles of care

Identifies scenario-role combinations where the median transit time
exceeds a percentile threshold relative to the grand distribution.

## Usage

``` r
detect_bottlenecks(data, threshold = 0.75)
```

## Arguments

- data:

  A `dynasimR_data` object or throughput tibble from
  [`role_throughput()`](https://rabanheller.github.io/dynasimR/reference/role_throughput.md).

- threshold:

  Numeric. Quantile above which a role is flagged as a bottleneck (0-1).
  Default `0.75` (top quartile).

## Value

A tibble with only the bottleneck rows.
