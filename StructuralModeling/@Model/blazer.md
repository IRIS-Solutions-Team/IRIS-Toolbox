---
title: blazer
---

# `blazer` ^^(Model)^^

{== Analyze sequential block structure of steady equations ==}


## Syntax

    [nameBlk, eqtnBlk, blkType, blazerObj] = blazer(model, ...)


## Input arguments 

__`model`__ [ Model ]
> 
> Model object
> 

## Output arguments 

__`nameBlk`__ [ cell ]
> 
> Lists of variables that each individual block will be solved for; the
> `nameBlk{i}.Level` element is a string array with the names of the
> variables whose levels will be solved for in the i-th block; the
> `nameBlk{i}.Change` element is a string array with the names of the
> variables whose changes (differences or rates of growth) will be solved
> for in the i-th block.
> 
> 

__`eqtnBlk`__ [ cell ] 
> 
> List of equations in each block.
> 
> 

__`blkType`__ [ solver.block.Type ] 
> 
> Type of each block: `SOLVE` or `ASSIGN`.
> 
> 

__`blazerObj`__ [ blazer.Blazer ]
> 
>     Blazer object.
> 

## Options 

__`Endogenize={ }`__ [ cellstr | char | string | empty ]
> 
>     List of parameters that will be endogenized in steady equations.
> 
> 

__`Exogenize={ }`__ [ cellstr | char | empty | string ] 
> 
>     List of transition or measurement variables that will be exogenized
>     in steady equations.
> 
> 

__`Kind='Steady'`__ [ `'Current'` | `'Stacked'` | `'Steady'` ]
> 
>     The method of sequential block analysis that will be performed.
> 


## Description 


Three ways the sequential block analysis can be performed:

*  `'Steady'` 
Investigate steady-state equations, considering lags and
leads to be the same entity as the respective current dated variable.

*  `'Current'` 
Investigate the current dated variables in dynamic
equations, taking lags and leads as given.

*  `'Stacked'` 
Investigate a whole structure of time-stacked equations
(not available yet).


### Reordering Algorithm


The reordering algorithm first identifies equations with a single
variable in each, and variables occurring in a single equation each, and
then uses a combination of column and row approximate minimum degree
permutations (`colamd`) followed by a Dulmage-Mendelsohn permutation
(`dmperm`).


### Output Returned from Blazer


The output arguments `NameBlk` and `EqtnBlk` are 1-by-N cell arrays,
where N is the number of blocks, and each cell is a 1-by-Kn cell array of
strings, where Kn is the number of variables and equations in block N.


## Examples

