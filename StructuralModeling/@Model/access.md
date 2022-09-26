---
title: access
---

# `access` ^^(Model)^^

{== Access properties of Model objects ==}


## Syntax

    output = access(model, what)
    output = model{what}


## Input arguments

__`model`__ [ Model ]
> 
> Model objects that will be queried about `what`.
> 

__`what`__ [ string ]
> 
> One of the valid queries into the model object properties listed below.
> 

## Output arguments

__`output`__ [ * ]
> 
> Response to the query about `what`.
> 

## Valid queries

__`"file-name"`__
> 
> Returns a string, or an array of strings, with the name(s) of model source
> files on which this model objects is based.
> 

__`"transition-variables"`__

__`"transition-shocks"`__

__`"measurement-variables"`__

__`"measurement-shocks"`__

__`"parameters"`__

__`"exogenous-variables"`__

> 
> Return a string array of all the names of the respective type in order of
> their apperance in the declaration sections of the source model file(s).
> 

__`"log-variables"`__
> 
> Returns the list of variables declared as 
> [`!log-variables`](../Slang/!log-variables.md).
> 

__`"log-status"`__
> 
> Returns a struct with `true` for all variables declared as
> [`!log-variables`](../Slang/!log-variables.md)
> and `false` for all other variables.
> 

__`"names-descriptions"`__
>
> Returns a struct with the desriptions strings for all model quantities
> (variables, shocks, parameters).
> 

__`"transition-equations"`__

__`"measurement-equations"`__

__`"measurement-trends"`__

__`"links"`__

> 
> Returns a vector of strings with all equations of the respective type.
> 

__`"equations-descriptions"`__
>
> Returns a struct with the desriptions strings for all model equations,
> ordered as follows: measurement equations, transition equations,
> measurement trends, links.
> 

__`"preprocessor"`__, __`"postprocessor"`__
> 
> Returns an array of Explanatory objects with the equations defined in thea
> `!preprocessor` or `!postprocessor` section of the model source.
> 

__`"parameter-values"`__ 
> 
> Returns a struct of all parameter values (not including std deviations or
> cross-correlation coefficients).
> 

__`"std-values"`__ 
> 
> Returns a struct of std deviations for all model shocks (transitory and
> measurement).
> 

__`"corr-values"`__
> 
> Returns a struct of cross-correlation coefficients for all pairs of
> transition shocks and all pairs of measurement shocks.
> 

__`"nonzero-corr-values"`__
> 
> Returns a struct of non-zero cross-correlation coefficients for all pairs
> of transition shocks and all pairs of measurement shocks.
> 


__`"steady-level"`__
> 
> Returns a struct with the steady-state levels of all model variables.
> 

__`"steady-change"`__
> 
> Returns a struct with the steady-state change (first difference or rate
> of change depending on the log status of each variables) for all model
> variables.
> 

__`"initials"`__
> 
> Returns a vector of strings listing all initial conditions necessary for
> a dynamic simulation.
> 

__`"stable-roots"`__

__`"unit-roots"`__

__`"unstable-roots"`__

> 
> Returns a vector of stable, unit o unstable eigenvalues, respectively.
> 

__`"max-lag"`__

__`"max-lead"`__

> 
> Returns the max lag or max lead occurring in the model equations.
> 

__`"stationary-status"`__

> 
> Returns a struct with `true` for all stationary variables, and `false`
> for all nonstationary variables.
> 

__`"transition-vector"`__

__`"measurement-vector"`__

__`"shocks-vector"`__

> 
> Returns a list of strings with the respective variables or shocks,
> including auxiliary lags and leads, as they appear in the rows of
> first order solution matrices.
> 

__`"forward-horizon"`__

> 
> Horizon for which the forwared expansion of the model solution has been
> calculated and is available in the model object.
> 


## Description


## Example


