---
title: grow
---

# `grow` ^^(Series)^^

{== Cumulate level time series from differences or rates of growth ==}


## Syntax

    outputSeries = grow(inputSeries, operator, changeSeries, dates)
    outputSeries = grow(inputSeries, operator, changeSeries, dates, shift)


## Input Arguments

__`inputSeries`__ [ Series ] 

> Input time series including at least the initial condition for the level.


__`operator`__ [ `"diff"` | `"difflog"` | `"roc"` | `"pcr"` ]

> Function expressing the relationship between the resulting `outputSeries`
> and the input `changeSeries`.


__`changeSeries`__ [ Series | numeric ] 

> Time series or numeric scalar specifying the change in the input time
> series (difference, difference of logs, gross rate of change, or percent
> change, see the input argument `operator`).


__`dates`__ [ Dater ] 

> Date range or a vector of dates on which the level series will be
> cumulated.


__`shift=-1`__ [ numeric ]

> Negative number specifying the lag of the base period to which the change
> `operator` function applies.


## Output Arguments

__`outputSeries`__ [ Series ] 

> Output time series constructed from the input time series, `inputSeries`,
> extended by its  differences or growth rates, `growth`.


## Options

__`Direction="forward"`__ [ `"forward"` | `"backward"` ]

> Direction of calculations in time; `Direction="backward"` means that
> the calculations start from the last date in `dates` going backwards
> to the first one, and an inverse operator is applied.


## Description

The function `grow()` calculates new values at `dates` (which may not
constitute a continuous range, and be discrete time periods instead)
using one of the the following formulas (depending on the `operator`):

* $ x_t = x_{t-k} + g_t $

* $ x_t = x_{t-k} \cdot \exp g_t $

* $ x_t = x_{t-k} \cdot g_t $

* $ x_t = x_{t-k} \cdot \left( 1 + \frac{g_t}{100} \right) $

where $ k $ is a time lag specified by the input argument `shift`, and the
values $ g_t $ are given by the second input series `growth`.
Alternatively, the operator applied to $ x_{t-k} $ and $ g_t $ can be any
user-specified function.

Any values contained in the input time series `inputSeries` outside the
`dates` are preserved in the output time series unchanged.


## Example

Extend a quarterly time series `x` using the gross rates of growth calculated
from another time series, `y`:

x = grow(x, "roc", roc(y), qq(2020,1):qq(2030,4));

