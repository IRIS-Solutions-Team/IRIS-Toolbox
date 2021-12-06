# access

{== Access properties of Model objects ==}


## Syntax

    output = access(model, what)


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

__`fileName`__
> 
> Returns a string, or an array of strings, with the name(s) of model source
> files on which this model objects is based.
> 

__`preprocessor`__, __`postprocessor`__
> 
> Returns an array of Explanatory objects with the equations defined in thea
> `!preprocessor` or `!postprocessor` section of the model source.
> 



## Description


## Example


