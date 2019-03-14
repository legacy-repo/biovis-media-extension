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
attrs <- list(
    title=getVector(attributes$title),
    xTitle=getVector(attributes$xTitle),
    yTitle=getVector(attributes$yTitle),
    subtitle=getVector(attributes$subtitle),
    text=getVector(attributes$text),
    queryURL=getVector(attributes$queryURL)
)

dataColnames <- colnames(data)

attrs$title <- if(is.null(attrs$title)) ' ' else attrs$title

attrs$xAngle <- as.integer(getVector(attributes$xAngle))

attrs$corrVars <- trim(unlist(strsplit(getVector(attributes$corrVars), ',')))
for (var in attrs$corrVars) {
    if (!var %in% dataColnames) {
        sprintf('%s is not in columns', var)
        attrs$corrVars <- NULL
    }
}

attrs$showDiag <- getBool(getVector(attributes$showDiag))
attrs$corrMethod <- getVector(attributes$corrMethod)
if (!attrs$corrMethod %in% c('square', 'circle')) {
    attrs$corrMethod <- 'square'
}

attrs$corrType <- getVector(attributes$corrType)
if (!attrs$corrType %in% c('full', 'lower', 'upper')) {
    attrs$corrType <- 'full'
}

attrs$hcOrder <- getBool(getVector(attributes$hcOrder))

attrs$hcMethod <- getVector(attributes$hcMethod)
if (!attrs$hcMethod %in% c('ward.D', 'ward.D2', 'single', 'complete', 'average', 'mcquitty', 'median', 'centroid')) {
    attrs$corrType <- 'complete'
}

attrs$showLab <- getBool(getVector(attributes$showLab))
