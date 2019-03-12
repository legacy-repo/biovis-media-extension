## `boxplot-r[choppy-report-plugin]`
### Description
Interactive boxplot visualization from a Shiny app(r version).

### Usage

```
@boxplot-r(dataFile='boxplot-r.rds', dataType='rds', title='',
           xAxis='DoubleBlind_0to24', xTitle='DoubleBlind_0to24',
           xAngle=90, yAxis='HbA1c_DF24to0', yTitle='HbA1c_DF24to0',
           colorAttr='DoubleBlind_0to24', subtitle='', text='')
```

### Arguments

```ini
; input data, may be a file or other data source.
; input data must be tidy data.
dataFile = boxplot-r.rds
; data file format
dataType = rds
; Shiny app title
title =
; The column name from data frame for x axis attribute
xAxis = DoubleBlind_0to24
xTitle = DoubleBlind_0to24
xAngle = 90
; The column name from data frame for y axis attribute
yAxis = HbA1c_DF24to0
yTitle = HbA1c_DF24to0
; The column name from data frame for color attribute
colorAttr = DoubleBlind_0to24
; query url(unsupported in the current version.)
queryURL = https://www.duckduckgo.com/?q=
; subtitle and text for scatter chart
subtitle =
text =
```

### Value
An interactive boxplot.

### Author(s)
Jingcheng Yang(yjcyxky@163.com)

### Examples

```
# If you need to show a default interactive plot by using sample data
@boxplot-r()

# If you have a custom data, you need to reset these arguments at least.
@boxplot-r(dataFile='boxplot-r.rds', dataType='rds', xAxis='DoubleBlind_0to24',
           yAxis='HbA1c_DF24to0')
```