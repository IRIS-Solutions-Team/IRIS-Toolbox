---
title: databank.fromSheet
---

# `databank.fromSheet` ^^(+databank)^^

{== Load databank of time series from a XLSX or CSV file ==}


## Syntax 

    [outputDb, names] = databank.fromSheet(fileName, ___)


## Input arguments 


__`fileName`__ [ string ]
> 
> File name from which the time series will be loaded into the `outputDb`.
> 


## Output arguments 


__`names`__ [ string ]
> 
> List of databank fields actually saved to the output file.
> 


## Options 


__`AddToDatabank=struct()`__ [ struct ]
> 
> Add the time series from the `fileName` file to this databank.
> 


__`IncludeComments=true`__ [ `true` | `false` ]
> 
> If `IncludeComments=true`, comments are expected to exist in a second
> row of the file header (underneath the variables names), and will be
> read in and assigned to the resulting time series.
> 


__`Frequencies`__ [ `@all` | Frequency ]
> 
> List of date frequencies; only time series with date frequencies on this
> list will be loaded; `Frequencies=@all` means all date frequencies.
> 


__`Sheet=1`__ [ numeric | string ]
> 
> Only in Excel spreadsheet files: specification of the sheet to read.
> 


__`SourceNames=@all`__ [ `@all` | string ]
> 
> List of time series fields from the `inputDb` that will be loaded;
> `SourceNames=@all` means all time series found in the `fileName` file.
> 


__`TargetNames=[]`__ [ empty | function | struct ]
> 
> Function or mapping to transform the source names in the file to target
> field names used in the `outputDb`; if `TargetNames=[]`, the time series will be
> saved under the source names.
> 


## Description 

The `databank.toSheet` and its reading counterpart `databank.toSheet`
handle multiple date frequencies by grouping the time series of the same
frequency, and loading/saving these groups from/to a single sheet.

At the moment, only numeric time series with real values are supported in
`databank.toSheet` and `databank.fromSheet`.


## Examples

```matlab
d = struct();
d.x = Series(yy(2020):yy(2030), 1);
d.y = Series(mm(2020,01):mm(2020,12), rand(12, 4));
databank.toSheet(d, "test.csv");
d1 = databank.fromSheet("test.csv");
databank.fromSheet(d, "test.xlsx");
d2 = databank.fromSheet("test.xlsx");
```

