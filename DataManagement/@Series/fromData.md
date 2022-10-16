---
title: Series.fromData
---

# `Series.fromData` ^^(Series)^^

{== Create a new time series from a data array ==}


## Syntax

    x = Series.fromData(dates, values, comments, userData)


## Input arguments


__`dates`__ [ Dater ]
> 
> Dates corresponding to the rows of the `values`; the size of
> `dates` and `values` must be compatible along first dimension.
> 

__`values`__ [ numeric | logical | str | cell ]
> 
> Data array (column vector, matrix, or a higher-dimensional array) for the
> new time series.
> 

__`comments=""`__ [ string ]
> 
> Comment or an array of comments associated with the inidivual columns of
> the data arrays.
> 

__`userData=struct()`__ [ struct ]
> 
> Struct with any kind of user data to be associated with the time series
> obejcStruct with any kind of user data to be associated with the time
> series object.
> 


## Output arguments


__`x`__ [ Series ]
> 
> New time series object.
> 


## Description


## Examples


