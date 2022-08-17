---
title: bsxfun
---

# `bsxfun`

{== Implement bsxfun for tseries class. ==}


## Syntax 

    Z = bsxfun(Func, X, Y)


## Input arguments 

__`Func`__ [ function_handle ]
>
> Function that will be applied to the input
> series, `FUN(X, Y)`.
>

__`X`__ [ Series | numeric ]
>
> Input time series or numeric array.
>

__`Y`__ [ Series | numeric ]
>
> Input time series or numeric array.
>

## Output arguments 

__`Z`__ [ tseries ]
>
> Result of `Func(X, Y)` with `X` and/or `Y` expanded
> properly in singleton dimensions.
>

## Options 

__`zzz=default`__ [ zzz | ___ ]
> 
> Description
> 


## Description 

See help on built-in `bsxfun` for more help.

## Examples

```matlab
% Create a multivariate time series and subtract mean from its
% individual columns.

    x = Series(1:10, rand(10, 4));
    xx = bsxfun(@minus, x, mean(x));
```

