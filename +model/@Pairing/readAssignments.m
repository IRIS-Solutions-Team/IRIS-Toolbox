function asgn = readAssignments(equation, euc, quantity)

TYPE = @int8;
PTR = @int16;

%--------------------------------------------------------------------------

ixm = equation.Type==TYPE(1);
ixt = equation.Type==TYPE(2);
ixmt = ixm | ixt;
if ~any(ixmt)
    return
end

nEqn = numel(equation.Input);
nQty = numel(quantity.Name);

% Equations written as assingments with a variable (or a log, exp, uminus
% transformation) on the LHS.
ixy = quantity.Type==TYPE(1);
ixx = quantity.Type==TYPE(2);
ixyx = ixy | ixx;
lsName = repmat({''}, 1, nQty);
lsName(ixyx) = quantity.Name(ixyx);
allBlazerType = enumeration('solver.block.Type');
nAssignType = numel(allBlazerType);
lsAssign = cell(1, nAssignType);
for i = 1 : nAssignType
    type = allBlazerType(i);
    lsAssign{i} = strcat(type, lsName);
end

% Initialize assignement struct.
asgn = model.Pairing.initAssignment(nEqn);

for i = find(ixmt)
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
        for ii = 1 : length(lsAssign)
            if isempty(lsAssign{ii})
                continue
            end
            ix = strcmp(lsAssign{ii}, lhs);
            if any(ix)
                type = allBlazerType(ii);
                ptr = PTR( find(ix) ); %#ok<FNDSB>
                break
            end
        end
    end
end
