## app.R — single-file fallback (kept so runApp(appDir) works when
## ui.R/server.R are preferred by shiny)

source("global.R", local = TRUE)
source("ui.R",     local = TRUE)
source("server.R", local = TRUE)
