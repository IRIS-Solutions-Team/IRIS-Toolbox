---
title: get
---

# `get` ^^(Series)^^

{== Query tseries object property ==}


## Syntax 

    Ans = get(X, Query)
    [Ans, Ans, ...] = get(X, Query, Query, ...)


## Input arguments 

__`X`__ [ model ]
> 
> Queried time series.
> 

__`Query`__ [ char ]
> 
> Query.
> 

## Output arguments 

__`Ans`__ [ ... ] 
> 
> Answer to the query.
> 

## Options 

__`zzz=default`__ [ zzz | ___ ]
> 
> Description
> 

## Description



## Valid Queries 

* `'End='` Returns [ numeric ] the date of the last observation.
* `'Freq='` Returns [ numeric ] the frequency (periodicity) of the time
series.
* `'NaNEnd='` Returns [ numeric ] the last date at which observations are
available in all columns; for scalar tseries, this query always returns
the same as `'end'`.
* `'NaNRange='` Returns [ numeric ] the date range from `'nanstart'` to
`'nanend'`; for scalar time series, this query always returns the same as
`'range'`.
* `'NaNStart='` Returns [ numeric ] the first date at which observations are
available in all columns; for scalar tseries, this query always returns
the same as `'start'`.
* `'Range='` Returns [ numeric ] the date range from the first observation to the
last observation.
* `'Start='` Returns [ numeric ] the date of the first observation.

## Examples

```matlab
```

