# <...>

{== Interpolate Matlab expression ==}

## Syntax

    <Expr>


## Description

The expression `Expr` enclosed within a pair of angle braces, `<...>`, is
evaluated as a Matlab expression, and converted to a character string.
The expression may refer to parameters passed into the function
[`model`](model/model), or to [`!for`](irislang/for) loop control
variable names. The expression must evaluate to a scalar number, a
logical scalar, or character string.


## Example

The following line of code

    pie{<K>}

which is assumed to be part of a model file named `my.model`, will expand
to

    pie{3}

in either of the following two calls to the function `model`:

    model('my.model','K=',3);

    P = struct( );
    P.K = 3;
    model('my.model','assign=',P);


## Example

The following [`!for`](irislang/for) loop

    !for
        < 2 : 4 >
    !do
        x? = x<?-1>{-1};
    !end

will expand to

    x2 = x1{-1};
    x3 = x2{-1};
    x4 = x3{-1};




