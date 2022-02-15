# !if

{== Choose a branch of code based on logical condition ==}

## Syntax with `else` and `elseif` clauses

    !if Condition1
        Block1
    !elseif Condition2
        Block2
    !elseif Condition3
    ...
    !else
        Block3
    !end

## Syntax with an else clause only

    !if Condition1
        Block1
    !else
        Block2
    !end

## Syntax without an else clause

    !if Condition
        Block1
    !end

## Description

The `!if` command works the same way as its
counterpart in the Matlab programming language.

Use the command to create multiple branches or versions of
the model source code. Whether a block of code in a particular branch is used or
discarded, depends on the condition after the opening `!if` command and
the conditions after subsequent `!elseif` commands if present. The
condition must be a Matlab expression that evaluates to true or false.
The condition can refer to model parameters, or to other fields included
in the database passed in through the option '`assign=`' in the
[`model`](model/model) function.

## Example

    !if B < Inf
        % This is a linearised sticky-price Phillips curve.
        pi = A*pi{-1} + (1-A)*pi{1} + B*log(mu*rmc);
    !else
        % This is a flexible-price mark-up rule.
        rmc = 1/mu;
    !end

If you set the parameter `B` to Inf in the parameter database when
reading in the model file, then the flexible-price equatio, `rmc = 0`, is
used and the Phillips curve equation discarded. To use the Phillips curve
equation instead, you need to re-read the model file with `B` set to a
number other than Inf. In this example, `B` needs to be, obviously,
declared as a model parameter.

## Example

    !if exogenous == true
        x = y;
    !else
        x = rho*x{-1} + epsilon;
    !end

When reading the model file in, create a parameter database, include at
least a field named `exogenous` in it, and use the `'assign='` option
to pass the database in. Note that you do not need to declare
`exogenous` as a parameter in the model file.

    P = struct( );
    P.exogenous = true;
    ...
    m = model('my.model','assign=',P);

In this case, the model will contain the first equation, `x = rho*x{-1} +
epsilon;` will be used, and the other discarded. To use the other
equation, `x = y`, you need to re-read the model file with
`exogenous` set to false:

    P = struct( );
    P.exogenous = false;
    ...
    m = model('my.model','assign=',P);

You can also use an abbreviate syntax to assign control parameters when
readin the model file; for instance

    m = model('my.model','exogenous=',true);




