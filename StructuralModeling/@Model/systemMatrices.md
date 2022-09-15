---
title: systemMatrices
---

# `systemMatrices` ^^(Model)^^

{== First-order system matrices describing the unsolved model ==}


## Syntax

    output = systemMatrices(model)


## Input Arguments

__`model`__ [ Model ] 
> 
> Model object whose system matrices will be
> returned.
> 

## Output Arguments

__`output`__ [ struct ]
> 
> Output struct with the matrices describing the unsolved system, see
> Description.
> 


__`numF`__ [ numeric ] 
> 
> Number of non-predetermined (aka forward-looking) transition variables
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
> Return the system matrices `output.A`, `output.B`, `output.D`,
> `output.F`, `output.G`, and `output.J` as sparse matrices; this option
> can be `true` only in models with one parameterization.
> 


## Description

The `output` struct contains the following fields:

* `.A`, `.B`, `.C`, `.D` - matrices (plain arrays or or NamedMat objects,
  depending on the option `MatrixFormat`) describing the first-order
  expansion of transition equations around steady state;

* `.F`, `.G`, `.H`, `.J` - matrices (plain arrays or or NamedMat objects,
  depending on the option `MatrixFormat`) describing the first-order
  expansion of measurement equations around steady state;

* `.NumForward` - the number of non-predetermined (forward-looking)
  variables in the transition vector;

* `.NumBackward` - the number of predetermined (backward-looking)
  variables in the transition vector;


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
