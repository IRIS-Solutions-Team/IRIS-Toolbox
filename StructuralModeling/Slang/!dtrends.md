# !dtrends

{== Block of deterministic trend equations ==}

## Syntax for linearised measurement variables

    !dtrends
        VariableName += Expression;
        VariableName += Expression;
        ...

## Syntax for log-linearised measurement variables

    !dtrends
        log(VariableName) += Expression;
        log(VariableName) += Expression;
        ...

## Syntax with equation labels

    !dtrends
        'Equation label' VariableName += Expression;
        'Equation label' LOG(VariableName) += Expression;

## Description

## Example

    !dtrends
        Infl += pi_;
        Rate += rho_ + pi_;




