## `tabulator[biovis-report-plugin]`
### Description
Interactive table. It is based on js library tabulator.

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
@tabulator(dataUrl='stack-barplot-example.csv')
```

### Arguments

```text
dataUrl: [string] Your own file with CSV data by specifying the URL/Local Path to your file.
```

### Value
An interactive table.

### Author(s)
Jingcheng Yang(yjcyxky@163.com)

### Examples

```
# If you have a custom data, you need to reset these arguments at least.
@tabulator(dataUrl='stack-barplot-example.csv')
```