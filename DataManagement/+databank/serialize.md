---
title: databank.serialize
---

# `databank.serialize` ^^(+databank)^^

{== Serialize databank entries to character vector ==}


## Syntax 

    [c, listSerialized] = databank.serialized(inputDb, dates, ...)


## Input arguments 

__`inputDb`__ [ struct | Dictionary | containers.Map ]
> 
> Input databank whose time series and numeric entries will be serialized
> to a character vector.
> 

__`inputDb`__ [ struct | Dictionary | containers.Map ]
> 
> Dates at which time series entries will be serialized; `Inf` means the
> all encompassing range determined from all time series entries.
> 

## Output arguments 

__`c`__ [ char ]
> 
> Character vector serializing the `inputDb`.
> 


## Options 

__`zzz=default`__ [ zzz | ___ ]
> 
> Description
> 


## Description 



## Examples

```matlab
```

