---
title: databank.toArray
---

# `databank.toArray` ^^(+databank)^^

{== Create numeric array from time series data ==}


## Syntax

    [outputArray, names, dates] = databank.toArray(inputDb, names, dates, columns)


## Input arguments

__`inputDb`__ [ struct | Dictionary ]
> 
> Input databank from which the time series data will be retrieved and
> converted to a numeric array.
> 

__`names`__ [ string | `@all` ]
> 
> List of time series names whose data will be retrieved from the
> `inputDb`; `names=@all` means all time series fields will be included.
> 

__`dates`__ [ Dater | `"unbalanced"` | `"balanced"` ]
> 
> Dates for which the time series data will be retrieved; the date
> frequency of the `dates` must be consistent with the date frequency of
> all time series listed in `names`.
> 
> * `dates=Inf` is the same as `dates="unbalanced"`.
> 
> * `dates="unbalanced"` means the dates will be automatically determined
>   to cover an unbalanced panel of data (the earliest available
>   observation among all time series to the latest).
> 
> * `dates="balanced"` means the dates will automatically determined to
>   cover a balanced panel of data (the earliest data at which data are
>   available for all time series to the latest date at which data are
>   available for all time series).
> 

__`columns=1`__ [ numeric ]
> 
> Column or columns that will be retrieved from the time series data; if
> multiple columns are specified, the data will be flattened in 2nd
> dimension; `columns=1` if omitted.
> 

## Output arguments 

__`outputArray`__ [ numeric ]
> 
> Numeric array created from the time series data from the fields listed in
> `names` and dates specified in `dates`.
> 

__`names`__ [ string ]
> 
> The names of the time series included in the `outputArray`; useful when
> the input argument `names=@all`.
> 

__`dates`__ [ Dater ]
> 
> The dates for which the time series data were retrieved and included in
> the `outputArray`; useful when the input argument `dates=Inf`.
> 

## Description


## Examples


