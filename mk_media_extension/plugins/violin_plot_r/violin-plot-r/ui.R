library(shiny)
library(shinyBS)
library(shinyjs)
library(plotly)

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
      #showpanel {width: 120px; margin-bottom: 10px; background-color: #f5f5f5; violin_-shadow: none;}
    "),
    tags$script(src="http://kancloud.nordata.cn/2019-02-27-iframeResizer.contentWindow.min.js",
                type="text/javascript")
  ),
  sidebarLayout(
    mainPanel(
      id='main',
      bsButton("showpanel", "Show/hide", icon=icon('far fa-chart-bar'),
               type = "toggle", value = TRUE),
      plotlyOutput('violin_plotlyR', width = "100%", height = "700px"),
      tags$div(
        id="violin_plot-r-title-area",
        class="chart-title-area",
        tags$h2(class="title", attrs$title),
        tags$p(class="content", attrs$text)
      )
    ),
    sidebarPanel(
      id = "sidebar",
      selectInput("violin_plot_r_x", "X variable :",
                  choices = choices,
                  selected = attrs$xAxis),
      selectInput("violin_plot_r_y", "Y variable :",
                  choices = choices,
                  selected = attrs$yAxis),
      selectInput("violin_plot_r_col", "Color mapping variable :",
                  choices = choices,
                  selected = attrs$colorAttr),
      selectInput("violin_plot_x_angle", "X labels angle :",
                  choices = c("0" = "0",
                              "30" = "30",
                              "45" = "45",
                              "60" = "60",
                              "90" = "90",
                              "135" = "135",
                              "180" = "180"),
                  selected = attrs$xAngle),
      selectInput("violin_plot_r_legend_pos", "Legend position :",
                  choices = c("vertical" = "v",
                              "horizontal" = "h"),
                  selected = "vertical"),
      sliderInput("violin_plot_r_title_size", "X&Y Title size :",
                  min = 15, max = 30, value = 16),
      sliderInput("violin_plot_r_xyl_labelsize", "X&Y&Legend labels size :",
                  min = 15, max = 30, value = 16),
      tags$p(
        actionButton("violin_plot_r-reset-zoom", 
                      HTML("<span class='glyphicon glyphicon-search' aria-hidden='true'></span> Reset Zoom"))
      )
    )
  )
))
