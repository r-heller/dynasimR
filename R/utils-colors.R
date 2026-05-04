# Internal colour helpers — not exported.

#' @keywords internal
#' @noRd
.safe_viridis <- function(n, option = "D", begin = 0.1, end = 0.9) {
  if (requireNamespace("viridis", quietly = TRUE)) {
    viridis::viridis(n, option = option, begin = begin, end = end)
  } else {
    grDevices::hcl.colors(n, palette = "viridis")
  }
}
