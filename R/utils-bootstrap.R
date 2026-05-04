# Internal bootstrap helpers — not exported.

#' @keywords internal
#' @noRd
.boot_quantile_ci <- function(x, n_boot = 1000, fun = stats::median,
                              probs = c(0.025, 0.975), seed = NULL) {
  if (!is.null(seed)) set.seed(seed)
  if (length(x) < 2) return(c(NA_real_, NA_real_))
  reps <- vapply(
    seq_len(n_boot),
    function(i) fun(sample(x, length(x), replace = TRUE), na.rm = TRUE),
    numeric(1)
  )
  stats::quantile(reps, probs = probs, names = FALSE, na.rm = TRUE)
}

#' @keywords internal
#' @noRd
.boot_diff_ci <- function(a, b, n_boot = 1000, fun = stats::median,
                          probs = c(0.025, 0.975), seed = NULL) {
  if (!is.null(seed)) set.seed(seed)
  reps <- vapply(
    seq_len(n_boot),
    function(i) {
      fa <- fun(sample(a, length(a), replace = TRUE), na.rm = TRUE)
      fb <- fun(sample(b, length(b), replace = TRUE), na.rm = TRUE)
      fa - fb
    },
    numeric(1)
  )
  stats::quantile(reps, probs = probs, names = FALSE, na.rm = TRUE)
}
