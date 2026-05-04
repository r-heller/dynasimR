## Export module --------------------------------------------------------

mod_export_ui <- function(id) {
  ns <- NS(id)
  tagList(
    fluidRow(
      shinydashboard::box(
        title = "LaTeX table export", status = "info",
        solidHeader = TRUE, width = 6,
        p("Outcomes table (scenario medians)."),
        downloadButton(ns("dl_latex_outcomes"),
                       "Download .tex",
                       class = "btn-primary")
      ),
      shinydashboard::box(
        title = "Figure export", status = "info",
        solidHeader = TRUE, width = 6,
        p("KM survival curve at single-column width."),
        selectInput(ns("export_format"), "Format",
          choices  = c("pdf", "svg", "png"), selected = "pdf"),
        numericInput(ns("export_width"),  "Width [mm]",
                     value = 174, min = 60, max = 200),
        numericInput(ns("export_height"), "Height [mm]",
                     value = 120, min = 60, max = 200),
        downloadButton(ns("dl_figure_km"),
                       "Download figure",
                       class = "btn-primary")
      )
    )
  )
}

mod_export_server <- function(id, sim_data) {
  moduleServer(id, function(input, output, session) {

    output$dl_latex_outcomes <- downloadHandler(
      filename = "dynasimR_outcomes.tex",
      content  = function(file) {
        tbl <- sim_data$summary |>
          dplyr::group_by(.data$scenario) |>
          dplyr::summarise(
            event_pct      = round(stats::median(.data$event_rate,
                                                 na.rm = TRUE) * 100,
                                   1),
            compliance_med = round(
              stats::median(.data$compliance_index,
                            na.rm = TRUE), 3),
            n              = dplyr::n(),
            .groups        = "drop"
          )
        dynasimR::export_latex_table(
          data     = tbl,
          filename = file,
          caption  = "Primary outcome metrics (median, per-replication).",
          label    = "outcomes"
        )
      }
    )

    output$dl_figure_km <- downloadHandler(
      filename = function()
        paste0("dynasimR_km.", input$export_format),
      content  = function(file) {
        km <- dynasimR::km_estimate(sim_data, endpoint = "stage2")
        dynasimR::export_figure(
          plot      = dynasimR::plot_km(km),
          filename  = file,
          width_mm  = input$export_width,
          height_mm = input$export_height
        )
      }
    )
  })
}
