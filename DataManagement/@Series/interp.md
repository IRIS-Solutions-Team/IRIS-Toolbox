---
title: Interpolate missing observations
---



{== Interpolate missing observations ==}


## Syntax 

    X = interp(X, Range, ...)


## Input arguments 

__`X`__ [ tseries ]
>
>Input time series.
>

__`Range`__ [ numeric | char ]
>
>Date range within which any missing
>observations (`NaN`) will be interpolated using observations available
>within that range.
>

## Output arguments 

__`X`__ [ tseries ]
>
>Tseries object with the missing observations
>interpolated.
>

## Options 

__`Method='Cubic'`__ [ char | `'Cubic'` ]
>
>Any valid method accepted by the
>built-in `interp1( )` function.
>

## Description 



## Examples

```matlab
```

