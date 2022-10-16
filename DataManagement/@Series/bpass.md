---
title: bpass
---

# `bpass` ^^(Series)^^

{== Band-pass filter ==}


## Syntax 

[X, T] = bpass(X, Band, ~Range, ...)
> 
> Input arguments marked with a `~` sign may be omitted.
> 


## Input arguments 

__`X`__ [ tseries ]
> 
> Input tseries object that will be filtered.
> 

__`Band`__ [ numeric ]
> 
> Band of periodicities to be retained in the output
> data, `Band = [Low, High]`.
> 

__`~Range=Inf`__ [ Dater ]
> 
> Date range on which the data will be
> filtered; if omitted, the entire time series range will be used.
> 

## Output arguments 

__`X`__ [ tseries ]
> 
> Band-pass filtered tseries object.
> 

__`T`__ [ tseries ]
> 
> Estimated trend tseries object.
> 


## Options 

__`AddTrend=true`__ [ `true` | `false` ]
> 
> Add the estimated linear time
> trend back to filtered output series if `band` includes `Inf`.
> 

__`Detrend=true`__ [ `true` | `false` | cell ]
> 
> Remove an estimated time
> trend from the data before filtering; specify options for detrending in
> a cell array; see [`trend`](tseries/trend).
> 

__`Log=false`__ [ `true` | `false` ]
> 
> Logarithmize the data before
> filtering, de-logarithmize afterwards.
> 

__`Method='cf'`__ [ `'cf'` | `'hwfsf'` ]
> 
> Type of band-pass filter:
> Christiano-Fitzgerald, or h-windowed frequency-selective filter.
> 

__`UnitRoot=true`__ [ `true` | `false` ] 
> 
> Assume unit root in the input
> data.
> 

## Description 

Christiano, L.J. and T.J.Fitzgerald (2003). The Band Pass Filter.
International Economic Review, 44(2), 435--465.

Iacobucci, A. & A. Noullez (2005). A Frequency Selective Filter for
Short-Length Time Series. Computational Economics, 25, 75--102.

## Examples

```matlab
```

