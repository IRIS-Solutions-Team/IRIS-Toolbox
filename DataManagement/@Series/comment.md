---
title: comment
---

# `comment` ^^(Series)^^

{== Get or set user comments in time series ==}


## Syntax for Getting User Comments

    newComment = comment(x)

## Syntax for Assigning User Comments

    x = comment(x, newComment)
    x = comment(x, y)


## Input arguments 

__`x`__ [ Series ]
> 
> Time series
> 

__`newComment`__ [ string ]
> 
> Comment(s) that will be assigned
> to each column of the input time series, `x`.
> 

__`y`__ [ Series ]
> 
> Another time series whose column comment(s) will be
> assigned to the input time series, `x`.
> 


## Output arguments 

__`x`__ [ Series ]
> 
> Output time series with new comments
> assigned.
> 

__`newComment`__ [ cellstr ] 
> 
> Comments from the input time series, `x`. 
> 

## Options 

__`zzz=default`__ [ zzz | ___ ]
> 
> Description
> 


## Description 

Multivariate time series have comments assigned to
each of their columns. When assigning comments (using the syntax with two
input arguments) you can either pass in a char (text string) or a cellstr
(a cell array of strings). If `ColumnNames` is a char, then this same
comment will be assigned to all of the time series columns. If
`ColumnNames` is a cellstr, its size in the 2nd and higher dimensions
must match the size of the time series data; the individual strings from
`ColumnNames` will be then copied to the comments belonging to the
individual time series columns.

## Examples

```matlab
x = Series(1:2, rand(2, 2));
x = comment(x, "Comment")

x =

    Series object: 2-by-2
    Class of Data: double

    1: 0.28521     0.67068
    2: 0.91586     0.78549

    "Dates"    "Comment"    "Comment"
    
    User data: empty

x = comment(x, ["Comment 1", "Comment 2"])

x =
    Series object: 2-by-2
    Class of Data: double

    1: 0.28521     0.67068
    2: 0.91586     0.78549

    "Dates"    "Comment 1"    "Comment 2"

    User Data: empty
```

