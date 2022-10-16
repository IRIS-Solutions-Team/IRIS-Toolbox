---
title: vertcat
---

# `vertcat` ^^(Series)^^

{== Vertical concatenation of tseries objects ==}


## Syntax 

    X = [X1; X2; ...; XN]
    X = vertcat(X1, X2, ..., XN)


## Input arguments 

__`X1`__, ..., __`XN`__ [ tseries ]
> 
> Input tseries objects that will be
> vertically concatenated; they all have to have the same size in 2nd and
> higher dimensions.
> 

## Output arguments 

__`X`__ [ tseries ]¨
> 
> Output tseries object created by overlaying `X1` with
> `X2`, and so on, see description below.
> 

## Options 

__`zzz=default`__ [ zzz | ___ ]
> 
> Description
> 


## Description 

Any NaN observations in `X1` are replaced with the observations from
`X2`. This replacement is performed separately for the real and imaginary
parts of the input data, and the real and imaginary parts are combined
back again.

The input tseries objects must be consistent in 2nd and higher
dimensions. The only exception is if some of the tseries objects are
scalar time series (i.e. with one column only) while the rest of them are
not. In that case, the scalar tseries are automatically expanded to match
the size of the multivariate tseries.

## Examples

```matlab
```
