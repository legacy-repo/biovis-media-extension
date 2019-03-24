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

getBool <- function(value) {
    if (value %in% c('True', 'TRUE', 'T', '1')) {
        return(TRUE)
    } else {
        return(FALSE)
    }
}

trim <- function (x) gsub("^\\s+|\\s+$", "", x)

data <- rawData

annoLabels <- getVector(attributes$annoLabels)
attrs <- list(
    title=getVector(attributes$title),
    xTitle=getVector(attributes$xTitle),
    yTitle=getVector(attributes$yTitle),
    subtitle=getVector(attributes$subtitle),
    text=getVector(attributes$text),
    queryURL=getVector(attributes$queryURL),
    showpanel=getBool(getVector(attributes$showpanel)),
    annoLabels=if(is.null(annoLabels)) NULL else trim(unlist(strsplit(annoLabels, ',')))
)

rawColnames <- colnames(data)
for (col in c('xAxis', 'yAxis', 'colorAttr', 'annoLabelVar')) {
    colname <- getVector(attributes[col])
    if (is.null(colname) || !(colname %in% rawColnames)) {
        if (col == 'xAxis' || col == 'yAxis') {
            stop("You must specify xAxis and yAxis in shiny.ini.")
        } else {
            attrs[col] <- 'None'
        }
    } else {
        attrs[col] <- colname
    }
}

mutColnames <- c('coord' = attrs[['coord']],
                 'category' = attrs[['category']],
                 'value' = attrs[['value']])

regionColnames <- c('coord' = attrs[['regionCoord']],
                    'name' = attrs[['regionName']])
