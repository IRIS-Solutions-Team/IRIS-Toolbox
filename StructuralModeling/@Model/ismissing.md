---
title: ismissing
---

# `ismissing` ^^(Model)^^

{== True if some initical conditions are missing from input database.==}


## Syntax
 
     [Flag,List] = ismissing(M,Inp,Range)

## Input arguments
 

 `M` [ model ]
>
> Model object.
>

 `Inp` [ struct ]
> 
> Input database from which initical conditions are
> obtained.
>

 `Range` [ numeric ]
>
> Simulation range.%
>

## Output arguments
 

 `Flag` [ `true` | `false` ] 
>
> True if one or more initial conditions
> required for simulation of the model `M` are missing from the database
> `Inp`.
>

 `List` [ cellstr ] 
>
> List of initial conditions missing from the
> database `Inp`.
>

## Description
 
>
> The complete list of initial conditions required for simulating the model
> `M` can be obtained by
>
>     get(M,'required')
>
>


## Examples

