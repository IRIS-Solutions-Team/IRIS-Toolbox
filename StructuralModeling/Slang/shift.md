# {...}

{== Lag or lead ==}

## Syntax

    VariableName{-lag}
    VariableName{lead}
    VariableName{+lead}

## Description

To create a lag or a lead of a variable, use a pair of curly brackets.

## Example

    !transition-equations
        x = rho*x{-1} + epsilon_x;
        pi = 1/2*pie{-1} + 1/2*pie{1} + gamma*y + epsilon_pi;
