---
title: wmean
---

# `wmean` ^^(Series)^^

{== Weighted average of time series observations. ==}


## Syntax 

    Y = wmean(X,RANGE,BETA)


## Input arguments 

__`X`__ [ tseries ] 
> 
> Input tseries object whose data will be averaged
> column by column.
> 

__`RANGE`__ [ numeric ] 
> 
> Date range on which the weighted average will be
> computed.
> 

__`BETA`__ [ numeric ]
> 
> Discount factor; the last observation gets a weight of
> of 1, the N-minus-1st observation gets a weight of `BETA`, the N-minus-2nd
> gets a weight of `BETA^2`, and so on.
> 

## Output arguments 

__`Y`__ [ numeric ] 
> 
> Array with weighted average of individual columns;
> the sizes of `Y` are identical to those of the input tseries object in
> 2nd and higher dimensions.
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

