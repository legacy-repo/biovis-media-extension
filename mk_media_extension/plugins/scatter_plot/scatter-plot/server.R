library(shiny)
# For more information, please see https://github.com/juba/scatterD3
library(scatterD3)
library(RColorBrewer)

default_lines <- data.frame(slope = c(0, Inf), 
                            intercept = c(0, 0),
                            stroke = "#000",
                            stroke_width = 1,
                            stroke_dasharray = c(5, 5))
threshold_line <- data.frame(slope = 0, 
                             intercept = 30, 
                             stroke = "#F67E7D",
                             stroke_width = 2,
                             stroke_dasharray = "")

shinyServer(function(input, output) {
  dataFunc <- reactive({
    data
  })
  
  lines <- reactive({
    if (input$scatterD3_threshold_line) {
      return(rbind(default_lines, threshold_line))
    }
    default_lines
  })

  colors <- reactiveValues(new = c())
  observeEvent(input$scatterD3_change_color, {
    col_var <- if (input$scatterD3_col == "None") NULL else dataFunc()[,input$scatterD3_col]
    if (is.null(col_var)) {
      colors$new <- c()
    }

    col_var <- as.vector(col_var)
    dataType <- 'all'
    is.wholenumber <- function(x, tol = .Machine$double.eps^0.5)  abs(x - round(x)) < tol
    if (all(unlist(lapply(col_var, is.character)))) {
      dataType <- 'div'
    } else if (all(unlist(lapply(col_var, is.wholenumber)))) {
      dataType <- 'qual'
    } else {
      dataType <- 'seq'
    }

    n <- length(unique(col_var))
    allChoices <- brewer.pal.info

    availableChoices <- allChoices[allChoices$maxcolors > n & allChoices$category == dataType,]

    if (dim(availableChoices)[1] != 0) {
      colorPal <- sample(rownames(availableChoices), size=1)
      colors$new <- brewer.pal(n, colorPal)
    } else {
      colors$new <- c()
    }
  })

  observeEvent(input$scatterD3_col, {
    colors$new <- c()
  })

  observeEvent(input$showpanel, {
    if(input$showpanel == TRUE) {
      removeCssClass("main", "col-sm-12")
      addCssClass("main", "col-sm-8")
      shinyjs::show(id = "sidebar")
      shinyjs::enable(id = "sidebar")
    }
    else {
      removeCssClass("main", "col-sm-8")
      addCssClass("main", "col-sm-12")
      shinyjs::hide(id = "sidebar")
    }
  })


  output$scatterPlot <- renderScatterD3({
    col_var <- if (input$scatterD3_col == "None") NULL else dataFunc()[,input$scatterD3_col]
    symbol_var <- if (input$scatterD3_symbol == "None") NULL else dataFunc()[,input$scatterD3_symbol]
    size_var <- if (input$scatterD3_size == "None") NULL else dataFunc()[,input$scatterD3_size]
    labels <- if (attrs$labelAttr == "None") NULL else dataFunc()[, attrs$labelAttr]

    scatterD3(
      x = dataFunc()[,input$scatterD3_x],
      y = dataFunc()[,input$scatterD3_y],
      lab = labels,
      xlab = input$scatterD3_x,
      ylab = input$scatterD3_y,
      x_log = input$scatterD3_x_log,
      y_log = input$scatterD3_y_log,
      col_var = col_var,
      colors = colors$new,
      col_lab = input$scatterD3_col,
      ellipses = input$scatterD3_ellipses,
      symbol_var = symbol_var,
      symbol_lab = input$scatterD3_symbol,
      size_var = size_var,
      size_lab = input$scatterD3_size,
      url_var = paste0(attrs$queryURL, labels),
      key_var = rownames(dataFunc()),
      point_opacity = input$scatterD3_opacity,
      labels_size = input$scatterD3_labsize,
      transitions = input$scatterD3_transitions,
      left_margin = 90,
      lines = lines(),
      lasso = TRUE,
      menu = TRUE,
      lasso_callback = "function(sel) {console.log(sel.data().map(function(d) {return d.lab}).join('\\n'));}"
    )
  })
})
