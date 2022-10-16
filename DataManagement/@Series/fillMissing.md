---
title: fillMissings
---

# `fillMissings` ^^(Series)^^

{== Fill missing time series observations ==}


## Syntax

    outputSeries = fillMissing(inputSeries, range, method)
    outputSeries = fillMissing(inputSeries, range, method, specs)
    outputSeries = fillMissing(inputSeries, range, anotherSeries)


## Input Arguments

__`inputSeries`__ [ Series ]
> 
> Input time series whose missing entries lying within the `range`
> will be filled with values determined by the `method` or from
> `anotherSeries`.
> 

__`range`__ [ Dater | `Inf` ]
> 
> Date range within which missing entries will be looked up in the
> `inputSeries` and filled with values determined by the `method` or from
> `anotherSeries`.
> 

__`method`__ [ string | Series ]
> 
> String specifying the method to obtain missing observations, or a time
> series with replacement values. 
> 
> The `method` can be any of the methods valid in the built-in
> `fillmissing()` function (see `help fillmissing`) or one of the
> regression methods provided by Iris: `"regressConstant"`,
> `"regressTrend"` or `"regressLogTrend"` for a regression on a constant, a
> regression on a constant and a linear time trend, and a log-regression on
> a constant and a time trend, respectively.
> 

__`specs`__ [ * ]
> 
> Some of the methods in the built-in `fillmissing()` function require
> addition specification (see `help fillmissing`).
> 

__`anotherSeries`__ [ Series ]
> 
> Another time series whose values will be used to fill missing entries in
> the `inputSeries`.
> 

## Output Arguments

__`outputSeries`__ [ Series ]
> 
> Output time series whose missing observations found within the
> `range` have been filled with values given by the `method` or from
> `anotherSeries`.
> 

## Description


## Example

