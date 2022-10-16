---
title: databank.fromArray
---

# `databank.fromArray` ^^(+databank)^^

{== Create a time series databank from a numeric array ==}


## Syntax

    db = databank.fromArray(array, names, startDate, ___)


## Input arguments

__`array`__ [ numeric ]
> 
> Numeric array with time series data in columns, from which a total
> of N time series will be created (where N is the number of columns in the
> `array`) with the first row dated `startDate`. If the `array` is 3- or
> higher-dimensional, multivariate time series will be created.
> 

__`names`__ [ string ]
> 
> List of time series names; the number of names must match the number of
> columns in the `array`.
> 

__`startDate`__ [ Dater ]
> 
> Date that will be used for the first row of the input `array`; the other
> columns will be dated contiguously from the `startDate`.
> 

## Output arguments

__`db`__ [ struct ]
> 
> Databank with time series newly created from the `array`.
> 


## Options



## Description


## Examples

