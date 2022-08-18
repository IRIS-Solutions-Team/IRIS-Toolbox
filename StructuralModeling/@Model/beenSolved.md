
---
title: beenSolved
---

{== True if first-order solution has been successfully calculated ==}


## Syntax

    flag = beenSolved(model)


## Input arguments 

  `model` [ model ]
> 
> Model object
> 

## Output arguments 

  `flag` [ `true` | `false` ]
>
> True for parameter variants for which a stable unique solution has
> been successfully calculated.
> 


## Options 


## Description 

> Basic Use Case
>
> Use this function to verify whether a first-order solution has been
> successfully calculated and assigned in the model object. The output
> argument, `flag`, is `true` if a valid solution exists in the model
> object and `false` if it does not.
> 
>
> Models with Multiple Parameter Variants 
>
> If the input model, `m`, contains multiple parameter variants, the output
> argument, `flag`, is a row vector of logical values of the same length as
> the number of variants, each element of which indicates the existence of
> a valid first-order solution for the respective parameter variant.
>


## Examples

