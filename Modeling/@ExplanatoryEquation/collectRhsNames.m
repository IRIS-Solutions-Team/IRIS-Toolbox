function rhsNames = collectRhsNames(this)
% collectRhsNames  Collect names of variables that occur on RHS only
%{
% ## Syntax ##
%
%
%     rhsNames = collectRhsNames(this)
%
%
% ## Input Arguments ##
%
%
% __`this`__ [ ExplanatoryEquation ]
% >
% ExplanatoryEquation object or array whose variables that occur only on
% the RHS of equations will be collected.
%
%
% ## Output Arguments ##
%
%
% __`rhsNames`__ [ string ]
% >
% Names of the variables that occur only on the RHS of equations in `this`
% ExplanatoryEquation object or array.
%
%
% ## Description ##
%
%
% ## Example ##
%
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

%--------------------------------------------------------------------------

rhsNames = unique([this.VariableNames], 'stable');
rhsNames = setdiff(rhsNames, [this.LhsName], 'stable');

end%

