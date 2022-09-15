---
title: eig
---

# `eig` ^^(Model)^^

{== Eigenvalues of model transition matrix ==}


## Syntax 

    [eigenVal, stab] = eig(M)

## Input arguments 

    `M` [ model ]
> 
> Model object whose eigenvalues will be returned.
> 

## Output arguments 


    __`eigenVal`__ [ numeric ]
> 
> Array of all eigenvalues associated with the model, i.e. all stable,
> unit, and unstable roots are included.
>

    __`stab`__ [ int8 ] 
>
> Classification of each root in the `EigenValues` vector: `0` means a
> stable root, `1` means a unit root, `2` means an unstable root; `stab` is
> filled with zeros in models or parameter variants where no solution has
> been computed.
>


## Options 


## Description 



## Examples


