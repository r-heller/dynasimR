# Fill `[XX_*]` placeholders in a LaTeX manuscript

Substitutes `[XX_*]` placeholders in a LaTeX source file with
automatically computed simulation statistics. The mapping from
placeholder to computation is assembled inside this function from
[`doctrine_effect()`](https://rabanheller.github.io/dynasimR/reference/doctrine_effect.md),
[`al_efficiency()`](https://rabanheller.github.io/dynasimR/reference/al_efficiency.md)
and
[`compute_ihl_index()`](https://rabanheller.github.io/dynasimR/reference/compute_ihl_index.md).

## Usage

``` r
fill_placeholders(
  sim_data,
  tex_file,
  output_file = NULL,
  dry_run = FALSE,
  muf_scenario = "M-S08",
  milnec_scenario = "M-S07",
  baseline_scenario = "M-S00"
)
```

## Arguments

- sim_data:

  A `dynasimR_data` object.

- tex_file:

  Character. Path to the LaTeX source file.

- output_file:

  Character. Output path; default appends `_filled` before `.tex`.

- dry_run:

  Logical. If `TRUE`, print replacements but do not write a file.
  Default `FALSE`.

- muf_scenario:

  Character. MUF scenario ID. Default `"M-S08"`.

- milnec_scenario:

  Character. MilNec scenario ID. Default `"M-S07"`.

- baseline_scenario:

  Character. Baseline scenario ID. Default `"M-S00"`.

## Value

Named character vector of the replacements (invisibly).
