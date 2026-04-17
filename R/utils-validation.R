# Internal validation helpers — not exported.

#' @keywords internal
#' @noRd
.require_cols <- function(x, cols, where = "input") {
  missing <- setdiff(cols, names(x))
  if (length(missing) > 0)
    cli::cli_abort(
      "{where} missing required column{?s}: {.val {missing}}"
    )
  invisible(TRUE)
}

#' @keywords internal
#' @noRd
.warn_cols <- function(x, cols, where = "input") {
  missing <- setdiff(cols, names(x))
  if (length(missing) > 0)
    cli::cli_warn(
      "{where} missing optional column{?s}: {.val {missing}}"
    )
  invisible(length(missing) == 0)
}

#' @keywords internal
#' @noRd
.in_range <- function(x, lo, hi, col_name = "value") {
  bad <- !is.na(x) & (x < lo | x > hi)
  if (any(bad))
    cli::cli_warn(
      "{sum(bad)} value(s) in {.field {col_name}} outside [{lo}, {hi}]"
    )
  invisible(!any(bad))
}
