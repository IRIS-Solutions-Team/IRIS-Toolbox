---
title: autoswap
---

# `autoswap` ^^(Plan)^^

{== Exogenize variables and endogenize shocks from autoswap pairs ==}


## Syntax

    p = autoswap(p, dates, names, ___)

## Input arguments

__`p`__ [ Plan ]
> 
> Simulation plan in which the endogeneity/exogeneity of some variables and
> some shocks (given gy `names`) will be swapped for running an inverted
> simulation.
>

__`dates`__ [ Dater ]
> 
> Date range or a vector of dates at which the autoswaps will take place.
> 


__`names`__ [ string ]
> 
> List of variable names or shocks names from the model source definitions
> of [autoswap pairs](../Slang/!autoswaps-simulate.md); the autoswap can be
> activated by including either the variable name or the shock name (makes
> no difference) in the list of `names`.
> 


## Options

__`anticipate=@auto`__ [ `@auto` | `true` | `false` ]
> 
> Anticipation status of the autoswap pair; if `anticipate=@auto`, the
> status will be derived from the current [anticipation status of the shock
> set in the simulation plan](../@Plan/anticipate);
> the anticipation status of the variable must, in that case, match that of
> the shock.
> 

## Output arguments


## Description


## Examples

Given a model based on the following source code

```iris
!transition-variables
    x, y, z

!transition-shocks
    shk_x, shk_y, shk_z

!transition-equations
    x = ... + shk_x;
    y = ... + shk_y;
    z = ... + shk_z;

!autoswaps-simulate
    x := shk_x;
    y := shk_y;
```

the following commands are all equivalent in a simulation plan created for
that model, see also the [`swap`](swap.md) function:

```matlab
p = autoswap(p, dates, ["x", "y"]);
p = autoswap(p, dates, ["shk_x", "shk_y"]);
p = autoswap(p, dates, ["x", "shk_y"]);
p = autoswap(p, dates, ["shk_x", "y"]);
p = swap(p, dates, ["x", "shk_x"], ["y", "shk_y"]);
```

