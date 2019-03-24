library(shiny)
library(ggplot2)
library(plotly)
library(RColorBrewer)

choices <- colnames(data)
names(choices) <- colnames(data)

computePos <- function(chr_num_var, pos_coord_var) {
  # chr_num_var pos_coord_var must be numeric and ordered.
  position <- c()
  ticks <- c()
  vlines <- c()
	lastbase <- 0

  numchroms <- length(unique(chr_num_var))
  if (numchroms==1) {
			position <- pos_coord_var
  } else {
    for (i in unique(chr_num_var)) {
      target_value <- max(pos_coord_var[chr_num_var == i - 1])
      if (is.infinite(target_value)) {
        target_value <- 0
      }
      lastbase <- lastbase + target_value
      position <- c(position, pos_coord_var[chr_num_var == i] + lastbase)

      ticks <- c(ticks, max(pos_coord_var[chr_num_var == i])/2 + lastbase)
      vlines <- c(vlines, max(pos_coord_var[chr_num_var == i]) + lastbase)
    }
  }
  return(list(pos=position, ticks=ticks, vlines=vlines))
}

shinyServer(function(input, output) {
  plotAttr <- reactiveValues(ticks=NULL, vlines=NULL)

  dataFunc <- reactive({
    if (!is.null(input$cnv_plot_pos_num_var) & 
        !is.null(input$cnv_plot_pos_coord)) {
      chr_num_var <- as.vector(as.character(data[,input$cnv_plot_pos_num_var]))
      pos_coord_var <- as.vector(as.character(data[,input$cnv_plot_pos_coord]))
      pos_list <- computePos(chr_num_var, pos_coord_var)
      plotAttr$ticks <- pos_list[['ticks']]
      plotAttr$vlines <- pos_list[['vline']]
      position <- pos_list[['pos']]
    } else {
      position <- data[, input$cnv_plot_x_var]
    }

    return(data.frame(data, pos=position))
  })

  # Compute Position?
  observeEvent(input$cnv_plot_compute_pos, {
    if (input$cnv_plot_compute_pos) {
      output$positionNumUI <- renderUI({ 
        selectInput("cnv_plot_pos_num_var", "Chromosome num :",
                    choices, selected=NULL)
      })
      output$positionCoorUI <- renderUI({
        selectInput("cnv_plot_pos_coord", "Coordinate :",
                    choices, selected=NULL)
      })
      output$xAxisUI <- NULL
    } else {
      output$xAxisUI <- renderUI({
        selectInput("cnv_plot_x_var", "X variable :",
                    choices, selected=NULL)  
      })
      output$positionNumUI <- NULL
      output$positionCoorUI <- NULL
    }
  })

  observeEvent(input$cnv_plot_anno_var, {
    if (input$cnv_plot_anno_var != 'none') {
      annoChoices <- unique(as.vector(dataFunc()[, input$cnv_plot_anno_var]))
      names(annoChoices) <- annoChoices
      output$annoListUI <- renderUI({
        selectInput("cnv_plot_anno_list", "Anno lables :",
                    choices = annoChoices,
                    multiple = TRUE,
                    selected = attrs$annoLabels)
      })
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

    output$cnvPlot <- renderPlotly({
      # annotateList <- input$cnv_plot_anno_list
      # if (!is.null(annotateList)) {
      #   annotation <- dataFunc()[dataFunc()[, input$cnv_plot_anno_var] %in% annotateList, ]
      # } else {
      #   annotation <- NULL
      # }

      # pos <- if (!is.null(input$cnv_plot_pos_num_var) & 
      #            !is.null(input$cnv_plot_pos_coord)) 'pos' else input$cnv_plot_x_var

      p <- ggplot(dataFunc(), aes_string(x=input$cnv_plot_x_var, 
                                         y=input$cnv_plot_y_var,
                                         group=input$cnv_plot_group_type)) + 
           geom_area(aes_string(color=input$cnv_plot_group_type,
                                fill=input$cnv_plot_group_type),
                                alpha = 0.1) +
           geom_line(aes_string(color=input$cnv_plot_group_type))
      
      # if (input$cnv_plot_compute_pos) {
      #   numchroms=length(unique(dataFunc()[, input$cnv_plot_x_var]))
      #   if (numchroms==1) {
      #     p <- p + xlab(paste("Chr", gsub("Y", "24", gsub("X", "23",
      #                         unique(dataFunc()[, input$cnv_plot_x_var])))))
      #   }else{
      #     labels <- gsub("24", "Y", gsub("23", "X", 
      #                    unique(dataFunc()[, input$cnv_plot_x_var])))
      #     p <- p + scale_x_continuous(name="Chromosome",
      #                                 breaks=plotAttr$ticks,
      #                                 labels=labels) +
      #          geom_vline(xintercept=plotAttr$vlines, linetype="dotted", color="grey", size=1)
      #   }
      # }

      # if (!is.null(annotation)) {
      #   p <- p + geom_point(data=annotation, 
      #                       aes_string(x='pos', y=input$cnv_plot_y_var),
      #                                 fill="black")
      # }

      p <- p + ggtitle(attrs$title) + ylab(attrs$ylab) + 
                theme(axis.text.x=element_text(size=input$cnv_plot_xyl_labelsize),
                      axis.text.y=element_text(size=input$cnv_plot_xyl_labelsize),
                      text=element_text(size=input$cnv_plot_xy_title_size),
                      legend.text=element_text(size=input$cnv_plot_xyl_labelsize),
                      legend.title=element_blank(),
                      plot.title = element_text(hjust=0.5))

      ggplotly(p) %>% layout(autosize=TRUE)
    })
  })
})
