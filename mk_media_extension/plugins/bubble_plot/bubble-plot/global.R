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
    return(as.vector(as.matrix(value)))
}

if (!as.vector(attributes$sizeAttr) %in% colnames(rawData)) {
    rawData[as.vector(attributes$sizeAttr)] <- rep.int(1, length(rownames(rawData)))
}

getDefault <- function(value, default, type='integer') {
    if (value == '' || is.null(value)) {
        return(default)
    } else {
        if (type == 'integer') {
            return(as.integer(value))
        } else {
            return(value)
        }
    }
}

data <- rawData %>% rename(colorAttr=as.vector(attributes$colorAttr),
                           nameAttr=as.vector(attributes$nameAttr),
                           sizeAttr=as.vector(attributes$sizeAttr),
                           xAxis=as.vector(attributes$xAxis),
                           yAxis=as.vector(attributes$yAxis),
                           sliderAttr=as.vector(attributes$sliderAttr))

attrs <- list(
    title=getVector(attributes$title),
    xTitle=getVector(attributes$xTitle),
    yTitle=getVector(attributes$yTitle),
    sliderTitle=getVector(attributes$sliderTitle),
    sliderId=tolower(getVector(attributes$sliderAttr)),
    sliderStep=getDefault(getVector(attributes$sliderStep), NULL)
)