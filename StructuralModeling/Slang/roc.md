---
title: roc
---

# `roc`

{== Gross rate of change pseudofunction ==}


## Syntax

    roc(expression)
    roc(expression, k)


## Description

If the input argument `k` is not specified, this pseudofunction expands
to

    ((expression)/(expression{-1}))

If the input argument `k` is specified, it expands to

    ((expression)/(expression{k}))

The time-shifted expressions, `expression{-1}` and `expression{k}`, are
based on `expression`, and have all its time subscripts shifted by –1 or
by `k` periods, respectively.


## Examples

The following two lines

```iris
roc(z)
roc(x+y,-2)
```

will expand to

```iris
((Z)/(Z{-1}))
((X+Y)/(X{-2}+Y{-2}))
```

