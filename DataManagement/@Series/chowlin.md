---
title: chowlin
---

# `chowlin` ^^(Series)^^

{== Chow-Lin distribution of low-frequency observations over higher-frequency periods ==}


## Syntax 

[Y2, B, RHO, U1, U2] = chowlin(Y1, X2)
[Y2, B, RHO, U1, U2] = chowlin(Y1, X2, Range, ...)


## Input arguments 

__`Y1`__ [ tseries ]
> 
> Low-frequency input time series that will be
> distributed over higher-frequency observations.
> 

__`X2`__ [ tseries ]
> 
> Time series with regressors used to distribute the
> input data.
> 

__`Range`__ [ numeric ] 
> 
> Low-frequency date range on which the
> distribution will be computed.
> 

## Output arguments 

__`Y2`__ [ tseries ]
> 
> Output data distributed with higher frequency.
> 

__`B`__ [ numeric ]
> 
> Vector of regression coefficients.
> 

__`RHO`__ [ numeric ]
> 
> Actually used autocorrelation coefficient in the
> residuals.
> 

__`U1`__ [ tseries ]
> 
> Low-frequency regression residuals.
> 

__`U2`__ [ tseries ]¨
> 
> Higher-frequency regression residuals.
> 

## Options 

__`Constant=true`__ [ `true` | `false` ]
> 
> Include a constant term in the
> regression.
> 

__`Log=false`__ [ `true` | `false` ]
> 
> Logarithmise the data before
> distribution, de-logarithmise afterwards.
> 

__`NGrid=200`__ [ numeric ]
> 
> Number of grid search points for finding
> autocorrelation coefficient for higher-frequency residuals.
> 

__`Rho='Estimate'`__ [ `'Estimate'` | `'Positive'` | `'Negative'` | numeric ]
> 
> How to determine the autocorrelation coefficient for higher-frequency
> residuals.
> 

__`TimeTrend=false`__ [ `true` | `false` ]
> 
> Include a time trend in the
> regression.
> 

## Description 

* Chow, G.C., and A.Lin (1971). Best Linear Unbiased Interpolation, 
Distribution and Extrapolation of Time Series by Related Times Series.
Review of Economics and Statistics, 53, pp. 372-75.

* Robertson, J.C., and E.W.Tallman (1999). Vector Autoregressions:
Forecasting and Reality. FRB Atlanta Economic Review, 1st Quarter 1999, 
pp.4-17.

## Examples

```matlab
```

