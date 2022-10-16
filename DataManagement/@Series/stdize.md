---
title: stdize
---

# `stdize` ^^(Series)^^

{== Standardize tseries data by subtracting mean and dividing by std deviation ==}


## Syntax 

[x, meanX, stdX] = stdize(x, ~normalize)
> 
> Input arguments marked with a `~` sign may be omitted
> 

## Input arguments 

__`x`__ [ TimeSubscriptable ]
> 
> Input time series whose data will be normalized.
> 

__`~normalize`__ [ `0` | `1` ]
> 
> Setting `normalize=0` normalizes the std deviation by N-1, `normalize=1`
> normalizes by N, where N is the sample length.
> 

## Output arguments 

__`x`__ [ TimeSubscriptable ]
> 
> Output time series with standardized data.
> 

__`meanX`__ [ numeric ]
> 
> Estimated mean subtracted from the input time series observations.
> 

__`stdX`__ [ numeric ]
> 
> Estimated std deviation by which the input time series observations have
> been divided.
> 

## Options 

__`zzz=default`__ [ zzz | ___ ]
> 
> Description
> 


## Description 



## Examples

```matlab
```

