## Doctrine module ------------------------------------------------------

mod_doctrine_ui <- function(id) {
  ns <- NS(id)
  tagList(
    fluidRow(
      shinydashboard::box(
        title = "Controls", status = "info",
        solidHeader = TRUE, width = 4,
        shinyWidgets::pickerInput(ns("muf"), "MUF scenario",
          choices = NULL, multiple = FALSE),
        shinyWidgets::pickerInput(ns("milnec"), "MilNec scenario",
          choices = NULL, multiple = FALSE),
        numericInput(ns("alpha"), "Alpha",
          value = 0.05, min = 0.001, max = 0.2, step = 0.01)
      ),
      shinydashboard::box(
        title = "Delta KIA", status = "primary",
        solidHeader = TRUE, width = 8,
        plotOutput(ns("doc_plot"), height = 320)
      )
    ),
    fluidRow(
      shinydashboard::box(
        title = "Auto-generated narrative",
        status = "success", solidHeader = TRUE, width = 12,
        htmlOutput(ns("narrative"))
      )
    ),
    fluidRow(
      shinydashboard::box(
        title = "Effect sizes", status = "info",
        solidHeader = TRUE, width = 6,
        DT::DTOutput(ns("effects_tbl"))
      ),
      shinydashboard::box(
        title = "Wilcoxon tests (BH-adj.)", status = "info",
        solidHeader = TRUE, width = 6,
        DT::DTOutput(ns("wilcox_tbl"))
      )
    )
  )
}

mod_doctrine_server <- function(id, sim_data,
                                default_muf    = "M-S08",
                                default_milnec = "M-S07") {
  moduleServer(id, function(input, output, session) {

    observe({
      sc <- unique(sim_data$summary$scenario)
      shinyWidgets::updatePickerInput(session, "muf",
        choices = sc,
        selected = if (default_muf %in% sc) default_muf else sc[1])
      shinyWidgets::updatePickerInput(session, "milnec",
        choices = sc,
        selected = if (default_milnec %in% sc) default_milnec
                   else sc[length(sc)])
    })

    doc_res <- reactive({
      req(input$muf, input$milnec)
      tryCatch(
        dynasimR::doctrine_effect(
          sim_data,
          muf_scenario    = input$muf,
          milnec_scenario = input$milnec,
          alpha           = input$alpha
        ),
        error = function(e) NULL
      )
    })

    output$doc_plot <- renderPlot({
      d <- doc_res()
      if (is.null(d)) {
        plot.new()
        text(0.5, 0.5, "Scenarios not available in data")
      } else {
        dynasimR::plot_doctrine(d)
      }
    })

    output$narrative <- renderUI({
      d <- doc_res()
      if (is.null(d)) return(HTML("<em>Pick two scenarios.</em>"))
      HTML(paste0("<p>", d$narrative, "</p>"))
    })

    output$effects_tbl <- DT::renderDT({
      d <- doc_res()
      if (is.null(d)) return(NULL)
      DT::datatable(d$effect_sizes, options = list(dom = "t"))
    })

    output$wilcox_tbl <- DT::renderDT({
      d <- doc_res()
      if (is.null(d)) return(NULL)
      DT::datatable(d$wilcoxon_tests, options = list(dom = "t"))
    })
  })
}
