---
title: addparam
---

# `qualifier.function-name`

{== Add model parameters to databank ==}


## Syntax

>Input arguments marked with a `~` sign may be omitted.

    D = addparam(M, ~D)


## Input Arguments

`M` [ model ] 
>
>Model object whose parameters will be added to databank `D`.
>

`~D` [ struct ] 
>
>Databank to which the model parameters will be added;
>if omitted, a new databank will be created.
>

## Output Arguments

`D` [ struct ] 
>
>Databank with the model parameters added.
>

## Description

>
>Function `addparam( )` adds all model parameters, including std
>deviations and nonzero cross-correlations, to the databank, `D`, as
>arrays with values for all parameter variants.
>
>Any existing databank entries whose names coincide with the names of
>model parameters will be overwritten.
>

## Example

    d = struct( );
    d = addparam(m, d);
