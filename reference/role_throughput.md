# Role-1 to Role-4 throughput analysis

Computes median and interquartile range of transit times for each role
of care along the chain of resuscitation. If a `role_completed` column
is present in the casualty data, computes fraction of patients
completing each role.

## Usage

``` r
role_throughput(data, roles = c("Role1", "Role2", "Role3", "Role4"))
```

## Arguments

- data:

  A `dynasimR_data` object or casualty tibble.

- roles:

  Character vector. Role labels in ordering. Default
  `c("Role1", "Role2", "Role3", "Role4")`.

## Value

A tibble with columns `scenario`, `role`, `n`, `median_min`, `q25`,
`q75`, `completed_frac`.
