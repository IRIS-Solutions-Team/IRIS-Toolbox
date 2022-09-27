---
title: databank.eval
---

# `databank.eval` ^^(+databank)^^

{== Evaluate an expression within a databank context ==}


## Syntax

    [output, output, ...] = databank.eval(inputDb, expression, expression, ...)
    outputs = databank.eval(inputDb, expressions)
    outputDb = databank.eval(inputDb, expressionsDb)


## Input arguments


__`inputDb`__ [ struct | Dictionary ]
> 
> Input databank whose fields constitute a workspace in which the
> expressions will be evaluated.%
> 

__`expression`__ [ char | string ]
> 
> Text string with an expression that will be evaluated in the workspace
> consisting of the `inputDb` fields.
> 

__`expressions`__ [ cellstr | string ]
> 
> Cell array of char vectors or string array (more than one element) with
> expressions that will be evaluated in the workspace consisting of the
> `inputDb` fields.
> 

__`expressionsDb`__ [ struct | Dictionary ]
> 
> Databank whose fields contain the expressions that are to be evaluated.
> 


## Output arguments


__`output`__ [ * ]
> 
> Result of the `expression` evaluated in the `inputDb` workspace.
> 


__`outputs`__ [ cell ]
> 
> Results of the `expressions` evaluated in the `inputDb` workspace.
> 


__`outputDb`__ [ struct | Dictionary ]
> 
> Output databank with the results of the expressions evaluated in the
> `inputDb` workspace.
> 


## Description

Any names, including dot-separated composite names, not immediately
followed by an opening parenthesis (round bracket), are treated as
`inputDb` fields. Dot=separated composite names are therefore
considered to be fields of databanks nested withing the `inputDb`.


Any names, including dot-separated composite names, immediately followed
by an opening parenthesis (round bracket), are considered calls to
functions, and not treated as `inputDb` fields.


To include round-bracket references to `inputDb` fields (such as
references to elements of arrays), include an extra space between the
name and the opening parenthesis.


## Example

```matlab
d = struct( );
d.aaa = [1, 2, 3];
databank.eval('10*aaa(2)')
```

will fail with a Matlab error unless there is function named `aaa`
existing in the current workspace. This is because `aaa(2)` is considered
to be a call to a function named `aaa`, and not a reference to the field
existing in the databank `d`.


To refer the second element of the field `aaa`, include an extra space between `aaa` and `(` 

```matlab
 databank.eval('10*aaa (2)')
```

