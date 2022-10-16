---
title: plotpred
---

# `plotpred` ^^(Series)^^

{== Visualize multi-step-ahead prediction ==}


## Syntax 

[Hx, Hy, Hm] = plotpred(~Range, X, Y, ...)


## Input arguments 

__`X`__ [ tseries ] 
> 
> Input data with time series observations.
> 

__`Y`__ [ tseries ] 
> 
> Prediction data arranged as described below; the
> prediction data returned from a Kalman filter can be used, see Example
> below.
> 

__`Range=Inf`__ [ numeric | Inf ] 
> 
> Date range on which the input data will be
> plotted.
> 

## Output arguments 

__`Hx`__ [ numeric ]
> 
> Handles to a line object showing the time series
> observations (the first column, `X`, in the input data).
> 

__`Hy`__ [ numeric ]
> 
> Handles to line objects showing the Kalman filter
> predictions (the second and further columns, `Y`, in the input data).
> 

__`Hm`__ [ numeric ] 
> 
> Handles to one-point line objects displaying a
> marker at the start of each line.
> 


## Options 

__`Connect=true`__ [ `true` | `false` ] 
> 
> Connect the prediction lines, 
> `Y`,  with the corresponding observation in `X`.
> 

__`FirstMarker='None'`__ [ `'None'` | char ] 
> 
> Type of marker displayed at
> the start of each prediction line.
> 

__`HandleVisibility={'on', 'on', 'on'}`__ [ cellstr ]
> 
> Visibility of
> handles to the lines created; the first element sets the visibility for
> the first line `Hx`, the second element sets the visibility for for the
> prediction lines `Hy` and the third element sets the visibility of the
> starting point markers, `Hm`.
> 

__`ShowNaNLines=true`__ [ `true` | `false` ] 
> 
> Show or remove lines with
> whose starting points are `NaN` (missing observations).
> 

> 
> See help on [`plot`](tseries/plot) and on the built-in function
> `plot` for options available.
> 

## Description 

The input data `Y` need to be a multicolumn time series (tseries object), 
with one-step-ahead predictions `x(t|t-1)` in the first column, 
two-step-ahead predictions `x(t|t-2)` in the second column, and so on.
Note the timing assumptions.

If `x1` is a series with one-step-ahead predictions `x(t+1|t)`, `x2` is a
series with two-step-ahead predictions `x(t+2|t)`, and so on, while `x`
is a series with the actual observations `x(t)`, the following command
will create a time series that can be then passed into `plotpred( )`:

    p = [ x1{-1}, x2{-2}, ..., xn{-n} ];
    plotpred(x, p);

## Examples

The `plotpred( )` function can be used with prediction-step data returned
from a Kalman filter, [`filter`](model/filter). The prediction-step data
need to be specifically requested using the `'output='` option (as they
are not included in the output database by default), with the prediction
horizon assigned in the `'ahead='` option (the horizon is `1` by
default):

```matlab
[~, g] = filter(m, d, startDate:endDate, ...
    'output=', 'pred', 'meanOnly=', true, 'ahead=', 8); 
figure( );
plotpred(startdate:enddate, d.x, g.pred.x); 
```

