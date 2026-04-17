setwd("C:/Users/raban/Documents/GitHub/dynasimR")
f <- list.files("man", pattern = "\\.Rd$", full.names = TRUE)
if (length(f) > 0) file.remove(f)
devtools::document()

Sys.setenv(`_R_CHECK_SYSTEM_CLOCK_` = FALSE)
res <- devtools::check(args = c("--as-cran", "--no-manual"),
                       quiet = TRUE, error_on = "never")
cat("\n=== RESULT: ", length(res$errors), "E /",
    length(res$warnings), "W /",
    length(res$notes), "N ===\n")
if (length(res$errors) > 0) {
  cat("\n--- ERRORS ---\n"); cat(res$errors, sep = "\n---\n")
}
if (length(res$warnings) > 0) {
  cat("\n--- WARNINGS ---\n"); cat(res$warnings, sep = "\n---\n")
}
if (length(res$notes) > 0) {
  cat("\n--- NOTES ---\n"); cat(res$notes, sep = "\n---\n")
}
