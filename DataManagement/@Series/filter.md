---
title: filter
---

# `filter` ^^(Series)^^

{== Apply rational transfer function (ARMA filter) to time series ==}


## Syntax 

    outputSeries = filter(inputSeries, model, range, ...)


## Input arguments 

__`inputSeries`__ [ Series ]
> 
> Input time series whose observations will be filtered through a
> rational transfer function defined by the Armani `model`.
> 

__`model`__ [ Armani ]
> 
> Rational transfer function, or linear ARMA filter, defined as an
> Armani object that will be used to filter the observations of the
> `inputSeries`.
> 

## Output arguments 

__`outputSeries`__ [ Series ]
> 
> Output time series created by applying a rational transfer function
> defined by the `model` to the observations of the `inputSeries` on
> the `range`.
> 

## Options 

__`FillMissing=0`__ [ empty | numeric | string | cell ]
> 
> Method that will be used to fill missing observations; the method
> will be passed as an input argument into the standard `fillmissing()`
> function; a cell array will be unfolded as a comma separated list; a
> numeric scalar `x` is equivalent to `{"constant", x}`; an empty
> option means no filling.
> 

## Description 



## Examples

```matlab
```

