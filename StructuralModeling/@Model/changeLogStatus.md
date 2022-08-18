
---
title: changeLogStatus
---


{==  Change log status of model variables ==}

## Syntax 

    model = changeLogStatus(model, newStatus, namesToChange)
    model = changeLogStatus(model, newStatus, name, name, ...)
    model = changeLogStatus(model, newStatusStruct)


## Input Arguments

**`model`**  [ Model ]  
>
> Model object within which the log status of variables will be changed.
>

**`newStatus`** [ `true` | `false` ]  
>
> New log status to which the selected variables will be changed.
>

**`namesToChange`** [ char | cellstr | string | `@all` ] 
> 
> List of variable names whose log status will be changed; `@all` means all
> measurement, transition and exogenous variables.
>

**`name`** [ char | string ]  
> 
> Variable name whose log status will be changed.
>

**`newStatusStruct`** [ struct ] 
>
>Struct with fields named after the model variables, each assigned `true`
>or `false` for its new log status.
>

## Output Arguments

**`status`** [ logical ]  
>
> Logical vector with the log status of the selected variables.
>

**`model`** [ Model ]  
>
> Model object in which the log status of the selected variables has been
> changed to `newStatus`.
>

## Description 


## Examples

