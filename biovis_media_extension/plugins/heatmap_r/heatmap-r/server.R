library(shiny)
# For more information, please see https://github.com/rstudio/heatmap_r
library(heatmaply)
library(RColorBrewer)

colors <- list(
  viridis = viridis(n = 256, alpha = 1, begin = 0, end = 1, direction = 1, option = "D"),
  magma = magma(n = 256, alpha = 1, begin = 0, end = 1, direction = 1),
  inferno = inferno(n = 256, alpha = 1, begin = 0, end = 1, direction = 1),
  plasma = plasma(n = 256, alpha = 1, begin = 0, end = 1, direction = 1),
  cividis = cividis(n = 256, alpha = 1, begin = 0, end = 1, direction = 1)
)

shinyServer(function(input, output) {
  dataFunc <- reactive({
    if (input$heatmap_r_x_log) {
      if (!is.null(input$heatmap_r_x)) {
        return(log2(data[, input$heatmap_r_x]))
      } else {
        return(log2(data))
      }
    }

    if (!is.null(input$heatmap_r_x)) {
      return(data[, input$heatmap_r_x])
    } else {
      return(data)
    }
  })

  labRowFunc <- reactive({
    if (input$heatmap_r_labrow != 'none') {
      return(as.vector(as.matrix(data[, input$heatmap_r_labrow])))
    } else {
      return(c())
    }
  })

  labColFunc <- reactive({
    return(colnames(dataFunc()))
  })

  observeEvent(input[['heatmap-r-reset-zoom']], {
    if (plotAttr$width == '98%') {
      plotAttr$width = '100%'
    } else if (plotAttr$width == '100%') {
      plotAttr$width = '99%'
    } else if (plotAttr$width == '99%') {
      plotAttr$width = '98%'
    }
  })

  observeEvent(input$heatmap_r_color, {
    plotAttr$colors <- colors[[input$heatmap_r_color]]
  })

  plotAttr <- reactiveValues(width = '100%', colors=NULL)

  observeEvent(input$showpanel, {
    if(input$showpanel == TRUE) {
      removeCssClass("main", "col-sm-12")
      addCssClass("main", "col-sm-8")
      shinyjs::show(id = "sidebar")
      shinyjs::enable(id = "sidebar")
      plotAttr$width = '99%'
    }
    else {
      removeCssClass("main", "col-sm-8")
      addCssClass("main", "col-sm-12")
      shinyjs::hide(id = "sidebar")
      plotAttr$width = '100%'
    }

    output$heatmapRPlot <- renderPlotly({
      # heatmaply(dataFunc(), Rowv = input$heatmap_r_rowv, Colv = input$heatmap_r_colv)
      heatmaply(dataFunc(), colors = plotAttr$colors, row_text_angle = 0, column_text_angle = 45,
                subplot_margin = 0, cellnote = NULL, draw_cellnote = FALSE,
                Rowv = input$heatmap_r_rowv, Colv = input$heatmap_r_colv,
                distfun = dist, hclustfun = hclust, dist_method = input$heatmap_r_dist_method,
                hclust_method = input$heatmap_r_hc_method, scale = input$heatmap_r_scale,
                na.rm = input$heatmap_r_na_rm, hide_colorbar = FALSE, ColSideColors = NULL,
                RowSideColors = NULL, width = plotAttr$width, height = '600px',
                plot_method = c("plotly"), cexRow = input$heatmap_r_cex_row,
                cexCol = input$heatmap_r_cex_col, showticklabels = c(FALSE, FALSE),
                dynamicTicks = FALSE, grid_size = 0.1, node_type = "heatmap",
                labRow = labRowFunc(), labCol = labColFunc())
    })
  })
})
