---
title: ifelse
---

# `ifelse` ^^(Series)^^

{== Replace time series values based on a test condition ==}


## Syntax 

X = ifelse(X, Test, IfTrue, ~IfFalse)
>
> Input arguments marked with a `~` sign may be omitted.
>

## Input arguments 

__`X`__ [ TimeSubscriptable ]
> 
> Input time series.
> 

__`Test`__ [ function_handle ]
> 
> Test function that returns `true` or
> `false` for each observation.
> 

__`IfTrue`__ [ any | empty ]
> 
> Value assigned to observations for which the
> `Test` function returns `true`; if isempty, these observations will
> remain unchanged.
> 

__`IfFalse`__ [ any | empty ]
> 
> Value assigned to observations for which
> the `Test` function returns `false`; if isempty or omitted, these
> observations will remain unchanged.
> 

## Output arguments 

__`X`__ [ TimeSubscriptable ]
> 
> Output time series.
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

