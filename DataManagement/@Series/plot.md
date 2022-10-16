---
title: plot
---

# `plot` ^^(Series)^^

{== Line chart for time series objects ==}


## Syntax 

    [h, range] = plot(inputSeries, ___)


## Input arguments

__`inputSeries`__ [ Series ] 
> 
> Input time series whose columns will be plotted as line graphs.
> 

## Output arguments

__`plotHandles`__ [ handle ] 
> 
> Handles to the lines plotted.
> 

__`range`__ [ Dater ] 
> 
> Date range actually plotted.
> 

## Options

__`AxesHandle=@gca`__ [ handle | function_handle ]
> 
> Axes handle to which the chart will be plotted; if the `AxesHandle` is a
> function, the function will be evaluated to obtain the proper axes
> handle.
> 

__`MultiFrequency=false`__ [ `true` | `false` ]
> 
> When `MultiFrequency=true`, the values are positioned not at the
> beginning of their time periods but in the middle; this improves the
> visuzalization of charts with multiple date frequencies (at the cost of
> the date ticks seemingly visually not aligned).
> 

__`DateTick=Inf`__ [ Dater | `Inf` ] 
> 
> Vector of dates locating tick marks on the X-axis; Inf means they will be
> created automatically.
> 

__`Range=Inf`__ [ Dater | `Inf` ]
> 
> Date range or vector of dates for which the chart will be created;
> `Range=Inf` means the date range will be create to contain all available
> observations in the `inputSeries`.
> 

__`Smooth=false`__ [ `true` | `false` ]
> 
> Use spline interpolation to make the plotted series smooth.
> 

__`Tight=false`__ [ `true` | `false` ] 
> 
> Make the y-axis tight.
> 

__`DateFormat=@config`__ [ char |  string | `@config` ] 
> 
> Date format string, or array of format strings (possibly different for
> each date); `@config` means the date format from the current IRIS
> configuration will be used.
> 

## Description


## Example 

```matlab
```

