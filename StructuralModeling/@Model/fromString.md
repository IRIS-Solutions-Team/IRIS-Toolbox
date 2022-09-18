---
title: Model.fromString
---

# `Model.fromString` ^^(Model)^^

{== Create new Model object from string array ==}


## Syntax

    m = Model.fromString(inputString, ...)


## Input arguments

__`inputString`__ [ string ]
> 
> Input string array whose elements will be joined as lines of model source
> codemodel source code.
> 

## Output arguments

__`m`__ [ Model ]
> 
> New Model object based on the `inputString`.
> 

## Options

> 
> The options are the same as in [`Model.fromFile`](fromFile.md).
> 

## Description


## Examples

```matlab
m = Model.fromString([
    "!variables x"
    "!shocks eps"
    "!parameters rho"
    "!equations x = rho*x{-1} + eps;"
], "linear", true);

m = solve(m);
m = steady(m);
```

