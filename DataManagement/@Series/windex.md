---
title: windex
---

# `windex` ^^(Series)^^

{== Plain weighted or Divisia index ==}


## Syntax 

    Y = windex(X, Weights, ~Range, ...)


## Input arguments 

__`X`__ [ tseries ] 
> 
> Input times series.
> 

__`Weights`__ [ tseries | numeric ]
> 
> Fixed or time-varying weights on the
> input time series.
> 

__`~Range=Inf`__ [ Dater | `Inf` ] 
> 
> Range on which the weighted index
> is computed.
> 


## Output arguments 

__`Y`__ [ tseries ]
> 
> Weighted index based on `X`.
> 


## Options 

__`Method='plain'`__ [ `'divisia'` | `'plain'` ] 
> 
> Weighting method.
> 

__`Log=false`__ [ `true` | `false` ] 
> 
> Logarithmize the input inputData before
> computing the index, delogarithmize the output inputData.
> 

## Description 



## Examples

```matlab
```

