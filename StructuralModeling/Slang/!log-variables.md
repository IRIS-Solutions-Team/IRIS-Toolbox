---
title: !log-variables
---

# !log-variables

{== List of logarithmized variables ==}


## Syntax

    !log-variables
        variableName, variableName, 
        variableName, ...


## Inverted syntax

    !log-variables !all-but
        variableName, variableName, 
        variableName, ...


## Description

List all log variables under this headings. Only measurement or
transition variables can be declared as log variables.

In non-linear models, all variables are linearized around the steady
state or a balanced-growth path. If you wish to log-linearise some of
them instead, put them on a `!log-variables` list. You can also use the
`!all-but` keyword to indicate an inverse list: all variables will be
log-linearized except those listed.


## Example

The following block of code will cause the variables `Y`, `C`, `I`, and
`K` to be declared as log variables, and hence log-linearized in the
model solution, while `r` and `pie` will be linearized:

    !transition-variables
        Y, C, I, K, r, pie

    !log-variables
        Y, C, I, K

You can do the same job by writing

    !transition-variables
        Y, C, I, K, r, pie

    !log-variables
        !all-but
        r, pie

