---
title: isequal
---

# `isequal`

{== Compare two tseries objects. ==}


## Syntax 

    Flag = isequal(X1, X2)


## Input arguments 

__`X1`__, __`X2`__ [ tseries ]
> 
> Two tseries objects that will be compared.
> 


## Output arguments

__`Flag`__ [ `true` | `false` ] 
>
>True if the two input tseries objects
>have identical contents: start date, data, comments, userdata, and
>captions.
>

## Options 

__`zzz=default`__ [ zzz | ___ ]
> 
> Description
> 


## Description 

The function `isequaln` is used to compare the tseries data, i.e. `NaN`s
are correctly matched.

## Examples

```matlab
```

