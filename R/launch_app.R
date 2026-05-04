#' Launch the dynasimR Shiny dashboard
#'
#' Starts the interactive analysis app bundled with dynasimR. The app
#' requires simulation data; either supply a directory via `data_dir`
#' or leave it `NULL` to use the bundled example data.
#'
#' @param data_dir Character. Path to a directory of simulation
#'   outputs. Default `NULL` = use bundled example data.
#' @param port Integer. Port for the local server. Default `3838`.
#' @param launch.browser Logical. Open in browser. Default `TRUE`.
#' @param ... Additional arguments forwarded to [shiny::runApp()].
#' @return Does not return (blocks until the app is closed).
#' @export
#' @examples
#' \dontrun{
#' launch_app()
#' launch_app(data_dir = "~/my-simulation/data/raw/")
#' }
launch_app <- function(data_dir       = NULL,
                       port           = 3838,
                       launch.browser = TRUE,
                       ...) {

  if (!requireNamespace("shiny", quietly = TRUE))
    cli::cli_abort(
      c("Package {.pkg shiny} required.",
        "i" = "Install with {.code install.packages('shiny')}.")
    )

  app_dir <- system.file("app", package = "dynasimR")
  if (!nzchar(app_dir) || !dir.exists(app_dir))
    cli::cli_abort(
      "App directory not found. Is dynasimR installed correctly?"
    )

  if (!is.null(data_dir)) {
    if (!dir.exists(data_dir))
      cli::cli_abort("data_dir not found: {.path {data_dir}}")
    options(dynasimR.data_dir = data_dir)
    cli::cli_alert_info("Loading data from {.path {data_dir}}")
  } else {
    options(dynasimR.data_dir = NULL)
    cli::cli_alert_info("Using bundled example data")
  }

  cli::cli_alert_success(
    "Starting dynasimR dashboard on port {port} ..."
  )
  shiny::runApp(
    appDir         = app_dir,
    port           = port,
    launch.browser = launch.browser,
    ...
  )
}

#' Check availability of Shiny-app dependencies
#'
#' Inspects the `Suggests:` packages required by the embedded Shiny
#' dashboard and prints a summary of which ones are installed.
#'
#' @return A tibble with columns `package`, `installed`, `version`,
#'   invisibly.
#' @export
check_app_dependencies <- function() {
  pkgs <- c("shiny", "shinydashboard", "shinyWidgets",
            "plotly", "DT", "fresh", "survminer", "broom",
            "xtable", "kableExtra", "viridis", "patchwork",
            "yaml", "nnet")

  status <- purrr::map_dfr(pkgs, function(p) {
    ok <- requireNamespace(p, quietly = TRUE)
    tibble::tibble(
      package   = p,
      installed = ok,
      version   = if (ok)
        as.character(utils::packageVersion(p)) else NA_character_
    )
  })

  missing <- dplyr::filter(status, !.data$installed)
  if (nrow(missing) > 0) {
    cli::cli_alert_warning(
      "Missing packages: {.pkg {missing$package}}"
    )
    cli::cli_code(
      paste0('install.packages(c("',
             paste(missing$package, collapse = '","'),
             '"))')
    )
  } else {
    cli::cli_alert_success("All Shiny-app dependencies available.")
  }
  invisible(status)
}
