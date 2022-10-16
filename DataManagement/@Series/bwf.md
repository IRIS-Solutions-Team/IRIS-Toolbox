---
title: bwf
---

# `bwf` ^^(Series)^^

{== Conditonal Butterworth filter ==}


## Syntax 

[T, C, CutOff, Lambda] = bwf(X, Order, ~Range, ...)


## Syntax with output arguments swapped

[T, C, CutOff, Lambda] = bwf2(X, Order, ~Range, ...)
> 
> Input arguments marked with a `~` sign may be omitted.
> 

## Input arguments 

__`X`__ [ tseries ]
> 
> Input tseries object that will be filtered.
> 

__`Order`__ [ numeric ] 
> 
> Order of the Butterworth filter; `Order=2`
> reproduces the Hodrick-Prescott filter [`hpf`](tseries/hpf), and
> `Order=1` reproduces the local linear filter [`llf`](tseries/llf).
> 

__`~Range`__ [ numeric | char | *`@all`]
> 
> Date range on which the input
> data will be filtered; `Range` can be `@all`, `Inf`, `[startdata, Inf]`, 
> or `[-Inf, enddate]`; if omitted, `@all` (i.e. the entire available range
> of the input series) is used.
> 

## Output arguments 

__`T`__ [ tseries ] 
> 
> Lower-frequency (trend) component.
> 

__`C`__ [ tseries ]
> 
> Higher-frequency (cyclical) component.
> 

__`CutOff`__ [ numeric ]
> 
> Cut-off periodicity; periodicities above the
> cut-off are attributed to trends, periodicities below the cut-off are
> attributed to gaps.
> 

__`Lambda`__ [ numeric ] 
> 
> Smoothing parameter actually used; this output
> argument is useful when the option `'CutOff='` is used instead of
> `'Lambda='`.
> 

## Options 

__`'CutOff='`__ [ numeric | *empty* ] 
> 
> Cut-off periodicity in periods
> (depending on the time series frequency); this option can be specified
> instead of `'Lambda='`; the smoothing parameter will be then determined
> based on the cut-off periodicity.
> 

__`'CutOffYear='`__ [ numeric | *empty* ] 
> 
> Cut-off periodicity in years;
> this option can be specified instead of `'Lambda='`; the smoothing
> parameter will be then determined based on the cut-off periodicity.
> `'infoSet='` [ `1` | *`2`* ] - Information set assumption used in the
> filter: `1` runs a one-sided filter, `2` runs a two-sided filter.
> 

__`'Lambda='`__ [ numeric | *`@auto`* ]
> 
> Smoothing parameter;
> needs to be specified for tseries objects with indeterminate frequency.
> See Description for default values.
> 

__`'level='`__ [ tseries ] 
> 
> Time series with soft and hard tunes on the
> level of the trend.
> 

__`'change='`__ [ tseries ] 
> 
> Time series with soft and hard tunes on the
> change in the trend.
> 

__`'log='`__ [ `true` | *`false`* ] 
> 
> Logarithmise the data before
> filtering, de-logarithmise afterwards.
> 

## Description 

__Default smoothing parameters__

If the user does not specify the smoothing parameter using the
`'lambda='` option (or reassigns the default `@auto`), a default value is
used. The default value is based on common practice and can be calculated
using the date frequency of the input time series as $\lambda = (10 \cdot
f)^n$, where $f$ is the frequency (yearly=1, half-yearly=2, quarterly=4, 
bi-monthly=6, monthly=12), and $n$ is the order of the filter, determined
by the input parameter `Order`.

## Examples

```matlab
```

