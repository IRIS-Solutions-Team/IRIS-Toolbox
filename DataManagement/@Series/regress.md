---
title: regress
---

# `regress` ^^(Series)^^

{== Ordinary or weighted least-square regression ==}


## Syntax

    [res, stdEst, res, stdRes, fit, dates, covEst] = regress(lhs, rhs, ...)


## Input arguments

__`lhs`__ [ Series ]
> 
> Time series of dependent (LHS) variables; can be a multivariate time
> series object for multiple dependent variables (sharing the same
> explanatory variables).
> 

__`rhs`__ [ Series ] 
> 
> Time series of explanatory (RHS) variables; can be a multivariate time
> series object for multiple explanatory variables.
> 

## Output arguments

__`est`__ [ numeric ]
> 
> Vector of estimated regression parameters.
> 

__`stdEst`__ [ numeric ]
> 
> Vector of std errors of the parameter estimates.
> 

__`res`__ [ Series ]
> 
> Time series of the regression residuals.
> 

__`stdRes`__ [ numeric ]
> 
> Estimate of the std deviation of the regression residuals.
> 

__`fit`__ [ Series ]
> 
> Time series of fitted values for the LHS variable(s).
> 

__`Dates`__ [ numeric ]
> 
> The dates of observations actually used in the regression.
> 

__`covEst`__ [ numeric ]
> 
> Covariance matrix of the regression parameter estimates.
> 

## Options

__`Dates=Inf`__ [ Dater | `Inf` ]
> 
> Dates on which the regression will be run; `Dates=Inf` means the entire range
> available will be used.
> 

__`Intercept=false`__ [ `true` | `false` ]
> 
> Include an intercept in the regression; `Intercept=true` means the
> intercept will be placed last in the matrix of explanatory variables.
> 

__`Weights=[]`__ [ Series | empty ]
> 
> Time series of regression weights on the observations in individual
> periods; `Weights=[]` means equal unit weight on all observations.
> 

## Description

This function calls the built-in `lscov` function.


## Example

Generate random explanatory variables `x` and `y` and noise `e`, construct a dependent
variable `a`, and estimate two regressions, one excluding the intercept
(not included in the "true" relationship), the other including the
intercept.

```matlab
x = Series(qq(2020,1), rand(1000,1));
y = Series(qq(2020,1), rand(1000,1));
e = Series(qq(2020,1), 0.1*randn(1000,1));
a = 0.5*x - 0.5*y + e;

[est1, stdEst2] = regress(a, [x, y])
[est2, stdEst2] = regress(a, [x, y], intercept=true)
```

