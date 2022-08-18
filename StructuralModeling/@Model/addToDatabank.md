
---
title: qualifier.function-name
---

{== Add model quantities to existing or new databank ==}


## Syntax

>
> Input arguments marked with a `~` sign may be omitted.
>
    d = addToDatabank(what, m, d, ...)
    d = addToDatabank(what, m, d, range, ...)


## Input Arguments

`what` [ char | cellstr | string ] 
>
> what model quantities to add:
> parameters, std deviations, cross-correlations.
>

`m` [ model ] 
>
> Model object whose parameters will be added to databank `d`.
>

`d` [ struct ] 
>
> Databank to which the model parameters will be added.
>

`~range` [ DateWrapper ] 
>
> Date range on which time series will be
> created; needs to be specified for `Shocks`.
>

## Output Arguments

`d` [ struct | Dictionary | containers.Map ]
>
> Databank with the model parameters added.
>

## Description

>
> Function `addToDatabank( )` adds all specified model quantities to the databank,
> `d`, as arrays with values for all parameter variants. If no input
> databank is entered, a new will be created.
>
> Specify one of the following to choose what model quantities to add:
>
`'Parameters'` - add plain parameters (no std deviations or cross correlations)
`'Std'` - add std deviations of model shocks
`'NonzeroCorr'` - add nonzero cross-correlations of model shocks
`'Corr'` - add all cross correlations of model shocks
`'Shocks'` - add time series for model shocks
`'Default'` - equivalent to `{'Parameters', 'Std', 'NonzeroCorr'}`
>
> These can be specified as case-insensitive char, strings, or combined in
> a cellstr or a string array.
>
> Any existing databank entries whose names coincide with the names of
> model parameters will be overwritten.
>

## Example

    d = struct( );
    d = addToDatabank('Parameters', m, d);
