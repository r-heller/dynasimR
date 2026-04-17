## Overview module ------------------------------------------------------

mod_overview_ui <- function(id) {
  ns <- NS(id)
  tagList(
    fluidRow(
      shinydashboard::valueBoxOutput(ns("box_scenarios"), width = 3),
      shinydashboard::valueBoxOutput(ns("box_reps"),      width = 3),
      shinydashboard::valueBoxOutput(ns("box_cas"),       width = 3),
      shinydashboard::valueBoxOutput(ns("box_sim_type"),  width = 3)
    ),
    fluidRow(
      shinydashboard::box(
        title = "KIA rate distribution",
        status = "primary", solidHeader = TRUE, width = 6,
        plotly::plotlyOutput(ns("kia_dist"), height = 320)
      ),
      shinydashboard::box(
        title = "IHL Compliance Index",
        status = "primary", solidHeader = TRUE, width = 6,
        plotly::plotlyOutput(ns("ihl_dist"), height = 320)
      )
    ),
    fluidRow(
      shinydashboard::box(
        title = "Summary table",
        status = "info", solidHeader = TRUE, width = 12,
        DT::DTOutput(ns("summary_tbl"))
      )
    )
  )
}

mod_overview_server <- function(id, sim_data) {
  moduleServer(id, function(input, output, session) {

    output$box_scenarios <- shinydashboard::renderValueBox({
      shinydashboard::valueBox(
        length(unique(sim_data$summary$scenario)),
        "Scenarios", icon = icon("layer-group"), color = "blue"
      )
    })
    output$box_reps <- shinydashboard::renderValueBox({
      shinydashboard::valueBox(
        nrow(sim_data$summary),
        "Replications (rows)", icon = icon("repeat"),
        color = "teal"
      )
    })
    output$box_cas <- shinydashboard::renderValueBox({
      shinydashboard::valueBox(
        nrow(sim_data$casualties),
        "Casualty events", icon = icon("user-injured"),
        color = "orange"
      )
    })
    output$box_sim_type <- shinydashboard::renderValueBox({
      shinydashboard::valueBox(
        sim_data$load_info$simulation_type,
        "Simulation type", icon = icon("microchip"),
        color = "purple"
      )
    })

    output$kia_dist <- plotly::renderPlotly({
      if (!"kia_rate" %in% names(sim_data$summary))
        return(plotly::plotly_empty())
      p <- ggplot2::ggplot(sim_data$summary,
        ggplot2::aes(x = .data$kia_rate,
                     fill = .data$scenario)) +
        ggplot2::geom_density(alpha = 0.4) +
        ggplot2::labs(x = "KIA rate", y = "Density", fill = NULL) +
        dynasimR::theme_dynasimR()
      plotly::ggplotly(p)
    })

    output$ihl_dist <- plotly::renderPlotly({
      if (!"ihl_compliance_index" %in% names(sim_data$summary))
        return(plotly::plotly_empty())
      p <- ggplot2::ggplot(sim_data$summary,
        ggplot2::aes(x = .data$ihl_compliance_index,
                     fill = .data$scenario)) +
        ggplot2::geom_density(alpha = 0.4) +
        ggplot2::labs(x = "IHL Compliance Index",
                      y = "Density", fill = NULL) +
        dynasimR::theme_dynasimR()
      plotly::ggplotly(p)
    })

    output$summary_tbl <- DT::renderDT({
      DT::datatable(
        sim_data$summary |>
          dplyr::group_by(.data$scenario) |>
          dplyr::summarise(
            n = dplyr::n(),
            dplyr::across(dplyr::where(is.numeric),
                          ~ round(stats::median(.x, na.rm = TRUE),
                                  3)),
            .groups = "drop"
          ),
        options = list(pageLength = 15, scrollX = TRUE)
      )
    })
  })
}
