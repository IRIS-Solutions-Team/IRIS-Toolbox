---
title: isStationary
---

# `isStationary` ^^(Model)^^

{== True if the model or a linear combination of its variables is stationary ==}


## Syntax

     flag = isStationary(m)
     flag = isStationary(m, name)
     flag = isStationary(m, expression)


## Input arguments 

__`m`__ [ model ]
> 
> Model object.
> 

__`name`__ [ string ]
> 
> Transition variable name.
> 

__`expression`__ [ string ] 
> 
> Text string defining a linear combination of
> transition variables; log variables need to be enclosed in `log(...)`.
> 

## Output arguments 

__`flag`__ [ `true` | `false` ]
> 
> True if the model (if called without a
> second input argument) or the specified transition variable or
> combination of transition variables (if called with a second input
> argument) is stationary.
> 

## Description


## Examples

In the following examples, `m` is a solved model object with two of its
transition variables named `x` and `y`, with the latter being declared as
a log variable:

```matlab
    isStationary(m)
    isStationary(m, 'x')
    isStationary(m, 'log(y)')
    isStationary(m, 'x - 0.5*log(y)')
```


