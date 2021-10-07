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
      plotlyOutput('groupBoxplot', width = "100%", height = "700px"),
      tags$div(
        class="chart-title-area",
        tags$h2(class="title", attrs$title),
        tags$p(class="content", attrs$text)
      )
    ),
    sidebarPanel(
      id = "sidebar",
      selectInput("group_boxplot_x", "X variable :",
                  choices = choices,
                  selected = attrs$xAxis),
      selectInput("group_boxplot_y", "Y variable :",
                  choices = choices,
                  selected = attrs$yAxis),
      selectInput("group_boxplot_col", "Color mapping variable :",
                  choices = choices,
                  selected = attrs$colorAttr),
      htmlOutput("selectUI"),
      selectInput("group_boxplot_x_labels", "X labels mapping variable :",
                  choices = c("None" = "None", choices),
                  selected = attrs$labelAttr),
      sliderInput("group_boxplot_title_size", "X&Y Title size :",
                  min = 0, max = 25, value = 11),
      sliderInput("group_boxplot_xyl_labelsize", "X&Y&Legend labels size :",
                  min = 0, max = 25, value = 11),
      tags$p(
        actionButton("group_boxplot-reset-zoom", 
                      HTML("<span class='glyphicon glyphicon-search' aria-hidden='true'></span> Reset Zoom")),
        actionButton("group_boxplot_change_color", 
                     HTML("<span class='glyphicon glyphicon-screenshot' aria-hidden='true'></span> Change Color"))
      )
    )
  )
))
