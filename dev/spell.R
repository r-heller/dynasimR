setwd("C:/Users/raban/Documents/GitHub/dynasimR")
if (!requireNamespace("spelling", quietly = TRUE)) {
  cat("spelling package not installed; skipping\n")
} else {
  r <- spelling::spell_check_package()
  if (nrow(r) == 0) {
    cat("No spell-check issues.\n")
  } else {
    print(r, n = 200)
  }
}
