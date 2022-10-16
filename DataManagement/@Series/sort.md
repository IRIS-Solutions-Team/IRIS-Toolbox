---
title: sort
---

# `sort` ^^(Series)^^

{== Sort tseries columns by specified criterion. ==}


## Syntax 

    [Y,INDEX] = sort(X,CRIT)


## Input arguments 

__`X`__ [ tseries ] 
> 
> Input tseries object whose columns will be sorted
> in order determined by the criterion `crit`.
> 

__`CRIT`__ [ 'sumsq' | 'sumabs' | 'max' | 'maxabs' | 'min' | 'minabs' ] 
> 
> Criterion used to sort the input tseries object columns.
> 

## Output arguments 

__`Y`__ [ tseries ] 
> 
> Output tseries object with columns sorted in order
> determined by the input criterion, `CRIT`.
> 

__`INDEX`__ [ numeric ] 
> 
> Vector of indices, `y = x{:,index}`.
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

