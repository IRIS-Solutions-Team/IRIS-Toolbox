---
title: arf
---

# `arf` ^^(Series)^^

{== Create autoregressive time series from input data ==}


## Syntax 

    x = arf(x, A, Z, range, ...)


## Input arguments 

__`x`__ [ Series ] - 
> 
> Input data from which initial condition will be taken.
> 

__`A`__ [ numeric ] - 
> 
> Vector of coefficients of the autoregressive polynomial.
> 

__`Z`__ [ numeric | Series ] - 
> 
> Exogenous input series or constant in the autoregressive process.
> 

__`range`__ [ Dater | `@all` ] - 
> 
> Date range on which the new time series observations will be computed;
> `range` does not include pre-sample initial condition. `@all` means the
> entire possible range will be used (taking into account the length of
> pre-sample initial condition needed).
> 


## Output Arguments 

__`x`__ [ Series ] 
> 
> Output data with new observations created by running an autoregressive
> process described by `A` and `Z`.
> 

## Description

The autoregressive process has one of the following forms:

    A1*x + A2*x(-1) + ... + An*x(-n) = z, 

or

    A1*x + A2*x(+1) + ... + An*x(+n) = z, 

depending on whether the range is increasing (running forward in time), 
or decreasing (running backward in time). The coefficients `A1`, ...`An`
are gathered in the input vector `A`, 

    A = [A1, A2, ..., An].


## Examples

The following two lines create an autoregressive process constructed from
normally distributed residuals

$$ x_t = \rho x_{t-1} + \epsilon_t $$


```matlab
rho = 0.8;
x = Series(1:20, @randn);
x = arf(x, [1, -rho], x, 2:20);
```


