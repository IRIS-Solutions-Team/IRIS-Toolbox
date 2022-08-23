function asgn = readAssignments(equation, euc, quantity)

PTR = @int16;

numEquations = numel(equation.Input);
numQuantities = numel(quantity.Name);
asgn = model.Pairing.initAssignments(numEquations); % Initialize assignement struct.
inxM = equation.Type==1;
inxT = equation.Type==2;
inxMT = inxM | inxT;
if ~any(inxMT)
    return
end


%
% Equations written as assingments with a variable or a parameter (or its
% log, exp, uminus transformation) on the LHS
%
inxYXP = getIndexByType(quantity, 1, 2, 4);
listNames = repmat({''}, 1, numQuantities);
listNames(inxYXP) = quantity.Name(inxYXP);
allBlazerTypes = enumeration('solver.block.Type');
numAssignTypes = numel(allBlazerTypes);
listAssigns = cell(1, numAssignTypes);
for i = 1 : numAssignTypes
    type = allBlazerTypes(i);
    listAssigns{i} = strcat(type, listNames);
end

for eq = find(inxMT)
    [asgn.Dynamic.Lhs(eq), asgn.Dynamic.Type(eq)] = hereTestEquation(euc.LhsDynamic{eq}, euc.RhsDynamic{eq});
    if ~isempty(euc.RhsSteady{eq})
        [asgn.Steady.Lhs(eq), asgn.Steady.Type(eq)] = hereTestEquation(euc.LhsSteady{eq}, euc.RhsSteady{eq});
    else
        asgn.Steady.Lhs(eq) = asgn.Dynamic.Lhs(eq);
        asgn.Steady.Type(eq) = asgn.Dynamic.Type(eq);
    end
end

return

    function [ptr, type] = hereTestEquation(lhs, rhs)
        % First, try to match the LHS of the equation with on of the
        % possible transformation of all possible variables. If a match is
        % found, check that the variable itself does not occur on the RHS
        % of the equation.
        %(
        ptr = PTR(0);
        type = solver.block.Type.UNKNOWN;
        if isempty(lhs)
            return
        end

        for ii = 1 : numel(listAssigns)
            if isempty(listAssigns{ii})
                continue
            end
            inxName = strcmp(listAssigns{ii}, lhs);
            if ~any(inxName)
                continue
            end
            if any(inxName)
                name = listNames{inxName};
                if isempty(regexp(rhs, ['\<', name, '\>'], 'Once'))
                    type = allBlazerTypes(ii);
                    ptr = PTR( find(inxName) ); %#ok<FNDSB>
                end
            end
        end
        %)
    end%
end%

