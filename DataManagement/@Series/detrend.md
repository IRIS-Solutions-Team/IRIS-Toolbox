---
title: detrend
---

# `detrend` ^^(Series)^^

{== Remove linear time trend from time series data ==}


## Syntax 

x = detrend(x, ~range,...)
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
> The date range on which the
> trend will be computed; if omitted or assigned `@all`, the entire range
> available will be used.
> 

## Output arguments 

__`x`__ [ tseries ]
> 
> Output time series with a trend removed.
>  


## Options 

> 
> See [`tseries/trend`](tseries/trend) for options available.
> 


## Description 



## Examples

```matlab
```

