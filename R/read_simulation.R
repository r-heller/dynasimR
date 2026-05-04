#' Load simulation outputs into the dynasimR standard format
#'
#' Reads CSV outputs from any discrete-event or agent-based
#' simulation framework that follows the dynasimR file-naming
#' convention and validates them against the dynasimR data schema.
#' Returns a structured S3 object of class `dynasimR_data`.
#'
#' @param data_dir Character. Path to the directory containing
#'   simulation outputs. Files are expected to follow the pattern
#'   `{scenario_id}_summary.csv`, `{scenario_id}_entities.csv` and
#'   (optionally) `{scenario_id}_timeseries.csv`.
#' @param scenarios Character vector. Scenario IDs to load. Default
#'   `NULL` loads every scenario found in `data_dir`.
#' @param validate Logical. Run [validate_dynasimR_data()] on the
#'   loaded tables. Default `TRUE`.
#' @param verbose Logical. Print progress messages. Default `TRUE`.
#'
#' @return An S3 object of class `dynasimR_data` (a list) with slots
#'   `summary`, `entities`, `timeseries`, `metadata` and `load_info`.
#' @export
#' @examples
#' \dontrun{
#' sim <- read_simulation("data/raw/")
#' sim <- read_simulation("data/raw/",
#'                        scenarios = c("A-S00", "A-S07", "A-S08"))
#' sim <- read_simulation(system.file("extdata", package = "dynasimR"))
#' }
read_simulation <- function(data_dir,
                            scenarios = NULL,
                            validate  = TRUE,
                            verbose   = TRUE) {

  if (!dir.exists(data_dir))
    cli::cli_abort(
      "Directory {.path {data_dir}} not found.",
      call = rlang::caller_env()
    )

  ## Discover scenarios ---------------------------------------------------
  summary_files <- list.files(data_dir, pattern = "_summary\\.csv$",
                              full.names = FALSE)
  available <- sub("_summary\\.csv$", "", summary_files)

  if (length(available) == 0)
    cli::cli_abort(
      c("No simulation outputs found in {.path {data_dir}}.",
        "i" = "Each scenario needs a _summary.csv file."
      )
    )

  if (!is.null(scenarios)) {
    missing_sc <- setdiff(scenarios, available)
    if (length(missing_sc) > 0)
      cli::cli_warn("Scenarios not found: {.val {missing_sc}}")
    scenarios <- intersect(scenarios, available)
    if (length(scenarios) == 0)
      cli::cli_abort("No matching scenarios in {.path {data_dir}}.")
  } else {
    scenarios <- available
  }

  ## Load helper ----------------------------------------------------------
  load_table <- function(sc, suffix) {
    f <- file.path(data_dir, paste0(sc, "_", suffix, ".csv"))
    if (!file.exists(f)) return(NULL)
    t <- readr::read_csv(f, show_col_types = FALSE,
                         progress = FALSE)
    if (!"scenario" %in% names(t)) t$scenario <- sc
    t
  }

  if (verbose) cli::cli_alert_info(
    "Loading {length(scenarios)} scenario{?s} from {.path {data_dir}}"
  )

  summary_tbls <- purrr::map(scenarios, load_table, "summary") |>
    purrr::compact()
  entity_tbls  <- purrr::map(scenarios, load_table, "entities") |>
    purrr::compact()
  tseries_tbls <- purrr::map(scenarios, load_table, "timeseries") |>
    purrr::compact()

  result <- list(
    summary    = if (length(summary_tbls) > 0) dplyr::bind_rows(summary_tbls)
                 else tibble::tibble(),
    entities   = if (length(entity_tbls)  > 0) dplyr::bind_rows(entity_tbls)
                 else tibble::tibble(),
    timeseries = if (length(tseries_tbls) > 0) dplyr::bind_rows(tseries_tbls)
                 else tibble::tibble()
  )

  ## Join metadata --------------------------------------------------------
  if (exists("scenario_meta", where = asNamespace("dynasimR"),
             inherits = FALSE)) {
    meta <- get("scenario_meta", envir = asNamespace("dynasimR"))
    join_meta <- function(tbl) {
      if (nrow(tbl) == 0) return(tbl)
      dplyr::left_join(tbl, meta, by = c("scenario" = "id"))
    }
    result$summary  <- join_meta(result$summary)
    result$entities <- join_meta(result$entities)
    result$metadata <- dplyr::filter(meta, .data$id %in% scenarios)
  } else {
    result$metadata <- tibble::tibble(id = scenarios)
  }

  ## Profile detection ----------------------------------------------------
  has_progress <- "progress_gain" %in% names(result$summary)
  has_event    <- "event_rate"    %in% names(result$summary)
  profile_type <- dplyr::case_when(
    has_progress & !has_event ~ "Profile_B",
    has_event & !has_progress ~ "Profile_A",
    has_progress &  has_event ~ "mixed",
    TRUE                      ~ "unknown"
  )

  ## Prefix-convention warning --------------------------------------------
  missing_prefix <- scenarios[!grepl("^[AB]-", scenarios)]
  if (length(missing_prefix) > 0)
    cli::cli_warn(c(
      "Scenario IDs without prefix: {.val {missing_prefix}}",
      "i" = paste(
        "Recommended: 'A-S00'-'A-S14' (Profile A) or",
        "'B-S00'-'B-S20' (Profile B).",
        "Prefixes are required when mixing both profiles.")
    ))

  ## load_info ------------------------------------------------------------
  result$load_info <- list(
    timestamp    = Sys.time(),
    data_dir     = data_dir,
    scenarios    = scenarios,
    profile_type = profile_type,
    n_summary    = nrow(result$summary),
    n_entities   = nrow(result$entities)
  )

  ## Stamp profile_type on all tables (if not already present) -----------
  if (nrow(result$summary) > 0 &&
      !"profile_type" %in% names(result$summary))
    result$summary$profile_type <- profile_type
  if (nrow(result$entities) > 0 &&
      !"profile_type" %in% names(result$entities))
    result$entities$profile_type <- profile_type
  if (nrow(result$timeseries) > 0 &&
      !"profile_type" %in% names(result$timeseries))
    result$timeseries$profile_type <- profile_type

  if (validate) result <- validate_dynasimR_data(result)

  if (verbose) cli::cli_alert_success(
    "Loaded {nrow(result$summary)} summary row{?s}, ",
    "{nrow(result$entities)} entit{?y/ies} ",
    "[{profile_type}]"
  )

  structure(result, class = c("dynasimR_data", "list"))
}

#' @export
print.dynasimR_data <- function(x, ...) {
  cli::cli_h1("dynasimR_data")
  cli::cli_bullets(c(
    "*" = "Scenarios: {.val {length(x$load_info$scenarios)}}",
    "*" = "Profile: {.val {x$load_info$profile_type}}",
    "*" = "Summary rows: {.val {nrow(x$summary)}}",
    "*" = "Entity events: {.val {nrow(x$entities)}}",
    "*" = "Loaded: {.val {format(x$load_info$timestamp, '%Y-%m-%d %H:%M')}}",
    "*" = "Path: {.path {x$load_info$data_dir}}"
  ))
  invisible(x)
}

#' Load the package-bundled example dataset
#'
#' Convenience wrapper around [read_simulation()] pointing at the
#' CSVs shipped in `inst/extdata/`.
#'
#' @return A `dynasimR_data` object.
#' @export
#' @examples
#' sim <- load_example_data()
#' print(sim)
load_example_data <- function() {
  ext <- system.file("extdata", package = "dynasimR")
  if (!nzchar(ext) || !dir.exists(ext))
    cli::cli_abort("Example data directory not found.")
  read_simulation(
    data_dir = ext,
    validate = TRUE,
    verbose  = FALSE
  )
}
