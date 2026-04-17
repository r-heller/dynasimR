## server.R — dynasimR Shiny dashboard

# Source module servers
module_dir <- file.path("modules")
for (m in list.files(module_dir, pattern = "\\.R$",
                     full.names = TRUE))
  source(m, local = TRUE)

function(input, output, session) {
  mod_overview_server("overview",    SIM_DATA)
  mod_map_server("map",              SIM_DATA)
  mod_survival_server("survival",    SIM_DATA)
  mod_comparison_server("comparison", SIM_DATA)
  mod_doctrine_server("doctrine",    SIM_DATA,
    default_muf    = DEFAULT_MUF,
    default_milnec = DEFAULT_MILNEC)
  mod_autonomy_server("autonomy",    SIM_DATA)
  mod_export_server("export",        SIM_DATA)
}
