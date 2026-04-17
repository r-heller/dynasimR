# 2D casualty map snapshot

Scatter plot of casualty positions (requires `x` and `y` columns in the
casualty table) coloured by identity or vital state.

## Usage

``` r
plot_map(data, color_by = c("identity", "vital_status"), scenarios = NULL)
```

## Arguments

- data:

  A `dynasimR_data` object or casualty tibble with `x`, `y` columns.

- color_by:

  Character. `"identity"` or `"vital_status"`. Default `"identity"`.

- scenarios:

  Character vector. Scenario IDs to include. Default `NULL` = all.

## Value

A ggplot2 object.
