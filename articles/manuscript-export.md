# Manuscript export workflow

This vignette shows how to get from raw simulation output to a Springer
Nature-compatible manuscript with automatically filled `[XX_*]`
placeholders.

## 1. LaTeX tables

``` r
library(dynasimR)
sim <- load_example_data()
doc <- doctrine_effect(sim,
  muf_scenario    = "M-S08",
  milnec_scenario = "M-S07")

export_latex_table(
  data     = doc$effect_sizes,
  filename = "table_doctrine.tex",
  caption  = "Doctrine effect sizes (Cohen's d and risk difference).",
  label    = "doctrine",
  note     = "n = 50 replications per scenario."
)
```

The generated `.tex` uses `\botrule` (required by `sn-jnl.cls`) and
escapes `<`/`>` in character cells.

## 2. Figures at Springer dimensions

``` r
km <- km_estimate(sim, endpoint = "role2")
export_figure(
  plot      = plot_km(km),
  filename  = "figure_km.pdf",
  width_mm  = 174,          # Springer single column
  height_mm = 110
)
```

## 3. Placeholder substitution in the .tex body

Given a source `sn-article.tex` with placeholders like
`[XX_DOCTRINE_DELTA_KIA]`, substitute them in one call:

``` r
reps <- fill_placeholders(
  sim_data          = sim,
  tex_file          = "sn-article.tex",
  output_file       = "sn-article_filled.tex",
  muf_scenario      = "M-S08",
  milnec_scenario   = "M-S07",
  baseline_scenario = "M-S00"
)
reps          # named character vector of substitutions performed
```

## Complete placeholder list

| Placeholder                 | Source                                                                                         |
|-----------------------------|------------------------------------------------------------------------------------------------|
| `[XX_DOCTRINE_DELTA_KIA]`   | [`doctrine_effect()`](https://rabanheller.github.io/dynasimR/reference/doctrine_effect.md)     |
| `[XX_DOCTRINE_DELTA_CI_LO]` | [`doctrine_effect()`](https://rabanheller.github.io/dynasimR/reference/doctrine_effect.md)     |
| `[XX_DOCTRINE_DELTA_CI_HI]` | [`doctrine_effect()`](https://rabanheller.github.io/dynasimR/reference/doctrine_effect.md)     |
| `[XX_IHL_MUF]`              | [`compute_ihl_index()`](https://rabanheller.github.io/dynasimR/reference/compute_ihl_index.md) |
| `[XX_IHL_MILNEC]`           | [`compute_ihl_index()`](https://rabanheller.github.io/dynasimR/reference/compute_ihl_index.md) |
| `[XX_OPTIMAL_AL]`           | [`al_efficiency()`](https://rabanheller.github.io/dynasimR/reference/al_efficiency.md)         |
| `[XX_KIA_BASELINE]`         | median KIA at baseline scenario                                                                |
| `[XX_KIA_BEST]`             | min median KIA across all scenarios                                                            |
