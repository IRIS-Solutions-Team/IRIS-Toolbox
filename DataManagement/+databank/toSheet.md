---
title: databank.toSheet
---

# `databank.toSheet` ^^(+databank)^^

{== Save databank of time series to a XLSX or CSV file ==}


## Syntax 

    names = databank.toSheet(inputDb, fileName, ___)


## Input arguments 


__`inputDb`__ [ struct | Dictionary ]
> 
> Databank whose time series will be saved to an XLSX or CSV file named
> `fileName`.
> 


__`fileName`__ [ string ]
> 
> File name under which the time series from the `inputDb` will be saved;
> the extension in the `fileName` will determine the format of the file:
>
> * `.xlsx` - an Excel spreadsheet file
> 
> * `.csv`, `.txt`, no extension - a CSV file
> 


## Output arguments 


__`names`__ [ string ]
> 
> List of databank fields actually saved to the output file.
> 


## Options 


__`IncludeComments=true`__ [ `true` | `false` ]
> 
> If `IncludeComments=true`, the time series comments will be included in
> the sheet as a second row in the header (underneath the variable names).
> 


__`NaN="NaN"`__ [ `"NaN"` | `""` ]
> 
> String to represent NaN values 
> 


__`Frequencies`__ [ `@all` | Frequency ]
> 
> List of date frequencies; only time series with date frequencies on this
> list will be saved; `Frequencies=@all` means all date frequencies.
> 


__`Sheet=1`__ [ numeric | string ]
> 
> Only in Excel spreadsheet files: specification of the sheet to read.
> 


__`SourceNames=@all`__ [ `@all` | string ]
> 
> List of time series fields from the `inputDb` that will be saved;
> `SourceNames=@all` means all time series fields.
> 


__`TargetNames=[]`__ [ empty | function | struct ]
> 
> Function or mapping to transform the databank source names to target
> names in the output file; if `TargetNames=[]`, the time series will be
> saved under their databank field names.
> 


__`NumDividers=1`__ [ numeric ]
> 
> Number of empty columns dividing sections with different date
> frequencies.
> 


## Description 

The `databank.toSheet` and its reading counterpart `databank.fromSheet`
handle multiple date frequencies by grouping the time series of the same
frequency, and saving/loading these groups to/from a single sheet.

At the moment, only numeric time series with real values are supported in
`databank.toSheet` and `databank.fromSheet`.


## Examples

```matlab
d = struct();
d.x = Series(yy(2020):yy(2030), 1);
d.y = Series(mm(2020,01):mm(2020,12), rand(12, 4));
databank.toSheet(d, "test.csv");
databank.toSheet(d, "test.xlsx");
```

