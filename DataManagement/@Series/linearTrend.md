---
title: Series.linearTrend
---

# `Series.linearTrend` ^^(Series)^^

{== Create time series with linear trend ==}

## Syntax

    x = Series.linearTrend(range)
    x = Series.linearTrend(range, step)
    x = Series.linearTrend(range, step, startValue)


## Input Arguments

__`range`__ [ Dater ]
> 
> Date range on which the trend time series will be created.
> 

__`step=1`__ [ numeric ]
> 
> Difference between two consecutive dates in the trend; if omitted, the
> increment of the trend will be 1.
> 

__`startValue=0`__ [ numeric ]
> 
> Starting value for the trend; if omitted, the trend will startValue at
> zero.
> 


## Output Arguments

__`x`__ [ Series ]
> 
> Output time series with a linear trend.
> 


## Description


## Example

