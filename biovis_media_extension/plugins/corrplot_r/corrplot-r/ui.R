library(shiny)
library(shinyBS)
library(shinyjs)
library(plotly)
library(colourpicker)

choices <- colnames(data)
names(choices) <- colnames(data)

shinyUI(fluidPage(
  useShinyjs(),
  tags$head(
    tags$style("
      .chart-title-area {margin: 20px; width: 100%;}
      .chart-title-area .title {display: flex; justify-content: center; font-size: 16px;}
      .chart-title-area .content {margin-left: 70px; overflow: visible;}
      #main {display: flex; flex-direction: column; align-items: flex-end;}
      #showpanel {width: 120px; margin-bottom: 10px; background-color: #f5f5f5; box-shadow: none;}
    "),
    tags$script(src="http://kancloud.nordata.cn/2019-02-27-iframeResizer.contentWindow.min.js",
                type="text/javascript")
  ),
  sidebarLayout(
    mainPanel(
      id='main',
      bsButton("showpanel", "Show/hide", icon=icon('far fa-chart-bar'),
               type = "toggle", value = attrs$showpanel),
      plotlyOutput('corrPlot', width = "100%", height = "700px"),
      tags$div(
        class="chart-title-area",
        tags$h2(class="title", attrs$title),
        tags$p(class="content", attrs$text)
      )
    ),
    sidebarPanel(
      id = "sidebar",
      selectInput("corrplot_corr_vars", "Correlation variables :",
                  choices = choices,
                  multiple = TRUE,
                  selected = attrs$corrVars),
      checkboxInput("corrplot_pmat", "Whether compute matrix of p-value.",
                    value = attrs$showDiag),
      selectInput("corrplot_method", "Visualization method of correlation matrix :",
                  choices = c("square" = "square"),
                  selected = attrs$corrMethod),
      selectInput("corrplot_type", "Visualization type of correlation matrix :",
                  choices = c("full" = "full",
                              "lower" = "lower",
                              "upper" = "upper"),
                  selected = attrs$corrType),
      checkboxInput("corrplot_show_diag", "Whether display the corr coefficients on the principal diagonal.",
                    value = attrs$showDiag),
      checkboxInput("corrplot_hc_order", "Be hc.ordered using hclust function?",
                    value = attrs$hcOrder),
      # selectInput("corrplot_hc_method", "the agglomeration method :",
      #             choices = c("ward.D" = "ward.D",
      #                         "ward.D2" = "ward.D2",
      #                         "single" = "single",
      #                         "complete" = "complete",
      #                         "average" = "average",
      #                         "mcquitty" = "mcquitty",
      #                         "median" = "median",
      #                         "centroid" = "centroid"),
      #             selected = attrs$hcMethod),
      checkboxInput("corrplot_show_lab", "Add correlation coefficient on the plot?",
                    value = attrs$showLab),
      sliderInput("corrplot_sig_level", "Significant level :",
                  min = 0, max = 1, value = 0.05, step=0.001),
      sliderInput("corrplot_xyl_labelsize", "X&Y&Legend labels size :",
                  min = 0, max = 25, value = 11),
      sliderInput("corrplot_title_size", "X&Y Title size :",
                  min = 0, max = 25, value = 11),
      tags$p(
        actionButton("corrplot-reset-zoom", 
                      HTML("<span class='glyphicon glyphicon-search' aria-hidden='true'></span> Reset Zoom")),
        actionButton("corrplot_change_color", 
                     HTML("<span class='glyphicon glyphicon-screenshot' aria-hidden='true'></span> Change Color"))
      )
    )
  )
))
