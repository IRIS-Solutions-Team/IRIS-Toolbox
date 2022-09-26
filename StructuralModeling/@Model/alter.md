---
title: alter
---

# `alter` ^^(Model)^^

{== Expand or reduce number of parameter variants in model object ==}


## Syntax 

    M = alter(M, N)


## Input arguments 

`M` [ model ]
> 
> Model object in which the number of parameter variants
> will be changed.
> 

`N` [ numeric ]
> 
> New number of model variants.
> 


## Output arguments 

`M` [ model ]
> 
> Model object with the new number of variants.
> 


## Description 

If the new number of parameter variants, `N`, is greater than the current
number of parameter variants in the model object, `M`, the last parameter
variant (including solution matrices, if available) is copied an
appropriate number of times.

If the new number of parameter variants, `N`, is smaller than the current
number of parameter variants in the model object, `M`, an appropriate
number of parameter variants is deleted from the end.



## Examples


