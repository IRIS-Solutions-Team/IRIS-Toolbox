---
title: adiff
---

# `adiff`

{== Annnualized first difference ==}


## Syntax 

this = diff(this, ~shift)
>
> Input arguments marked with a `~` sign may be omitted
>

## Input arguments 

__`this`__ [ TimeSubscriptable ]
> 
> Input time series.
> 

__`~shift`__ [ numeric ]
> 
> Number of periods over which the first difference
> will be computed; `y=this-this{shift}`; `shift` is a negative number
> for the usual backward differencing; if omitted, `shift=-1`.
> 

## Output arguments 

__`this`__ [ TimeSubscriptable ]
> 
> First difference of the input time series.
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

