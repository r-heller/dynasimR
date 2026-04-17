setwd("C:/Users/raban/Documents/GitHub/dynasimR")
library(rsvg)
rsvg_png("man/figures/logo.svg", "man/figures/logo.png", height = 240)
cat("PNG size:", file.info("man/figures/logo.png")$size, "bytes\n")
