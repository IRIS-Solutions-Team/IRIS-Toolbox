---
title: rebase
---

# `rebase` ^^(Series)^^

{== Rebase times series data to specified period ==}


## Syntax

    [outputSeries, priorValue, reciprocal] = rebase(inputSeries, basePeriod, baseValue, ___)


## Input arguments

__`inputSeries`__ [ Series ]
> 
>  Input time series that will be rebased.
> 

__`basePeriod`__ [ Dater | `"allStart"` | `"allEnd"` ] -
> 
> Date relative to which the input data will be rebased;
> `'allStart'` means the first date for which all time series columns have
> a NaN observation; `'allEnd'` means the last such date. The `basePeriod`
> may be a vector of dates, in which case the mean or geometric mean of the
> corresponding values will be calculated.
> 

__`baseValue`__  [ numeric ]
> 
> The new value that the `outputSeries` will see in the `basePeriod`.
> 


## Options

__`Mode="auto"`__ [ `"auto"` | `"additive"` | `"multiplicative"` ]
> 
> Rebasing mode; if `Mode="auto"`, the rebasing mode will be based on the
> `baseValue`: `"additive"` for `baseValue=0`, `"multiplicative"`
> otherwise;
> 

__`Reciprocal=[]`__ [ empty | Series ]
> 
> A reciprocal series that will be rebased so that the sum or the product
> (depending on the `Mode=`) of the `inputSeries` and the `Reciprocal` is
> preserved. The `Reciprocal=` series must be the same size as the
> `inputSeries`.
> 


## Output arguments

__`outputSeries`__ [ Series ]
> 
> Rebased output time series.
> 

__`priorValue`__ [ numeric ]
> 
> The value of the `inputSeries` in `basePeriod` before rebasing.
> 

__`reciprocal`__ [ empty | Series ]
> 
> Rebased reciprocal series.
> 


## Description


## Example


