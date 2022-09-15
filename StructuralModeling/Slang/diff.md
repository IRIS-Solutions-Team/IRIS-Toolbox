---
title: diff
---

# `diff`

{== First difference pseudofunction ==}

## Syntax

    diff(Expr)
    diff(Expr,K)

## Description

If the input argument `K` is not specified, this pseudofunction expands to

    ((Expr)-(Expr{-1}))

If the input argument `K` is specified, it expands to

    ((Expr)-(Expr{K}))

The two derived expressions, `Expr{-1}` and `Expr{K}`, are
based on `Expr`, and have all its time subscripts shifted by --1 or
by `K` periods, respectively.

## Example

These two lines

    diff(Z)
    diff(log(X{1})-log(Y{-1}),-2)

will expand to

    ((Z)-(Z{-1}))
    ((log(X{1})-log(Y{-1}))-(log(X{-1})-log(Y{-3})))




