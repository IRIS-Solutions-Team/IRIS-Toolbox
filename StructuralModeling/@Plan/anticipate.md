---
title: anticipate
---

# `anticipate` ^^(Plan)^^


## Syntax

    plan = anticipate(plan, anticipate, names)


## Input arguments

__`plan`__ [ Plan ] 
> 
> Simulation plan.
> 

__`anticipate`__ [ true | false ]
> 
> New anticipation status for the `names` (variables, shocks).
> 

__`names`__ [ string ]
> 
> List of quantities whose anticipation status will be set to
> `anticipate`.
> 

__`name`__ [ string ]
> 
> Name of quantity whose anticipation status will be set to
> `anticipate`.
> 

## Output arguments

__`p`__ [ Plan ]
> 
> Simulation plan with a new anticipation status for the specified
> quantities.
> 


## Description

The anticipation status of each variable and shock is determined as
follows:

1. At the top level, the overall anticipation status is given by the
   `anticipate` option at the time of creating the Plan object (its default value
   is `true`).

2. Each shock and variable can be assigned a different anticipation status
   using this function, `anticipate`.

3. Furthermore, each exogenize/endogenize swap pair can be assigned yet its
   own specific anticipation status.

## Example



