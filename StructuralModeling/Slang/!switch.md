
# !switch

{== Switch among several cases based on expression.==}


## Syntax with an otherwise clause

    !switch Expr
        !case Balue1
            Block1
        !case Balue2
            Block2
        ...
        !otherwise
            OtherwiseBlock
    !end

## Syntax without an otherwise clause

    !switch Expr
        !case Value1
            Block1
        !case Value2
            Block2
        ...
    !end

## Description

The `!switch...!case...!otherwise...!end` command works the same way as
its counterpart in the Matlab programming language.

Use the `!switch...!case...!end` command to create a larger number of
branches of the model code. Which block of code is actually read in and
which blocks are discarded depends on which value in the `!case` clauses
matches the value of the `!switch` expression. This works exactly as the
`switch...case...end` command in Matlab. The expression after the `!switch`
part of the command must must be a valid Matlab expression, and can refer
to the model parameters, or to other fields included in the parameter
database passed in when you run the [`model`](model/model) function;
see [the option `'assign='`](model/model).

If the expression fails to be matched by any value in the `!case`
clauses, the branch in the `!otherwise` clause is used. If it is a
`!switch` command without the `!otherwise` clause, the whole command is
discarded. The Matlab function `isequal` is used to match the `!switch`
expression with the `!case` values.

## Example

    !switch policy_regime
  
        !case 'IT'
            r = rho*r{-1} + (1-rho)*kappa*pie{4} + epsilon;
  
        !case 'Managed_exchange_rate'
            s = s{-1} + epsilon;
  
        !case 'Constant_money_growth'
            m-m{-1} = m{-1}-m{-2} + epsilon;
       
    !end

When reading the model file in, create a parameter database, include at
least a field named `policy_regime` in it, and use the option `'assign='`
to pass the database in. Note that you do not need to declare
`policy_regime` as a parameter in the model file.

    P = struct( );
    P.policy_regime = 'Managed_exchange_rate';
    ...
    m = model('my.model','assign',P);

In this case, the managed exchange rate policy rule, `s = s{-1} +
epsilon;` is read in and the rest of the `!switch` command is discarded.
To use another branch of the `!switch` command you need to re-read the
model file again with a different value assigned to the `policy_regime`
field of the input database.




