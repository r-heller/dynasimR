## Global state shared between ui.R and server.R

suppressPackageStartupMessages({
  library(dynasimR)
  library(shiny)
  library(shinydashboard)
  library(shinyWidgets)
  library(plotly)
  library(DT)
  library(dplyr)
  library(ggplot2)
})

# Data path set by dynasimR::launch_app(), or NULL for example data
.data_dir <- getOption("dynasimR.data_dir", default = NULL)

SIM_DATA <- if (!is.null(.data_dir)) {
  dynasimR::read_simulation(.data_dir, verbose = FALSE)
} else {
  dynasimR::load_example_data()
}

SCENARIO_META <- dynasimR::scenario_meta
COLORS        <- dynasimR::dynasimR_colors()

AVAILABLE_SCENARIOS <- unique(SIM_DATA$summary$scenario)

scenario_choices <- function(scenarios = AVAILABLE_SCENARIOS) {
  sc <- SCENARIO_META |>
    dplyr::filter(.data$id %in% scenarios)
  if (nrow(sc) == 0) return(setNames(scenarios, scenarios))
  setNames(sc$id, paste0(sc$id, " - ", sc$label))
}

# MUF / MilNec guesses depending on which simulation is loaded
.is_rehasim <- identical(SIM_DATA$load_info$simulation_type,
                         "REHASIM")
DEFAULT_MUF    <- if (.is_rehasim) "R-S19" else "M-S08"
DEFAULT_MILNEC <- if (.is_rehasim) "R-S00" else "M-S07"
