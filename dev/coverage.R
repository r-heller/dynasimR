setwd("C:/Users/raban/Documents/GitHub/dynasimR")
cov <- covr::package_coverage(quiet = TRUE)
cat("Coverage:", round(covr::percent_coverage(cov), 1), "%\n")
