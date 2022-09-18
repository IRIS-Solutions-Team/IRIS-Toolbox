---
title: system
---

# `system` ^^(Model)^^

{== System matrices for the unsolved model ==}


## Syntax

    [A, B, C, D, F, G, H, J, list, numF] = system(model)


## Input Arguments

__`model`__ [ Model ] 
> 
> Model object whose system matrices will be
> returned.
> 

## Output Arguments

__`A`, `B`, `C`, `D`, `F`, `G`, `H`, `J`__  [ numeric ] 
> 
> Matrices of the unsolved system, see Description.
> 

__`list`__ [ cell ] 
> 
> Lists of measurement variables, transition variables includint their
> auxiliary lags and leads, shocks, measurement equations, and transition
> equations as they appear in the rows and columns of the system matrices.
> 

__`numF`__ [ numeric ] 
> 
> Number of non-predetermined (forward-looking) transition variables
> (multiplied by the first `numF` columns of matrices `A` and `B`).
> 

## Options

__`ForceDiff=false`__ [ `true` | `false` ] 
> 
> If `false`, automatically detect which equations need to be
> re-differentiated based on parameter changes from the last time the
> system matrices were calculated; if `true`, recalculate all derivatives.
> 

__`MatrixFormat="NamedMatrix"`__ [ `"plain"` | `"NamedMatrix"` ]
> 
> Format of the output matrix.
> 

__`Normalize=true`__ [ `true` | `false` ]
> 
> Normalize (divide) the derivatives within each equation by the largest of
> them.
> 

__`Sparse=false`__ [ `true` | `false` ] 
> 
> Return matrices `A`, `B`, `D`,
> `F`, `G`, and `J` as sparse matrices; can be set to `true` only in models
> with one parameterization.
> 


## Description

The system before the model is solved has the following form:

    A E[xf;xb] + B [xf(-1);xb(-1)] + C + D e = 0

    F y + G xb + H + J e = 0

where 

* `E` is a conditional expectations operator;

* `xf` is a vector of non-predetermined (forward-looking) transition
  variables;

* `xb` is a vector of predetermined (backward-looking) transition
  variables;

* `y` is a vector of measurement variables

* `e` is a vector of transition and measurement shocks.


## Example


