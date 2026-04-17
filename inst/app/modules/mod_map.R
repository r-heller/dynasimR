## Map module -----------------------------------------------------------

mod_map_ui <- function(id) {
  ns <- NS(id)
  tagList(
    fluidRow(
      shinydashboard::box(
        title = "Entity positions",
        status = "primary", solidHeader = TRUE, width = 12,
        shinyWidgets::pickerInput(ns("scenario"), "Scenario",
          choices  = NULL,
          multiple = FALSE),
        selectInput(ns("color_by"), "Colour by",
          choices = c("group", "status"),
          selected = "group"),
        plotly::plotlyOutput(ns("map_plot"), height = 560)
      )
    )
  )
}

mod_map_server <- function(id, sim_data) {
  moduleServer(id, function(input, output, session) {

    observe({
      chs <- unique(sim_data$entities$scenario)
      shinyWidgets::updatePickerInput(session, "scenario",
        choices = chs, selected = chs[1])
    })

    output$map_plot <- plotly::renderPlotly({
      req(input$scenario)
      if (!all(c("x", "y") %in% names(sim_data$entities))) {
        return(plotly::plotly_empty() |>
          plotly::layout(annotations = list(
            list(text = "No x/y columns in data",
                 showarrow = FALSE,
                 x = 0.5, y = 0.5,
                 xref = "paper", yref = "paper"))))
      }
      p <- dynasimR::plot_map(
        sim_data,
        color_by  = input$color_by,
        scenarios = input$scenario
      )
      plotly::ggplotly(p)
    })
  })
}
