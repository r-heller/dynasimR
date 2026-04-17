#' 2D casualty map snapshot
#'
#' Scatter plot of casualty positions (requires `x` and `y` columns in
#' the casualty table) coloured by identity or vital state.
#'
#' @param data A `dynasimR_data` object or casualty tibble with `x`,
#'   `y` columns.
#' @param color_by Character. `"identity"` or `"vital_status"`.
#'   Default `"identity"`.
#' @param scenarios Character vector. Scenario IDs to include.
#'   Default `NULL` = all.
#' @return A ggplot2 object.
#' @export
plot_map <- function(data,
                     color_by  = c("identity", "vital_status"),
                     scenarios = NULL) {

  color_by <- match.arg(color_by)
  d <- if (inherits(data, "dynasimR_data")) data$casualties else data
  if (!all(c("x", "y") %in% names(d)))
    cli::cli_abort("Casualty table needs 'x' and 'y' columns.")
  if (!is.null(scenarios))
    d <- dplyr::filter(d, .data$scenario %in% scenarios)

  p <- ggplot2::ggplot(
    d,
    ggplot2::aes(x = .data$x, y = .data$y,
                 color = .data[[color_by]])
  ) +
    ggplot2::geom_point(alpha = 0.6, size = 1.2) +
    ggplot2::coord_fixed() +
    ggplot2::labs(x = "X [km]", y = "Y [km]", color = NULL) +
    theme_dynasimR()

  if (color_by == "identity")
    p <- p + scale_color_identity_dynasimR()
  p
}
