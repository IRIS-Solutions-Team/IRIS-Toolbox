---
title: bn
---

# `bn` ^^(Model)^^

{== Beveridge-Nelson trends ==}


## Syntax

    outp = bn(m, inputDb, range, ___)


## Input arguments

__`m`__ [ Model ] 
> 
> Solved model object.
> 

__`inputDb`__ [ struct ]
> 
> Input databank on which the BN trends will be computed.
> 

__`range`__ [ Dater ] 
> 
> Date range on which the BN trends will be computed.
> 

## Output arguments 

__`outp`__ [ struct ]
> 
> Output databank with the BN trends.
> 

## Options

__`Deviation=false`__ [ `true` | `false` ] 
> 
> Input and output data are deviations from steady-state paths.
> 


## Description 

The BN decomposition is accurate only if the input data have been generated
using unanticipated shocks.


## Examples


