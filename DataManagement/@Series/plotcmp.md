---
title: plotcmp
---

# `plotcmp`

{== Comparison graph for two time series. ==}


## Syntax 

    [Ax,Lhs,Rhs] = plotcmp(X,...)
    [Ax,Lhs,Rhs] = plotcmp(Range,X,...)


## Input arguments 

__`Range`__ [ numeric ] 
>
> Date range; if not specified the entire range of
> the input tseries object will be plotted.
>

__`X`__ [ tseries ] 
> 
> Tseries object with two or more columns; the
> difference (between the second and the first column (or any other linear
> combination of its columns specified through the option `'compare='`)
> will be displayed as an RHS area or bar graph.
> 

## Output arguments 

__`Ax`__ [ handle | numeric ] 
> 
> Handles to the LHS and RHS axes.
> 

__`Lhs`__ [ handle | numeric ] 
>
> Handles to the two original lines.
>

__`Rhs`__ [ handle | numeric ] 
> 
> Handles to the area or bar difference
> graph.
> 

## Options 

__`'baseLine='`__ [ *`true`* | `false` ] 
> 
> Draw a baseline in the bar/area
> difference graph.
> 

__`'compare='`__ [ numeric | *`[-1;1]`* ] 
> 
> Linear combination of the
> observations that will be plotted in the RHS graph; `[-1;1]` means a
> difference between the second series and the first series,
> `X{:,2}-X{:,1}`.
> 

__`'cmpColor='`__ [ numeric | *`[1,0.75,0.75]`* ] 
> 
> Color that will be used
> to plot the area or bar difference (comparison) graph.
> 

__`'cmpPlotFunc='`__ [ `@area` | *`@bar`* ] 
> 
> Function that will be used
> to plot the difference (comparision) data on the RHS.
> 

> 
> See help on [`tseries/plotyy`](tseries/plotyy) for other options
> available.
> 

## Description 



## Examples

```matlab
```

