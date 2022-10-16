---
title: redate
---

# `redate` ^^(Series)^^

{== Change time dimension of time series ==}


## Syntax 

    x = redate(x, oldDate, newDate)


## Input arguments 

__`x`__ [ tseries ]
> 
> Input time series.
> 

__`oldDate`__ [ Dater ]
> 
> Base date that will be converted to a new
> date; `oldDate` does not need to be the stard date of `X` and does not
> even need to be within the current date range of `X`.
> 

__`newDate`__ [ Dater ]
> 
> A new date to which the base date `oldDate`
> will be changed; `newDate` need not be the same frequency as `oldDate`.
> 

## Output arguments 

__`x`__ [ tseries ] 
> 
> Output tseries object with identical data as the
> input tseries object, but with its time dimension changed.
> 

## Options 

__`zzz=default`__ [ zzz | ___ ]
> 
> Description
> 


## Description 



## Examples

Create a time series on a date range from `2000Q1` to `2000Q4`. Change
the time dimension of the time series so that `1999Q4` (which is a date
outside the original time series range) changes into `2009Q4` (which will
again be a date outside the new time series range).

```matlab
    x = Series(qq(2000, 1):qq(2000, 4), 1:4)
    x =
        Series object: 4-by-1
        2000Q1:  1
        2000Q2:  2
        2000Q3:  3
        2000Q4:  4
        ''
        User Data: empty

    redate(x, qq(1999, 4), qq(2009, 4))
    ans =
        Series object: 4-by-1
        2010Q1:  1
        2010Q2:  2
        2010Q3:  3
        2010Q4:  4
        ''
        User Data: empty
```
