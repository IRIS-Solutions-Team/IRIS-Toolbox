---
title: movavg
---

# `movavg`

{== Moving geometric average pseudofunction ==}

## Syntax

    movgeom(Expr)
    movgeom(Expr,K)

## Description

If the second input argument, `K`, is negative, this function expands to
the moving geometric average of the last K periods (including the current
period), i.e.

    (((Expr)*(Expr{-1})* ... *(Expr{-(K-1)})^(1/-K))

where `Expr{-N}` derives from `Expr` and has all its time subscripts
shifted by `-N` (if specified).

If the second input argument, `K`, is positive, this function expands to
the moving geometric average of the next K periods ahead (including the
current period), i.e.

    (((Expr)*(Expr{1})* ... *(Expr{K-1})^(1/K))

If the second input argument, `K`, is not specified, the default value -4
is used (based on the fact that most of the macroeconomic models are
quarterly).

## Example

The following three lines

    movgeom(Z)
    movgeom(Z,-3)
    movgeom(X+Y{-1},2)

will expand to

    (((Z)*(Z{-1})*(Z{-2})*(Z{-3}))^(1/4))
    (((Z)*(Z{-1})*(Z{-2}))^(1/3))
    (((X+Y{-1})*(X{1}+Y))^(1/2))


