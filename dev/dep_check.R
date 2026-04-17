d <- read.dcf("DESCRIPTION")
imp <- if ("Imports" %in% colnames(d)) d[, "Imports"] else ""
sug <- if ("Suggests" %in% colnames(d)) d[, "Suggests"] else ""
imp_pkgs <- trimws(gsub("\\s*\\([^)]*\\)", "", strsplit(imp, ",")[[1]]))
sug_pkgs <- trimws(gsub("\\s*\\([^)]*\\)", "", strsplit(sug, ",")[[1]]))
cat("Imports:\n"); cat(imp_pkgs, sep = "\n")
cat("\n\nSuggests:\n"); cat(sug_pkgs, sep = "\n")

used <- system("grep -rhoE \"\\b[a-zA-Z][a-zA-Z0-9.]*::[a-zA-Z_.]+\" R/ | sed 's/::.*//' | sort -u",
  intern = TRUE)
cat("\n\nUsed via ::\n"); cat(used, sep = "\n")

cat("\n\nIn Imports but NOT used:\n")
cat(setdiff(imp_pkgs, used), sep = "\n")
cat("\n\nUsed but NOT in Imports or Suggests:\n")
cat(setdiff(used, c(imp_pkgs, sug_pkgs, "base")), sep = "\n")
