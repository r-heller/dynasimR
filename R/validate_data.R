#' Validate a dynasimR_data object
#'
#' Checks that the required columns are present in each table and
#' reports out-of-range values. Does not modify the data; returns it
#' unchanged (with warnings when problems are found).
#'
#' @param x A `dynasimR_data` object (list with `summary`, `casualties`,
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
    if ("kia_rate" %in% names(x$summary))
      .in_range(x$summary$kia_rate, 0, 1, "kia_rate")
    if ("ihl_compliance_index" %in% names(x$summary))
      .in_range(x$summary$ihl_compliance_index, 0, 1,
                "ihl_compliance_index")
  }

  ## casualties ------------------------------------------------------
  if (!is.null(x$casualties) && nrow(x$casualties) > 0) {
    req <- c("scenario", "replication")
    missing <- setdiff(req, names(x$casualties))
    if (length(missing) > 0) {
      msg <- glue::glue(
        "casualties missing: {paste(missing, collapse=', ')}")
      issues <- c(issues, msg)
      if (strict) cli::cli_abort(msg)
      cli::cli_warn(msg)
    }
    if ("injury_severity" %in% names(x$casualties))
      .in_range(x$casualties$injury_severity, 0, 1, "injury_severity")
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
