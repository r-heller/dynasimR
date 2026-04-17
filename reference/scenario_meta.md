# Scenario metadata for MEDTACS-SIM and REHASIM

Describes all simulation scenarios (MEDTACS M-S00..M-S14 and REHASIM
R-S00..R-S20) with their research-question mapping, doctrine principle,
UAV configuration and autonomy level.

## Usage

``` r
scenario_meta
```

## Format

A tibble with 35 rows and the following columns:

- id:

  Character. Scenario identifier with prefix (`"M-"` for MEDTACS, `"R-"`
  for REHASIM).

- simulation:

  Character. `"MEDTACS"` or `"REHASIM"`.

- label:

  Character. Human-readable scenario name.

- rq:

  Character. Associated research question (`"RQ1"`..`"RQ4"`, `"SENS"`,
  `"PIPE"`).

- doctrine:

  Character. Doctrine principle (`"MUF"`, `"MIL_NEC"`, `"MIXED"`,
  `"NA"`).

- uav:

  Character. UAV configuration (`"NONE"`, `"ISR"`, `"CASEVAC"`,
  `"ARMED"`, `"MIXED"`).

- al:

  Integer. Autonomy level (0-5) or NA.

## Source

MEDTACS-SIM and REHASIM concept papers (Heller 2026).
