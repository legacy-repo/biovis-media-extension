library(shiny)
# For more information, please see https://plot.ly/r/shinyapp-explore-diamonds/
library(ggplot2)
library(plotly)
library(ggpubr)
library(RColorBrewer)

shinyServer(function(input, output, session) {
  # to relay the height/width of the plot's container, we'll query this 
  # session's client data http://shiny.rstudio.com/articles/client-data.html
  cdata <- session$clientData

  dataFunc <- reactive({
    data
  })

  reactiveVar <- reactiveValues(colors = c())

  # Change color
  observeEvent(input$violin_plot_r_change_color, {
    col_var <- (if (input$violin_plot_r_col == "None") NULL 
                else dataFunc()[,input$violin_plot_r_col])

    if (is.null(col_var)) {
      reactiveVar$colors <- c()
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
      reactiveVar$colors <- brewer.pal(n, colorPal)
    } else {
      reactiveVar$colors <- c()
    }
  })

  # Reset color
  observeEvent(input$violin_plot_r_col, {
    reactiveVar$colors <- c()
  })

  # Switch panel to hide/show status
  observeEvent(input$showpanel, {
    if(input$showpanel == TRUE) {
      removeCssClass("main", "col-sm-12")
      addCssClass("main", "col-sm-8")
      shinyjs::show(id="sidebar")
      shinyjs::enable(id="sidebar")
    }
    else {
      removeCssClass("main", "col-sm-8")
      addCssClass("main", "col-sm-12")
      shinyjs::hide(id="sidebar")
    }

    output$violin_plotlyR <- renderPlotly({
      if (input$violin_plot_r_legend_pos == 'v') {
        legend_x_pos = 1.1
        legend_y_pos = 1.1
      } else {
        legend_x_pos = 0.5
        legend_y_pos = 1.1
      }

      xangle <- as.integer(input$violin_plot_x_angle)

      p <- ggplot(dataFunc(), aes_string(x=input$violin_plot_r_x,
                                         y=input$violin_plot_r_y, 
                                         fill=input$violin_plot_r_col)) + 
            geom_violin(trim = FALSE) + 
            geom_jitter(shape=16, position=position_jitter(0.2),
                        fill=input$violin_plot_r_col) + 
            rotate_x_text(angle=xangle) + 
            theme(axis.text.x=element_text(size=input$violin_plot_r_xyl_labelsize, 
                                           hjust=1, margin=margin(-3,0,0,0)),
                  axis.text.y=element_text(size=input$violin_plot_r_xyl_labelsize,
                                           margin=margin(0,-3,0,0)),
                  text=element_text(size=input$violin_plot_r_title_size),
                  legend.text=element_text(size=input$violin_plot_r_xyl_labelsize),
                  legend.title=element_blank(),
                  panel.background=element_blank(),
                  panel.grid.major=element_blank(),
                  axis.line=element_line(colour='black'))
      (ggplotly(p) %>% 
       layout(autosize=TRUE, xaxis=list(automargin=TRUE),
              legend=list(orientation=input$violin_plot_r_legend_pos,
                          xanchor="center", yanchor="auto",
                          y=legend_y_pos, x=legend_x_pos)))
    })
  })
})
