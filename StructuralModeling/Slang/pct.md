---
title: pct
---

# `pct`

{== Percent change ==}


## Syntax

    pct(expression)
    pct(expression, k)


## Description

If the input argument `k` is not specified, this pseudofunction expands
to

    (100*((expression)/(expression{-1})-1))

If the input argument `k` is specified, it expands to

    (100*((expression)/(expression{k})-1))

The time-shifted expressions, `expression{-1}` and `expression{k}`, are
based on `expression`, and have all its time subscripts shifted by –1 or by
`k` periods, respectively.


## Examples

The following two lines

```iris
pct(z)
pct(x+y, -2)
```

will expand to

```iris
(100*((z)/(z{-1})-1))
(100*((x+y)/(x{-2}+y{-2})-1))
```

