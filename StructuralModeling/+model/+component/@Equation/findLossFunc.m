function [equation, euc, isLoss] = findLossFunc(equation, euc)
% findLossFunc  Find loss function equation and move them down to last position
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

TYPE = @int8;

%--------------------------------------------------------------------------

isLoss = false;
ixt = equation.Type==TYPE(2);

% The loss function starts with `min(` or `min#(`. The equation must not
% contain an equal sign (i.e. the LHS must be empty).
ixMin0 = strncmp(euc.RhsDynamic, 'min(', 4);
ixMinN = strncmp(euc.RhsDynamic, 'min#(', 5);
ixLhsEmpty = cellfun(@isempty, euc.LhsDynamic);
ixMin = (ixMin0 | ixMinN) & ixLhsEmpty;

if any(ixMin & ~ixt)
    throw( exception.Base('Equation:LossFuncMustBeTransition', 'error') );
end

ixLoss = ixMin & ixt;
if sum(ixLoss)==1
    input = euc.RhsDynamic{ixLoss};
    isLoss = true;
    euc.LhsDynamic{ixLoss} = '';
    euc.RhsSteady{ixLoss} = '';
    euc.SignSteady{ixLoss} = '';
    euc.LhsSteady{ixLoss} = '';
    % Mark nonlinear loss function. Remove min or min# from the equation; keep
    % the discount factor expression, including the parentheses, in since it
    % needs to be postparsed.
    if any(ixMinN)
        euc.SignDynamic{ixLoss} = '=#';
        euc.RhsDynamic{ixLoss}(1:4) = '';
    else
        euc.SignDynamic(ixLoss) = {''};
        euc.RhsDynamic{ixLoss}(1:3) = '';
    end
    % Check discount factor for being empty.
    close = textfun.matchbrk(euc.RhsDynamic{ixLoss});
    factor = strtrim(euc.RhsDynamic{ixLoss}(2:close-1));
    if isempty(factor)
        throw( ...
            exception.Base('Equation:LossFuncDiscountEmpty', 'error'), ...
            input ...
        ); %#ok<GTARG>
    end
    % Order the loss function last.
    posFrom = find(ixLoss, 1, 'first');
    posTo = find(ixt, 1, 'last');
    equation = move(equation, posFrom, posTo);
    euc = move(euc, posFrom, posTo);
    
elseif sum(ixLoss)>1
    throw( ...
        exception.Base('Equation:MultipleLossFunc', 'error') ...
    );

end

end
