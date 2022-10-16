---
title: rmse
---

# `rmse` ^^(Series)^^

{== Calculate RMSE for given observations and predictions ==}


## Syntax


    [rmse, error] = rmse(inputSeries, prediction, ...)


## Input arguments


__`actual`__ [ Series ] 
> 
> Input time series with actual observations.
> 

__`prediction`__ [ Series ]
> 
> Input time series with predictions, possibly including multiple
> prediction horizons in individual columns; this is typically the
> outcome of running a Kalman filter with the option `Ahead=`.
> 

## Options

__`Range=Inf`__ [ Dater | `Inf` ]
> 
> Date range on which the prediction errors will be calculated; `Inf`
> means all observations available will be included in the
> calculations.
> 

## Output arguments

__`rootMSE`__ [ numeric ]
> 
> Numeric array with root mean squared errors for each column of the
> `prediction` time series.
> 

__`error`__ [ Series ] -
> 
> Time series with prediction errors from which the RMSEs are
> calculated; `error` is simply the difference between `actual` and the
> individual columns in `prediction`.
> 

## Description


## Example


