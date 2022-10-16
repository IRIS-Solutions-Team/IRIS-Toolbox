---
title: pct
---

# `pct` ^^(Series)^^

{== Percent rate of change ==}


## Syntax 

x = pct(x, ~shift, ...)
> 
> Input arguments marked with a `~` sign may be omitted
> 

## Input Arguments ##

__`x`__ [ TimeSubscriptable ]
> 
> Input time series.
> 

__`~shift`__ [ numeric | `'yoy'` ]
> 
> Time shift (lag or lead) over which the percent rate of change will be
> computed, i.e. between time t and t+k; if omitted, `shift=-1`; if
> `shift='yoy'` a year-on-year percent rate is calculated (with the actual
> `shift` depending on the date frequency of the input series `x`).
> 

## Output Arguments ##

__`x`__ [ TimeSubscriptable ]
> 
> Percentage rate of change in the input data.
> 

## Options ##

__`'OutputFreq='`__ [ *empty* | Frequency ]
> 
> Convert the percent rate of change to the requested date
> frequency; empty means plain percent rate of change with no conversion.
> 

## Description ##


## Examples ##

In this example, `x` is a monthly time series. The following command
computes the annualized percent rate of change between month t and t-1:

```matlab
pct(x, -1, 'OutputFreq=', 1)
```

while the following line computes the annualized percent rate of change
between month t and t-3:

```matlab
pct(x, -3, 'OutputFreq=', 1)
```

In this example, `xm` is a monthly time series and `xq` is a quarterly
series. The following pairs of commands are equivalent for calculating
the year-over-year percent rates of change:

```matlab
pct(xm, -12)
pct(xm, 'yoy')
```

and

```matlab
pct(xq, -4)
pct(xq, 'yoy')
```
