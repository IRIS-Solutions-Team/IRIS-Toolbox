% collectAllNames  Collect all variable names, error names and fitted names from all equations
%{
% ## Syntax ##
%
%
%     [variableNames, residualNames, fittedNames = collectAllNames(this)
%
%
% ## Input Arguments ##
%
%
% __`this`__ [ Explanatory ]
% >
% Explanatory object or array whose variable names, residual names
% and fitted names will be returned.
%
%
% ## Output Arguments ##
%
%
% __`variableNames`__ [ string ]
% >
% List of all variable names, both LHS and RHS variables, that occur in
% `this` Explanatory object or array; each name is listed only once
% even if it occurs in multiple equations.
%
%
% __`residualNames`__ [ string ]
% >
% List of residual names associated with all equations in `this`
% Explanatory object or array.
%
%
% __`fittedNames`__ [ string ]
% >
% List of fitted names associated with all equations in `this`
% Explanatory object or array.
%
%
% ## Description ##
%
%
% ## Example ##
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2019 IRIS Solutions Team

function [variableNames, residualNames, fittedNames, controlNames] = collectAllNames(this)

variableNames = unique([this.VariableNames], 'stable');
if nargout<=1
    return
end

residualNames = unique([this.ResidualName], 'stable');
if nargout<=2
    return
end

fittedNames = unique([this.FittedName], 'stable');
if nargout<=3
    return
end

controlNames = collectControlNames(this);

end%

