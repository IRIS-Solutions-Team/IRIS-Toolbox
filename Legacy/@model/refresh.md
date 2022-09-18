---
title: refresh
---

# `refresh`

{== Refresh dynamic links ==}


## Syntax


    model = refresh(model)


## Input arguments

__`model`__ [ Model ] 
> 
> Model object whose dynamic links will be refreshed.
> 

## Output arguments

__`model`__ [ Model ] 
> 
> Model object with dynamic links refreshed.
> 

## Description

Dynamic links are defined in `!links` sections of the model source code.
They connect the values of selected parameters or the steady-state values
of selected transition or measurement variables to expressions involving
other parameters and other steady-state values.


## Example

