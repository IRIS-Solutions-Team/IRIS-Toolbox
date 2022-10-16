---
title: chainlink
---

# `chainlink` ^^(Series)^^

{== Calculate chain linked aggregate level series from level components and weights ==}


## Syntax

    [aggregateLevel, aggregateRate, info] = chainlink(levels, weights, ...)


## Input arguments

__`levels`__ [ Series ]
> 
> Time series with level data of components that will be chain link
> aggregated.
> 

__`weights`__ [ Series ]
> 
> Time series with weights of the input components `levels`.
> 


## Output arguments

__`aggregateLevel`__ [ Series ]
> 
> Aggregate level series calculated by chain linking the `levels`
> components with `weights`.
> 

__`aggregateRate`__ [ Series ]
> 
> Aggregate rates of change relative with the end period of previous year
> set as the base period.
> 

__`info`__ [ struct ]
> 
> Output information struct with the following fields:
> 
> * `.Rates` - rates of change in the individual components with the end
>   period of previous year set as the base period;
> 
> * `.Weights` - component weights; may potentially differ from the input
> `weights` because of normalization; see the option `NormalizeWeights=`.
> 


## Options

__`Range=Inf`__ [ `Inf` | Dater ]
> 
> Date range on which the aggregation will be calculated; `Inf` means the
> entire range available in `levels` and `weights`.
> 

__`RebaseDates=[]`__ [ empty | Dates ]
> 
> Dates of observations whose average will be used to rebase the resulting
> level aggregate; empty dates means to rebasing is performed.
> 

__`NormalizeWeights=true`__ [ `true` | `false` ]
> 
> Normalize the input `weights` so that they sum up to 1 in each period.
> 

## Description


## Examples


