---
title: min
---

# `min`

{== Define loss function for optimal policy ==}

## Syntax

    min(Disc) Expr;

## Syntax for exact non-linear simulations

    min#(Disc) Expr;

## Description

The loss function must be types as one of the transition equations. The
`Disc` is a parameter or an expression defining the discount factor
(applied to future dates), and the expression `Expr` defines the loss
fuction. The `Disc` expression must not contain a comma.

If you use the `min#(Disc)` syntax, all equations created by
differentiating the lagrangian w.r.t. individual variables will be
earmarked for exact nonlinear simulations provided the respective
derivative is nonzero. This only makes sense if the loss function is
other than quadratic, and hence its derivatives are nonlinear.

There are two types of optimal policy that can be calculated:
time-consistent discretionary policy, and time-inconsistent optimal
policy with commitment. Use the option `'optimal='` in the function
[`model`](model/model) at the time of loading the model file to switch
between these two types of policy; the option can be either
`'discretion'` (default) or `'commitment'`.

## Example

This is a simple model file with a Phillips curve and a quadratic loss
function.

    !transition-variables
        x, pi

    !transition-shocks
        u

    !parameters
        alpha, beta, gamma

    !transition-equations
        min(beta) pi^2 + lambda*x^2;
        pi = alpha*pi{-1} + (1-alpha)*pi{1} + gamma*y + u;




