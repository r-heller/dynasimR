## data-raw/generate_example_data.R
##
## Generates synthetic example output CSVs for four scenarios
## (A-S00 baseline, A-S01 observation resource, A-S07 policy B,
## A-S08 policy A) with 50 replications each.
## Writes to inst/extdata/.
##
## Run with: source("data-raw/generate_example_data.R")

library(tibble)
library(dplyr)
library(readr)
library(purrr)

set.seed(2026)

out_dir <- file.path("inst", "extdata")

# Clean previously generated files (old schema) before rewriting
old_files <- list.files(out_dir,
  pattern = "^(M-S|A-S|B-S).*\\.csv$", full.names = TRUE)
file.remove(old_files[file.exists(old_files)])

dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

scenarios <- list(
  "A-S00" = list(event_base = 0.35, comp_base = 0.78, n_ent = 80),
  "A-S01" = list(event_base = 0.28, comp_base = 0.85, n_ent = 80),
  "A-S07" = list(event_base = 0.30, comp_base = 0.65, n_ent = 80),
  "A-S08" = list(event_base = 0.22, comp_base = 0.92, n_ent = 80)
)

groups <- c("A", "B", "C")
n_reps <- 50

gen_summary <- function(sc, cfg) {
  purrr::map_dfr(seq_len(n_reps), function(rep) {
    tibble::tibble(
      scenario                        = sc,
      replication                     = rep,
      event_rate                      = stats::plogis(
        stats::qlogis(cfg$event_base) + stats::rnorm(1, 0, 0.2)
      ),
      compliance_index                = stats::plogis(
        stats::qlogis(cfg$comp_base) + stats::rnorm(1, 0, 0.15)
      ),
      median_time_to_first_service    = round(
        stats::rgamma(1, shape = 4,
                      rate = 4 / (60 - 20 * (cfg$comp_base - 0.7)))
      ),
      median_time_to_stage2           = round(
        stats::rgamma(1, shape = 4, rate = 4 / 180)
      )
    )
  })
}

gen_entities <- function(sc, cfg) {
  purrr::map_dfr(seq_len(n_reps), function(rep) {
    n <- cfg$n_ent
    grp <- sample(groups, n, replace = TRUE,
                  prob = c(0.45, 0.35, 0.20))
    sev <- stats::runif(n, 0.1, 0.95)
    event_p <- stats::plogis(
      stats::qlogis(cfg$event_base) + 2 * (sev - 0.5) +
        ifelse(grp == "C", 0.15, 0) +
        ifelse(grp == "B" & sc == "A-S07", 0.25, 0)
    )
    event <- stats::rbinom(n, 1, event_p)
    t_service <- round(stats::rweibull(n, shape = 1.3,
                                       scale = 60 / cfg$comp_base))
    received_service <- stats::rbinom(n, 1, cfg$comp_base)
    t_stage2 <- round(stats::rweibull(n, shape = 1.3, scale = 200))
    reached_stage2 <- stats::rbinom(n, 1, 0.85 - 0.3 * event)
    tibble::tibble(
      scenario           = sc,
      replication        = rep,
      entity_id          = seq_len(n),
      group              = grp,
      severity           = round(sev, 3),
      severity_category  = dplyr::case_when(
        sev > 0.75 ~ "P1",
        sev > 0.50 ~ "P2",
        sev > 0.25 ~ "P3",
        TRUE       ~ "P4"
      ),
      status             = ifelse(event == 1,
                                  "TERMINATED", "ACTIVE"),
      event              = event,
      event_time         = round(stats::rweibull(n, 1.1, 300)),
      time_to_first_service = t_service,
      received_service   = received_service,
      time_to_stage2     = t_stage2,
      reached_stage2     = reached_stage2,
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
    active <- cfg$n_ent *
      (1 - stats::plogis(0.1 * (t_step - 20))) +
      stats::rnorm(n_steps, 0, 2)
    tibble::tibble(
      scenario             = sc,
      replication          = rep,
      time_step            = t_step,
      time_unit            = "step",
      active_entities      = pmax(0, round(active)),
      capacity_utilisation = pmin(1, pmax(0,
        0.5 + 0.005 * t_step + stats::rnorm(n_steps, 0, 0.1)))
    )
  })
}

for (sc in names(scenarios)) {
  cfg <- scenarios[[sc]]
  readr::write_csv(gen_summary(sc, cfg),
                   file.path(out_dir, paste0(sc, "_summary.csv")))
  readr::write_csv(gen_entities(sc, cfg),
                   file.path(out_dir, paste0(sc, "_entities.csv")))
  readr::write_csv(gen_timeseries(sc, cfg),
                   file.path(out_dir, paste0(sc, "_timeseries.csv")))
  message("Wrote ", sc, " triple.")
}

## A small companion metadata CSV ---------------------------------------
readr::write_csv(
  tibble::tibble(
    id         = names(scenarios),
    label      = c("Baseline", "Observation resource",
                   "Policy B (baseline comparator)",
                   "Policy A (priority by severity)"),
    event_base = purrr::map_dbl(scenarios, "event_base"),
    comp_base  = purrr::map_dbl(scenarios, "comp_base")
  ),
  file.path(out_dir, "scenario_metadata.csv")
)

message("Done: ", out_dir)
