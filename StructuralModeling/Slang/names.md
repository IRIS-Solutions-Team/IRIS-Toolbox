
# Declaring model names

{== Declare names of model quantities: Variables, shocks, parameters ==}

Each model quantity (variable, shock, parameter) needs to be declared, i.e.
listed under an appropriate heading. Model source code can contain the following types of model names

Model name type | Keyword | Remark
---|---|---
Transition variables | `!transition-variables` | May be abbreviated to `!variables`
Transition shocks | `!transition-shocks` | May be abbreviated to `!shocks`
Measurement variables | `!measurement-variables` | 
Measurement shocks | `!measurement-shocks` | 
Parameters | `!parameters` |
Exogenous variables | `!exogenous-variables` | May only be used in `!dtrends` equations


## Syntax

List the names under the respective keyword. The names are
separated by white spaces, commas or semicolons, and may be given
optional annotations. An annotation is enclosed in double quotes and
immediately precedes the respective name.

    !transition-variables
        variableName, variableName, ...
        "Description of the variable" variableName
        ...


## Example: Declare transition variables

The following section declares three variables, `pie`, `y`, and `re`

```iris
!transition-variables
    pie, "Real output" y
    "Real exchange rate" re
```


## Example: Split declaration

Declaration of a particular type of model names can be split into any
number of sections (as long as each model name is declared only once). The
following snippet is equivalent to the previous example:

```iris
!transition-variables
    pie

!transition-variables
    "Real output" y

!transition-variables
    "Real exchange rate" re
```

This is useful when you use some of the control structures, such as
[`!if`](!if.md), [`!switch.md`](!switch.md), or [`!for`](!for.md), or when you
split the model source code into multiple source files.

