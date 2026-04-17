## data-raw/survival_params.R
##
## Literature-derived Weibull survival parameters per Triage category.
## Run with: source("data-raw/survival_params.R")

library(tibble)
library(usethis)

survival_params <- tibble::tribble(
  ~category, ~k,   ~lambda, ~source,
  "T1",      1.2,     60,   "Eastridge et al. 2012; Kotwal et al. 2016",
  "T2",      1.5,    240,   "Eastridge et al. 2012",
  "T3",      1.8,    720,   "Kotwal et al. 2016",
  "T4",      0.8,     20,   "Eastridge et al. 2012 (expectant)"
)

usethis::use_data(survival_params, overwrite = TRUE, compress = "xz")
