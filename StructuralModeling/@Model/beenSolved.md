---
title: beenSolved
---

# `beenSolved` ^^(Model)^^

{== True if first-order solution has been successfully calculated ==}


## Syntax

    flag = beenSolved(model)


## Input arguments 

__`model`__ [ model ]
> 
> Model object
> 

## Output arguments 

__`flag`__ [ `true` | `false` ]
> 
> True for parameter variants for which a stable unique solution has
> been successfully calculated.
> 


## Description 


### Basic use case

Use this function to verify whether a first-order solution has been
successfully calculated and assigned in the model object. The output
argument, `flag`, is `true` if a valid solution exists in the model
object and `false` if it does not.


### Models with multiple parameter variants 

If the input model, `m`, contains multiple parameter variants, the output
argument, `flag`, is a row vector of logical values of the same length as
the number of variants, each element of which indicates the existence of
a valid first-order solution for the respective parameter variant.


## Examples

