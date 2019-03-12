library(shiny)
# For more information, please see https://plot.ly/r/shinyapp-explore-diamonds/
library(ggplot2)
library(plotly)
library(dplyr)
library(RColorBrewer)

getColors <- function(n, dataType='seq') {
  allChoices <- brewer.pal.info

  availableChoices <- allChoices[allChoices$maxcolors > n & allChoices$category == dataType,]

  if (dim(availableChoices)[1] != 0) {
    colorPal <- sample(rownames(availableChoices), size=1)
    if (n <= 3) {
      options <- brewer.pal(3, colorPal)
      return(options[1:n])
    } else {
      return(brewer.pal(n, colorPal))
    }
  } else {
    return(NULL)
  }
}

getLen <- function(x) {
  return(length(unique(x)))
}

shinyServer(function(input, output, session) {
  # to relay the height/width of the plot's container, we'll query this 
  # session's client data http://shiny.rstudio.com/articles/client-data.html
  cdata <- session$clientData

  dataFunc <- reactive({
    if(input$stack_barplot_smart_color != 'None') {
      if(input$stack_barplot_label != 'None') {
        data <- data[order(data[, input$stack_barplot_smart_color]),]
        labels <- data[, input$stack_barplot_label]
        data[, input$stack_barplot_label] <- factor(labels, levels=as.vector(unique(labels)))
      }
      return(data)
    } else {
      return(data)
    }
  })

  plotAttr <- reactiveValues(colors = NULL)

  observeEvent(input$stack_barplot_smart_color, {
    fill <- if(input$stack_barplot_label == 'None') NULL else input$stack_barplot_label
    if(input$stack_barplot_smart_color != 'None') {
      colorGroup <- aggregate(x=dataFunc()[fill],
                              by=list(dataFunc()[,input$stack_barplot_smart_color]),
                              FUN=getLen)
      if (is.null(colorGroup)) {
        plotAttr$colors <- NULL
      } else {
        colorNum <- colorGroup[, fill]
        colors <- unlist(lapply(colorNum, getColors, dataType='seq'))
        if (sum(colorNum) == length(colors)) {
          plotAttr$colors <- colors
        } else {
          plotAttr$colors <- NULL
        }
      }
    } else {
      plotAttr$colors <- NULL
    }
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

    output$stackBarPlot <- renderPlotly({
      angle <- as.integer(attrs$xAngle)
      fill <- if(input$stack_barplot_label == 'None') NULL else input$stack_barplot_label
      fillVar <- unique(dataFunc()[, fill])
      colors <- if(is.null(plotAttr$colors)) getColors(length(fillVar)) else plotAttr$colors

      # build graph with ggplot syntax
      p <- ggplot(dataFunc(), aes_string(fill=fill,
                                         y=input$stack_barplot_y,
                                         x=input$stack_barplot_x)) + 
            geom_bar(stat="identity", position=input$stack_barplot_bar_pos) +
            labs(x=attrs$xTitle, y=attrs$yTitle) +
            theme(axis.text.x=element_text(angle=angle, hjust=1,
                                           size=input$stack_barplot_xyl_labelsize),
                  axis.text.y=element_text(size=input$stack_barplot_xyl_labelsize),
                  text=element_text(size=input$stack_barplot_title_size),
                  legend.text=element_text(size=input$stack_barplot_xyl_labelsize),
                  legend.title=element_blank(),
                  panel.background=element_rect(fill = "white"),
                  axis.line=element_line(colour='black'))
      
      if (!is.null(colors)) {
        p <- p + scale_fill_manual(values=colors)
      }

      (ggplotly(p) %>% layout(autosize=TRUE))
    })
  })
})
