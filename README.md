> Author: Jingcheng Yang
>
> Email: yjcyxky@163.com
>
> Date: 2018-12-13

# Choppy Media Extension

## Summary
Display dynamic plot or more multimedia content in markdown.

Choppy-media-extension is an extension for Python-Markdown. It can launch dynamic plot or preprocess multimedia.

## Dependencies

Choppy requires Python 3+ and Python-Markdown to be loaded in your environment in order for full functionality to work.

## Syntax
```
@boxplot-r(dataFile='boxplot-r.rds', dataType='rds', title='',
           xAxis='DoubleBlind_0to24', xTitle='DoubleBlind_0to24',
           xAngle=90, yAxis='HbA1c_DF24to0', yTitle='HbA1c_DF24to0',
           colorAttr='DoubleBlind_0to24', subtitle='', text='')

Such as @plugin-name(arg1=value, arg2=value)
```

## Installation

```
pip install mk-media-extension
```

## Plugins
1. [boxplot-r: Interactive boxplot visualization from a Shiny app(r version).](http://docs.3steps.cn/docs/plugins/boxplot-r.html)
2. [corrplot-r: Interactive correlation plot visualization from a Shiny app(r version).](http://docs.3steps.cn/docs/plugins/corrplot-r.html)
3. [data-table-js: Another interactive data table. It is based on datatables js library.](http://docs.3steps.cn/docs/plugins/data-table-js.html)
4. [density-plot: Interactive density plot visualization from a Shiny app(r version).](http://docs.3steps.cn/docs/plugins/density-plot.html)
5. [group-boxplot: Interactive group-boxplot visualization from a Shiny app(r version).](http://docs.3steps.cn/docs/plugins/group-boxplot.html)
6. [pivot-table-js: Interactive pivot-table and pivot-chart. It is based on webdatarocks and highcharts.](http://docs.3steps.cn/docs/plugins/pivot-table-js.html)
7. [rocket-plot-r: Interactive rocket plot visualization from a Shiny app(r version).](http://docs.3steps.cn/docs/plugins/rocket-plot-r.html)
8. [stack-barplot-r: Interactive stack barplot visualization from a Shiny app(r version).](http://docs.3steps.cn/docs/plugins/stack-barplot-r.html)
9. [upset-r: Interactive upset plot visualization from a Shiny app(r version).](http://docs.3steps.cn/docs/plugins/upset-r.html)
10. [violin-plot-r: Interactive violin plot visualization from a Shiny app(r version).](http://docs.3steps.cn/docs/plugins/violin-plot-r.html)