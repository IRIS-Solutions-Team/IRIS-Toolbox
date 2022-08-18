
---
title: qualifier.function-name
---

{== Add model std deviations to databank ==}


## Syntax

>
> Input arguments marked with a `~` sign may be omitted.
>
    D = addstd(M, ~D)


## Input Arguments

`M` [ model ] 
>
> Model object whose std deviations will be added to databank `D`.
>

`~D` [ struct ] 
>
> Databank to which the model std deviations will be added
>

## Output Arguments

`D` [ struct ] 
>
> Databank with the model std deviations added.
>

## Description

>
> Function `addplainparam( )` adds all plain parameters to the databank,
> `D`, as arrays with values for all parameter variants. Plain parameters
> include all model parameters except std deviations and cross-correlations
> of shocks.
>
> Any existing databank entries whose names coincide with the names of
> model std deviations will be overwritten.
>

## Example

    d = struct( );
    d = addstd(m, d);
