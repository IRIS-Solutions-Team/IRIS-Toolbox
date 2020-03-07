function asgn = readAssignments(equation, euc, quantity)

TYPE = @int8;
PTR = @int16;

%--------------------------------------------------------------------------

numEquations = numel(equation.Input);
numQuantities = numel(quantity.Name);
asgn = model.component.Pairing.initAssignment(numEquations); % Initialize assignement struct.
ixm = equation.Type==TYPE(1);
ixt = equation.Type==TYPE(2);
inxMT = ixm | ixt;
if ~any(inxMT)
    return
end


%
% Equations written as assingments with a variable or a parameter (or its
% log, exp, uminus transformation) on the LHS
%
inxYXP = getIndexByType(quantity, TYPE(1), TYPE(2), TYPE(4));
listNames = repmat({''}, 1, numQuantities);
listNames(inxYXP) = quantity.Name(inxYXP);
allBlazerTypes = enumeration('solver.block.Type');
numAssignTypes = numel(allBlazerTypes);
listAssigns = cell(1, numAssignTypes);
for i = 1 : numAssignTypes
    type = allBlazerTypes(i);
    listAssigns{i} = strcat(type, listNames);
end

for i = find(inxMT)
    [asgn.Dynamic.Lhs(i), asgn.Dynamic.Type(i)] = testLhs(euc.LhsDynamic{i});
    if ~isempty(euc.RhsSteady{i})
        [asgn.Steady.Lhs(i), asgn.Steady.Type(i)] = testLhs(euc.LhsSteady{i});
    else
        asgn.Steady.Lhs(i) = asgn.Dynamic.Lhs(i);
        asgn.Steady.Type(i) = asgn.Dynamic.Type(i);
    end
end

return




    function [ptr, type] = testLhs(lhs)
        ptr = PTR(0);
        type = solver.block.Type.UNKNOWN;
        if isempty(lhs)
            return
        end
        for ii = 1 : length(listAssigns)
            if isempty(listAssigns{ii})
                continue
            end
            ix = strcmp(listAssigns{ii}, lhs);
            if any(ix)
                type = allBlazerTypes(ii);
                ptr = PTR( find(ix) ); %#ok<FNDSB>
                break
            end
        end
    end%
end%

