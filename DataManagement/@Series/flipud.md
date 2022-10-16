---
title: flipud
---

# `flipud` ^^(Series)^^

{== Flip time series data up to down ==}


## Syntax 

    x = flipud(x)


## Input arguments 

__`x`__ [ Series ] 
> 
> Time series whose data will be flipped up to down.
> 

## Output arguments 

__`x`__ [ Series ] 
> 
> Time series with its data flipped up to down.
> 


## Description 

The data vector or matrix of the input time series is flipped up to down
using the standard Matlab function `flipud`, i.e. the rows of the data
vector or matrix are reorganized from last to first.

## Examples

```matlab
x = Series(qq(2000,1):qq(2000,4), 1:4)
    x =
        Series object: 4-by-1
        2000Q1:  1
        2000Q2:  2
        2000Q3:  3
        2000Q4:  4
        ''
        user data: empty

>> flipud(x)
    ans =
        Series object: 4-by-1
        2000Q1:  4
        2000Q2:  3
        2000Q3:  2
        2000Q4:  1
        ''
        user data: empty
```

