---
title: byAttributes
---

# `byAttributes` ^^(Model)^^

{== Look up model quantities and equation by attributes ==}


## Syntax

    [quantities, equations] = byAttributes(model, attr1, attr2, ...)


## Input arguments 

__`model`__ [ Model ]
> 
> Model object that will be searched for quantities and equations by their
> attributes.
> 

__`attr1`__, __`attr2`__, ... [ string ]
> 
> Each `attrX` is a string or vector of strings. The function then returns
> the `quantities` and `equations` that have at least on of the `attr1`
> attributes and at least one of the `attr2` attributes, and so on.
> 

## Output arguments 

__`quantities`__ [ string ]
> 
> List of the quantities (variables, shocks, parameters) that have at least
> on of the `attr1` attributes and at least one of the `attr2` attributes,
> and so on.
> 

__`equations`__ [ string ]
> 
> List of the equations  that have at least
> on of the `attr1` attributes and at least one of the `attr2` attributes,
> and so on.
> 

## Description 


## Examples
