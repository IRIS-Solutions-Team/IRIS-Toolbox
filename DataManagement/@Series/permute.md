---
title: permute
---

# `permute` ^^(Series)^^

{== Permute dimensions of a tseries object. ==}


## Syntax 

    X = permute(X,Order)


## Input arguments 

__`X`__ [ tseries ] 
>
> Tseries object whose dimensions, except the first
> (time) dimension, will be rearranged in the order specified by the vector
> `order`.
>

__`Order`__ [ numeric ] 
>
> New order of dimensions; because the time
> dimension cannot be permuted, `order(1)` must be always `1`.
>

## Output arguments 

__`X`__ [ tseries ] Output tseries object with its dimensions permuted.
> 
> Output tseries object with its dimensions permuted.
> 


## Options 

__`zzz=default`__ [ zzz | ___ ]
> 
> Description
> 


## Description 

See help on the standard Matlab function `permute`.

## Examples

```matlab
```

