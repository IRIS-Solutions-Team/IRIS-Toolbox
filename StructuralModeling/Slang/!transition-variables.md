# `!transition-variables | !variables`

{== List of transition variables ==}


## Syntax

The keyword `!transition-variables` can be abbreviated to `!variables`

    !transition-variables
        variableName, variableName, ...
        "Description of the variable" variableName
        ...


## Description

The `!transition-variables` keyword starts a new declaration block for
transition variables (i.e. endogenous variables); the names of the
variables must be separated by commas, semi-colons, or line breaks. You
can have as many declaration blocks as you wish in any order in your
model file: They all get combined together when you read the model file
in. Each variable must be declared (exactly once).

You can add descriptors to the variables (enclosed in single or double
quotes, preceding the name of the variable); these will be stored in, and
accessible from, the model object.


## Example

```iris
    !transition-variables
        pie, "Real output" y
        "Real exchange rate" re
```

