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
      .display-spinner {display: block;}
      .hide-spinner {display: none;}
      #main {display: flex; flex-direction: column; align-items: flex-end;}
      #showpanel {width: 120px; margin-bottom: 10px; background-color: #f5f5f5; box-shadow: none;}

      #rocket-plot-spinner .loader,
      #rocket-plot-spinner .loader:before,
      #rocket-plot-spinner .loader:after {
        background: #00bbb7;
        -webkit-animation: load1 1s infinite ease-in-out;
        animation: load1 1s infinite ease-in-out;
        width: 1em;
        height: 4em;
      }

      #rocket-plot-spinner .loader {
        color: #00bbb7;
        text-indent: -9999em;
        margin: 50% auto;
        position: relative;
        font-size: 11px;
        -webkit-transform: translateZ(0);
        -ms-transform: translateZ(0);
        transform: translateZ(0);
        -webkit-animation-delay: -0.16s;
        animation-delay: -0.16s;
      }

      #rocket-plot-spinner .loader:before,
      #rocket-plot-spinner .loader:after {
        position: absolute;
        top: 0;
        content: '';
      }

      #rocket-plot-spinner .loader:before {
        left: -1.5em;
        -webkit-animation-delay: -0.32s;
        animation-delay: -0.32s;
      }

      #rocket-plot-spinner .loader:after {
        left: 1.5em;
      }

      @-webkit-keyframes load1 {
        0%,
        80%,
        100% {
          box-shadow: 0 0;
          height: 4em;
        }
        40% {
          box-shadow: 0 -2em;
          height: 5em;
        }
      }

      @keyframes load1 {
        0%,
        80%,
        100% {
          box-shadow: 0 0;
          height: 4em;
        }
        40% {
          box-shadow: 0 -2em;
          height: 5em;
        }
      }

      #rocket-plot-spinner {
        background-color: #fffffff2;
        position: absolute;
        top: 40%;
        width: 100%;
        z-index: 100;
        -webkit-transform: translateY(-50%);
        transform: translateY(-50%);
        overflow: hidden;
      }
    "),
    tags$script(src="http://kancloud.nordata.cn/2019-02-27-iframeResizer.contentWindow.min.js",
                type="text/javascript")
  ),
  sidebarLayout(
    mainPanel(
      id='main',
      bsButton("showpanel", "Show/hide", icon=icon('far fa-chart-bar'),
               type = "toggle", value = TRUE),
      tags$div(
        id="rocket-plot-spinner",
        tags$div(id="rocket-plot-loader", class="loader", 'Loading')
      ),
      plotlyOutput('rocketPlot', width = "100%", height = "700px"),
      tags$div(
        class="chart-title-area",
        tags$h2(class="title", attrs$title),
        tags$p(class="content", attrs$text)
      )
    ),
    sidebarPanel(
      id = "sidebar",
      selectInput("rocket_plot_x", "X variable :",
                  choices = choices,
                  selected = attrs$xAxis),
      selectInput("rocket_plot_y", "Y variable :",
                  choices = choices,
                  selected = attrs$yAxis),
      selectInput("rocket_plot_label", "Label variable :",
                  choices = c("None" = "None", choices),
                  selected = attrs$labelAttr),
      selectInput("rocket_plot_method", "Method(please wait) :",
                  choices = c('None' = 'None',
                              'Linear Regression' = 'linear_regression',
                              'Pearson Correlation' = 'pearson_correlation'),
                  selected = attrs$method),
      colourInput("rocket_plot_color", "Choose point color", "#084594"),
      # selectInput("rocket_plot_x_angle", "X labels angle :",
      #             choices = c("0" = "0",
      #                         "30" = "30",
      #                         "45" = "45",
      #                         "60" = "60",
      #                         "90" = "90",
      #                         "135" = "135",
      #                         "180" = "180"),
      #             selected = "60"),
      sliderInput("rocket_plot_point_size", "Point size :",
                  min=0.5, max=10, value=attrs$pointSize, step=0.1),
      sliderInput("rocket_plot_xyl_labelsize", "X&Y&Legend labels size :",
                  min = 0, max = 25, value = 11),
      sliderInput("rocket_plot_title_size", "X&Y Title size :",
                  min = 0, max = 25, value = 11),
      tags$p(
        actionButton("rocket_plot-reset-zoom", 
                      HTML("<span class='glyphicon glyphicon-search' aria-hidden='true'></span> Reset Zoom")),
        actionButton("rocket_plot_change_color", 
                     HTML("<span class='glyphicon glyphicon-screenshot' aria-hidden='true'></span> Change Color"))
      )
    )
  )
))
