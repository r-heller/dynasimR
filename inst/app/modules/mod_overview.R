## Overview module ------------------------------------------------------

mod_overview_ui <- function(id) {
  ns <- NS(id)
  tagList(
    fluidRow(
      shinydashboard::valueBoxOutput(ns("box_scenarios"), width = 3),
      shinydashboard::valueBoxOutput(ns("box_reps"),      width = 3),
      shinydashboard::valueBoxOutput(ns("box_ent"),       width = 3),
      shinydashboard::valueBoxOutput(ns("box_profile"),   width = 3)
    ),
    fluidRow(
      shinydashboard::box(
        title = "Event-rate distribution",
        status = "primary", solidHeader = TRUE, width = 6,
        plotly::plotlyOutput(ns("event_dist"), height = 320)
      ),
      shinydashboard::box(
        title = "Compliance Index",
        status = "primary", solidHeader = TRUE, width = 6,
        plotly::plotlyOutput(ns("compliance_dist"), height = 320)
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
    output$box_ent <- shinydashboard::renderValueBox({
      shinydashboard::valueBox(
        nrow(sim_data$entities),
        "Entity events", icon = icon("dot-circle"),
        color = "orange"
      )
    })
    output$box_profile <- shinydashboard::renderValueBox({
      shinydashboard::valueBox(
        sim_data$load_info$profile_type,
        "Profile type", icon = icon("microchip"),
        color = "purple"
      )
    })

    output$event_dist <- plotly::renderPlotly({
      if (!"event_rate" %in% names(sim_data$summary))
        return(plotly::plotly_empty())
      p <- ggplot2::ggplot(sim_data$summary,
        ggplot2::aes(x = .data$event_rate,
                     fill = .data$scenario)) +
        ggplot2::geom_density(alpha = 0.4) +
        ggplot2::labs(x = "Event rate", y = "Density",
                      fill = NULL) +
        dynasimR::theme_dynasimR()
      plotly::ggplotly(p)
    })

    output$compliance_dist <- plotly::renderPlotly({
      if (!"compliance_index" %in% names(sim_data$summary))
        return(plotly::plotly_empty())
      p <- ggplot2::ggplot(sim_data$summary,
        ggplot2::aes(x = .data$compliance_index,
                     fill = .data$scenario)) +
        ggplot2::geom_density(alpha = 0.4) +
        ggplot2::labs(x = "Compliance Index", y = "Density",
                      fill = NULL) +
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
