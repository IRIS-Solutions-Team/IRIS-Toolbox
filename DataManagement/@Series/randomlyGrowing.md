---
title: Series.randomlyGrowing
---

# `Series.randomlyGrowing` ^^(Series)^^

{== Create randomly growing time series ==}


## Syntax

    outputSeries = Series.randomlyGrowing(range)
    outputSeries = Series.randomlyGrowing(range, [mean, stdev], ...)


## Input Arguments

__`range`__ [ Dater ]
> 
> Date range on which the randomly growing time series will be created.
> 

__`[mean=0, stdev=1]`__ [ numeric ]
> 
> The mean and std deviation of the Normal distribution from which the
> log-growth rate or the difference will be drawn; see Description.
> 

## Output Arguments

__`outputSeries`__ [ Series ]
> 
> Output time series.
> 

## Options

__`Comment=""`__ [ string ]
> 
> Comment, or an array of comments (depending on the `Dimensions` option)
> that will be assigned to the `outputSeries`.
> 

__`Dimensions=1`__ [ numeric ]
> 
> The size of the `outputSeries` in 2nd and higher dimensions.
> 
    
__`Exponentiate=true`__ [ `true` | `false` ]
> 
> Exponentiate the cumulative sum of random numbers to create the
> `outputSeries`.
> 

__`Initial=0`__ [ numeric ]
> 
> Initial value for the cumulative sum of random numbers (before
> exponentiation when `Exponentiate=true`.
> 

## Description

The output series is created as follows:

1. Generate a series of a total of N random numbers from $N(\mu, \sigma)$,
   where the mean $\mu$ and the std deviation $\sigma$ are determined by
   the input arguments `mean` and `stdev`, respectively, and N is the
   number of periods in the `range`.

1. Replace the first random number in the series with `Initial`, and
   calculate the cumulative sum of these random numbers.

1. When `Exponentiate=true`, exponentiate the cumulated series.


## Example

```matlab
x = Series.randomlyGrowing(qq(2020,1):qq(2030,4), [0.01, 0.02])
```

