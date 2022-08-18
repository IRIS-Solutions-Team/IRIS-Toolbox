
---
title: autoswaps
---

{== Inquire about or assign autoswap pairs ==}


## Syntax for Inquiring About Autoswap Pairs 

    a = autoswaps(model)

## Syntax for Assigning Autoswap Pairs

    model = autoswaps(model, a)

## Input arguments 

  `model` [ Model ]
> 
> Model object that will be inquired about autoswap pairs or assigned new
> autoswap pairs
> 

  `a` [ AutoswapStruct ] 
>
> AutoswapStruct object containing two substructs, `.Simulate` and
> `.Steady`. Each field in the substructs defines a variable/shock pair (in
> `.Simulate`), or a variable/parameter pair (in `.Steady`).
>


## Output arguments 

`model` [ Model ]
>
> Model object with the definitions of autoswap pairs newly assigned.
> 

  `a` [ AutoswapStruct ] 
>
> AutoswapStruct object containing two substructs, `.Simulate` and
> `.Steady`. Each field in the substructs defines a variable/shock pair (in
> `.Simulate`), or a variable/parameter pair (in `.Steady`).
>

## Options 


## Description 



## Examples

