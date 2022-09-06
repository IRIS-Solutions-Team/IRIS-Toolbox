---
title: findEquation
---

# `findEquation

{== Find equations whose input strings pass one or more tests ==}


## Syntax 

    [equations, descriptions, aliases] = findEquations(model, test, ...)


## Input arguments 

`model` [ Model ]
> 
> Model object whose equations will be searched.
> 


`test` [ function ]
> 
> Function returning a `true` or `false` for an equation input string;
> specify more than one tests as the third and futher input arguments.
> 


## Output arguments 

`equations` [ string ]
> 
> List of input strings of the equations that pass all `tests`.
> 


`descriptions` [ string ]
> 
> List of descriptions of the equations that pass all `tests`.
> 


`aliases` [ string ]
> 
> List of aliases of the equations that pass all `tests`.
> 


## Options 

__`%%%=%%%`__ [ %%% ]
> 
> %%%
> 


## Description 


## Examples


