---
title: spy
---

# `spy` ^^(Series)^^

{== Visualise time series observations based on a true-false test ==}


## Syntax 

    [axesHandle, hTrue, hFalse] = spy(x, ...)
    [axesHandle, hTrue, hFalse] = spy(range, x, ...)


## Input arguments 

__`x`__ [ Series ] 
> 
> Input time series whose observations that pass or fail
> a test will be plotted as markers.
> 

__`range`__ [ Series ]
> 
> Date range on which the time series observations
> will be visualised; if not specified the entire available range will be
> used.
> 


## Output arguments 

__`axesHandle`__ [ Axes ]
> 
> Handle to the axes created.
> 

__`hTrue`__ [ Line ]
> 
> Handle to the marks plotted for the observations
> that pass the test.
> 

__`hFalse`__ [ Line ]
> 
> Handle to the marks plotted for the observations
> that fail the test.
> 

## Options 

__`Interpreter=@auto`__ [ `@auto` | char | string ] 
> 
> Value assigned to the
> axes property `TickLabelInterpreter` to interpret the strings entered
> throught `Names=`; `@uato` means `TickLabelInterpreter` will not be
> changed.
> 

__`Names={ }`__ [ cellstr ] 
> 
> Names that will be used to annotate
> individual columns of the input time series.
> 

__`ShowTrue=true`__ [ `true` | `false` ]
> 
> Display marks for the
> observations that pass the test.
> 

__`ShowFalse=false`__ [ `true` | `false` ] 
> 
> Display marks for the
> observations that fail the test.
> 

__`Squeeze=false`__ [ `true` | `false` ] 
> 
> Adjust the PlotBoxAspecgtRatio
> property to squeeze the graph.
> 

__`Test=@isfinite`__ [ function_handle ]¨
> 
> Test applied to each
> observations; only the values returning a true will be displayed.
> 

> 
> See help on [`Series/plot`](Series/plot) and the built-in function
> `spy` for all options available.
> 

## Description 



## Examples

```matlab
```

