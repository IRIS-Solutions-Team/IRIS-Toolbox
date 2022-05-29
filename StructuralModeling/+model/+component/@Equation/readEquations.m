% readEqtns  Post-parse measurement and transition equations
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function equation = readEquations(equation, euc)

numEquations = numel(equation.Input);

inxM = equation.Type==1;
inxT = equation.Type==2;
inxL = equation.Type==4;
inxMTL = inxM | inxT | inxL;
if ~any(inxMTL)
    return
end

dynamic = repmat({''}, 1, numEquations);
steady = repmat({''}, 1, numEquations);
for i = find(inxMTL)
    dynamic{i} = hereCombineLhsRhs(euc.LhsDynamic{i}, euc.RhsDynamic{i});
    if ~isempty(euc.RhsSteady{i})
        steady{i} = hereCombineLhsRhs(euc.LhsSteady{i}, euc.RhsSteady{i});
    end
end

equation.Dynamic(inxMTL) = dynamic(inxMTL);
equation.Steady(inxMTL) = steady(inxMTL);
equation.IxHash(inxMTL) = strcmp(euc.SignDynamic(inxMTL), '=#');

return

    function eqtn = hereCombineLhsRhs(lhs, rhs)
        if isempty(lhs)
            eqtn = rhs;
        else
            sign = '+';
            if any( rhs(1)=='+-' )
                sign = '';
            end
            eqtn = ['-[', lhs, ']', sign, rhs];
        end
    end%
end%

