## data-raw/scenario_meta.R
##
## Builds the `scenario_meta` tibble describing all supported scenarios
## for Profile A (A-S00..A-S14) and Profile B (B-S00..B-S20).
## Run with: source("data-raw/scenario_meta.R")

library(tibble)
library(usethis)

profile_a <- tibble::tribble(
  ~id,      ~profile,    ~label,                                  ~rq,    ~policy,    ~resource,    ~al,
  "A-S00",  "Profile_A", "Baseline, no auxiliary resource",       "RQ1",  "policy_a", "none",       0L,
  "A-S01",  "Profile_A", "Observation resource, policy A",        "RQ1",  "policy_a", "observation",1L,
  "A-S02",  "Profile_A", "Transport resource, policy A",          "RQ2",  "policy_a", "transport",  2L,
  "A-S03",  "Profile_A", "Mixed resource fleet, policy A",        "RQ2",  "policy_a", "mixed",      2L,
  "A-S04",  "Profile_A", "Active resource, policy A",             "RQ2",  "policy_a", "active",     2L,
  "A-S05",  "Profile_A", "Observation + transport, policy A",     "RQ2",  "policy_a", "mixed",      1L,
  "A-S06",  "Profile_A", "High entity load, policy A",            "SENS", "policy_a", "mixed",      2L,
  "A-S07",  "Profile_A", "Policy B (baseline comparator)",        "RQ3",  "policy_b", "mixed",      2L,
  "A-S08",  "Profile_A", "Policy A (priority by severity)",       "RQ3",  "policy_a", "mixed",      2L,
  "A-S09",  "Profile_A", "AL2 autonomy",                          "RQ4",  "policy_a", "active",     2L,
  "A-S10",  "Profile_A", "AL3 autonomy",                          "RQ4",  "policy_a", "active",     3L,
  "A-S11",  "Profile_A", "AL4 autonomy",                          "RQ4",  "policy_a", "active",     4L,
  "A-S12",  "Profile_A", "AL5 full autonomy",                     "RQ4",  "policy_a", "active",     5L,
  "A-S13",  "Profile_A", "Degraded communications, policy A",     "SENS", "policy_a", "mixed",      2L,
  "A-S14",  "Profile_A", "Low-visibility operations, policy A",   "SENS", "policy_a", "mixed",      2L
)

profile_b <- tibble::tribble(
  ~id,      ~profile,    ~label,                                  ~rq,    ~policy,    ~resource, ~al,
  "B-S00",  "Profile_B", "Baseline flow",                         "RQ1",  "policy_b", "none",    NA_integer_,
  "B-S01",  "Profile_B", "Increased capacity",                    "RQ1",  "policy_b", "none",    NA_integer_,
  "B-S02",  "Profile_B", "Reduced capacity",                      "RQ1",  "policy_b", "none",    NA_integer_,
  "B-S03",  "Profile_B", "Peripheral transfer delay",             "RQ2",  "policy_b", "none",    NA_integer_,
  "B-S04",  "Profile_B", "Expert-staff shortage",                 "RQ2",  "policy_b", "none",    NA_integer_,
  "B-S05",  "Profile_B", "Early activation protocol",             "RQ2",  "policy_b", "none",    NA_integer_,
  "B-S06",  "Profile_B", "Expanded eligibility",                  "RQ3",  "mixed",    "none",    NA_integer_,
  "B-S07",  "Profile_B", "Remote-service expansion",              "RQ3",  "policy_b", "none",    NA_integer_,
  "B-S08",  "Profile_B", "Off-site continuation",                 "RQ3",  "policy_b", "none",    NA_integer_,
  "B-S09",  "Profile_B", "Automated prioritisation",              "RQ4",  "policy_b", "none",    NA_integer_,
  "B-S10",  "Profile_B", "Integrated case management",            "RQ4",  "policy_b", "none",    NA_integer_,
  "B-S11",  "Profile_B", "Multi-modal service bundle",            "RQ4",  "policy_b", "none",    NA_integer_,
  "B-S12",  "Profile_B", "Inter-node pooling",                    "SENS", "policy_b", "none",    NA_integer_,
  "B-S13",  "Profile_B", "Surge stress test",                     "SENS", "policy_b", "none",    NA_integer_,
  "B-S14",  "Profile_B", "Mass-arrival event",                    "SENS", "policy_b", "none",    NA_integer_,
  "B-S15",  "Profile_B", "Region-A focus",                        "SENS", "policy_b", "none",    NA_integer_,
  "B-S16",  "Profile_B", "Region-B focus",                        "SENS", "policy_b", "none",    NA_integer_,
  "B-S17",  "Profile_B", "Coverage expansion",                    "RQ3",  "mixed",    "none",    NA_integer_,
  "B-S18",  "Profile_B", "Cost-constrained",                      "SENS", "policy_b", "none",    NA_integer_,
  "B-S19",  "Profile_B", "Policy A (priority by severity)",       "RQ3",  "policy_a", "none",    NA_integer_,
  "B-S20",  "Profile_B", "Pipeline intake from profile A",        "PIPE", "policy_b", "none",    NA_integer_
)

scenario_meta <- dplyr::bind_rows(profile_a, profile_b)

usethis::use_data(scenario_meta, overwrite = TRUE, compress = "xz")
