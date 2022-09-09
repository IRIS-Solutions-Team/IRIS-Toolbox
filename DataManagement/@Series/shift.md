---
title: shift
---

# `shift`

{== Shift times series by a lag or lead ==}


## Syntax 

    outputSeries = shift(inputSeries, sh)


## Input arguments 

__`inputSeries`__ [ Series ] 
> 
> Input time series that will be shifted by the lag or lead `sh`.
> 

__`sh`__ [ numeric ]
> 
> The lag (a negative number) or lead (a positive number) by which the
> `inputSeries` will be shifted; see Description for what happens if
> `sh` is a vector of numbers.
> 

## Output arguments 

__`outputSeries`__ [ Series ] 
> 
> Output time series created by shifting the `inputSeries` by a lag or
> lead specified in `sh`.
> 

## Options 

__`zzz=default`__ [ zzz | ___ ]
> 
> Description
> 

## Description 

The `outputSeries` is created simply by changing the start date of the
time series, shifting it by `-sh` periods.

If `sh` an array of numbers, the `outputSeries` is created by
concatenating the individual shifts along second dimension, i.e.
    shift(x, sh)

is the same (but more efficient) as
    [shift(x, sh(1)), shift(x, sh(2)), ...]

## Examples

Create a time series with two columns:
    
```matlab
    x = Series(1, rand(10,2))
    x =
        Series Object: 10-by-2
        Class of Data: double
                1          2
            _______    _______
        1:     0.40458    0.69627
        2:     0.44837    0.09382
        3:     0.36582     0.5254
        4:      0.7635    0.53034
        5:      0.6279    0.86114
        6:     0.77198    0.48485
        7:     0.93285    0.39346
        8:     0.97274    0.67143
        9:     0.19203    0.74126
        10:    0.13887    0.52005
        "Dates"    ""    ""
        User Data: Empty
```

Call the method `shift` with multiple lags and/or leads. The resulting
time series is a concatenation of the individual lags and/or leads:

```matlab
    shift(x, [-1, +2])
    ans =
        Series Object: 13-by-4
        Class of Data: double
                1          2          3          4
            _______    _______    _______    _______
        1:         NaN        NaN    0.40458    0.69627
        2:         NaN        NaN    0.44837    0.09382
        3:         NaN        NaN    0.36582     0.5254
        4:     0.40458    0.69627     0.7635    0.53034
        5:     0.44837    0.09382     0.6279    0.86114
        6:     0.36582     0.5254    0.77198    0.48485
        7:      0.7635    0.53034    0.93285    0.39346
        8:      0.6279    0.86114    0.97274    0.67143
        9:     0.77198    0.48485    0.19203    0.74126
        10:    0.93285    0.39346    0.13887    0.52005
        11:    0.97274    0.67143        NaN        NaN
        12:    0.19203    0.74126        NaN        NaN
        13:    0.13887    0.52005        NaN        NaN
        "Dates"    ""    ""    ""    ""
        User Data: Empty
```
