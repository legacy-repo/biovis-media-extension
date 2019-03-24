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
      .chart-title-area {margin: -20px; width: 100%;}
      .chart-title-area .title {display: flex; justify-content: center; font-size: 16px;}
      .chart-title-area .content {margin-left: 70px;}

      #main {display: flex; flex-direction: column; align-items: flex-end;}
      #showpanel {width: 120px; margin-bottom: 10px; background-color: #f5f5f5; box-shadow: none}
    "),
    tags$script(src="http://kancloud.nordata.cn/2019-02-27-iframeResizer.contentWindow.min.js",
                type="text/javascript")
  ),
  sidebarLayout(
    mainPanel(
      id='main',
      bsButton("showpanel", "Show/hide", icon=icon('far fa-chart-bar'),
               type = "toggle", value = attrs$showpanel),
      plotlyOutput('cnvPlot', width = "100%", height = "700px"),
      tags$div(
        class="chart-title-area",
        tags$h2(class="title", attrs$title),
        tags$p(class="content", attrs$text)
      )
    ),
    sidebarPanel(
      id = "sidebar",
      checkboxInput("cnv_plot_compute_pos", "Compute coord?", value = FALSE),
      htmlOutput("positionNumUI"),
      htmlOutput("positionCoorUI"),
      htmlOutput("xAxisUI"),
      selectInput("cnv_plot_y_var", "Y variable :",
                  choices = choices,
                  selected = attrs$yAxis),
      selectInput("cnv_plot_group_type", "Color variable :",
                  choices = choices,
                  selected = attrs$colorAttr),
      selectInput("cnv_plot_anno_var", "Anno variable :",
                  choices = c("None" = "none", choices),
                  selected = attrs$annoLabelVar),
      htmlOutput("annoListUI"),
      sliderInput("cnv_plot_xy_title_size", "X&Y Title size :",
                  min = 14, max = 25, value = 14),
      sliderInput("cnv_plot_xyl_labelsize", "X&Y&Legend labels size :",
                  min = 14, max = 25, value = 14)
      # tags$p(
      #   actionButton("cnv-plot-reset-zoom", 
      #                HTML("<span class='glyphicon glyphicon-search' aria-hidden='true'></span> Reset Zoom"))
        # tags$a(id = "cnv-plot-svg-export", href = "#", class = "btn btn-default",
        #        HTML("<span class='glyphicon glyphicon-save' aria-hidden='true'></span> Download SVG"))
    )
  )
))
