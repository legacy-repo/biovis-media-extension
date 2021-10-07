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
      plotOutput('boxplotR', width = "100%", height = "700px"),
      plotlyOutput('boxplotlyR', width = "100%", height = "700px"),
      tags$div(
        id="boxplot-r-title-area",
        class="chart-title-area",
        tags$h2(class="title", attrs$title),
        tags$p(class="content", attrs$text)
      )
    ),
    sidebarPanel(
      id = "sidebar",
      checkboxInput("boxplot_r_interactive", "Full Interactive Plot", value = TRUE),
      selectInput("boxplot_r_x", "X variable :",
                  choices = choices,
                  selected = attrs$xAxis),
      selectInput("boxplot_r_y", "Y variable :",
                  choices = choices,
                  selected = attrs$yAxis),
      selectInput("boxplot_r_col", "Color mapping variable :",
                  choices = choices,
                  selected = attrs$colorAttr),
      selectInput("boxplot_r_legend_pos", "Legend position (Only supported by non-interactive mode):",
                  choices = c("none" = "none",
                              "right" = "right",
                              "left" = "left",
                              "bottom" = "bottom",
                              "top" = "top"),
                  selected = "bottom"),
      htmlOutput("selectUI"),
      sliderInput("boxplot_r_title_size", "X&Y Title size :",
                  min = 14, max = 25, value = 14),
      sliderInput("boxplot_r_xyl_labelsize", "X&Y&Legend labels size :",
                  min = 14, max = 25, value = 14),
      sliderInput("boxplot_r_y_axis_len", "Y Axis Length :",
                  min = 1, max = 25, value = 3, step = 1),
      selectInput("plot_color_mode", "Color Scale:",
                  choices = BioVisReportR::get_mode_lst(),
                  selected = "color"),
      selectInput("plot_palname", "Color Palette:",
                  choices = BioVisReportR::get_pal_lst(),
                  selected = "npg")
    )
  )
))
