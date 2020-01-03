function [eqn, pai] = readDtrends(eqn, euc, qty)
% readDtrends  Read deterministic trends.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2020 IRIS Solutions Team.

TYPE = @int8;
PTR = @int16;

%--------------------------------------------------------------------------

nEqtn = length(eqn.Input);
pai = model.component.Pairing.initDtrend(nEqtn);
ixd = eqn.Type==TYPE(3);
if ~any(ixd)
    return
end
ixy = qty.Type==TYPE(1);

% Create list of measurement variable names against which the LHS of
% dtrends equations will be matched. Add log(...) for log-variables.
lsName = qty.Name;
ixLog = qty.IxLog;
lsCompleteName = lsName;
lsCompleteName(ixLog) = strcat('log(', lsCompleteName(ixLog), ')');
lsName(~ixy) = {[ ]};
lsCompleteName(~ixy) = {[ ]};

ixLogMissing = false(1, nEqtn);
ixInvalid = false(1, nEqtn);
ixMultiple = false(1, nEqtn);
for i = find(ixd)
    ix = strcmp(lsCompleteName, euc.LhsDynamic{i});
    if ~any(ix)
        if any(strcmp(lsName, euc.LhsDynamic{i}))
            ixLogMissing(i) = true;
        else
            ixInvalid(i) = true;
        end
        continue
    end
    p = PTR(find(ix)); %#ok<FNDSB>
    if any(p==pai)
        ixMultiple(i) = true;
    end
    pai(i) = p;
end

if any(ixLogMissing)
    throw( exception.Base('Equation:LHS_VARIABLE_MUST_LOG_IN_DTREND', 'error'), ...
        eqn.Input{ixLogMissing} );
end
if any(ixInvalid)
    throw( exception.Base('Equation:INVALID_LHS_DTREND', 'error'), ...
        eqn.Input{ixInvalid} );
end
if any(ixMultiple)
    lsMultiple = euc.LhsDynamic(ixMultiple);
    lsMultiple = unique(lsMultiple);
    throw( exception.Base('Equation:MULTIPLE_LHS_DTREND', 'error'), ...
        lsMultiple{:} );
end

eqn.Dynamic(ixd) = euc.RhsDynamic(ixd);

end
