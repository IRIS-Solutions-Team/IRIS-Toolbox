---
title: lasso
---

# `lasso` ^^(Series)^^

{== Least absolute shrinkage and selection operator ==}


## Syntax 

[B, BStd, Residuals, EStd, Fitted, Range, BCov] = lasso(Y, X, ~Range, ...)
> 
> Input arguments marked with a `~` sign may be omitted.
> 

## Input arguments 

__`Y`__ [ TimeSubscriptable ]
> 
> Time series of left-hand-side (dependent)
> observations.
> 

__`X`__ [ TimeSubscriptable ]
> 
> Time series of right-hand-side
> (independent) observations. 
> 

__`~Range`__ [ numeric ]
> 
> Date range on which the lasso will be run;
> if omitted, the entire range available will be used.
> 

## Output arguments 

__`B`__ [ numeric ]
> 
> Vector of estimated lasso coefficients.
> 

__`BStd`__ [ numeric ]
> 
> Vector of std errors of the estimates.
> 

__`Residuals`__ [ TimeSubscriptable ]
> 
> Time series with the lasso residuals.
> 

__`EStd`__ [ numeric ]
> 
> Estimate of the std deviation of the lasso
> residuals.
> 

__`Fitted`__ [ TimeSubscriptable ] 
> 
> Time series with fitted LHS
> observations.
> 

__`Range`__ [ numeric ]
> 
> The actually used date range.
> 

__`bBCov`__ [ numeric ]
> 
> Covariance matrix of the coefficient estimates.
> 

## Options 

__`Intercept=false`__ [ `true` | `false` ]
> 
> Include an intercept in the
> lasso; if `true` the constant will be placed last in the matrix of
> lassoors.
> 

__`Weighting=[ ]`__ [ TimeSubscriptable | numeric | empty ] 
> 
> Time series with weights on
> observations in individual periods, or a discount factor for weighting
> the observations from the most recent to the most distant.
> 

## Description 

This function calls the built-in `lscov` function.

## Examples

```matlab
```

