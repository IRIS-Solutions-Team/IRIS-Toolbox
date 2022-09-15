---
title: diffsrf
---

# `diffsrf` ^^(Model)^^

{== Differentiate shock response functions w.r.t. specified parameters ==}


## Syntax 

    outputDatabank = diffsrf(model, numOfPeriods, listOfParams, ...)
    outputDatabank = diffsrf(model, range, listOfParams, ...)

## Input arguments 

 `model` [ model ]
>
> Model object whose response functions will be
> simulated and differentiated.
>

 `range` [ numeric | char ] 
>
> Simulation date range with the first date
> being the shock date.
>

 `numOfPeriods` [ numeric ] 
> 
> Number of simulation periods.
> 

 `listOfParams` [ char | cellstr ] 
>
> List of parameters w.r.t. which the
> shock response functions will be differentiated.
>

## Output arguments 


    `outputDatabank` [ struct ]
> 
> Database with shock reponse derivatives 
> returned in multivariate time series.
>


## Options 

> 
> See [`model/srf`](model/srf) for options available
> 
## Description 



## Examples


