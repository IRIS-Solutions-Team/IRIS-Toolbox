---
title: movprod
---

# `movprod`

{== Moving product pseudofunction ==}

## Syntax

    movprod(Expr)
    movprod(Expr,K)

## Description

If the second input argument, `K`, is negative, this function expands to
the moving product of the last K periods (including the current period),
i.e.

    ((Expr)*(Expr{-1})* ... *(Expr{-(K-1)})

where `Expr{-N}` derives from `Expr` and has all its time
subscripts shifted by `-N` (if specified).

If the second input argument, `K`, is positive, this function expands to
the moving product of the next K periods ahead (including the current
period), i.e.

    ((Expr)*(Expr{1})* ... *(Expr{K-1})

If the second input argument, `K`, is not specified, the default value -4
is used (based on the fact that most of the macroeconomic models are
quarterly).

## Example

The following three lines

    movprod(Z)
    movprod(Z,-3)
    movprod(X+Y{-1},2)

will expand to

    ((Z)*(Z{-1})*(Z{-2})*(Z{-3}))
    ((Z)*(Z{-1})*(Z{-2}))
    ((X+Y{-1})*(X{1}+Y))




