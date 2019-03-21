library(shiny)
library(shinyBS)
library(shinyjs)
library(shinycssloaders)
library(mutsneedle)
library(plotly)

choices <- colnames(data)
names(choices) <- colnames(data)

regionChoices <- colnames(regionData)
names(regionChoices) <- colnames(regionData)

shinyUI(fluidPage(
  useShinyjs(),
  tags$head(
    tags$style("
      .chart-title-area {margin: -20px; width: 100%;}
      .chart-title-area .title {display: flex; justify-content: center; font-size: 16px;}
      .chart-title-area .content {margin-left: 70px;}

      #main {display: flex; flex-direction: column; align-items: flex-end;}
      #showpanel {width: 120px; margin-bottom: 10px; background-color: #f5f5f5; box-shadow: none}
      #mutsNeedle {width: -webkit-fill-available !important; }
    "),
    tags$script(src="http://kancloud.nordata.cn/2019-02-27-iframeResizer.contentWindow.min.js",
                type="text/javascript")
  ),
  sidebarLayout(
    mainPanel(
      id='main',
      bsButton("showpanel", "Show/hide", icon=icon('far fa-chart-bar'),
               type = "toggle", value = attrs$showpanel),
      mutsneedleOutput("mutsNeedle", height=700),
      tags$div(
        class="chart-title-area",
        tags$h2(class="title", attrs$title),
        tags$p(class="content", attrs$text)
      )
    ),
    sidebarPanel(
      id = "sidebar",
      selectInput("muts_needle_coord", "Muts Needle Coord :",
                  choices = choices,
                  selected = attrs$coord),
      selectInput("muts_needle_category", "Mutation Category :",
                  choices = choices,
                  selected = attrs$category),
      selectInput("muts_needle_value", "Num of Mutations :",
                  choices = choices,
                  selected = attrs$value),
      selectInput("muts_needle_region_coord", "Muts Region Coord :",
                  choices = c("None" = "none", regionChoices),
                  selected = attrs$regionCoord),
      selectInput("muts_needle_region_name", "Muts Region Coord :",
                  choices = c("None" = "none", regionChoices),
                  selected = attrs$regionName),
      sliderInput("muts_needle_maxlength", "X Axis Maxlength : ",
                  min = 600, max = 1500, value = 800, step=50)
      # tags$p(
      #   actionButton("heatmap-r-reset-zoom", 
      #                HTML("<span class='glyphicon glyphicon-search' aria-hidden='true'></span> Reset Zoom"))
        # tags$a(id = "heatmap-r-svg-export", href = "#", class = "btn btn-default",
        #        HTML("<span class='glyphicon glyphicon-save' aria-hidden='true'></span> Download SVG"))
    )
  )
))
