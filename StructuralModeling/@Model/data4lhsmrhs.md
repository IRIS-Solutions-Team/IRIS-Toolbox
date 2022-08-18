---
title: data4lhsmrhs
---

{== Prepare model data array ==}


## Syntax 

    [YXEPG, RowNames, ExtendedRange] = data4lhsmrhs(Model, InpDatabank, Range)


## Input Arguments 

 `Model` [ model ]
> 
> Model object whose equations will be later
>evaluated by calling [`lhsmrhs`](model/lhsmrhs).
>

 `InpDatabank` [ struct ] 
> 
> Input database with observations on
>measurement variables, transition variables, and shocks on which
>[`lhsmrhs`](model/lhsmrhs) will be evaluated.
>

 `Range` [ DateWrapper ] 
> 
> Continuous range on which
>[`lhsmrhs`](model/lhsmrhs) will be evaluated.
>


## Output Arguments

 `YXEPG` [ numeric ] 
>
> Numeric array with the observations on
>measurement variables, transition variables, shocks and exogenous
>variables (including time trend) organized row-wise.
>

 `RowNames` [ cellstr ] 
> 
> List of measurement variables, transition
>variables, shocks, parameters and exogenous variables in order of their
>appearance in the rows of `YXEPG`.
>

 `ExtendedRange` [ DateWrapper ] 
> 
> Extended range including pre-sample
>and post-sample observations needed to evaluate lags and leads of
>transition variables.
>

## Description
>
>The output array, `YXEPG`, is N-by-T-by-K where N is the total number of
>all quantities in the `Model` (measurement variables, transition
>variables, shocks, parameters, and exogenous variables including a time
>trend), T is the number of periods including the pre-sample and
>post-sample periods needed to evaluate lags and leads, and K is the
>number of alternative data sets (i.e. the number of columns in each input
>time series) in the `InputDatabank`.
>

## Example 

    YXEPG = data4lhsmrhs(m, d, range);
    d = lhsmrhs(m, YXEPG);

