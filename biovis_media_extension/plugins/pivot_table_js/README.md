## `pivot-table-js[biovis-report-plugin]`
### Description
Interactive pivot-table and pivot-chart. It is based on webdatarocks and highcharts.

### Example Data
```
        Stage ReadCount  Sample.ID StageGroup
Adapter Only   2178202   A-QI-1-1          1
Adapter Only    706077   A-QI-1-2          1
Adapter Only   1674179   A-QI-1-3          1
Adapter Only    991912   B-QI-1-1          1
Adapter Only    889332   B-QI-1-2          1
Adapter Only    677786   B-QI-1-3          1
Adapter Only    286820 P10-QI-4-1          1
Adapter Only    805699 P10-QI-4-2          1
Adapter Only    766579 P10-QI-4-3          1
Adapter Only    104417 P10-QI-4-4          1
Adapter Only    113903 P10-QI-4-5          1
```

### Usage

```
@pivot-table-js(dataUrl='stack-barplot-example.csv', enableLocal=False)
```

### Arguments

```text
dataUrl: [string] Your own file with JSON or CSV data by specifying the URL/Local Path to your file.
enableLocal: [boolean] If enable to upload local file from users' computer. default is False
```

### Value
An interactive pivot-table and pivot-chart.

### Author(s)
Jingcheng Yang(yjcyxky@163.com)

### Examples

```
# If you have a custom data, you need to reset these arguments at least.
@pivot-table-js(dataUrl='stack-barplot-example.csv')

# If you want to enable user to upload file, you need to use enableLocal argument.
@pivot-table-js(dataUrl='stack-barplot-example.csv', enableLocal=True)
```