---
title: arma
---

# `arma` ^^(Series)^^

{== Apply ARMA model to input series ==}


## Syntax 

    Y = arma(X, E, AR, MA, Range)


## Input arguments 

__`X`__ [ tseries ]
> 
> Input time series from which initial condition will
> be constructed.
> 

__`E`__ [ tseries ]¨
> 
> Input time series with innovations; `NaN` values in
> `E` on `Range` will be replaced with `0`.
> 

__`AR`__ [ numeric | empty ]
> 
> Row vector of AR polynominal coefficients;
> if empty, `AR = 1`; see Description.
> 

__`MA`__ [ numeric | empty ]
> 
> Row vector of MA polynominal coefficients;
> if empty, `MA = 1`; see Description.
> 

__`Range`__ [ numeric | char ]
> 
> Range on which the output series
> observations will be constructed.
> 

## Output arguments 

__`X`__ [ tseries ]
> 
> Output time series constructed by running an ARMA
> model on the input series `X` and `E`; the output time series also
> includes p initial conditions where p is the order of the AR polynomial.
> 

## Options 

__`zzz=default`__ [ zzz | ___ ]
> 
> Description
> 


## Description 

The output series is constructed as follows:

$$ A(L) X_t = M(L) E_t $$

where \(A(L) = A_0 + A_1 L + \cdots\) and \(M(L)=M_0 + M_1 L + \cdots\) are
polynomials in lag operator \(L\) defined by the vectors `AR` and `MA`:

$$ X_t = \frac{1}{A_1} \left( -A_2 X_{t-1} - A_3 X_{t-2} - \cdots
+ M_0 E_t + M_1 E_{t-1} + \cdots \right) $$ .

Note that the coefficient \(A_0\) is `AR(1)`, \(A_1\) is `AR(2)`, and so
on.

## Examples

Construct an AR(1) process with autoregression coefficient 0.8, built
from normally distributed innovations:

```matlab
X = Series(0:20, 0);
E = Series(1:20, @randn);
X = arma(X, E, [1, -0.8], [ ], 1:20);
plot(X);
```

