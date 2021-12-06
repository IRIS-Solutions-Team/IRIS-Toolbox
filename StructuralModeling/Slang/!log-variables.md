# !log-variables

{== List of log-linearised variables ==}

## Syntax

    !log-variables
        VariableName, VariableName, 
        VariableName, ...


## Syntax with inverted list

    !log-variables
        !all-but
        VariableName, VariableName, 
        VariableName, ...


## Syntax with regular expression(s)

    !log-variables
        VariableName, VariableName, 
        VariableName, ...


## Description

List all log variables under this headings. Only measurement or
transition variables can be declared as log variables.

In non-linear models, all variables are linearised around the steady
state or a balanced-growth path. If you wish to log-linearise some of
them instead, put them on a `!log-variables` list. You can also use the
`!all-but` keyword to indicate an inverse list: all variables will be
log-linearised except those listed.


## Example

The following block of code will cause the variables `Y`, `C`, `I`, and
`K` to be declared as log variables, and hence log-linearised in the
model solution, while `r` and `pie` will be linearised:

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




