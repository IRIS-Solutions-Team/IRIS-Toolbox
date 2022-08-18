
---
title: qualifier.function-name
---

{== Add plain parameters to databank ==}


## Syntax

    D = addplainparam(M, ~D)


## Input Arguments

`M` [ model ] 
>
> Model object whose parameters will be added to databank `D`.
>

`~D` [ struct ] 
>
> Databank to which the model parameters will be added;
> if omitted, a new databank will be created.
>

## Output Arguments

`D` [ struct ] 
>
> Databank with the model parameters added.
>

## Description

>
> Function `addplainparam( )` adds all plain parameters to the databank,
> `D`, as arrays with values for all parameter variants. Plain parameters
> include all model parameters except std deviations and cross-correlations
> of shocks.
>
> Any existing databank entries whose names coincide with the names of
> model parameters will be overwritten.
>

## Example

    d = struct( );
    d = addplainparam(m, d);
