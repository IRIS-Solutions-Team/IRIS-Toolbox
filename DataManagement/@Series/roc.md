---
title: roc
---

# `roc` ^^(Series)^^

{== Gross rate of change ==}


## Syntax 

x = roc(x, ~shift, ...)
> 
> Input arguments marked with a `~` sign may be omitted
> 

## Input arguments 

__`x`__ [ Series ]
>
> Input time series.
>

__`~shift=-1`__ [ numeric | `"YoY"` | `"BoY"` | `"EoLY"` ]
>
> Time shift (lag or lead) over which the rate of change will be computed,
> i.e. between time t and t+k; the `shift` specified as `"YoY"`, `"BoY"` or
> `"EoLY"` means year-on-year changes, changes relative to the beginning of
> current year, or changes relative to the end of previous year,
> respectively (these do not work with `INTEGER` date frequency).
>

## Output arguments 

__`x`__ [ TimeSubscriptable ]
>
> Percentage rate of change in the input data.
>

## Options 

__`'OutputFreq='`__ [ *empty* | Frequency ]
> 
> Convert the rate of change to the requested date
> frequency; empty means plain rate of change with no conversion.
> 

## Description 



## Examples

```matlab
```

Here, `x` is a monthly time series. The following command computes the
rate of change between month t and t-1:

```matlab
roc(x, -1)
```

The following line computes the rate of change between
month t and t-3:

```matlab
roc(x, -3)
```

In this example, `xm` is a monthly time series and `xq` is a quarterly
series. The following pairs of commands are equivalent for calculating
the year-over-year rates of change:

```matlab
roc(xm, -12)
roc(xm, 'YoY')
```

and

```matlab
roc(xq, -4)
roc(xm, 'YoY')
```
