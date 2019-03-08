library(shiny)
library(shinyBS)
library(shinyjs)
library(plotly)
library(colourpicker)
library(shinycssloaders)

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
      .load-container .loader {background-color: #ffffffcc !important;}
    "),
    tags$script(src="http://kancloud.nordata.cn/2019-02-27-iframeResizer.contentWindow.min.js",
                type="text/javascript")
  ),
  sidebarLayout(
    mainPanel(
      id='main',
      bsButton("showpanel", "Show/hide", icon=icon('far fa-chart-bar'),
               type = "toggle", value = TRUE),
      withSpinner(plotlyOutput('rocketPlot', width = "100%", height = "700px"),
                  type=getOption("spinner.type", default = 1),
                  color.background="#ffffffcc"),
      tags$div(
        class="chart-title-area",
        tags$h2(class="title", attrs$title),
        tags$p(class="content", attrs$text)
      )
    ),
    sidebarPanel(
      id = "sidebar",
      selectInput("rocket_plot_x", "X variable :",
                  choices = choices,
                  selected = attrs$xAxis),
      selectInput("rocket_plot_y", "Y variable :",
                  choices = choices,
                  selected = attrs$yAxis),
      selectInput("rocket_plot_label", "Label variable :",
                  choices = c("None" = "None", choices),
                  selected = attrs$labelAttr),
      selectInput("rocket_plot_method", "Method(please wait) :",
                  choices = c('None' = 'None',
                              'Linear Regression' = 'linear_regression',
                              'Pearson Correlation' = 'pearson_correlation'),
                  selected = attrs$method),
      colourInput("rocket_plot_color", "Choose point color", "#084594"),
      # selectInput("rocket_plot_x_angle", "X labels angle :",
      #             choices = c("0" = "0",
      #                         "30" = "30",
      #                         "45" = "45",
      #                         "60" = "60",
      #                         "90" = "90",
      #                         "135" = "135",
      #                         "180" = "180"),
      #             selected = "60"),
      sliderInput("rocket_plot_point_size", "Point size :",
                  min=0.5, max=10, value=attrs$pointSize, step=0.1),
      sliderInput("rocket_plot_xyl_labelsize", "X&Y&Legend labels size :",
                  min = 0, max = 25, value = 11),
      sliderInput("rocket_plot_title_size", "X&Y Title size :",
                  min = 0, max = 25, value = 11),
      tags$p(
        actionButton("rocket_plot-reset-zoom", 
                      HTML("<span class='glyphicon glyphicon-search' aria-hidden='true'></span> Reset Zoom")),
        actionButton("rocket_plot_change_color", 
                     HTML("<span class='glyphicon glyphicon-screenshot' aria-hidden='true'></span> Change Color"))
      )
    )
  )
))
