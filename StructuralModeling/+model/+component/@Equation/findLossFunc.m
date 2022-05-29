% findLossFunc  Find loss function equation and move them down to last position
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function [equation, euc, isLoss] = findLossFunc(equation, euc)

isLoss = false;
inxT = equation.Type==2;

%
% The loss function starts with `min(` or `min#(`. The equation must not
% contain an equal sign (i.e. the LHS must be empty).
%
inxMin0 = startsWith(euc.RhsDynamic, 'min(');
inxMinN = startsWith(euc.RhsDynamic, 'min#(');
inxLhsEmpty = cellfun(@isempty, euc.LhsDynamic);
inxMin = (inxMin0 | inxMinN) & inxLhsEmpty;

if any(inxMin & ~inxT)
    throw( exception.Base('Equation:LossFuncMustBeTransition', 'error') );
end

inxLoss = inxMin & inxT;

if sum(inxLoss)==1

    input = euc.RhsDynamic{inxLoss};
    isLoss = true;
    euc.LhsDynamic{inxLoss} = '';
    euc.RhsSteady{inxLoss} = '';
    euc.SignSteady{inxLoss} = '';
    euc.LhsSteady{inxLoss} = '';

    %
    % Mark nonlinear loss function. Remove min or min# from the equation; keep
    % the discount factor expression, including the parentheses, in since it
    % needs to be postparsed.
    %
    if any(inxMinN)
        euc.SignDynamic{inxLoss} = '=#';
        euc.RhsDynamic{inxLoss}(1:4) = '';
    else
        euc.SignDynamic(inxLoss) = {''};
        euc.RhsDynamic{inxLoss}(1:3) = '';
    end

    %
    % Check discount factor for being empty
    %
    close = textfun.matchbrk(euc.RhsDynamic{inxLoss});
    factor = strtrim(euc.RhsDynamic{inxLoss}(2:close-1));
    if isempty(factor)
        throw( ...
            exception.Base('Equation:LossFuncDiscountEmpty', 'error'), ...
            input ...
        ); %#ok<GTARG>
    end

    %
    % Move the loss function to last position within transition equations
    %
    posFrom = find(inxLoss, 1, 'first');
    posTo = find(inxT, 1, 'last');
    equation = move(equation, posFrom, posTo);
    euc = move(euc, posFrom, posTo);

elseif sum(inxLoss)>1

    throw( ...
        exception.Base('Equation:MultipleLossFunc', 'error') ...
    );

end

end%

