library(shiny)
library(shinyBS)
library(shinyjs)
library(shinycssloaders)
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
      #showpanel {width: 120px; margin-bottom: 10px; background-color: #f5f5f5; box-shadow: none;}  
    "),
    tags$script(src="http://kancloud.nordata.cn/2019-02-27-iframeResizer.contentWindow.min.js",
                type="text/javascript")
  ),
  sidebarLayout(
    mainPanel(
      id='main',
      bsButton("showpanel", "Show/hide", icon=icon('far fa-chart-bar'), type = "toggle", value = TRUE),
      withSpinner(plotlyOutput("heatmapRPlot", height = "700px")),
      tags$div(
        class="chart-title-area",
        tags$h2(class="title", attrs$title),
        tags$p(class="content", attrs$text)
      )
    ),
    sidebarPanel(
      id = "sidebar",
      selectInput("heatmap_r_x", "Matrix variable:",
                  choices = choices,
                  multiple = TRUE,
                  selected = attrs$colNameLst),
      checkboxInput("heatmap_r_rowv", "Determines if the row dendrogram should be reordered.", value = attrs$rowv),
      checkboxInput("heatmap_r_colv", "Determines if the col dendrogram should be reordered.", value = attrs$colv),
      checkboxInput("heatmap_r_x_log", "Logarithmic x scale", value = FALSE),
      checkboxInput("heatmap_r_na_rm", "Logical indicating whether NA's should be removed.", value = TRUE),
      selectInput("heatmap_r_dist_method", "The dist method :",
                  choices = c("euclidean" = "euclidean",
                              "maximum" = "maximum",
                              "manhattan" = "manhattan",
                              "canberra" = "canberra",
                              "binary" = "binary",
                              "minkowski" = "minkowski"),
                  selected = attrs$distMethod),
      selectInput("heatmap_r_hc_method", "The hclust method :",
                  choices = c("ward.D" = "ward.D",
                              "ward.D2" = "ward.D2",
                              "single" = "single",
                              "complete" = "complete",
                              "average" = "average",
                              "mcquitty" = "mcquitty",
                              "median" = "median",
                              "centroid" = "centroid"),
                  selected = attrs$hcMethod),
      selectInput("heatmap_r_scale", "Scale variable (if the values should be centered and scaled) :",
                  choices = c("None" = "none", "row" = "row", "column" = "column"),
                  selected = attrs$scale),
      selectInput("heatmap_r_labrow", "Labels for Row:",
                  choices = c("None" = "none", choices),
                  selected = attrs$labRow),
      selectInput("heatmap_r_color", "Color for heatmatp:",
                  choices = c("viridis", "magma", "cividis",
                              "inferno", "plasma"),
                  selected = "viridis"),
      sliderInput("heatmap_r_cex_row", "Row font size ratio (* 14) :", min = 1, max = 4, value = 1.2, step = 0.05),
      sliderInput("heatmap_r_cex_col", "Col font size ratio (* 14) :", min = 1, max = 4, value = 1.2, step = 0.05),
      tags$p(
        actionButton("heatmap-r-reset-zoom", 
                     HTML("<span class='glyphicon glyphicon-search' aria-hidden='true'></span> Reset Zoom"))
        # tags$a(id = "heatmap-r-svg-export", href = "#", class = "btn btn-default",
        #        HTML("<span class='glyphicon glyphicon-save' aria-hidden='true'></span> Download SVG"))
      )
    )
  )
))
