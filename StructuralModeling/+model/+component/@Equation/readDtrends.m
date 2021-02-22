function [eqn, pairing] = readDtrends(eqn, euc, qty)
% readDtrends  Read deterministic trends
%
% Backend [IrisToolbox] function
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

TYPE = @int8;
PTR = @int16;

%--------------------------------------------------------------------------

numEquations = numel(eqn.Input);
pairing = model.component.Pairing.initDtrend(numEquations);
inxD = eqn.Type==TYPE(3);
if ~any(inxD)
    return
end
inxY = qty.Type==TYPE(1);

% Create list of measurement variable names against which the LHS of
% dtrends equations will be matched. Add log(...) for log-variables.
listName = qty.Name;
inxLog = qty.IxLog;
listCompleteName = listName;
listCompleteName(inxLog) = strcat('log(', listCompleteName(inxLog), ')');
listName(~inxY) = {[ ]};
listCompleteName(~inxY) = {[ ]};

inxLogMissing = false(1, numEquations);
inxInvalid = false(1, numEquations);
inxMultiple = false(1, numEquations);
for i = find(inxD)
    inx = strcmp(listCompleteName, euc.LhsDynamic{i});
    if ~any(inx)
        if any(strcmp(listName, euc.LhsDynamic{i}))
            inxLogMissing(i) = true;
        else
            inxInvalid(i) = true;
        end
        continue
    end
    p = PTR(find(inx)); %#ok<FNDSB>
    if any(p==pairing)
        inxMultiple(i) = true;
    end
    pairing(i) = p;
end

if any(inxLogMissing)
    throw( ...
        exception.Base('Equation:LHS_VARIABLE_MUST_LOG_IN_DTREND', 'error'), ...
        eqn.Input{inxLogMissing} ...
    );
end
if any(inxInvalid)
    throw( ...
        exception.Base('Equation:INVALID_LHS_DTREND', 'error'), ...
        eqn.Input{inxInvalid} ...
    );
end
if any(inxMultiple)
    listMultiple = euc.LhsDynamic(inxMultiple);
    listMultiple = unique(listMultiple);
    throw( ...
        exception.Base('Equation:MULTIPLE_LHS_DTREND', 'error'), ...
        listMultiple{:} ...
    );
end

eqn.Dynamic(inxD) = euc.RhsDynamic(inxD);

end%

