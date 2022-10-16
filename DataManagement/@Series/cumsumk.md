---
title: cumsumk
---

# `cumsumk` ^^(Series)^^

{== Cumulative sum with a k-period leap ==}


## Syntax 

    Y = cumsumk(X, Range, ...)


## Input arguments 

__`X`__ [ tseries ]
> 
> Input time series.
> 

__`Range`__ [ Dater | Inf ] 
> 
> Range on which the cumulative sum
> will be computed and the output time series returned, not including the
> presample or postsample needed.
> 


## Output arguments 

__`X`__ [ tseries ] 
> 
> Output time series constructed as described below;
> the time series is returned for the `Range`, without the presample or
> postsample data used for initial or terminal condition.
> 

## Options 

__`K=@auto`__ [ numeric | `@auto` ] 
> 
> Number of periods that will be leapt
> the cumulative sum will be taken; `@auto` means `K` is chosen to match
> the frequency of the input series (e.g. `K=-4` for quarterly data), or
> `K=-1` for integer
> frequency.
> 

__`Log=false`__ [ `true` | `false` ] 
> 
> Logarithmize the input data before, 
> and de-logarithmize the output data back afterwards.
> 

__`Rho=1`__ [ numeric ] 
>
>Autoregressive coefficient.
>


## Description 

If `K<0`, the first `K` observations in the output series are copied from
the input series, and the new observations are given recursively by
    Y{t} = Rho*Y{t-K} + X{t}.

If `K>0`, the last `K` observations in the output series are copied from
the input series, and the new observations are given recursively by
    Y{t} = Rho*Y{t+K} + X{t}, 
going backwards in time.

If `K == 0`, the input data are returned.

## Examples

Construct random data with seasonal pattern, and run X12 to seasonally
adjust these series.

```matlab
x = tseries(qq(1990, 1):qq(2020, 4), @randn);
x1 = cumsumk(x, -4, 1);
x2 = cumsumk(x, -4, 0.7);
x1sa = x12(x1);
x2sa = x12(x2);
```

The new series `x1` will be a unit-root process while `x2` will be
stationary. Note that the command on the second line could be replaced
with `x1 = cumsumk(x)`.

