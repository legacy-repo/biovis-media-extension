# More detail information, please see http://caleydo.org/tools/upset/
# https://github.com/hms-dbmi/UpSetR/
library(shiny)
library(shinyBS)
library(shinyjs)
library(plotly)
library(shinycssloaders)

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
      plotlyOutput("plotly_upset", height = "700px"),
      tags$div(
        class="chart-title-area",
        tags$h2(class="title", attrs$title),
        tags$p(class="content", attrs$text)
      )
    ),
    sidebarPanel(
      id = "sidebar",
      uiOutput("sets"),
      selectInput(
        "intersection_assignment_type",
        "Intersection assignment type",
        choices = c(
          `Highest-order (UpSet)` = "upset",
          `All associated intersections` = "all"
        ),
        selected = attrs$assignmentType
      ),
      uiOutput("nsets"),
      sliderInput(
        "nintersects",
        label = "Number of intersections",
        min = 2,
        max = 40,
        step = 1,
        value = attrs$nIntersects
      ),
      checkboxInput("set_sort", "Sort sets by size?", value = attrs$setSort),
      checkboxInput("bar_numbers",
                    "Show bar numbers?", value = attrs$showBarNumbers),
      checkboxInput(
        "show_empty_intersections",
        label = "Show empty intersections?",
        value = attrs$showEmptyInterSec
      ),
      tags$p(
        actionButton("upset_plot_change_color", 
                     HTML("<span class='glyphicon glyphicon-screenshot' aria-hidden='true'></span> Change Color"))
      )
    )
  )
))
