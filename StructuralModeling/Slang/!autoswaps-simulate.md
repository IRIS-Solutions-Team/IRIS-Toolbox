---
title: "!autoswaps-simulate"
---

# `!autoswaps-simulate` ^^(Slang)^^

{== Define variable-shock pairs for autoswap in dynamic simulations ==}


## Syntax

    !autoswaps-simulate
        variableName := shockName; variableName := shockName;
        variableName := shockName;


## Description

The section `!autoswaps-simulate` defines pairs of variables and shocks
that can be used to simplify and automate the specification of dynamic
[simulation plan](../@Plan/index.md) objects by calling the function
[`autoswap`](../@Plan/autoswap.md).

On the left-hand side of the definition must be a valid measurement or
transition variable name. On the right-hand side must be a valid
measurement or transition shock name.


## Example

```iris
!transition-variables
    x, y, z

!transition-shocks
    ex, ey, ez

!measurement-variables
    x_obs, y_obs, z_obs

!autoswaps-simulate
    x := ex;
    y_obs := ey;
```

