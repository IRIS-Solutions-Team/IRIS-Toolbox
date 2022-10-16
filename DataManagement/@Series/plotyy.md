---
title: plotyy
---

# `plotyy` ^^(Series)^^

{== Line plot function with LHS and RHS axes for time series ==}


## Syntax 

    [Ax, Lhs, Rhs, Range] = plotyy(X, Y, ...)
    [Ax, Lhs, Rhs, Range] = plotyy(Range, X, Y, ...)
    [Ax, Lhs, Rhs, Range] = plotyy(LhsRange, X, RhsRange, Y, ...)

## Input arguments 

__`Range`__ [ numeric | char ] 
> 
> Date range; if not specified the entire
> range of the input tseries object will be plotted.
> 

__`LhsRange`__ [ numeric | char ]
> 
> LHS plot date range.
> 

__`RhsRange`__ [ numeric | char ] 
> 
> RHS plot date range.
> 

__`X`__ [ Series ]
> 
> Input tseries object whose columns will be plotted
> and labelled on the LHS.
> 

__`Y`__ [ Series ] 
> 
> Input tseries object whose columns will be plotted
> and labelled on the RHS.
> 

## Output arguments 

`Ax` [ Axes ] 
> 
> Handles to the LHS and RHS axes.
> 

`Lhs` [ Axes ] 
> 
> Handles to series plotted on the LHS axis.
> 

`Rhs` [ Line ] 
> 
> Handles to series plotted on the RHS axis.
> 

`Range` [ numeric ]
> 
> Actually plotted date range.
> 

## Options 

__`'Coincide='`__ [ `true` | *`false`* ] 
> 
> Make the LHS and RHS y-axis
> grids coincide.
> 

__`'LhsPlotFunc='`__ [ `@area` | `@bar` | *`@plot`* | `@stem` ]
> 
> Function that will be used to plot the LHS data.
> 

__`'LhsTight='`__ [ `true` | *`false`* ] 
> 
> Make the LHS y-axis tight.
> 

__`'RhsPlotFunc='`__ [ `@area` | `@bar` | *`@plot`* | `@stem` ] 
> 
> Function that will be used to plot the RHS data.
> 

__`'RhsTight='`__ [ `true` | *`false`* ] 
> 
> Make the RHS y-axis tight.
> See help on [`tseries/plot`](tseries/plot) and the built-in function
> `plotyy` for all options available. 
> 

## Description 



## Examples

```matlab
```

