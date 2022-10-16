---
title: Series.seasonDummy
---

# `Series.seasonDummy` ^^(Series)^^

{== Create time series with seasonal dummies ==}


## Syntax

    outputSeries = Series.seasonDummy(range, dummyPeriods, ...)


## Input Arguments

__`range`__ [ Dater ]
> 
> Date range on which the time series will be created.
> 

__`dummyPeriods`__ [ numeric ]
> 
> Numeric periods in which the new `outputSeries` will be assigned the
> value `1` in each year of the `range`; otherwise, the values will `0`;
> the `dummyPeriods` are frequency specific and depend on the date
> frequency of the `range`, e.g. the `dummyPeriods` represent quarters for
> a quarterly `range`, months for a monthly `range`, etc.
> 

Any further input arguments (third, fourth, etc.) will be pased into the
[`Series`](Series.md) constructor as the third, fourth, etc. input arguments (i.e.
the `comments`, `userData`, etc.)


## Output Arguments

__`outputSeries`__ [ Series ]
> 
> New time series with the value `1` in the `dummyPeriods` in each year
> within the `range`, and with `0` otherwise.
> 

## Description


## Examples

```matlab
x = Series.seasonDummy(mm(2020,01):mm(2029,12), 1)
x = Series.seasonDummy(mm(2020,01):mm(2029,12), [1, 7])
```

