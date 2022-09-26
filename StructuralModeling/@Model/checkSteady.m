%{
% 
% # `checkSteady` ^^(Model)^^
% 
% {== Check if equations hold for currently assigned steady-state values ==}
% 
%}
% --8<--


% Type `web Model/checkSteady.md` for help on this function
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 IRIS Solutions Team

function [flag, dcy, list, sortedList] = checkSteady(this, varargin)

flag = NaN;
dcy = NaN;
list = NaN;
sortedList = NaN;

checkSteadyOptions = prepareCheckSteady(this, varargin{:});

if ~checkSteadyOptions.Run
    return
end

needsSort = nargout>3;
nv = countVariants(this);
this = refresh(this);

if checkSteadyOptions.Warning
    if lower(checkSteadyOptions.EquationSwitch)==lower("dynamic")
        chkQty(this, Inf, 'parameters:dynamic', 'sstate', 'log');
    else
        chkQty(this, Inf, 'parameters:steady', 'sstate', 'log');
    end
end

% `dcy` is a matrix of discrepancies; it has two columns when dynamic
% equations are evaluated, or one column when steady equations are
% evaluated.
[flag, dcy, maxAbsDiscr, list] = implementCheckSteady(this, Inf, checkSteadyOptions);

if any(~flag) && checkSteadyOptions.Error
    tmp = { };
    for i = find(~flag)
        for j = 1 : length(list{i})
            tmp{end+1} = exception.Base.alt2str(i); %#ok<AGROW>
            tmp{end+1} = list{i}{j}; %#ok<AGROW>
        end
    end
    if strcmpi(checkSteadyOptions.EquationSwitch, 'Dynamic')
        exc = exception.Base('Model:SteadyErrorInDynamic', 'error');
    else
        exc = exception.Base('Model:SteadyErrorInSteady', 'error');
    end
    throw(exc, tmp{:});
end

if needsSort
    sortedList = cell(1, nv);
    for iAlt = 1 : nv
        [~, ix] = sort(maxAbsDiscr(:, iAlt), 1, 'descend');
        dcy(:, :, iAlt) = dcy(ix, :, iAlt);
        sortedList{iAlt} = this.Equation.Input(ix);
    end
end

if nv==1
    list = list{1};
    if needsSort
        sortedList = sortedList{1};
    end
end

end%

