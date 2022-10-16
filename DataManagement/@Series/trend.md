---
title: trend
---

# `trend` ^^(Series)^^

{== Estimate time trend in time series data. ==}


## Syntax 

x = trend(x, ~range, ...)
> 
> Input arguments marked with a `~` sign may be omitted.
> 

## Input arguments 

__`x`__ [ tseries ] 
> 
> Input time series.
> 

__`~range`__ [ numeric | `@all` | char ] 
> 
> Range for which the trend will be
> computed; if omitted or assigned `@all`, the entire range of the input times series.
> 

## Output arguments 

__`x`__ [ tseries ] 
> 
> Output trend time series.
> 


## Options 

__`'Break='`__ [ numeric | *empty* ] 
> 
> Vector of breaking points at which
> the trend may change its slope.
> 

__`'Connect='`__ [ *`true`* | `false` ]
> 
> Calculate the trend by connecting
> the first and the last observations.
> 

__`'Diff='`__ [ `true` | *`false`* ] 
> 
> Estimate the trend on differenced data.
> 

__`'Log='`__ [ `true` | *`false`* ] 
> 
> Logarithmize the input data, 
> de-logarithmize the output data.
> 

__`'Season='`__ [ `true` | *`false`* | `2` | `4` | `6` | `12` ] 
> 
> Include deterministic seasonal factors in the trend.
> 

## Description 



## Examples

```matlab
```

