## data-raw/generate_example_data.R
##
## Generates synthetic MEDTACS-SIM output CSVs for 4 scenarios
## (M-S00 baseline, M-S01 ISR-UAV, M-S07 MilNec, M-S08 MUF) with
## 50 replications each. Writes to inst/extdata/.
##
## Run with: source("data-raw/generate_example_data.R")

library(tibble)
library(dplyr)
library(readr)
library(purrr)

set.seed(2026)

out_dir <- file.path("inst", "extdata")
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

scenarios <- list(
  "M-S00" = list(kia_base = 0.35, ihl_base = 0.78, cas_n = 80),
  "M-S01" = list(kia_base = 0.28, ihl_base = 0.85, cas_n = 80),
  "M-S07" = list(kia_base = 0.30, ihl_base = 0.65, cas_n = 80),
  "M-S08" = list(kia_base = 0.22, ihl_base = 0.92, cas_n = 80)
)

identities <- c("FRIEND", "FOE", "CIVILIAN")
n_reps     <- 50

gen_summary <- function(sc, cfg) {
  purrr::map_dfr(seq_len(n_reps), function(rep) {
    tibble::tibble(
      scenario             = sc,
      replication          = rep,
      kia_rate             = stats::plogis(
        stats::qlogis(cfg$kia_base) + stats::rnorm(1, 0, 0.2)
      ),
      ihl_compliance_index = stats::plogis(
        stats::qlogis(cfg$ihl_base) + stats::rnorm(1, 0, 0.15)
      ),
      median_time_to_first_care = round(
        stats::rgamma(1, shape = 4,
                      rate = 4 / (60 - 20 * (cfg$ihl_base - 0.7)))
      ),
      median_time_to_role2      = round(
        stats::rgamma(1, shape = 4, rate = 4 / 180)
      )
    )
  })
}

gen_casualties <- function(sc, cfg) {
  purrr::map_dfr(seq_len(n_reps), function(rep) {
    n <- cfg$cas_n
    ident <- sample(identities, n, replace = TRUE,
                    prob = c(0.45, 0.35, 0.20))
    inj_sev <- stats::runif(n, 0.1, 0.95)
    kia_p <- stats::plogis(
      stats::qlogis(cfg$kia_base) + 2 * (inj_sev - 0.5) +
        ifelse(ident == "CIVILIAN", 0.15, 0) +
        ifelse(ident == "FOE" & sc == "M-S07", 0.25, 0)
    )
    died <- stats::rbinom(n, 1, kia_p)
    t_care <- round(stats::rweibull(n, shape = 1.3,
                                    scale = 60 / cfg$ihl_base))
    received_care <- stats::rbinom(n, 1, cfg$ihl_base)
    t_role2 <- round(stats::rweibull(n, shape = 1.3, scale = 200))
    reached_role2 <- stats::rbinom(n, 1, 0.85 - 0.3 * died)
    tibble::tibble(
      scenario           = sc,
      replication        = rep,
      patient_id         = seq_len(n),
      identity           = ident,
      injury_severity    = round(inj_sev, 3),
      injury_category    = dplyr::case_when(
        inj_sev > 0.75 ~ "T1",
        inj_sev > 0.50 ~ "T2",
        inj_sev > 0.25 ~ "T3",
        TRUE           ~ "T4"
      ),
      vital_status       = ifelse(died == 1, "KIA", "SURVIVED"),
      died               = died,
      survival_time      = round(stats::rweibull(n, 1.1, 300)),
      time_to_first_care = t_care,
      received_care      = received_care,
      time_to_role2      = t_role2,
      reached_role2      = reached_role2,
      x                  = round(stats::runif(n, 0, 50), 2),
      y                  = round(stats::runif(n, 0, 50), 2)
    )
  })
}

gen_timeseries <- function(sc, cfg) {
  n_steps <- 60
  # First 10 reps only
  purrr::map_dfr(seq_len(10), function(rep) {
    t_step <- seq_len(n_steps)
    active <- cfg$cas_n *
      (1 - stats::plogis(0.1 * (t_step - 20))) +
      stats::rnorm(n_steps, 0, 2)
    tibble::tibble(
      scenario    = sc,
      replication = rep,
      time_step   = t_step,
      time_unit   = "min",
      active_casualties = pmax(0, round(active)),
      capacity_utilisation = pmin(1, pmax(0,
        0.5 + 0.005 * t_step + stats::rnorm(n_steps, 0, 0.1)))
    )
  })
}

for (sc in names(scenarios)) {
  cfg <- scenarios[[sc]]
  readr::write_csv(gen_summary(sc, cfg),
                   file.path(out_dir, paste0(sc, "_summary.csv")))
  readr::write_csv(gen_casualties(sc, cfg),
                   file.path(out_dir, paste0(sc, "_casualties.csv")))
  readr::write_csv(gen_timeseries(sc, cfg),
                   file.path(out_dir, paste0(sc, "_timeseries.csv")))
  message("Wrote ", sc, " triple.")
}

## Include a small scenario_metadata.csv for convenience ---------------
readr::write_csv(
  tibble::tibble(
    id       = names(scenarios),
    label    = c("Baseline", "ISR UAV", "Military Necessity",
                 "Medical Urgency First"),
    kia_base = purrr::map_dbl(scenarios, "kia_base"),
    ihl_base = purrr::map_dbl(scenarios, "ihl_base")
  ),
  file.path(out_dir, "scenario_metadata.csv")
)

message("Done: ", out_dir)
