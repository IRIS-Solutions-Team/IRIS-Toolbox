function equation = readEquations(equation, euc)
% readEqtns  Post-parse measurement and transition equations.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

TYPE = @int8;

%--------------------------------------------------------------------------

nEqtn = numel(equation.Input);

ixm = equation.Type==TYPE(1);
ixt = equation.Type==TYPE(2);
ixmt = ixm | ixt;
if ~any(ixmt)
    return
end

dynamic = repmat({''}, 1, nEqtn);
steady = repmat({''}, 1, nEqtn);
for i = find(ixmt)
    dynamic{i} = combineLhsRhs(euc.LhsDynamic{i}, euc.RhsDynamic{i});
    if ~isempty(euc.RhsSteady{i})
        steady{i} = combineLhsRhs(euc.LhsSteady{i}, euc.RhsSteady{i});
    end
end

equation.Dynamic(ixmt) = dynamic(ixmt);
equation.Steady(ixmt) = steady(ixmt);
equation.IxHash(ixmt) = strcmp(euc.SignDynamic(ixmt), '=#');

return




    function eqtn = combineLhsRhs(lhs, rhs)
        if isempty(lhs)
            eqtn = rhs;
        else
            sign = '+';
            if any( rhs(1)=='+-' )
                sign = '';
            end
            eqtn = ['-[', lhs, ']', sign, rhs];
        end
    end
end
