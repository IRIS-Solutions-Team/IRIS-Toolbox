---
title: swap
---

# `swap` ^^(Plan)^^

{== Exogenize variables and endogenize shocks ==}

## Syntax 

    p = swap(p, datesToSwap, pairToSwap, pairToSwap, ...)


## Input arguments


__`p`__ [ Plan ] 
> 
> Simulation plan to which the new swapped pairs will be added.
> 

__`datesToSwap`__ [ DateWrapper ]
> 
> Dates at which the endogeneity and exogeneity of the variable-shock
> pairs will be swapped.
> 

__`pairToSwap`__ [ string ] 
> 
> String array consisting of the name of a variables (transition or
> measurement) and the name of a shock (transition or measurement)
> whose endogeneity and exogeneity will be swapped in the simulation at
> specified dates, `datesToSwap`. Any number of pairs can be specified
> as input arguments to the `swap(~)` function.
> 

## Output arguments

__`p`__ [ Plan ] 
> 
> Simulation plan with the new swap information included.
> 

## Description 


The simulation plan only specifies the dates and the names of variables
and shocks; it does not include the particular values to which the
variables will be exogenized. These values need to be included in the
input databank entering the [`Model/simulate`](../@Model/simulate.md) 
function.


## Example 


