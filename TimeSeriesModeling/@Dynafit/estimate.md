---
title: estimate
---

# `estimate`

{== Estimate Dynamo using static principal components ==}


## Syntax


    [a, outputDb, contribDb, range] = estimate(a, inputDb, range, [R, Q], ___) 


## Input arguments


__`a`__ [ Dynamo ]
> 
> Empty Dynamo object.
> 


__`inputDb`__ [ struct ]
> 
> Input database.
> 


__`range`__ [ numeric ]
> 
> Estimation range.
> 


__`R`__ [ numeric ]
> 
> Selection criterion for the number of factors:
> Minimum requested proportion of input data volatility explained by the
> factors

__`Q`__ [ numeric ]
> 
> Selection criterion for the number of factors:
> Maximum number of factors
> 


## Output arguments


__`A`__ [ Dynamo ] 
> 
> Estimated Dynamo object.
> 

__`outputDb`__ [ struct ]
> 
> Output database with the observed series, their common components
> (`common_?`), the estimates of the factors (`factor?`), the
> idiosyncratic residuals (`res_?`) and the factor residuals
> (`res_factor?`).
> 


__`contribDb`__ [ struct ] 
> 
> Contributions of the individual input series to the estimated factors.
> 


## Options


__`Cross=true`__ [ `true` | `false` | numeric ]
> 
> Keep off-diagonal
> elements in the covariance matrix of idiosyncratic residuals; if false
> all cross-covariances are reset to zero; if a number between zero and
> one, all cross-covariances are multiplied by that number
> 


__`Order=1`__ [ numeric ]
> 
> Order of the VAR for factors
> 


__`Rank=Inf`__ [ numeric ]
> 
> Restriction on the rank of the factor VAR residuals.
> 

## Description


## Examples


