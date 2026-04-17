# Supply-Demand Index (SDI) per region (REHASIM)

Computes a per-region Supply-Demand Index: the ratio of available
rehabilitation capacity to demand. Values \> 1 indicate oversupply,
values \< 1 undersupply.

## Usage

``` r
spatial_supply_demand(
  data,
  region_col = "region",
  supply_col = "supply",
  demand_col = "demand",
  eps = 1
)
```

## Arguments

- data:

  A `dynasimR_data` object or summary tibble with `region`, `supply` and
  `demand` columns.

- region_col:

  Character. Region column name. Default `"region"`.

- supply_col:

  Character. Supply column name. Default `"supply"`.

- demand_col:

  Character. Demand column name. Default `"demand"`.

- eps:

  Numeric. Offset to avoid division by zero. Default `1`.

## Value

A tibble with columns `region`, `supply_median`, `demand_median`,
`sdi_median`, `sdi_q025`, `sdi_q975`, `undersupply`.
