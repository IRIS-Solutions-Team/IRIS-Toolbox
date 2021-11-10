# || 

{== Separate alias from the rest of name or equation description ==}

## Syntax in name descriptions

    "Description || Alias" name


## Syntax in equation labels

    "Description || Alias" equation;


## Description

When used in descriptions of variables, shocks, and parameters, or in
equation labels, the double exclamation mark starts an alias (but the
exlamation marks are not included in it). The alias can be used to
specify, for example, a LaTeX code associated with the variable, shock,
parameter, or equation. The aliases can be retrieved from the model code
by using the appropriate query in the function
[`Model/access`](../model/access.md).


## Example

Based on this snippet of a model source file,

```iris
!transition-variables
    "Output gap || $\hat y_t$" y_gap
```

in the resulting model object, the description of the variable `y_gap`
will be "Output gap" while its alias will be "$\hat y_t$".

