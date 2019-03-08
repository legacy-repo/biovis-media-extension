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

  if (is.null(attrs$title)) {
    shinyjs::hide(id="boxplot-r-title-area")
  }

  dataFunc <- reactive({
    data
  })

  statCompareChoices <- reactive({
    # select pairs to compare
    colorChoices <- levels(dataFunc()[, input$boxplot_r_col])
    combnChoices <- t(combn(colorChoices, 2))
    comparisons <- apply(combnChoices, 1, paste0, collapse=" vs. ")
    names(comparisons) <- comparisons
    comparisons
  })

  output$selectUI <- renderUI({ 
    selectInput("boxplot_r_stat_compare", "Select pairs to compare :",
                statCompareChoices(), multiple=TRUE, selected=NULL)
  })

  reactiveVar <- reactiveValues(colors = c(), my_comparisons = NULL, interactive=TRUE)

  # Change color
  observeEvent(input$boxplot_r_change_color, {
    col_var <- if (input$boxplot_r_col == "None") NULL else dataFunc()[,input$boxplot_r_col]
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
  observeEvent(input$boxplot_r_col, {
    reactiveVar$colors <- c()
  })

  # 
  observeEvent(input$boxplot_r_stat_compare, {
    if (!is.null(input$boxplot_r_stat_compare)) {
      reactiveVar$my_comparisons = strsplit(input$boxplot_r_stat_compare, split=" vs. ")
    } else {
      reactiveVar$my_comparisons = NULL
    }
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

    observeEvent(input$boxplot_r_interactive, {
      if (input$boxplot_r_interactive) {
        shinyjs::show(id="boxplotlyR")
        shinyjs::hide(id="boxplotR")
        output$boxplotlyR <- renderPlotly({
        # important to adjust the label position!
          p <- ggboxplot(dataFunc(), x=input$boxplot_r_x, y=input$boxplot_r_y,
                         fill=input$boxplot_r_col, palette = reactiveVar$colors) + 
              rotate_x_text(angle=as.integer(attrs$xAngle)) + 
              theme(axis.text.x=element_text(size=input$boxplot_r_xyl_labelsize),
                    axis.text.y=element_text(size=input$boxplot_r_xyl_labelsize),
                    text=element_text(size=input$boxplot_r_title_size),
                    legend.text=element_text(size=input$boxplot_r_xyl_labelsize),
                    legend.title=element_blank(),
                    plot.title = element_text(hjust=0.5),
                    legend.position=input$boxplot_r_legend_pos) +
              ylim(min(dataFunc()[, input$boxplot_r_y], 0)*1.2,
                    max(dataFunc()[, input$boxplot_r_y]) + input$boxplot_r_y_axis_len)
          ggplotly(p) %>% layout(autosize=TRUE, boxmode = "group")
        })
      } else {
        shinyjs::hide(id="boxplotlyR")
        shinyjs::show(id="boxplotR")
        output$boxplotR <- renderPlot({
        # important to adjust the label position!
          p <- ggboxplot(dataFunc(), x=input$boxplot_r_x, y=input$boxplot_r_y,
                         fill=input$boxplot_r_col, palette = reactiveVar$colors) + 
              stat_compare_means(comparisons=reactiveVar$my_comparisons) + 
              stat_compare_means(label.y=7.5, label.x=4, bracket.size = 15) + 
              rotate_x_text(angle=as.integer(attrs$xAngle)) + 
              theme(axis.text.x=element_text(size=input$boxplot_r_xyl_labelsize),
                    axis.text.y=element_text(size=input$boxplot_r_xyl_labelsize),
                    text=element_text(size=input$boxplot_r_title_size),
                    legend.text=element_text(size=input$boxplot_r_xyl_labelsize),
                    legend.title=element_blank(),
                    plot.title = element_text(hjust=0.5),
                    legend.position=input$boxplot_r_legend_pos) +
              ylim(min(dataFunc()[, input$boxplot_r_y], 0)*1.2,
                    max(dataFunc()[, input$boxplot_r_y]) + input$boxplot_r_y_axis_len)
          print(p)
        })
      }
    })
  })
})
