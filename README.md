> Author: Jingcheng Yang
>
> Email: yjcyxky@163.com
>
> Date: 2018-12-13

# Biovis Media Extension

## Summary
Display dynamic plot or more multimedia content in markdown.

Biovis-media-extension is an extension for Python-Markdown. It can launch dynamic plot or preprocess multimedia.

## Dependencies

Biovis requires Python 3+ and Python-Markdown to be loaded in your environment in order for full functionality to work.

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
pip install biovis-media-extension
```
