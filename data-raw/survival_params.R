## data-raw/survival_params.R
##
## Example Weibull event-time parameters per priority category.
## Values are illustrative and can be replaced for a particular
## application.
##
## Run with: source("data-raw/survival_params.R")

library(tibble)
library(usethis)

survival_params <- tibble::tribble(
  ~category, ~k,   ~lambda, ~source,
  "P1",      1.2,     60,   "package example",
  "P2",      1.5,    240,   "package example",
  "P3",      1.8,    720,   "package example",
  "P4",      0.8,     20,   "package example"
)

usethis::use_data(survival_params, overwrite = TRUE, compress = "xz")
