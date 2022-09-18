---
title: findeqtn
---

# `findeqtn` ^^(Model)^^

{== Find equations by their labels. ==}


## Syntax 

    [Eqtn, Eqtn, ...] = findeqtn(M, Label, Label, ...)


## Input arguments 

 `m` [ model ]
>
> Model object in which the equations will be searched
> for.
> 
>
 `Label` [ char | rexp ]
>
> Equation labels that will be searched for,
> or rexp objects (regular expressions) against which the labels will be
> matched.
>

## Output arguments 

 `Eqtn` [ char | cellstr ]
> 
> If `Label` is a text string, `Eqtn` is
> the first equation with the label `Label`; if `Label` is a rexp
> object (regular expression), `Eqtn` is a cell array of equations matched
> successfully against the regular expression.
>
 


## Options 


## Description 



## Examples

