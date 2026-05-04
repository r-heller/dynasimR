# Internal LaTeX helpers — not exported.

#' @keywords internal
#' @noRd
.escape_latex_math <- function(x) {
  if (is.null(x)) return(x)
  x <- gsub("<", "$<$", x, fixed = TRUE)
  x <- gsub(">", "$>$", x, fixed = TRUE)
  x
}

#' @keywords internal
#' @noRd
.sn_replace_bottomrule <- function(tex) {
  # sn-jnl.cls requires \botrule instead of \bottomrule
  gsub("\\\\bottomrule", "\\\\botrule", tex)
}

#' @keywords internal
#' @noRd
.format_p <- function(p) {
  if (is.na(p)) return("NA")
  if (p < 0.001) return("< 0.001")
  if (p < 0.01)  return(formatC(p, digits = 3, format = "f"))
  formatC(p, digits = 3, format = "f")
}
