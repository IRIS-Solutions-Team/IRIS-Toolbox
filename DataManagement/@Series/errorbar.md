---
title: errorbar
---

# `errorbar` ^^(Series)^^

{== Line plot with error bars ==}


## Syntax 

    [LL, EE, Range] = errorbar(X, W, ...)
    [LL, EE, Range] = errorbar(Range, X, W, ...)
    [LL, EE, Range] = errorbar(AA, Range, X, W, ...)
    [LL, EE, Range] = errorbar(X, Lo, Hi, ...)
    [LL, EE, Range] = errorbar(Range, X, Lo, Hi, ...)
    [LL, EE, Range] = errorbar(AA, Range, X, Lo, Hi, ...)


## Input arguments 

__`AA`__ [ numeric ]
> 
> Handle to axes in which the graph will be plotted; if
> not specified, the current axes will used.
> 

__`Range`__ [ numeric | char ]
> 
> Date range; if not specified the entire
> range of the input tseries object will be plotted.
> 

__`X`__ [ tseries ]
> 
> Tseries object whose data will be plotted as a line
> graph.
> 

__`W`__ [ tseries ]
> 
> Width of the bands that will be plotted around the
> lines.
> 

__`Lo`__ [ tseries ]
> 
> Width of the band below the line.
> 

__`Hi`__ [ tseries ]
> 
> Width of the band above the line.
> 

## Output arguments 

__`LL`__ [ numeric ] 
> 
> Handles to lines plotted.
> 

__`EE`__ [ numeric ]
> 
> Handles to error bars plotted.
> 

__`Range`__ [ numeric ]
> 
> Actually plotted date range.
> 

## Options 

__`'relative='`__ [ *`true`* | `false` ]
> 
> If `true`, the data for the
> lower and upper bounds are relative to the centre, i.e. the bounds will
> be added to the centre (in this case, `Lo` must be negative numbers and
> `Hi` must be positive numbers). If `false`, the bounds are absolute data
> (in this case `Lo` must be lower than `X`, and `Hi` must be higher than
> `X`).
> 

See help on [`tseries/plot`](tseries/plot).


## Description 



## Examples

```matlab
```

