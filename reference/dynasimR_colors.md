# NATO-inspired colour palette for dynasimR plots

Returns a named list of hex colours used by all `plot_*` functions.

## Usage

``` r
dynasimR_colors()
```

## Value

A named list with entries `FRIEND`, `FOE`, `CIVILIAN`, `SAVED`, `KIA`,
`NEUTRAL`, `ACCENT`, `BG`.

## Examples

``` r
pal <- dynasimR_colors()
pal$FRIEND
#> [1] "#1B3A6B"
```
