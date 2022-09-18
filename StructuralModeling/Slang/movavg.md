---
title: movavg
---

# `movavg`

{== Moving average pseudofunction ==}

## Syntax

    movavg(Expr)
    movavg(Expr,K)

## Description

If the second input argument, `K`, is negative, this function expands to
the moving average of the last K periods (including the current period),
i.e.

    (((Expr)+(Expr{-1})+ ... +(Expr{-(K-1)})/-K)

where `Expr{-N}` derives from `Expr` and has all its time subscripts
shifted by `-N` (if specified).

If the second input argument, `K`, is positive, this function expands to
the moving average of the next K periods ahead (including the current
period), i.e.

    (((Expr)+(Expr{1})+ ... +(Expr{K-1})/K)

If the second input argument, `K`, is not specified, the default value -4
is used (based on the fact that most of the macroeconomic models are
quarterly).

## Example

The following three lines

    movavg(Z)
    movavg(Z,-3)
    movavg(X+Y{-1},2)

will expand to

    (((Z)+(Z{-1})+(Z{-2})+(Z{-3}))/4)
    (((Z)+(Z{-1})+(Z{-2}))/3)
    (((X+Y{-1})+(X{1}+Y))/2)




