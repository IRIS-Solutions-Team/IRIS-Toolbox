# !for

{== For-loop control structure for automated creation of model source code ==}


## Abbreviated syntax (cannot be nested)

In the abbreviated syntax, the control name is simply `?`

    !for tokens !do
        template
    !end


## Full syntax

    !for ?controlName = tokens !do
        template
    !end


## Full syntax with Matlab expression

    !for ?controlName = <matlab> !do
        template
    !end


## Description

Use the `!for` control structure to specify a template and let the
Iris preparser automatically create multiple instances of the template by
iterating over a list of tokens. The preparser cycles over the individual
strings from the list; in each iteration, the current string is used to
replace all occurences of the control variable in the template. The name
of the control name is either implicitly a question mark, `?`, in the
abbreviated syntax, or any string starting with a question mark and not
containing blank spaces, question marks (other than the leading question
mark), colons or periods; for example, `?x`, `?#`, `?NAME+`.

The tokens (text strings) in the list must be separated by commas, blank
spaces, or line breaks and they themselves must not contain any of those.
In each iteration,

* all occurrences of the control variable in the template are replaced
with the currently processed token;

* all occurrences in the template of `?.controlName`  are
replaced with the currently processed token converted to lower case;
this option is NOT available with the abbreviated syntax;

* all occurrences in the template of `?:controlName`  are
replaced with the currently processed token converted to upper case;
this option is NOT available with the abbreviated syntax;

The list of tokens can be based on Matlab expressions [Matlab
expressions](evaluate.md) that evaluates to a list of strings: Enclose an expression in a pair of angle braces,
`<...>`. The expression must evaluate to either a numeric vector, a char
vector, a string vetor, or a cell array of numerics and/or strings; the
value will be then converted to a comma-separted list of strings.


## Examples

### Automate similar equations

In a model sourc file, instead of writing a number of definitions of
growth rates like the following ones

```iris
dP = P/P{-1} - 1;
dW = W/W{-1} - 1;
dX = X/X{-1} - 1;
dY = Y/Y{-1} - 1;
```

can use the `!for` control structure as follows:

```iris
!for P, W, X, Y !do
    d? = ?/?{-1} - 1;
!end
```


### Also with declarations

We redo the previous example, but using now the fact that you can have as
many variable declaration sections or equation sections as you wish. The
`!for` control structure can therefore not only produce the equations for
you, but also declare the respectie variables.

```
!for P, W, X, Y !do
    !transition_variables
        d?
    !transition_equations
        d? = ?/?{-1} - 1;
!end
```


The preparser expands this structure as follows:

```iris
!transition_variables
    dP
!transition_equations
    dP = P/P{-1} - 1;
!transition_variables
    dW
!transition_equations
    dW = W/W{-1} - 1;
!transition_variables
    dX
!transition_equations
    dX = X/X{-1} - 1;
!transition_variables
    dY
!transition_equations
    dY = Y/Y{-1} - 1;
```


## Switch lower/upper case as needed 

In a model source file, instead of writing a number of autoregression 
processes like the following ones

    X = rhox*X{-1} + ex;
    Y = rhoy*Y{-1} + ey;
    Z = rhoz*Z{-1} + ez;

use a `!for` control structure as follows changing the lower/upper case of
the tokens as needed:

```iris
!for
    ?# = X, Y, Z
!do
    ?# = rho?.#*?{-1} + e?.#;
!end
```


## Example

Redo the previous example, but now for six variables named `A1`, `A2`, `B1`,
`B2`, `C1`, `C2`, nesting two `!for` control structures one within
the other:

```
!for ?letter = A, B, C !do
    !for ?number = 1, 2 !do
        ?letter?number = rho?.letter?number * ?letter?number{-1} e?.letter?number;
    !end
!end
```

The preparser produces the following six equations:

```iris
A1 = rhoa1*A1{-1} + ea1;
A2 = rhoa2*A2{-1} + ea2;
B1 = rhob1*B1{-1} + eb1;
B2 = rhob2*B2{-1} + eb2;
C1 = rhoc1*C1{-1} + ec1;
C2 = rhoc2*C2{-1} + ec2;
```

### Use Matlab expressions

We use a Matlab expression (the colon operator) to simplify the list of
tokens. The following block of code


```iris
!for 1, 2, 3, 4, 5, 6, 7 !do
    a? = a?{-1} + res_a?;
!end
```

can be simplified as follow:

```iris
!for <1 : 7> !do
    a? = a?{-1} + res_a?;
!end
```

or generalized with the use of Matlab variable name supplied through the
option `assign=` when [reading the model source file](../@Model/fromFile.md).

```iris
!for <1 : N> !do
    a? = a?{-1} + res_a?;
!end
```


