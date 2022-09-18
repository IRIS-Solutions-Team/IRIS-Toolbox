---
title: assign
---

# `assign` ^^(Model)^^

{== Assign parameters, steady states, std deviations or cross-correlations ==}


## Syntax 

    [M, Assigned] = assign(M, P)
    [M, Assigned] = assign(M, N)
    [M, Assigned] = assign(M, Name, Value, Name, Value, ...)
    [M, Assigned] = assign(M, List, Values)

## Syntax for Fast Assign

    % Initialise
    assign(M, List);

    % Fast assign
    M = assign(M, Values);
    ...
    M = assign(M, Values);
    ...


## Input arguments 

__`M`__ [ model ]
> 
> Model object.
> 

__`P`__ [ struct ] 
> 
> Database whose fields refer to parameter
> names, variable names, std deviations, or cross-correlations.
> 

__`N`__ [ model ] 
> 
> Another model object from which all parameteres
> (including std erros and cross-correlation coefficients), and
> steady-states values will be assigned that match the name and type in
> `M`.
> 

__`Name`__ [ char ]
> 
> A parameter name, variable name, std
> deviation, cross-correlation, or a regular expression that will be
> matched against model names.
> 

__`Value`__ [ numeric ] 
> 
> A value (or a vector of values in case of
> multiple parameterisations) that will be assigned.
> 

__`List`__ [ cellstr ]
> 
> A list of parameter names, variable names, std
> deviations, or cross-correlations.
> 

__`Values`__ [ numeric ]
> 
> A vector of values.
> 

## Output arguments 

__`M`__ [ model ]
> 
> Model object with newly assigned parameters and/or
> steady states.
> 

__`Assigned`__ [ cellstr | `Inf` ] 
>  
> List of actually assigned parameter
> names, variables names (steady states), std deviations, and
> cross-correlations; `Inf` indicates that all values has been assigned
> from another model object.
> 


## Options 



## Description 


Calls with `Name`-`Value` or `List`-`Value` pairs throw an error if some
names in the list are not valid names in the model object. Calls with a
database, `P`, or another model object, `N`, do not perform this check.



## Examples


