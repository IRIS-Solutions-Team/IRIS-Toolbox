function [variableNames, residualNames, fittedNames] = collectAllNames(this)
% collectAllNames  Collect all variable names, error names and fitted names from all equations
%
% Backend IRIS function
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2019 IRIS Solutions Team

%--------------------------------------------------------------------------

variableNames = unique([this.VariableNames], 'stable');
if nargout==1
    return
end

residualNames = unique([this.ResidualName], 'stable');
if nargout==2
    return
end

fittedNames = unique([this.FittedName], 'stable');

end%

