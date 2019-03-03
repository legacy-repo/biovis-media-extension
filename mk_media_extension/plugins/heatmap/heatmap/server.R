library(shiny)
# For more information, please see https://github.com/rstudio/d3heatmap
library(d3heatmap)
library(RColorBrewer)

shinyServer(function(input, output) {
  dataFunc <- reactive({
    if (input$d3heatmap_x_log) {
      if (!is.null(input$d3heatmatp_x)) {
        return(log2(data[, input$d3heatmatp_x]))
      } else {
        return(log2(data))
      }
    }

    if (!is.null(input$d3heatmatp_x)) {
      return(data[, input$d3heatmatp_x])
    } else {
      return(data)
    }
  })

  labRowFunc <- reactive({
    if (input$d3heatmatp_labrow != 'None') {
      return(as.vector(as.matrix(data[, input$d3heatmatp_labrow])))
    } else {
      return(rownames(data))
    }
  })

  labColFunc <- reactive({
    return(colnames(dataFunc()))
  })

  observeEvent(input[['d3heatmap-reset-zoom']], {
    if (plot$width == '98%') {
      plot$width = '100%'
    } else if (plot$width == '100%') {
      plot$width = '99%'
    } else if (plot$width == '99%') {
      plot$width = '98%'
    }
  })

  observeEvent(input$showpanel, {
    if(input$showpanel == TRUE) {
      removeCssClass("main", "col-sm-12")
      addCssClass("main", "col-sm-8")
      shinyjs::show(id = "sidebar")
      shinyjs::enable(id = "sidebar")
      plot$width = '99%'
    }
    else {
      removeCssClass("main", "col-sm-8")
      addCssClass("main", "col-sm-12")
      shinyjs::hide(id = "sidebar")
      plot$width = '100%'
    }
  })

  plot <- reactiveValues(width = '100%')

  output$d3heatmapPlot <- renderD3heatmap({
    d3heatmap(
      x = dataFunc(),
      Rowv = input$d3heatmap_rowv,
      Colv = input$d3heatmap_colv,
      scale = input$d3heatmap_scale,
      na.rm = input$d3heatmap_na_rm,
      labRow = labRowFunc(),
      labCol = labColFunc(),
      colors = input$d3heatmatp_color,
      cexRow = input$d3heatmatp_cex_row,
      cexCol = input$d3heatmatp_cex_col,
      width = plot$width
    )
  })
})
