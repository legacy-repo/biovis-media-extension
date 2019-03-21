library(shiny)
library(plotly)
library(UpSetR)
library(RColorBrewer)

setlimit <- 20

shinyServer(function(input, output) {
  # Render a control for users to pick from their supplied sets

  getColors <- function(default=NULL, colorName=NULL, dataType='seq') {
    if (!is.null(default) && default ) {
      colors = (c("vbarcolor" = "#e85b24",
                  "pointcolor" = "#3b3b3b",
                  "hbarcolor" = "#357faa"))
    } else {
      n <- 3
      allChoices <- RColorBrewer::brewer.pal.info

      availableChoices <- allChoices[allChoices$maxcolors > n & allChoices$category == dataType,]

      if (dim(availableChoices)[1] != 0) {
        colorPal <- sample(rownames(availableChoices), size=1)
        colors <- RColorBrewer::brewer.pal(n, colorPal)
        names(colors) <- c("vbarcolor", "pointcolor", "hbarcolor")
      }
    }

    if (!is.null(colorName) && colorName %in% names(colors)) {
      return(colors[colorName])
    } else {
      return(colors)
    }
  }

  plotAttr <- reactiveValues(colors = getColors(default=TRUE))

  observeEvent(input$upset_plot_change_color, {
    plotAttr$colors <- getColors(dataType='qual')
  })

  output$sets <- renderUI({
    valid_sets <- getValidSets()
    req(!is.null(valid_sets))
    
    selectInput(
      "sets",
      "Sets",
      choices = names(valid_sets),
      selectize = TRUE,
      multiple = TRUE,
      selected = names(valid_sets)
    )
  })
  
  # Render a control to decide how many sets to consider in the plot
  
  output$nsets <- renderUI({
    selected_sets <- getSelectedSets()
    req(!is.null(selected_sets))
    
    max_sets <-
      ifelse(length(selected_sets) > setlimit,
             setlimit,
             length(selected_sets))
    sliderInput(
      "nsets",
      label = "Number of sets to include in plot",
      min = 2,
      max = max_sets,
      step = 1,
      value = min(10, max_sets)
    )
  })
  
  ############################################################################# Form accessors
  
  # Accessor for user-selected sets
  
  getSelectedSetNames <- reactive({
    req(input$sets)
    input$sets
  })
  
  # Accessor for the nsets parameter
  
  getNsets <- reactive({
    req(!is.null(input$nsets))
    input$nsets
  })
  
  # Accessor for the nintersections parameter
  
  getNintersections <- reactive({
    validate(need(!is.null(input$nintersects), "Waiting for nintersects"))
    input$nintersects
  })
  
  getShowEmptyIntersections <- reactive({
    validate(need(
      !is.null(input$show_empty_intersections),
      "Waiting for empty intersections option"
    ))
    input$show_empty_intersections
  })
  
  # Accessor for the intersection assignment type
  
  getIntersectionAssignmentType <- reactive({
    validate(need(
      !is.null(input$intersection_assignment_type),
      "Waiting for group_by"
    ))
    input$intersection_assignment_type
  })
  
  # Set sorting
  
  getSetSort <- reactive({
    validate(need(!is.null(input$set_sort), "Waiting for set_sort"))
    input$set_sort
  })
  
  # Bar numbers
  
  getBarNumbers <- reactive({
    validate(need(!is.null(input$bar_numbers), "Waiting for bar numbers"))
    input$bar_numbers
  })
  
  ############################################################################# The business end- derive sets and pass for intersection
  
  # Get the input file
  
  getInfile <- reactive({
    inFile <- input$file1
    
    if (is.null(inFile)) {
      # Look for example data to use by default
      
      if (file.exists(system.file("extdata", "movies.csv", package = "UpSetR"))) {
        filename <- system.file("extdata", "movies.csv", package = "UpSetR")
      } else if (file.exists('movies.csv')) {
        filename <- 'movies.csv'
      } else {
        filename <- NULL
      }
    } else {
      filename <- inFile$datapath
    }
  })
  
  # Set input sets
  getValidSets <- reactive({
    withProgress(message = "Deriving input sets", value = 0, {
      setdata <- data
      logical_cols <-
        colnames(setdata)[apply(setdata, 2, function(x)
          all(x %in% c(0, 1)))]
      names(logical_cols) <- logical_cols
      
      lapply(logical_cols, function(x)
        which(setdata[[x]] == 1))
    })
  })
  
  # Subset sets to those selected
  
  getSelectedSets <- reactive({
    valid_sets <- getValidSets()
    validate(need(!is.null(valid_sets), "Please upload data"))
    chosen_sets <- getSelectedSetNames()
    sets <- valid_sets[chosen_sets]
    if (getSetSort()) {
      sets <- sets[order(unlist(lapply(sets, length)))]
    }
    sets
  })
  
  # Get the sets we're going to use based on nsets
  
  getSets <- reactive({
    selected_sets <- getSelectedSets()
    req(length(selected_sets) > 0)
    
    nsets <- getNsets()
    selected_sets[1:min(nsets, length(selected_sets))]
  })
  
  # Calculate intersections between sets
  
  calculateIntersections <- reactive({
    selected_sets <- getSets()
    
    sets <- getSets()
    nsets <- length(sets)
    
    # Get all possible combinations of sets
    
    combinations <- function(items, pick) {
      x <- combn(items, pick)
      lapply(seq_len(ncol(x)), function(i)
        x[, i])
    }
      
    assignment_type <- getIntersectionAssignmentType()
    
    # No point starting at size 1 in a non-upset plot
    
    startsize <- ifelse(assignment_type == "upset", 1, 2)
    
    combos <- lapply(startsize:nsets, function(x) {
      combinations(1:length(selected_sets), x)
    })
    
    # Calculate the intersections of all these combinations
    intersects <- lapply(combos, function(combonos) {
      lapply(combonos, function(combo) {
        Reduce(intersect, selected_sets[combo])
      })
    })
      
    # For UpSet-ness, membership of higher-order intersections takes priority Otherwise just return the number of entries in each intersection
    
    intersects <- lapply(1:length(intersects), function(i) {
      intersectno <- intersects[[i]]
      members_in_higher_levels <-
        unlist(intersects[(i + 1):length(intersects)])
      lapply(intersectno, function(intersect) {
        if (assignment_type == "upset") {
          length(setdiff(intersect, members_in_higher_levels))
        } else {
          length(intersect)
        }
      })
    })
      
    combos <- unlist(combos, recursive = FALSE)
    intersects <- unlist(intersects)
    
    if (!getShowEmptyIntersections()) {
      combos <- combos[which(intersects > 0)]
      intersects <- intersects[which(intersects > 0)]
    }
      
    # Sort by intersect size
    combos <- combos[order(intersects, decreasing = TRUE)]
    intersects <-
      intersects[order(intersects, decreasing = TRUE)]
    list(combinations = combos, intersections = intersects)
  })
  
  # Add some line returns to contrast names
  
  getSetNames <- reactive({
    selected_sets <- getSets()
    gsub("_", " ", names(selected_sets))
  })
  
  # Make the grid of points indicating set membership in intersections
  
  upsetGrid <- reactive({
    selected_sets <- getSets()
    ints <- calculateIntersections()
    
    intersects <- ints$intersections
    combos <- ints$combinations
    
    # Reduce the maximum number of intersections if we don't have that many
    
    nintersections <- getNintersections()
    nintersections <- min(nintersections, length(combos))
    
    # Fetch the number of sets
    
    nsets <- getNsets()
    setnames <- getSetNames()
    
    lines <-
      data.table::rbindlist(lapply(1:nintersections, function(combono) {
        data.frame(
          combo = combono,
          x = rep(combono, max(2, length(combos[[combono]]))),
          y = (nsets - combos[[combono]]) + 1,
          name = setnames[combos[[combono]]]
        )
      }))
    
    plot_ly(
      type = "scatter",
      mode = "markers",
      marker = list(color = "lightgrey", size = 8)
    ) %>% add_trace(
      type = "scatter",
      name = "No Hit",
      x = rep(1:nintersections,
              length(selected_sets)),
      y = unlist(lapply(1:length(selected_sets), function(x)
        rep(x - 0.5, nintersections))),
      hoverinfo = "none"
    ) %>% add_trace(
      type = "scatter",
      name = "Hit",
      data = group_by(lines, combo),
      mode = "lines+markers",
      x = lines$x,
      y = lines$y - 0.5,
      line = list(color = plotAttr$colors["pointcolor"],
                  width = 3),
      marker = list(color = plotAttr$colors["pointcolor"],
                    size = 10),
      hoverinfo = "text",
      text = ~ name
    ) %>% layout(
      xaxis = list(
        showticklabels = FALSE,
        showgrid = FALSE,
        zeroline = FALSE
      ),
      yaxis = list(
        showticklabels = FALSE,
        showgrid = TRUE,
        range = c(0, nsets),
        zeroline = FALSE,
        range = 1:nsets
      ),
      margin = list(t = 0, b = 40),
      autosize=TRUE
    )
  })
  
  # Make the bar chart illustrating set sizes
  upsetSetSizeBarChart <- reactive({
    setnames <- getSetNames()
    selected_sets <- getSets()
    
    plot_ly(
      x = unlist(lapply(selected_sets, length)),
      name = 'Num of Items',
      y = setnames,
      type = "bar",
      orientation = "h",
      marker = list(color = plotAttr$colors["hbarcolor"])
    ) %>% layout(
      bargap = 0.4,
      yaxis = list(
        categoryarray = rev(setnames),
        categoryorder = "array"
      ),
      autosize=TRUE
    )
  })
  
  # Make the bar chart illustrating intersect size
  upsetIntersectSizeBarChart <- reactive({
    ints <- calculateIntersections()
    intersects <- ints$intersections
    combos <- ints$combinations
    nintersections <- getNintersections()
    
    p <-
      plot_ly(showlegend = FALSE) %>% add_trace(
        name = "Num of Items",
        x = 1:nintersections,
        y = unlist(intersects[1:nintersections]),
        type = "bar",
        marker = list(color = plotAttr$colors["vbarcolor"],
                      hoverinfo = "none")
      )
    
    bar_numbers <- getBarNumbers()
    
    if (bar_numbers) {
      p <-
        p %>% add_trace(
          type = "scatter",
          name = "Num of Items",
          mode = "text",
          x = 1:nintersections,
          y = unlist(intersects[1:nintersections]) + (max(intersects) * 0.05),
          text = unlist(intersects[1:nintersections]),
          textfont = list(color = plotAttr$colors["vbarcolor"]),
          hoverinfo = "none"
        )
    }
    p %>% layout(autosize=TRUE)
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
  
    output$plotly_upset <- renderPlotly({
      grid <- upsetGrid()
      set_size_chart <- upsetSetSizeBarChart()
      intersect_size_chart <- upsetIntersectSizeBarChart()
      
      # Hide tick labels on the grid
      
      # Unfortunately axis titles get hidden on the subplot. Not sure why.
      
      intersect_size_chart <-
        intersect_size_chart %>% layout(yaxis = list(title = "Intersections size"))
      
      # The y axis labels of the
      
      s1 <-
        subplot(
          plotly_empty(type = "scatter", mode = "markers"),
          plotly_empty(type = "scatter", mode = "markers"),
          plotly_empty(type = "scatter", mode = "markers"),
          set_size_chart,
          nrows = 2,
          widths = c(0.6, 0.4)
        )
      s2 <-
        subplot(intersect_size_chart,
                grid,
                nrows = 2,
                shareX = TRUE) %>% layout(showlegend = TRUE)
      
      subplot(s1, s2, widths = c(0.2, 0.8))
    })
  })
})
