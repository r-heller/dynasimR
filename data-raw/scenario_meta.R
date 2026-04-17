## data-raw/scenario_meta.R
##
## Builds the `scenario_meta` tibble describing all MEDTACS-SIM
## (M-S00..M-S14) and REHASIM (R-S00..R-S20) scenarios.
## Run with: source("data-raw/scenario_meta.R")

library(tibble)
library(usethis)

medtacs <- tibble::tribble(
  ~id,      ~simulation, ~label,                                  ~rq,    ~doctrine, ~uav,      ~al,
  "M-S00",  "MEDTACS",   "Baseline, no UAV, MUF",                 "RQ1",  "MUF",     "NONE",    0L,
  "M-S01",  "MEDTACS",   "ISR UAV, MUF",                          "RQ1",  "MUF",     "ISR",     1L,
  "M-S02",  "MEDTACS",   "CASEVAC UAV, MUF",                      "RQ2",  "MUF",     "CASEVAC", 2L,
  "M-S03",  "MEDTACS",   "Mixed UAV fleet, MUF",                  "RQ2",  "MUF",     "MIXED",   2L,
  "M-S04",  "MEDTACS",   "Armed UAV, MUF",                        "RQ2",  "MUF",     "ARMED",   2L,
  "M-S05",  "MEDTACS",   "ISR + CASEVAC, MUF",                    "RQ2",  "MUF",     "MIXED",   1L,
  "M-S06",  "MEDTACS",   "High casualty load, MUF",               "SENS", "MUF",     "MIXED",   2L,
  "M-S07",  "MEDTACS",   "Military Necessity doctrine",           "RQ3",  "MIL_NEC", "MIXED",   2L,
  "M-S08",  "MEDTACS",   "Medical Urgency First doctrine",        "RQ3",  "MUF",     "MIXED",   2L,
  "M-S09",  "MEDTACS",   "AL2 autonomy",                          "RQ4",  "MUF",     "ARMED",   2L,
  "M-S10",  "MEDTACS",   "AL3 autonomy",                          "RQ4",  "MUF",     "ARMED",   3L,
  "M-S11",  "MEDTACS",   "AL4 autonomy",                          "RQ4",  "MUF",     "ARMED",   4L,
  "M-S12",  "MEDTACS",   "AL5 full autonomy",                     "RQ4",  "MUF",     "ARMED",   5L,
  "M-S13",  "MEDTACS",   "Degraded comms, MUF",                   "SENS", "MUF",     "MIXED",   2L,
  "M-S14",  "MEDTACS",   "Night operations, MUF",                 "SENS", "MUF",     "MIXED",   2L
)

rehasim <- tibble::tribble(
  ~id,      ~simulation, ~label,                                  ~rq,    ~doctrine, ~uav,   ~al,
  "R-S00",  "REHASIM",   "Baseline rehabilitation flow",          "RQ1",  "MIL_NEC", "NONE", NA_integer_,
  "R-S01",  "REHASIM",   "Increased capacity",                    "RQ1",  "MIL_NEC", "NONE", NA_integer_,
  "R-S02",  "REHASIM",   "Reduced capacity",                      "RQ1",  "MIL_NEC", "NONE", NA_integer_,
  "R-S03",  "REHASIM",   "Peripheral transfer delay",             "RQ2",  "MIL_NEC", "NONE", NA_integer_,
  "R-S04",  "REHASIM",   "Expert staff shortage",                 "RQ2",  "MIL_NEC", "NONE", NA_integer_,
  "R-S05",  "REHASIM",   "Early mobilisation protocol",           "RQ2",  "MIL_NEC", "NONE", NA_integer_,
  "R-S06",  "REHASIM",   "Increased civilian access",             "RQ3",  "MIXED",   "NONE", NA_integer_,
  "R-S07",  "REHASIM",   "Telerehab expansion",                   "RQ3",  "MIL_NEC", "NONE", NA_integer_,
  "R-S08",  "REHASIM",   "Home-based continuation",               "RQ3",  "MIL_NEC", "NONE", NA_integer_,
  "R-S09",  "REHASIM",   "AI triage",                             "RQ4",  "MIL_NEC", "NONE", NA_integer_,
  "R-S10",  "REHASIM",   "Integrated case management",            "RQ4",  "MIL_NEC", "NONE", NA_integer_,
  "R-S11",  "REHASIM",   "Multi-modal therapy bundle",            "RQ4",  "MIL_NEC", "NONE", NA_integer_,
  "R-S12",  "REHASIM",   "Inter-hospital pooling",                "SENS", "MIL_NEC", "NONE", NA_integer_,
  "R-S13",  "REHASIM",   "Pandemic stress test",                  "SENS", "MIL_NEC", "NONE", NA_integer_,
  "R-S14",  "REHASIM",   "Mass casualty event",                   "SENS", "MIL_NEC", "NONE", NA_integer_,
  "R-S15",  "REHASIM",   "Region A focus",                        "SENS", "MIL_NEC", "NONE", NA_integer_,
  "R-S16",  "REHASIM",   "Region B focus",                        "SENS", "MIL_NEC", "NONE", NA_integer_,
  "R-S17",  "REHASIM",   "Insurance expansion",                   "RQ3",  "MIXED",   "NONE", NA_integer_,
  "R-S18",  "REHASIM",   "Cost-constrained",                      "SENS", "MIL_NEC", "NONE", NA_integer_,
  "R-S19",  "REHASIM",   "Medical Urgency First (civilian-incl.)","RQ3",  "MUF",     "NONE", NA_integer_,
  "R-S20",  "REHASIM",   "Pipeline from MEDTACS M-S05 Role 4",    "PIPE", "MIL_NEC", "NONE", NA_integer_
)

scenario_meta <- dplyr::bind_rows(medtacs, rehasim)

usethis::use_data(scenario_meta, overwrite = TRUE, compress = "xz")
