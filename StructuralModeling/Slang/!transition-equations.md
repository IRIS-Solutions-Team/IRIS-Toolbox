# !transition-equations

{== Block of transition equations ==}


## Syntax

    !transition-equations
        Equation1;
        Equation2;
        Equation2;
        ...

## Abbreviated syntax

    !equations
        Equation1;
        Equation2;
        Equation3;
        ...

## Syntax with equation labels

    !transition-equations
        Equation1;
        'Equation label' Equation2;
        Equation3;
        ...

## Description

The `!transition-equations` keyword starts a new block of transition
equations (i.e. endogenous equations); the equations can stretch over
multiple lines and must be separated by semi-colons. You can have as many
equation blocks as you wish in any order in your model file: They all
get combined together when you read the model file in.

You can add descriptive labels to the equations (in single or double
quotes, preceding the equation); these will be stored in, and
accessible from, the model object.

## Example

    !transition-equations
        'Euler equation' C{1}/C = R*beta;



