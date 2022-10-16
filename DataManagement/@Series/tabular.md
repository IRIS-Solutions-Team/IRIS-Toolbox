---
title: tabular
---

# `tabular` ^^(Series)^^

{== Display time series in tabular view ==}


## Syntax 

    tabular(x)


## Input arguments 

__`x`__ [ Series ]
> 
> Time series that will be displayed in tabular view.
> 

## Output arguments 

__`yyy`__ [ yyy | ___ ]
> 
> Description
> 


## Options 

__`zzz=default`__ [ zzz | ___ ]
> 
> Description
> 


## Description 

The function `tabular(~)` displays time series depending on their date
frequency the following way:

* `HALFYEARLY`, `QUARTERLY`, `MONTHLY`, and `WEEKLY` time series will be
displayed with each calendar year on a row;

* `DAILY` time series will be displayed with each calendar month on a row;

* `YEARLY` and `INTEGER` time series will be displayed the usual way.

## Examples

Create a quarterly tseries, and use `tabular` to display it one calendar
year per row.

```matlab
    x = Series(qq(2000, 3):qq(2002, 2), @rand)
    x =
        Series object: 8-by-1
        2000Q3:  0.95537
        2000Q4:  0.68029
        2001Q1:  0.86056
        2001Q2:  0.93909
        2001Q3:  0.68019
        2001Q4:  0.91742
        2002Q1:  0.25669
        2002Q2:  0.88562
        ''
        User Data: empty

    tabular(x)
        Series object: 8-by-1
        2000Q1-2000Q4:        NaN           NaN     0.9553698     0.6802907
        2001Q1-2001Q4:  0.8605621     0.9390935      0.680194     0.9174237
        2002Q1-2002Q4:  0.2566917     0.8856181           NaN           NaN
        ''
        User Data: empty
```
