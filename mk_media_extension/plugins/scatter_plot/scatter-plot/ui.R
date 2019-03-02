library(shiny)
library(shinyBS)
library(shinyjs)
library(scatterD3)

choices <- colnames(data)
names(choices) <- colnames(data)

shinyUI(fluidPage(
  useShinyjs(),
  tags$head(
    tags$style("
      .chart-title-area {margin: 20px; width: 100%;}
      .chart-title-area .title {display: flex; justify-content: center; font-size: 16px;}
      .chart-title-area .content {margin-left: 70px;}
      #main {display: flex; flex-direction: column; align-items: flex-end;}
      #showpanel {width: 120px; margin-bottom: 10px; background-color: #f5f5f5; box-shadow: none;}
    "),
    tags$script(src="http://kancloud.nordata.cn/2019-02-27-iframeResizer.contentWindow.min.js",
                type="text/javascript")
  ),
  sidebarLayout(
    mainPanel(
      id='main',
      bsButton("showpanel", "Show/hide", icon=icon('far fa-chart-bar'), type = "toggle", value = TRUE),
      scatterD3Output("scatterPlot", height = "700px"),
      tags$div(
        class="chart-title-area",
        tags$h2(class="title", attrs$title),
        tags$p(class="content", attrs$text)
      )
    ),
    sidebarPanel(
      id = "sidebar",
      selectInput("scatterD3_x", "X variable :",
                  choices = choices,
                  selected = attrs$xAxis),
      checkboxInput("scatterD3_x_log", "Logarithmic x scale", value = FALSE),
      selectInput("scatterD3_y", "Y variable :",
                  choices = choices,
                  selected = attrs$yAxis),
      checkboxInput("scatterD3_y_log", "Logarithmic y scale", value = FALSE),
      selectInput("scatterD3_col", "Color mapping variable :",
                  choices = c("None" = "None", choices),
                  selected = attrs$colorAttr),
      checkboxInput("scatterD3_ellipses", "Confidence ellipses", value = FALSE),
      selectInput("scatterD3_symbol", "Symbol mapping variable :",
                  choices = c("None" = "None", choices),
                  selected = attrs$nameAttr),
      selectInput("scatterD3_size", "Size mapping variable :",
                  choices = c("None" = "None", choices),
                  selected = attrs$sizeAttr),
      checkboxInput("scatterD3_threshold_line", "Arbitrary threshold line", value = FALSE),    
      sliderInput("scatterD3_labsize", "Labels size :",
                  min = 0, max = 25, value = 11),
      sliderInput("scatterD3_opacity", "Points opacity :", min = 0, max = 1, value = 1, step = 0.05),
      checkboxInput("scatterD3_transitions", "Use transitions", value = TRUE),
      tags$p(
        # actionButton("scatterD3-reset-zoom", 
        #              HTML("<span class='glyphicon glyphicon-search' aria-hidden='true'></span> Reset Zoom")),
        actionButton("scatterD3_change_color", 
                     HTML("<span class='glyphicon glyphicon-screenshot' aria-hidden='true'></span> Change Color")),
        tags$a(id = "scatterD3-svg-export", href = "#", class = "btn btn-default",
               HTML("<span class='glyphicon glyphicon-save' aria-hidden='true'></span> Download SVG")))
    )
  )
))
