library(shiny)
library(shinyBS)
library(shinyjs)
library(d3heatmap)

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
      d3heatmapOutput("d3heatmapPlot", height = "700px"),
      tags$div(
        class="chart-title-area",
        tags$h2(class="title", attrs$title),
        tags$p(class="content", attrs$text)
      )
    ),
    sidebarPanel(
      id = "sidebar",
      selectInput("d3heatmap_x", "Matrix variable:",
                  choices = choices,
                  multiple = TRUE,
                  selected = attrs$colNameLst),
      checkboxInput("d3heatmap_rowv", "Determines if the row dendrogram should be reordered.", value = attrs$rowv),
      checkboxInput("d3heatmap_colv", "Determines if the col dendrogram should be reordered.", value = attrs$colv),
      checkboxInput("d3heatmap_x_log", "Logarithmic x scale", value = FALSE),
      checkboxInput("d3heatmap_na_rm", "Logical indicating whether NA's should be removed.", value = TRUE),
      selectInput("d3heatmap_scale", "Scale variable (if the values should be centered and scaled) :",
                  choices = c("none" = "none", "row" = "row", "column" = "column"),
                  selected = attrs$scale),
      selectInput("d3heatmap_labrow", "Labels for Row:",
                  choices = c("None" = "None", choices),
                  selected = attrs$labRow),
      selectInput("d3heatmap_color", "Color for heatmatp:",
                  choices = c("YlOrRd", "Blues"),
                  selected = "Blues"),
      sliderInput("d3heatmap_cex_row", "xAxis font size ratio (* 14) :", min = 0, max = 4, value = 1, step = 0.05),
      sliderInput("d3heatmap_cex_col", "yAxis font size ratio (* 14) :", min = 0, max = 4, value = 1, step = 0.05),
      tags$p(
        actionButton("d3heatmap-reset-zoom", 
                     HTML("<span class='glyphicon glyphicon-search' aria-hidden='true'></span> Reset Zoom"))
        # tags$a(id = "d3heatmap-svg-export", href = "#", class = "btn btn-default",
        #        HTML("<span class='glyphicon glyphicon-save' aria-hidden='true'></span> Download SVG"))
      )
    )
  )
))
