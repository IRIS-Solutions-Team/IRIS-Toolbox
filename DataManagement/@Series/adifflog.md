---
title: adifflog
---

# `adifflog` ^^(Series)^^

{== Annnualized first difference of logs ==}


## Syntax 

this = diff(this, ~shift)
> 
> Input arguments marked with a `~` sign may be omitted
> 

## Input arguments 

__`this`__ [ Series ] 
>
> Input time series.
>

__`~shift`__ [ numeric ]
>
> Number of periods over which the first difference of logarithms will
> be computed; `y=this-this{shift}`; `shift` is a negative number for
> the usual backward differencing; if omitted, `shift=-1`.
>

## Output arguments 

__`this`__ [ Series ]
>
>    First difference of logarithms of the input time series.
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

