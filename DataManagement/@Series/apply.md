---
title: apply
---

# `apply` ^^(Series)^^

{== Apply function to time series period by period ==}


## Syntax


    x = apply(func, x, dates, y1, y2, etc...)


## Input arguments


__`func`__ [ function_handle ]
>
> Function that will be applied to the input series `x` period by period
> (allowing for time recursive formulas); see Description for details of
> referencing the input time series (`x`, `y1`, `y2`, etc...) in the
> `func`.
> 

__`x`__ [ Series ]
> 
> Input series to which the `func` will be applied period by period.
> 


__`dates`__ [ Dater ]
> 
> Dates at which the new values will be calculated for `x` and stored in
> the output series.
> 


__`y1`__, __`y2`__, etc... [ Series | numeric ]
> 
> Extra input arguments with which the `func` will be evaluated.
> 


## Description

The function `func` must accept a total of N input arguments where N is 2
plus the number of the extra input arguments `y1`, `y2`, etc... The first
two input arguments must be the input series `x` and the time index,
say `t`.

Any use of a time series in the `func` must be followed explicitly by
a round-bracket reference `(t, :)` where `t` is the name of the time
reference. In a special case where the time series is a scalar series
(a single column), this can be abbreviated to `(t)`.


## Example

Autoregressive process

    >> x = Series(qq(2020,1), 1);
    >> func = @(x, t) 0,8*x(t-1) + 5;
    >> x = apply(func, x, qq(2020,2):qq(2021,4))
    x = 
        Series Object: 8-by-1
        Class of Data: double
        2020Q1:        1
        2020Q2:      5.8
        2020Q3:     9.64
        2020Q4:   12.712
        2021Q1:  15.1696
        2021Q2:  17.1357
        2021Q3:  18.7085
        2021Q4:  19.9668
        'Dates'    ''
        User Data: Empty


## Example

Autoregressive process with exogenous input

```matlab
>> x = Series(qq(2020,1), 1);                
>> y = Series(qq(2020,1):qq(2021,4), (1:8)');
>> func = @(x, t, y) 0.8*x(t-1) + y(t);      
>> x = apply(func, x, qq(2020,2):qq(2021,4), y)
x = 
    Series Object: 8-by-1
    Class of Data: double
    2020Q1:        1
    2020Q2:      2.8
    2020Q3:     5.24
    2020Q4:    8.192
    2021Q1:  11.5536
    2021Q2:  15.2429
    2021Q3:  19.1943
    2021Q4:  23.3554
    'Dates'    ''
    User Data: Empty
```

