---
title: convert
---

# `convert` ^^(Series)^^

{== Convert time series to another frequency ==}

    
## Syntax

    outputSeries = convert(inputSeries, newFreq, ...)
    outputSeries = convert(inputSeries, newFreq, range, ...)


## Input Arguments

__`inputSeries`__ [ Series ] 

> Input time series that will be converted to a new
> frequency, `freq`, aggregating or intrapolating the data.


__`newFreq`__ [ Frequency ]

> New frequency to which the input data will be converted; see Description
> for frequency formats allowed.


__`range=Inf`__ [ Dater ]

> Date range on which the input data will be converted; `Inf` means the
> conversion will be done on the entire time series range.


## Output Arguments

__`outputSeries`__ [ Series ]

> Output tseries created by converting the `inputSeries` to the new
> frequency (aggregating or interpolating).


## Options

__`RemoveNaN=false`__ [ `true` | `false` ]

> Exclude `NaN` values from agreggation.


__`Missing=@default`__ [ `@default` | numeric | `"previous"` | `"next"` ]

> Fill missing observations with this value before conversion:
> 
> * `@default` means no preprocessing;
> 
> * `"previous"` or `"next"` means fill in the nearest preceding or nearest
> following value available in the time series.


## Options for High- to Low-Frequency Aggregation

__`Method="mean"`__ [ "mean" | "sum" | "first" | "last" | function_handle ]

> Aggregation method; `"first"`, `"last"` and `"random"` select the
> first, last or a random observation from the high-frequency periods
> contained in the correspoding low-frequency period.


__`RemoveWeekends=false`__ [ `true` | `false` ]

> For daily frequency time series only: remove all weekend observations
> before aggregation.


__`Select=Inf`__ [ numeric ]

> Select only these high-frequency observations within each low-frequency
> period; `Inf` means all observations will be used.


### Options for Low- to High-Frequency Interpolation

__`Method="pchip"`__ [ string | `"quadSum"` | `"quadMean"` | `"flat"` | `"first"` | `"last"` ]

> Interpolation method; any option valid for the built-in function
> `interp1` can be used, or `'QuadSum'` or `'QuadMean'`; these two options
> use quadratic interpolation preserving the sum or the average of
> observations within each period.


__`Position="center"`__ [ `"center"` | `"start"` | `"end"` ] 

> Position of dates within each period in the low-frequency date grid.


__`RemoveWeekends=false`__ [ `true` | `false` ]

> For interpolation to daily frequency only: replace all weekend
> observations in the final time series (after interpolation) with `NaN`
> (or the default missing value as defined in the time series object
> property `.MissingValue`).


## Description

The function handle that you pass in through the `Method` option when you
aggregate the data (convert higher frequency to lower frequency) should
behave like the built-in functions `mean`, `sum` etc. In other words, it
is expected to accept two input arguments:

* the data to be aggregated;

* the dimension along which the aggregation is calculated.

The function will be called with the second input argument set to 1, as
the data are processed en block columnwise. If this call fails,
`convert()` will attempt to call the function with just one input
argument, the data, but this is not a safe option under some
circumstances since dimension mismatch may occur.


## Example

