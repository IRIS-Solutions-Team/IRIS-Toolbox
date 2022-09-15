---
title: changeLogStatus
---

# `changeLogStatus` ^^(Model)^^

{==  Change log status of model variables ==}

## Syntax 

    model = changeLogStatus(model, newStatus, namesToChange)
    model = changeLogStatus(model, newStatus, name, name, ...)
    model = changeLogStatus(model, newStatusStruct)


## Input Arguments

__`model`__  [ Model ]  
> 
> Model object within which the log status of variables will be changed.
> 

__`newStatus`__ [ `true` | `false` ]  
> 
> New log status to which the selected variables will be changed.
> 

__`namesToChange`__ [ char | cellstr | string | `@all` ] 
> 
> List of variable names whose log status will be changed; `@all` means all
> measurement, transition and exogenous variables.
> 

__`name`__ [ char | string ]  
> 
> Variable name whose log status will be changed.
> 

__`newStatusStruct`__ [ struct ] 
> 
> Struct with fields named after the model variables, each assigned `true`
> or `false` for its new log status.
> 

## Output Arguments

__`status`__ [ logical ]  
> 
> Logical vector with the log status of the selected variables.
> 

__`model`__ [ Model ]  
> 
> Model object in which the log status of the selected variables has been
> changed to `newStatus`.
> 

## Description 


## Examples

