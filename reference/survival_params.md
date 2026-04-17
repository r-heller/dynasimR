# Weibull survival parameters by triage category

Literature-derived Weibull shape and scale parameters for modelling
time-to-death in combat casualties, stratified by Triage category
(T1-T4).

## Usage

``` r
survival_params
```

## Format

A tibble with 4 rows and the following columns:

- category:

  Character. Triage category (`"T1"`..`"T4"`).

- k:

  Numeric. Weibull shape parameter.

- lambda:

  Numeric. Weibull scale parameter in minutes.

- source:

  Character. Primary literature source.

## Source

Eastridge et al. (2012) J Trauma 73:S431; Kotwal et al. (2016) JAMA Surg
151:15.
