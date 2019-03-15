library(shiny)
# For more information, please see https://plot.ly/r/shinyapp-explore-diamonds/
library(ggplot2)
library(plotly)
library(RColorBrewer)

shinyServer(function(input, output, session) {
  # to relay the height/width of the plot's container, we'll query this 
  # session's client data http://shiny.rstudio.com/articles/client-data.html
  cdata <- session$clientData

  dataFunc <- reactive({
    data
  })

  colors <- reactiveValues(new = c())
  observeEvent(input$group_boxplot_change_color, {
    col_var <- if (input$group_boxplot_col == "None") NULL else dataFunc()[,input$group_boxplot_col]
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

  observeEvent(input$group_boxplot_col, {
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

    output$groupBoxplot <- renderPlotly({
      x_var <- dataFunc()[, input$group_boxplot_x]
      labels <- if (input$group_boxplot_x_labels == "None") rownames(x_var) else dataFunc()[, input$group_boxplot_x_labels]
      xTitle <- if(is.null(attrs$xTitle)) input$group_boxplot_x else attrs$xTitle
      yTitle <- if(is.null(attrs$yTitle)) input$group_boxplot_y else attrs$yTitle
      legendTitle <- if(is.null(attrs$legendTitle)) input$group_boxplot_col else attrs$legendTitle
          
      # build graph with ggplot syntax
      p <- ggplot(dataFunc(),
                  aes_string(x=input$group_boxplot_x,
                             y=input$group_boxplot_y,
                             fill=input$group_boxplot_col)) + 
          geom_boxplot() +
          scale_x_discrete(labels = levels(labels)) +
          theme(axis.title=element_text(size=input$group_boxplot_title_size),
                axis.text.x=element_text(angle=60, hjust=1, size=input$group_boxplot_x_labelsize),
                axis.text.y=element_text(size=input$group_boxplot_y_labelsize),
                legend.text=element_text(size=input$group_boxplot_legend_labelsize),
                legend.position='right') +
          labs(x=xTitle, y=yTitle, fill=legendTitle)
      
      ggplotly(p) %>% layout(autosize=TRUE, boxmode = "group")
    })
  })
})
