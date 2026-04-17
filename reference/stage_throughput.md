# Stage throughput analysis

Computes median and interquartile range of transit times for each
processing stage along the entity flow. If a `reached_stageN` column is
present in the entity data, computes the fraction of entities completing
each stage.

## Usage

``` r
stage_throughput(data, stages = c("Stage1", "Stage2", "Stage3", "Stage4"))
```

## Arguments

- data:

  A `dynasimR_data` object or entity tibble.

- stages:

  Character vector. Stage labels in ordering. Default
  `c("Stage1", "Stage2", "Stage3", "Stage4")`.

## Value

A tibble with columns `scenario`, `stage`, `n`, `median_time`, `q25`,
`q75`, `completed_frac`.
