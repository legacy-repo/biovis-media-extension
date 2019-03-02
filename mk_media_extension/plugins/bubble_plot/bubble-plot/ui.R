# More info:
#   https://github.com/jcheng5/googleCharts
# Install:
#   devtools::install_github("jcheng5/googleCharts")
library(googleCharts)

# Use global max/min for axes so the view window stays
# constant as the user moves between years
xlim <- list(
  min = min(data$xAxis) - (max(data$xAxis) - min(data$xAxis))/10,
  max = max(data$xAxis) + (max(data$xAxis) - min(data$xAxis))/10
)
ylim <- list(
  min = min(data$yAxis),
  max = max(data$yAxis) + (max(data$yAxis) - min(data$yAxis))/10
)

shinyUI(fluidPage(
  tags$head(
    tags$script(src="http://kancloud.nordata.cn/2019-02-27-iframeResizer.contentWindow.min.js",
                type="text/javascript")
  ),

  # This line loads the Google Charts JS library
  googleChartsInit(),

  # # Use the Google webfont "Source Sans Pro"
  # tags$link(
  #   href=paste0("http://fonts.googleapis.com/css?",
  #               "family=Source+Sans+Pro:300,600,300italic"),
  #   rel="stylesheet", type="text/css"),
  # tags$style(type="text/css",
  #   "body {font-family: 'Source Sans Pro'}"
  # ),

  googleBubbleChart("chart",
    width="100%", height = "475px",
    # Set the default options for this chart; they can be
    # overridden in server.R on a per-update basis. See
    # https://developers.google.com/chart/interactive/docs/gallery/bubblechart
    # for option documentation.
    options = list(
      fontName = "Source Sans Pro",
      fontSize = 13,
      # Set axis labels and ranges
      hAxis = list(
        title = attrs$xTitle,
        viewWindow = xlim
      ),
      vAxis = list(
        title = attrs$yTitle,
        viewWindow = ylim
      ),
      # The default padding is a little too spaced out
      chartArea = list(
        top = 50, left = 75,
        height = "75%", width = "75%"
      ),
      # Allow pan/zoom
      explorer = list(),
      # Set bubble visual props
      bubble = list(
        opacity = 0.4, stroke = "none",
        # Hide bubble label
        textStyle = list(
          color = "none"
        )
      ),
      # Set fonts
      titleTextStyle = list(
        fontSize = 16
      ),
      tooltip = list(
        textStyle = list(
          fontSize = 12
        )
      )
    )
  ),
  fluidRow(
    shiny::column(4, offset = 4,
      sliderInput(attrs$sliderId, attrs$sliderTitle,
        min = min(data$sliderAttr), max = max(data$sliderAttr),
        value = min(data$sliderAttr), animate = TRUE,
        step = attrs$sliderStep)
    )
  )
))
