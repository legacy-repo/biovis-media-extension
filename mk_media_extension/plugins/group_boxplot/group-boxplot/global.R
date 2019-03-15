library(configr)
library(dplyr)

config <- read.config(file = 'shiny.ini')
dataConfig <- config$data
attributes <- config$attributes

if (dataConfig$dataType == 'rds') {
    rawData <- readRDS(dataConfig$dataFile)
} else if (dataConfig$dataType == 'csv') {
    rawData <- read.csv(dataConfig$dataFile, header=TRUE)
}

getVector <- function(value) {
    if (!is.null(value)) {
        return(as.vector(as.matrix(value)))
    } else {
        return(NULL)
    }
}

data <- rawData
attrs <- list(
    title=getVector(attributes$title),
    subtitle=getVector(attributes$subtitle),
    text=getVector(attributes$text),
    queryURL=getVector(attributes$queryURL),
    xTitle=getVector(attributes$xTitle),
    yTitle=getVector(attributes$yTitle)
)

dataColnames <- colnames(data)
for (col in c('xAxis', 'yAxis', 'colorAttr', 'labelAttr')) {
    colname <- getVector(attributes[col])
    if (is.null(colname) || !(colname %in% dataColnames)) {
        if (col == 'xAxis' || col == 'yAxis') {
            stop("You must specify xAxis and yAxis in shiny.ini.")
        } else {
            attrs[col] <- 'None'
        }
    } else {
        attrs[col] <- colname
    }
}
