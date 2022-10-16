---
title: difflog
---

# `difflog` ^^(Series)^^

{== First difference of log ==}


## Syntax 

x = difflog(x, ~shift)
> 
> Input arguments marked with a `~` sign may be omitted
> 

## Input arguments 

__`x`__ [ Series ] 
> 
> Input time series.
> 

__`~shift`__ [ numeric ] 
> 
> Number of periods over which the first difference will be computed;
> `y=log(x)-log(x{shift})`; `shift` is a negative number for the usual
> backward differencing; if omitted, `shift=-1`. 
> 


## Output arguments 

__`x`__ [ Series ]
> 
> First difference of the log of the input time series.
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

