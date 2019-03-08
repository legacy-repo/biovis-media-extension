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
               type = "toggle", value = TRUE),
      plotlyOutput('densityPlot', width = "100%", height = "700px"),
      tags$div(
        class="chart-title-area",
        tags$h2(class="title", attrs$title),
        tags$p(class="content", attrs$text)
      )
    ),
    sidebarPanel(
      id = "sidebar",
      selectInput("density_plot_x", "X variable :",
                  choices = choices,
                  selected = attrs$xAxis),
      selectInput("density_plot_col", "Color mapping variable :",
                  choices = choices,
                  selected = attrs$colorAttr),
      selectInput("density_plot_x_angle", "X labels angle :",
                  choices = c("0" = "0",
                              "30" = "30",
                              "45" = "45",
                              "60" = "60",
                              "90" = "90",
                              "135" = "135",
                              "180" = "180"),
                  selected = "60"),
      sliderInput("density_plot_x_labelsize", "X labels size :",
                  min = 0, max = 25, value = 11),
      sliderInput("density_plot_y_labelsize", "Y labels size :",
                  min = 0, max = 25, value = 11),
      sliderInput("density_plot_title_size", "X&Y Title size :",
                  min = 0, max = 25, value = 11),
      sliderInput("density_plot_legend_labelsize", "Legend labels size :",
                  min = 0, max = 25, value = 11),
      tags$p(
        actionButton("density_plot-reset-zoom", 
                      HTML("<span class='glyphicon glyphicon-search' aria-hidden='true'></span> Reset Zoom")),
        actionButton("density_plot_change_color", 
                     HTML("<span class='glyphicon glyphicon-screenshot' aria-hidden='true'></span> Change Color"))
      )
    )
  )
))
