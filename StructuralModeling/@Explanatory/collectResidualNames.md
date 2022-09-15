---
title: collectLhsNames
---

# `collectLhsNames`

{== Collect names of LHS variables ==}


## Syntax

    residualNames = collectRhsNames(this)


## Input Arguments

__`this`__ [ Explanatory ]
> 
> Explanatory object or array from which the names of all residuals will be
> collected and returned.
> 

## Output Arguments

__`residualNames`__ [ string ]
> 
> The names of all residuals collected from `this` Explanatory object or array.
> 

## Description


## Examples

```matlab
x = Explanatory.fromString(["a = a{-1}", "b = a + c"]);
collectResidualNames(x)
```

```
ans =
  1x2 string array
    "res_a"    "res_b"
```

```matlab
x = Explanatory.fromString(["a = a{-1}", "b = a + c"]);
x(1).ResidualNamePattern = ["shock_", "_f2"];
collectResidualNames(x)
```

```
ans =
  1x2 string array
    "shock_a_f2"    "res_b"
```

