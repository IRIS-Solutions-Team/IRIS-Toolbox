function controlNames = collectControlNames(this)
% collectControlNames  Collect names of control parameters
%{
% ## Syntax ##
%
%
%     controlNames = collectControlNames(this)
%
%
% ## Input Arguments ##
%
%
% __`this`__ [ Explanatory ]
% >
% An Explanatory object or array from which all control parameter
% names will be collected.
%
%
% ## Output Arguments ##
%
%
% __`controlNames`__ [ string ]
% >
% List of all unique control parameter names, in order of their appearance
% in `this` Explanatory object or array.
%
%
% ## Description ##
%
%
% ## Example ##
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2019 [IrisToolbox] Solutions Team

%--------------------------------------------------------------------------

controlNames = unique([this.ControlNames], 'stable');

end%

