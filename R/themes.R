#' NATO-inspired colour palette for dynasimR plots
#'
#' Returns a named list of hex colours used by all `plot_*` functions.
#'
#' @return A named list with entries `FRIEND`, `FOE`, `CIVILIAN`,
#'   `SAVED`, `KIA`, `NEUTRAL`, `ACCENT`, `BG`.
#' @export
#' @examples
#' pal <- dynasimR_colors()
#' pal$FRIEND
dynasimR_colors <- function() {
  list(
    FRIEND   = "#1B3A6B",
    FOE      = "#A61C24",
    CIVILIAN = "#C99A2E",
    SAVED    = "#2E7D32",
    KIA      = "#212121",
    NEUTRAL  = "#607D8B",
    ACCENT   = "#2E75B6",
    BG       = "#F5F7FA"
  )
}

#' ggplot2 theme for dynasimR figures
#'
#' A minimalist, Springer-Nature-friendly ggplot2 theme tuned for a
#' 174 mm single-column layout at 11 pt base size.
#'
#' @param base_size Numeric. Base font size. Default `11`.
#' @param legend_pos Character. Legend position. Default `"bottom"`.
#' @return A ggplot2 theme object.
#' @export
theme_dynasimR <- function(base_size = 11, legend_pos = "bottom") {
  ggplot2::theme_minimal(base_size = base_size) +
    ggplot2::theme(
      plot.title       = ggplot2::element_text(
        face = "bold", color = "#1B3A6B", size = base_size + 1),
      plot.subtitle    = ggplot2::element_text(
        color = "#666666", size = base_size - 1),
      panel.grid.minor = ggplot2::element_blank(),
      panel.grid.major = ggplot2::element_line(
        color = "#E8E8E8", linewidth = 0.3),
      legend.position  = legend_pos,
      legend.title     = ggplot2::element_text(face = "bold"),
      strip.text       = ggplot2::element_text(face = "bold"),
      plot.caption     = ggplot2::element_text(
        color = "#888888", size = base_size - 2, hjust = 0)
    )
}

#' Colour scale for combatant identity
#'
#' Applies dynasimR identity colours (`FRIEND`/`FOE`/`CIVILIAN`) to a
#' ggplot2 `color` aesthetic.
#'
#' @param ... Arguments passed to [ggplot2::scale_color_manual()].
#' @return A ggplot2 scale object.
#' @export
scale_color_identity_dynasimR <- function(...) {
  ggplot2::scale_color_manual(
    values = c(
      FRIEND   = dynasimR_colors()$FRIEND,
      FOE      = dynasimR_colors()$FOE,
      CIVILIAN = dynasimR_colors()$CIVILIAN
    ), ...
  )
}

#' Fill scale for combatant identity
#'
#' As [scale_color_identity_dynasimR()] but for the `fill` aesthetic.
#'
#' @param ... Arguments passed to [ggplot2::scale_fill_manual()].
#' @return A ggplot2 scale object.
#' @export
scale_fill_identity_dynasimR <- function(...) {
  ggplot2::scale_fill_manual(
    values = c(
      FRIEND   = dynasimR_colors()$FRIEND,
      FOE      = dynasimR_colors()$FOE,
      CIVILIAN = dynasimR_colors()$CIVILIAN
    ), ...
  )
}

#' Colour scale for doctrine principle
#'
#' @param ... Arguments passed to [ggplot2::scale_color_manual()].
#' @return A ggplot2 scale object.
#' @export
scale_color_doctrine_dynasimR <- function(...) {
  ggplot2::scale_color_manual(
    values = c(
      MUF     = dynasimR_colors()$FRIEND,
      MIL_NEC = dynasimR_colors()$FOE
    ),
    labels = c(
      MUF     = "Medical Urgency First",
      MIL_NEC = "Military Necessity"
    ),
    ...
  )
}
