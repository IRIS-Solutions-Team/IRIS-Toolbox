# %{...%}

{== Block comments ==}


## Syntax

    %{ ...
    ...
    ... %}


## Description

Anything between the opening block comment sign, `%{`, and the closing block
comment sign, `%}`, is discarded.

Unlike in Matlab, the opening and closing block comment signs do not need
to stand alone on otherwise blank lines. You can even have block comments
contained within a single line.

## Example

```iris
    !transition_equations
        x = rho*x{-1} %{ this is a valid block comment %} + epsilon;
```


