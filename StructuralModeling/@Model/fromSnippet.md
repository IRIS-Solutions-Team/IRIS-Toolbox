---
title: Model.fromSnippet
---

# `Model.fromSnippet` ^^(Model)^^

{== Create new Model object from snippet of code within m-file ==}


## Syntax

    m = Model.fromSnippet(snippetName, ...)


## Input arguments

__`snippetName`__ [ string ]
> 
> Name(s) of snippet(s) of code embedded in the same m-file as the call to
> this function.
> 

## Output arguments


__`m`__ [ Model ]
> 
> New Model object based on the snippet(s) of code.
> 

## Options

> 
> The options are the same as in [`Model.fromFile`](fromFile.md).
> 

## Description

The snippet of model source code is placed within the very m-file (script
or function) from where the `Model.fromSnippet` is called. In that
file, the snippet needs to be enclosed within Matlab block comment signs,
and inside those, within a start and and end mark as follows:

```matlab
%{
snippetName>>>
...
... % Here goes the model source code
...
<<<snippetName 
%}
```

Note there is no space between the name of the snippet and the start and
end markes, `>>>` and `<<<`, respectively.

The snippet can be placed anywhere in the m-file, before or after the
`Model.fromSnippet` function.


## Examples

```matlab
m = Model.fromSnippet("example", Linear=true);
m.rho_x = 0.8;

%{
example>>>
    !variables
        x
    !parameters
        rho_x
    !shocks
        eps_x
    !equations
        x = rho_x*x{-1} + eps_x;
<<<example
%}

m = solve(m);
m = steady(m);
```

