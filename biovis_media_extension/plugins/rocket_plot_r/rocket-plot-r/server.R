library(shiny)
# For more information, please see https://plot.ly/r/shinyapp-explore-diamonds/
library(ggplot2)
library(plotly)
library(dplyr)
library(RColorBrewer)

shinyServer(function(input, output, session) {
  # to relay the height/width of the plot's container, we'll query this 
  # session's client data http://shiny.rstudio.com/articles/client-data.html
  cdata <- session$clientData

  dataFunc <- reactive({
    if (input$rocket_plot_label == 'None') {
      data$text <- paste("\nX: ", data[, input$rocket_plot_x],
                         "\nY: ", data[, input$rocket_plot_y])      
    } else {
      data$text <- paste(data[, input$rocket_plot_label],
                         "\nX: ", data[, input$rocket_plot_x],
                         "\nY: ", data[, input$rocket_plot_y])
    }

    return(data)
  })

  dataFilterFunc <- reactive({
    # Filter data with min threshold
    thr.filter=log2(6)
    if (input$rocket_plot_x == input$rocket_plot_y) {
      dataFilter <- (dataFunc() %>% filter(input$rocket_plot_x>=thr.filter,
                                            input$rocket_plot_y>=thr.filter)
                                %>% select(input$rocket_plot_x, input$rocket_plot_y)
                                %>% mutate(Y=dataFunc()[,input$rocket_plot_y])
                                %>% rename(X=input$rocket_plot_x, Y=Y))
    } else {
      dataFilter <- (dataFunc() %>% filter(input$rocket_plot_x>=thr.filter,
                                            input$rocket_plot_y>=thr.filter)
                                %>% select(input$rocket_plot_x, input$rocket_plot_y)
                                %>% rename(X=input$rocket_plot_x, Y=input$rocket_plot_y))      
    }
    return(dataFilter)
  })

  plotData <- reactiveValues(methodResult = NULL, intercept = NA, slope = NA,
                             correlationPos = c(1, 1))
  
  observeEvent(input$rocket_plot_method, {
    if (all(is.numeric(dataFilterFunc()$X)) && all(is.numeric(dataFilterFunc()$Y))) {
      if (input$rocket_plot_method == 'None') {
        plotData$methodResultStr <- ''
        plotData$intercept <- NA
        plotData$slope <- NA
      }

      if (input$rocket_plot_method == 'linear_regression') {
        removeCssClass('rocket-plot-spinner', "hide-spinner")
        addCssClass('rocket-plot-spinner', 'display-spinner')

        dataFilterLm <- lm(Y~X, dataFilterFunc())
        slope <- dataFilterLm$coefficients[2]
        intercept <- dataFilterLm$coefficients[1]
        dataFilterLmSummary <- summary(dataFilterLm)
        rSquared <- dataFilterLmSummary$r.squared
        plotData$methodResultStr <- sprintf(' Y = %.2fX + %.2f\nR-squared = %.4f',
                                            slope, intercept, rSquared)
        plotData$intercept <- intercept
        plotData$slope <- slope
      } else if (input$rocket_plot_method == 'pearson_correlation') {
        removeCssClass('rocket-plot-spinner', "hide-spinner")
        addCssClass('rocket-plot-spinner', 'display-spinner')

        cor <- cor(dataFilterFunc()$X, dataFilterFunc()$Y)
        plotData$methodResultStr <- sprintf('Correlation=%.2f', cor)
        plotData$intercept <- 0
        plotData$slope <- 1
      }
      plotData$correlationPos <- c(max(dataFilterFunc()$X)*0.3,
                                   max(dataFilterFunc()$Y)*0.95)
      removeCssClass('rocket-plot-spinner', 'display-spinner')
      addCssClass('rocket-plot-spinner', "hide-spinner")
    }
  })
  
  observeEvent(input$rocket_plot_x, {
      updateSelectInput(session, "rocket_plot_method", selected="None")
  })
  
  observeEvent(input$rocket_plot_y, {
    updateSelectInput(session, "rocket_plot_method", selected="None")
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

    output$rocketPlot <- renderPlotly({
      # angle <- as.integer(input$rocket_plot_x_angle)
      angle <- as.integer(attrs$xAngle)
      pal <- brewer.pal(8, 'Blues')

      xTitle <- if(is.null(attrs$xTitle)) input$rocket_plot_x else attrs$xTitle
      yTitle <- if(is.null(attrs$yTitle)) input$rocket_plot_y else attrs$yTitle
      
      # build graph with ggplot syntax
      p <- ggplot(dataFunc(), aes_string(x=input$rocket_plot_x,
                                         y=input$rocket_plot_y,
                                         text="text")) + 
            geom_abline(slope=plotData$slope, intercept=plotData$intercept,
                        color=pal[4], size=.6) +
            geom_point(size=input$rocket_plot_point_size, colour=input$rocket_plot_color,
                       alpha=attrs$pointAlpha) + 
            coord_fixed(ratio=input$lock_ratio) +
            labs(x=xTitle, y=yTitle) +
            theme(axis.text.x=element_text(angle=angle, hjust=1,
                                           size=input$rocket_plot_xyl_labelsize),
                  axis.text.y=element_text(size=input$rocket_plot_xyl_labelsize),
                  text=element_text(size=input$rocket_plot_title_size),
                  legend.text=element_text(size=input$rocket_plot_xyl_labelsize),
                  legend.title=element_blank(),
                  panel.background=element_rect(fill = "white"),
                  axis.line=element_line(colour='black'))

      (ggplotly(p, tooltip="text") %>%
       layout(autosize=TRUE,
              annotations=list(text=plotData$methodResultStr, 
                               x=plotData$correlationPos[1],
                               y=plotData$correlationPos[2],
                               showarrow=FALSE )))
    })
  })
})
