---
title: isempty
---

# `isempty` ^^(Series)^^

{== True if tseries object data matrix is empty. ==}


## Syntax 

    Flag = isempty(X)


## Input arguments 

__`X`__ [ tseries ]
> 
> Tseries object.
> 


## Output arguments 

`Flag` [ `true` | `false` ] 
> 
> True if tseries object data matrix is empty.
> 


## Options 

__`zzz=default`__ [ zzz | ___ ]
> 
> Description
> 


## Description 



## Examples

```matlab
x1 = tseries(1:10,@rand);
isempty(x1)
    ans =
        0
x2 = tseries( );
isempty(x2)
    ans =
        1
```

