---
title: normalize
---

# `normalize`

{== Normalize (or rebase) data to particular date or value ==}


## Syntax 

X = normalize(X, ~NormDate, ...)
> 
> Input arguments marked with a `~` sign may be omitted.
> 

## Input arguments 

__`X`__ [ tseries ]
> 
> Input time series that will be normalized.
> 

__`~NormDate='NaNStart'`__ [ Dater | `'Start'` | `'End'` |
`'NanStart'` | `'NanEnd'` ]
> 
> Date relative to which the input data will
> be normalize; see help on `tseries.get` to understand `'Start'`, `'End'`,
> `'NaNStart'`, `'NaNEnd'`.
> 

## Output arguments 

__`X`__ [ tseries ]
> 
> Normalized time series.
> 


## Options 

__`Mode='mult'`__ [ `'add'` | `'mult'` ]
> 
> Additive or multiplicative
> normalization.
> 

## Description 



## Examples

```matlab
```

