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

if (!as.vector(attributes$labelAttr) %in% colnames(rawData)) {
    rawData[as.vector(attributes$labelAttr)] <- rownames(rawData)
}

data <- rawData %>% rename(colorAttr=as.vector(attributes$colorAttr),
                           nameAttr=as.vector(attributes$nameAttr),
                           sizeAttr=as.vector(attributes$sizeAttr),
                           xAxis=as.vector(attributes$xAxis),
                           yAxis=as.vector(attributes$yAxis),
                           labelAttr=as.vector(attributes$labelAttr))

attrs <- list(
    title=getVector(attributes$title),
    xTitle=getVector(attributes$xTitle),
    yTitle=getVector(attributes$yTitle),
    colorTitle=getVector(attributes$colorTitle),
    nameTitle=getVector(attributes$nameTitle),
    sizeTitle=getVector(attributes$sizeTitle),
    subtitle=getVector(attributes$subtitle),
    text=getVector(attributes$text)
)

if (as.logical(as.vector(attributes$titleAsLabel))) {
    labels <- list(
        xAxis=getVector(attributes$xTitle),
        yAxis=getVector(attributes$yTitle),
        colorAttr=getVector(attributes$colorTitle),
        nameAttr=getVector(attributes$nameTitle),
        sizeAttr=getVector(attributes$sizeTitle),
        queryURL=getVector(attributes$queryURL)
    )
} else {
    labels <- list(
        colorAttr=as.vector(attributes$colorAttr),
        nameAttr=as.vector(attributes$nameAttr),
        sizeAttr=as.vector(attributes$sizeAttr),
        xAxis=as.vector(attributes$xAxis),
        yAxis=as.vector(attributes$yAxis),
        queryURL=getVector(attributes$queryURL)
    )
}