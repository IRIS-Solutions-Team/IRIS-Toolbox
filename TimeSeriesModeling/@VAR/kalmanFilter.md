---
title: kalmanFilter
---


# `kalmanFilter` ^^(VAR)^^


{== Run Kalman filter on VAR model ==}


## Syntax

    [outputDb, v, info] = kalmanFilter(v, inputDb, range, ...)


## Input arguments


__`v`__ [ VAR ]
> 
> Input VAR model.
> 


__`inputDb`__ [ struct ]
> 
> Input databank from which initial condition will be read.
> 


__`range`__ [ numeric ]
> 
> Filtering range.
> 


## Output arguments


__`outputDb`__ [ struct ]
> 
> Output databank with prediction and/or smoothed data.
> 


__`v`__ [ VAR ]
> 
> Output VAR object.
> 


## Options


__`Cross=1`__ [ numeric | `1` ]
> 
> Multiplier applied to the off-diagonal elements of the covariance matrix
> (cross-covariances); `Cross=` must be between `0` and `1` (inclusive).
> 


__`Deviation=false`__ [ `true` | `false` ]
> 
> Both input and output data are deviations from the unconditional mean.
> 


__`MeanOnly=false`__ [ `true` | `false` ]
> 
> Return a plain databank with mean forecasts only.
> 


__`Omega=[]`__ [ numeric | empty ]
> 
> Modify the covariance matrix of residuals for this run of the filter.
> 


## Description


## Example


