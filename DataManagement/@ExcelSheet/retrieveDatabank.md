---
title: retrieveDatabank
---

# `retrieveDatabank`

{== Retrieve batch of time series from ExcelSheet into databank ==}


## Syntax 

    outputDb = retrieveDatabank(excelSheet, excelRange, ...)


## Input arguments 

__`excelSheet`__ [ ExcelSheet ] 
> 
> ExcelSheet object from which the time series will be retrieved and
> returned in an `outputDb`; `excelSheet` needs to have its
> `NamesLocation` property assigned.
> 

__`excelRange`__ [ string | numeric ] 
> 
> Excel row range (if the ExcelSheet object has Row orientation) or
> column range (column orientation) from which the time series will be
> retrieved.
> 


## Output arguments 

__`outputDb`__ [ | ] 
> 
> Output databank with the requsted time series.
> 

## Options 

__`AddToDatabank=[ ]`__ [ empty | struct | Dictionary ] 
> 
> Add the requested time series to an existing databank; the type (Matlab
> class) of this databank needs to be consistent with option `OutputType=`.
> 

__`OutputType='struct'`__ [ `'struct'` | `'Dictionary'` ] 
> 
> Type (Matlab class) of the output databank.
> 

## Description 



## Examples

```matlab
```

