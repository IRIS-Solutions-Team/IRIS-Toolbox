---
title: barcon
---

# `barcon`

{== Contribution bar graph for time series (Series) objects ==}


## Syntax 

[H, Range] = barcon(~Ax, ~Range, X, ...)
>
> Input arguments marked with a `~` sign may be omitted.
>


## Input arguments 

__`~Ax`__ [ handle | numeric ] 
>
>Handle to axes in which the graph will be
>plotted; if omitted the chart will be plotted in the current axes.
>

__`~Range`__ [ numeric | char ]
> Date range; if omitted the chart will be
> plotted for the entire time series range.
>

__`X`__ [ Series ] 
> Input time series whose columns will be plotted as
> a contribution bar graph.
>

## Output arguments 

__`H`__ [ handle | numeric ]
>
> Handles to the bar objects plotted.
>

__`Range`__ [ numeric ]
>
> Actually plotted date range.
>

## Options 

__`DateFormat=@config`__ [ char | `@config` ]
>
> Date format string;
> `@config` means the `PlotDateTimeFormat` setting from the current IRIS
> configuration will be used.
>

__`ColorMap=lines( )`__ [ numeric ]
>
> Color map to fill the contribution bars.
>

__`EvenlySpread=false`__ [ `true` | `false` ]
>
> Colors of the contribution
> bars are evenly spread across the color map.
>

>
> See help on [`Series/plot`](Series/plot) and the built-in function
> `bar` for other options available.
>

## Description 



## Examples

```matlab
```

