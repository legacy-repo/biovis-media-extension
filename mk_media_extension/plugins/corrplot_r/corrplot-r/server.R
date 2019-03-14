library(shiny)
# For more information, please see https://plot.ly/r/shinyapp-explore-diamonds/
library(ggplot2)
library(plotly)
library(dplyr)
library(ggcorrplot)
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
    if (!is.null(input$corrplot_corr_vars)) {
      return(cor(data[, input$corrplot_corr_vars]))
    } else {
      return(cor(data))
    }
  })

  plotAttr <- reactiveValues(p.mat = NULL, colors=c("blue", "white", "red"))

  observeEvent(input$corrplot_pmat, {
    if(input$corrplot_pmat) {
      plotAttr$p.mat <- cor_pmat(dataFunc())
    } else {
      plotAttr$p.mat <- NULL
    }
  })

  observeEvent(input$corrplot_change_color, {
    plotAttr$colors <- getColors(3, 'div')
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

    output$corrPlot <- renderPlotly({
      angle <- as.integer(attrs$xAngle)

      # build graph with ggplot syntax
      p <- ggcorrplot(dataFunc(), method=input$corrplot_method, type=input$corrplot_type,
                      show.diag=input$corrplot_show_diag, colors=plotAttr$colors,
                      outline.col="white", hc.order=input$corrplot_hc_order, 
                      hc.method=input$corrplot_hc_method, lab=input$corrplot_show_lab, 
                      lab_col="black", lab_size=4, p.mat=plotAttr$p.mat,
                      sig.level=input$corrplot_sig_level, title=attrs$title,
                      show.legend=TRUE, legend.title="", insig="pch",
                      ggtheme = ggplot2::theme_gray, pch = 4, pch.col = "black") +
            # labs(x="", y="", fill="Corr") +
            theme(axis.text.x=element_text(angle=angle, hjust=1, margin=margin(-3,0,0,0),
                                           size=input$corrplot_xyl_labelsize),
                  axis.text.y=element_text(size=input$corrplot_xyl_labelsize,
                                           margin=margin(0,-3,0,0)),
                  text=element_text(size=input$corrplot_title_size),
                  legend.text=element_text(size=input$corrplot_xyl_labelsize),
                  legend.title=element_blank(),
                  panel.background=element_blank(),
                  panel.grid.major=element_blank(),
                  axis.line=element_line(colour='black'))

      (ggplotly(p) %>% layout(autosize=TRUE))
    })
  })
})
