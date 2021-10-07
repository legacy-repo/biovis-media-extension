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

getInt <- function(value) {
    if (!is.null(value)) {
        int <- as.integer(as.vector(as.matrix(value)))
        if (is.na(int)) {
            int <- 0
        }
        return(int)
    } else {
        return(0)
    }
}

data <- rawData

attrs <- list(
    title=getVector(attributes$title),
    subtitle=getVector(attributes$subtitle),
    text=getVector(attributes$text),
    queryURL=getVector(attributes$queryURL),
    showpanel=getBool(getVector(attributes$showpanel)),
    assignmentType=getVector(attributes$assignmentType),
    showEmptyInterSec=getBool(getVector(attributes$showEmptyInterSec)),
    showBarNumbers=getBool(getVector(attributes$showBarNumbers)),
    setSort=getBool(getVector(attributes$setSort)),
    nIntersects=getInt(getVector(attributes$nIntersects)),
    assignmentType=getVector(attributes$nIntersects)
)
