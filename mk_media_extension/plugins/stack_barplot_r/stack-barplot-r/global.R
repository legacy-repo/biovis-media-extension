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

if (is.null(attributes$labelAttr) || !as.vector(attributes$labelAttr) %in% colnames(rawData)) {
    rawData[as.vector(attributes$labelAttr)] <- rownames(rawData)
}

if (is.null(attributes$barPos) || !as.vector(attributes$barPos) %in% c('fill', 'dodge', 'stack')) {
    attributes$barPos <- 'fill'
}

data <- rawData
attrs <- list(
    title=getVector(attributes$title),
    subtitle=getVector(attributes$subtitle),
    text=getVector(attributes$text),
    queryURL=getVector(attributes$queryURL),
    xTitle=getVector(attributes$xTitle),
    xAngle=getVector(attributes$xAngle),
    yTitle=getVector(attributes$yTitle),
    barPos=getVector(attributes$barPos)
)

dataColnames <- colnames(data)
for (col in c('xAxis', 'yAxis', 'labelAttr', 'smartColor')) {
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
