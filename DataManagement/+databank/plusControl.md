---
title: databank.plusControl
---

# `databank.plusControl` ^^(+databank)^^

{== Create simulation-plus-control database ==}


## Syntax 

    [outputDb, controlDb] = databank.plusControl(model, inputDb, ...)
    [outputDb, controlDb] = databank.plusControl(model, inputDb, controlDb, ...)


## Input arguments 

__`model`__ [ model ]
> 
> Model object on which the databases `inputDb` and `controlDb`__ are
> based.
> 

__`inputDb`__ [ struct ]
> 
> Simulation (or any other kind of) databank to which the `controlDb`
> will be add.
> 

__`controlDb`__ [ struct ]
> 
> Control database that will be subtracted form the `inputDb`; if omitted a
> steady-state databank for the `model` is created and used in the place of
> the control databank.
> 

## Output arguments 

__`outputData`__ [ struct ]
> 
> Simulation-minus-control database, in which all log variables are
> `inputDb.x/controlDb.x`, and all other variables are
> `inputDb.x-controlDb.x`.
> 

__`controlDb`__ [ struct ]
> 
> Control database that has been added to the `inputDb` database to
> create `outputDb`.
> 

## Options 

__`Range=Inf`__ [ Dater | `Inf` ]

> This range is used in two places:
> 
> * if a `controlDb` is not supplied, the `model` steady-state databank is
>   created with the `Range` input argument (meaning the control
>   databank will exist on this range plus any necessary presample and
>   postsample periods); if `opt.Range` refers to
>   `-Inf` or `Inf`, then the control databank is created on an
>   all-encompassing range of the `inputDb`.
> 
> * each `model` variable time series is clipped to the `Range` before
>   being included in the `outputDb`.
> 

## Description 


## Example 

