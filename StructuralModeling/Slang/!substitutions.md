# !substitutions

{== Define text substitutions ==}


## Basic syntax for defining substitutions

    !substitutions
        name1 := expression1;
        name2 := expression2;


## Basic syntax for using substitutions

    $name1$


## Syntax for including substitutions as preprocessing equations

Each substitution will be automatically added to
[`!preprocessor`](!preprocessor.md) equations

    !substitutions-preprocessor
        name3 := expression3;
        name4 := expression4;


## Syntax for including substitutions as postprocessing equations

Each substitution will be automatically added to
[`!postprocessor`](!postpreprocessor.md) equations

    !substitutions-postprocessor
        name5 := expression5;
        name6 := expression6;



## Description

The `!substitutions` starts a block with substitution definitions. The
definition of each substitution must begin with the name of the
substitution, followed by a colon-equal sign, `:=`, and a text string ended
with a semi-colon. The semi-colon is not part of the substitution.  Then,
each occurence of the name of a substitution enclosed in dollar signs, i.e.
`$name$`, will be replaced with the text string from the definition of the
respective substitution.

Some rules for using the substitutions:

* If more than one source file are specified, substitutions from one file
  are available in any other file as well.

* The right-hand-side expressions in the definitions of substitutions can
  refer to other substitutions; recursive definitions will, off course, not
  work.

* The substitutions are literal text substitutions; parenthesise the RHS
  expressions properly when using the substitutions in math expressions;
  see Examples below.

* If included in the preprocessor or postprocessor, the RHS expressions in
  the substitutions must also comply with the syntax of
  [@Explanatory](../explanatory/index.md) equations.


## Examples


### Using parentheses to preserve precendence of math operations

The following snippet of model source

```iris
!substitution
    a := ((omega1+omega2)/(omega1+omega2+omega3));

!transition-equations
    X = $a$^2*Y + (1-$a$^2)*Z;
```


will expand to the following expression

```iris
!transition-equations
    X = ((omega1+omega2)/(omega1+omega2+omega3))^2*Y + ...
      (1-((omega1+omega2)/(omega1+omega2+omega3))^2)*Z;
```

Note that the outermost parentheses are needed to preserve the intended
math expression.


### Substitutions included in preprocessor and/or postprocessor

The following snippet of model source 

```iris
!substitutions-postprocessor
    alpha := (a + b + c)/3;
```

is equivalent to this snippet

```iris
!substitutions
    alpha := (a + b + c)/3;

!postprocessor
    alpha = (a + b + c)/3;
```

or also to this ones

```
!substitutions
    alpha := (a + b + c)/3;

!postprocessor
    alpha = $alpha$;
```

