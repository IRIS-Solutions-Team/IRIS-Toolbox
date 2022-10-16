---
title: find
---

# `find` ^^(Series)^^

{== Find dates at which tseries observations are non-zero or true ==}


## Syntax 

    Dates = find(X)
    Dates = find(X,Func)


## Input arguments 


__`X`__ [ tseries ]
> 
> Input tseries object.
> 

__`Func`__ [ @all | @any ]
> 
> Controls whether the output `Dates` will
> contain periods where all observations are non-zero, or where at least
> one observation is non-zero. If not specified, `@all` is
> assumed.
> 


## Output arguments 

__`Dates`__ [ numeric | cell ]
> 
> Vector of dates at which all or any
> (depending on `Func`) of the observations are non-zero. 
> 

## Options 

__`zzz=default`__ [ zzz | ___ ]
> 
> Description
> 


## Description 



## Examples

```matlab
```

