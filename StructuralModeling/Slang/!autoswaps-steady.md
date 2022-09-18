---
title: "!autoswaps-steady"
---

# `!autoswaps-steady` ^^(Slang)^^

{== Definitions of variable-parameter pairs to be autoexogenized in steady-state calculations ==}


## Syntax

    !autoswaps-steady
        variableName := parameterName; variableName := parameterName;
        variableName := parameterName;


## Description

The section `!autoswaps-steady` defines pairs of variables and parameters
that can be used to simplify and automate the definition of exogenized
variables and endogenized parameters in steady-state calculations, i.e.
in calling the function [`Model/steady`](../model/steady).

On the left-hand side of the definition must be a valid measurement or
transition variable name. On the right-hand side must be a valid
parameter name.


## Examples

```iris
!transition_variables
    x, y, z

!parameters
    alpha, beta, gamma

!measurement_variables
    x_obs, y_obs, z_obs

!dynamic_autoexog
    x := alpha;
    y_obs := beta;
```

