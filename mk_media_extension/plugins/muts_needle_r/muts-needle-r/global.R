library(configr)
library(dplyr)

config <- read.config(file = 'shiny.ini')
dataConfig <- config$data
attributes <- config$attributes

if (dataConfig$dataType == 'rds') {
    rawData <- readRDS(dataConfig$dataFile)
    rawRegionData <- readRDS(dataConfig$regionDataFile)
} else if (dataConfig$dataType == 'csv') {
    rawData <- read.csv(dataConfig$dataFile, header=TRUE)
    rawRegionData <- read.csv(dataConfig$regionDataFile, header=TRUE)
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

data <- rawData
regionData <- rawRegionData

attrs <- list(
    title=getVector(attributes$title),
    subtitle=getVector(attributes$subtitle),
    text=getVector(attributes$text),
    queryURL=getVector(attributes$queryURL),
    showpanel=getBool(getVector(attributes$showpanel))
)

print(attrs)

rawColnames <- c(colnames(data), colnames(regionData))
for (col in c('coord', 'category', 'value', 'regionCoord', 'regionName',
              'geneCol', 'geneName', 'transcriptCol', 'transcriptName')) {
    colname <- getVector(attributes[col])
    if (is.null(colname) || !(colname %in% rawColnames)) {
        if (col == 'coord' || col == 'value') {
            stop("You must specify coord and value in shiny.ini.")
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
