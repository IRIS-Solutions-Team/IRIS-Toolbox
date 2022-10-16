---
title: clip
---

# `clip` ^^(Series)^^

{== Clip time series to a shorter range ==}


## Syntax 

    outputSeries = clip(inputSeries, newStart, newEnd)
    outputSeries = clip(inputSeries, newStart:newEnd)


## Input arguments 

__`inputSeries`__ [ Series ]
> 
> Input time series whose date range will be clipped.
> 


__`newStart`__ [ Dater | `-Inf` ]
> 
> New start date; `-Inf` means keep the current start date.
> 

__`newEnd`__ [ Dater | `Inf` ]
> 
> New end date; `Inf` means keep the current enddate.
> 


## Output arguments 

__`outputSeries`__ [ Series ]
> 
> Output time series  with its date range clipped to the new range from
> `newStart` to `newEnd`. 
> 


## Description 



## Examples

```matlab
x = Series(qq(2020,1), rand(8, 1));
getRange(x)
y = clip(x, -Inf, qq(2020,4));
getRange(y)
[x, y]
```

```matlab
ans = 
  1x8 QUARTERLY Date(s)
     2020Q1      2020Q2      2020Q3      2020Q4      2021Q1      2021Q2      2021Q3      2021Q4 
ans = 
  1x4 QUARTERLY Date(s)
     2020Q1      2020Q2      2020Q3      2020Q4 
ans = 
    Series Object: 8-by-2
    Class of Data: double
                  1          2   
               _______    _______
    2020Q1:    0.62248    0.62248
    2020Q2:    0.58704    0.58704
    2020Q3:    0.20774    0.20774
    2020Q4:    0.30125    0.30125
    2021Q1:    0.47092        NaN
    2021Q2:    0.23049        NaN
    2021Q3:    0.84431        NaN
    2021Q4:    0.19476        NaN
    "Dates"    ""    ""
    User Data: Empty
```

