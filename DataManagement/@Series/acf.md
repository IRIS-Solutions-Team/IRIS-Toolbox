---
title: acf
---

# `acf` ^^(Series)^^

{== Sample autocovariance and autocorrelation functions ==}

## Syntax

    [C, R] = acf(x)
    [C, R] = acf(x, dates, ...)


## Input arguments

__`x`__ [ Series ]
>
> Input time series.
>

__`dates`__ [ numeric | Inf ]
>
> Dates or date range from which the input
> tseries data will be used.
>

## Output arguments


__`C`__ [ numeric ]
>
> Auto-/cross-covariance matrices.
>

__`R`__ [ numeric ]
>
> Auto-/cross-correlation matrices.
> 

## Options


__`Demean=true`__ [ `true` | `false` ]
>
> Estimate and remove sample mean from the data before computing the ACF.
>

__`Order=0`__ [ numeric ]
>
> The order up to which the ACF will be computed.
> 

__`SmallSample=true`__ [ `true` | `false` ]
>
> Adjust the degrees of freedom for small samples by subtracting `1` from
> the number of periods.
> 

## Description


## Examples

```matlab
```

