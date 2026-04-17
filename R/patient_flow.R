#' Role-1 to Role-4 throughput analysis
#'
#' Computes median and interquartile range of transit times for each
#' role of care along the chain of resuscitation. If a `role_completed`
#' column is present in the casualty data, computes fraction of
#' patients completing each role.
#'
#' @param data A `dynasimR_data` object or casualty tibble.
#' @param roles Character vector. Role labels in ordering. Default
#'   `c("Role1", "Role2", "Role3", "Role4")`.
#'
#' @return A tibble with columns `scenario`, `role`, `n`, `median_min`,
#'   `q25`, `q75`, `completed_frac`.
#' @export
role_throughput <- function(data,
                            roles = c("Role1", "Role2",
                                      "Role3", "Role4")) {

  d <- if (inherits(data, "dynasimR_data")) data$casualties else data

  role_time_col <- function(r) {
    candidates <- c(
      paste0("time_to_", tolower(r)),
      paste0("time_", tolower(r))
    )
    found <- intersect(candidates, names(d))
    if (length(found) == 0) NA_character_ else found[1]
  }

  out <- purrr::map_dfr(roles, function(r) {
    col <- role_time_col(r)
    if (is.na(col)) return(NULL)
    reached_col <- paste0("reached_", tolower(r))
    d |>
      dplyr::group_by(.data$scenario) |>
      dplyr::summarise(
        role       = r,
        n          = dplyr::n(),
        median_min = stats::median(.data[[col]], na.rm = TRUE),
        q25        = stats::quantile(.data[[col]], 0.25,
                                     na.rm = TRUE, names = FALSE),
        q75        = stats::quantile(.data[[col]], 0.75,
                                     na.rm = TRUE, names = FALSE),
        completed_frac = if (reached_col %in% names(.data))
          mean(.data[[reached_col]], na.rm = TRUE)
        else NA_real_,
        .groups = "drop"
      )
  })
  out
}

#' Bottleneck detection across roles of care
#'
#' Identifies scenario-role combinations where the median transit
#' time exceeds a percentile threshold relative to the grand
#' distribution.
#'
#' @param data A `dynasimR_data` object or throughput tibble from
#'   [role_throughput()].
#' @param threshold Numeric. Quantile above which a role is flagged as
#'   a bottleneck (0-1). Default `0.75` (top quartile).
#' @return A tibble with only the bottleneck rows.
#' @export
detect_bottlenecks <- function(data, threshold = 0.75) {

  if (inherits(data, "dynasimR_data"))
    tp <- role_throughput(data)
  else tp <- data

  if (!"median_min" %in% names(tp))
    cli::cli_abort("Expected column 'median_min'.")

  cutoff <- stats::quantile(tp$median_min, probs = threshold,
                            na.rm = TRUE, names = FALSE)

  tp |>
    dplyr::mutate(is_bottleneck = .data$median_min > cutoff) |>
    dplyr::filter(.data$is_bottleneck)
}
