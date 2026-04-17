#' Stage throughput analysis
#'
#' Computes median and interquartile range of transit times for each
#' processing stage along the entity flow. If a `reached_stageN`
#' column is present in the entity data, computes the fraction of
#' entities completing each stage.
#'
#' @param data A `dynasimR_data` object or entity tibble.
#' @param stages Character vector. Stage labels in ordering. Default
#'   `c("Stage1", "Stage2", "Stage3", "Stage4")`.
#'
#' @return A tibble with columns `scenario`, `stage`, `n`,
#'   `median_time`, `q25`, `q75`, `completed_frac`.
#' @export
stage_throughput <- function(data,
                             stages = c("Stage1", "Stage2",
                                        "Stage3", "Stage4")) {

  d <- if (inherits(data, "dynasimR_data")) data$entities else data

  stage_time_col <- function(s) {
    candidates <- c(
      paste0("time_to_", tolower(s)),
      paste0("time_", tolower(s))
    )
    found <- intersect(candidates, names(d))
    if (length(found) == 0) NA_character_ else found[1]
  }

  out <- purrr::map_dfr(stages, function(s) {
    col <- stage_time_col(s)
    if (is.na(col)) return(NULL)
    reached_col <- paste0("reached_", tolower(s))
    d |>
      dplyr::group_by(.data$scenario) |>
      dplyr::summarise(
        stage       = s,
        n           = dplyr::n(),
        median_time = stats::median(.data[[col]], na.rm = TRUE),
        q25         = stats::quantile(.data[[col]], 0.25,
                                      na.rm = TRUE, names = FALSE),
        q75         = stats::quantile(.data[[col]], 0.75,
                                      na.rm = TRUE, names = FALSE),
        completed_frac = if (reached_col %in% names(.data))
          mean(.data[[reached_col]], na.rm = TRUE)
        else NA_real_,
        .groups = "drop"
      )
  })
  out
}

#' Bottleneck detection across processing stages
#'
#' Identifies scenario-stage combinations where the median transit
#' time exceeds a percentile threshold relative to the grand
#' distribution.
#'
#' @param data A `dynasimR_data` object or throughput tibble from
#'   [stage_throughput()].
#' @param threshold Numeric. Quantile above which a stage is flagged
#'   as a bottleneck (0-1). Default `0.75` (top quartile).
#' @return A tibble with only the bottleneck rows.
#' @export
detect_bottlenecks <- function(data, threshold = 0.75) {

  if (inherits(data, "dynasimR_data"))
    tp <- stage_throughput(data)
  else tp <- data

  if (!"median_time" %in% names(tp))
    cli::cli_abort("Expected column 'median_time'.")

  cutoff <- stats::quantile(tp$median_time, probs = threshold,
                            na.rm = TRUE, names = FALSE)

  tp |>
    dplyr::mutate(is_bottleneck = .data$median_time > cutoff) |>
    dplyr::filter(.data$is_bottleneck)
}
