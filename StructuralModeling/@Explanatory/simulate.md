---
title: islinear
---

# `islinear`

{== True for models declared as linear.==}


## Syntax 

    Flag = islinear(M)


## Input arguments 

`m` [ model ]
> 
> Queried model object.
> 


## Output arguments 

`Flag` [ `true` | `false` ]
> 
> True if the model has been declared linear
> 


## Options 



## Description 

>
> The value returned dependes on whether the model has been declared as
> linear by the user when constructing the model object by calling the
> [`model/model`](model/model) function. In other words, no check is
> performed whether or not the model is actually linear.
>


## Examples

    m = model('mymodel.file', 'linear=', true);
    islinear(m)
    ans =
         1

