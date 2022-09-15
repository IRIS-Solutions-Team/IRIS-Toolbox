---
title: reset
---

# `reset` ^^(Model)^^

{== Reset specific values within model object ==}


## Syntax

    model = reset(model)
    model = reset(model, request)


## Input Arguments

__`model`__ [ Model ] 
> 
> Model object in which the requested type(s) of values
> will be reset.
> 

__`request`__ [ `"corr"` | `"plainparameters"` | `"parameters"` | `"steady"` | `"std"` | `"stdcorr"` ] 
> 
> Type(s) of values that will be reset; if omitted, everything
> will be reset.
> 

## Output Arguments

__`model`__ [ Model ] 
> 
> Model object with the requested values reset.
> 

## Description

* `"corr"` - Reset all cross-correlation coefficients to `0`.

* `"plainParameters"` - Reset all plain parameters (not including `std_` or `corr_`) to `NaN`.

* `"parameters"` - Reset all parameters to `NaN`.

* `"steady"` - Reset all steady state values to `NaN`.

* `"std"` - Reset all std deviations (`std_`) to `1` (in linear models) or `log(1.01)` (in non-linear models).

* `"stdCorr"` - Equivalent to `"Std"` and `"Corr"`.


## Examples


