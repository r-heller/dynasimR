## R CMD check results

0 errors | 0 warnings | 0 notes

## Test environments

* local: Windows 11, R 4.5.2
* GitHub Actions: ubuntu-latest (release, devel, oldrel-1),
  macos-latest (release), windows-latest (release)

## This is a new submission.

The package provides an analysis and visualisation layer for
discrete-event and agent-based simulation outputs, primarily applied
to the MEDTACS-SIM and REHASIM military/medical simulation projects.
All external, non-base dependencies are widely used CRAN packages
(dplyr, ggplot2, survival, rlang, cli, glue, readr, tibble, tidyr,
purrr). Optional integrations (shiny, plotly, xtable, broom, nnet,
viridis, patchwork, kableExtra, etc.) are declared as `Suggests:` and
accessed through `requireNamespace()` guards.
