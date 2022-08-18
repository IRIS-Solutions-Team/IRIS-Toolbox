
---
title: qualifier.function-name
---

{== Add model cross-correlations to databank ==}

## Syntax
>
>Input arguments marked with a `~` sign may be omitted.
>
    D = addcorr(M, ~D, ...)


## Input Arguments

 `M` [ model ]
>
> Model object whose model cross-correlations will be added to databank `D`.
>

`~D` [ struct ] 
>
> Databank to which the model cross-correlations  will
> be added; if omitted, a new databank will be created.
>

## Output Arguments

`D` [ struct ] 
>
> Databank with the model cross-correlations added.
>

## Options

`'AddZeroCorr='` [ `true` | *`false`* ]
>
> Add all cross-correlations including those set to zero; 
> if `false`, only non-zero cross-correlations
> will be added.


## Description
>
>Any existing databank entries whose names coincide with the names of
>model cross-correlations will be overwritten.
>

## Example

    d = struct( );
    d = addcorr(m, d);
