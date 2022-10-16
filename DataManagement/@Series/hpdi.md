---
title: hpdi
---

# `hpdi` ^^(Series)^^

{== Highest probability density interval ==}


## Syntax 

    Int = hpdi(X, Coverage, ~Dim)


## Input arguments 

__`X`__ [ tseries ] 
> 
> Input time series; HPDIs will be calculated
> separately for each set of data along dimension `Dim`.
> 

__`Coverage`__ [ numeric ]
> 
> Percent coverage of the calculated interval,
> between 0 and 100.
> 

__`~Dim=1`__ [ numeric ]
> 
> Dimension along which the percentiles will be
> calculated.
> 

## Output arguments 

__`Int`__ [ tseries ]
> 
> Output array (if `Dim==1`) or output time series
> (if `Dim>1`) with the lower and upper bounds of the HPDIs.
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

