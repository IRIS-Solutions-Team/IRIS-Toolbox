---
title: difflog
---

# `difflog`

{== First log-difference pseudofunction ==}

## Syntax

    difflog(Expr)
    difflog(Expr,K)

## Description

If the input argument `K` is not specified, this pseudofunction expands
to

    (log(Expr)-log(Expr{-1}))

If the input argument `K` is specified, it expands to

    (log(Expr)-log(Expr{K}))

The two derived expressions, `Expr{-1}` and `Expr{K}`, are based on
`Expr`, and have all its time subscripts shifted by --1 or by `K`
periods, respectively.

## Example

The following two lines of code

    difflog(Z)
    difflog(X{1}/Y{-1},-2)

will expand to

    (log(Z)-log(Z{-1}))
    (log(X{1}/Y{-1})-log(X{-1}/Y{-3}))




