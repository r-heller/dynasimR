#' Validate a dynasimR_data object
#'
#' Checks that the required columns are present in each table and
#' reports out-of-range values. Does not modify the data; returns it
#' unchanged (with warnings when problems are found).
#'
#' @param x A `dynasimR_data` object (list with `summary`, `entities`,
#'   `timeseries`).
#' @param strict Logical. If `TRUE`, missing required columns abort;
#'   if `FALSE` (default), they produce a warning and the function
#'   still returns `x`.
#' @return The input `x`, invisibly, possibly with attribute
#'   `validation_issues` attached.
#' @export
validate_dynasimR_data <- function(x, strict = FALSE) {

  issues <- character(0)

  ## summary ---------------------------------------------------------
  if (!is.null(x$summary) && nrow(x$summary) > 0) {
    req <- c("scenario", "replication")
    missing <- setdiff(req, names(x$summary))
    if (length(missing) > 0) {
      msg <- glue::glue("summary missing: {paste(missing, collapse=', ')}")
      issues <- c(issues, msg)
      if (strict) cli::cli_abort(msg)
      cli::cli_warn(msg)
    }
    if ("event_rate" %in% names(x$summary))
      .in_range(x$summary$event_rate, 0, 1, "event_rate")
    if ("compliance_index" %in% names(x$summary))
      .in_range(x$summary$compliance_index, 0, 1,
                "compliance_index")
  }

  ## entities --------------------------------------------------------
  if (!is.null(x$entities) && nrow(x$entities) > 0) {
    req <- c("scenario", "replication")
    missing <- setdiff(req, names(x$entities))
    if (length(missing) > 0) {
      msg <- glue::glue(
        "entities missing: {paste(missing, collapse=', ')}")
      issues <- c(issues, msg)
      if (strict) cli::cli_abort(msg)
      cli::cli_warn(msg)
    }
    if ("severity" %in% names(x$entities))
      .in_range(x$entities$severity, 0, 1, "severity")
  }

  ## timeseries ------------------------------------------------------
  if (!is.null(x$timeseries) && nrow(x$timeseries) > 0) {
    req <- c("scenario", "replication", "time_step")
    missing <- setdiff(req, names(x$timeseries))
    if (length(missing) > 0) {
      msg <- glue::glue(
        "timeseries missing: {paste(missing, collapse=', ')}")
      issues <- c(issues, msg)
      if (!strict) cli::cli_warn(msg)
    }
  }

  if (length(issues) > 0)
    attr(x, "validation_issues") <- issues

  invisible(x)
}
