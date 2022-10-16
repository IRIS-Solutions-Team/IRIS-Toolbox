---
title: expsm
---

# `expsm` ^^(Series)^^

{== Exponential smoothing ==}


## Syntax 

X = expsm(X, Beta, ~Range, ...)
> 
> Input arguments marked with a `~` sign may be omitted.
> 


## Input arguments 

__`X`__ [ tseries ] 
> 
> Input time series.
> 

__`Beta`__ [ numeric ]
> 
> Exponential factor.
> 

## Output arguments 

__`X`__ [ tseries ]
> 
> Exponentially smoothed series.
> 

## Options 

__`Initials=NaN`__ [ numeric ]
> 
> Use this value before the first observation to
> initialize the smoothing.
> 

__`Log=false`__ [ `true` | `false` ]
> 
> Logarithmize the data before
> filtering, de-logarithmize afterwards.
> 

__`Range=Inf`__ [ Dater ] 
> 
> Range on which the exponential smoothing will
> be performed; if omitted, the entire time series range is used.
> 

## Description 



## Examples

```matlab
```

