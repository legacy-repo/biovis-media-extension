library(shiny)
# For more information, please see https://github.com/freezecoder/mutsneedle
library(mutsneedle)
library(RColorBrewer)

shinyServer(function(input, output) {
  dataFunc <- reactive({
    data
  })

  regionDataFunc <- reactive({
    regionData
  })

  mutColnamesFunc <- reactive({
    mutColnames
  })

  regionColnamesFunc <- reactive({
    regionColnames
  })

  plotAttr <- reactiveValues(mutdata=NULL, domains=NULL, width='100%')

  observeEvent(input$showpanel, {
    if(input$showpanel == TRUE) {
      removeCssClass("main", "col-sm-12")
      addCssClass("main", "col-sm-8")
      shinyjs::show(id = "sidebar")
      shinyjs::enable(id = "sidebar")
      plotAttr$width = '990px'
    }
    else {
      removeCssClass("main", "col-sm-8")
      addCssClass("main", "col-sm-12")
      shinyjs::hide(id = "sidebar")
      plotAttr$width = '1000px'
    }

    output$mutsNeedle <- renderMutsneedle({
      if (all(mutColnamesFunc() != names(mutColnamesFunc()))) {
        plotAttr$mutdata <- (data.frame(dataFunc()) %>% 
                             rename(!!mutColnamesFunc()[c('coord', 'value')]))
      } else {
        plotAttr$mutdata <- dataFunc()
      }

      if (all(regionColnamesFunc() != names(regionColnamesFunc()))) {
        # TODO: rename colnames
        plotAttr$domains <- data.frame(regionDataFunc())
      } else {
        plotAttr$domains <- regionDataFunc()
      }

      mutsneedle(title=attrs$title, mutdata=plotAttr$mutdata,
                 domains=plotAttr$domains, gene="TP53", transcript="TP53",
                 maxlength=input$muts_needle_maxlength,
                 width="1000px", height="700px")
    })
  })
})
