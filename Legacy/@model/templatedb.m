function d = templatedb(this)
% templatedb  Create model-specific template database
%
%
% ## Syntax ##
%
%     outputDatabank = templatedb(model)
%
%
% ## Input Arguments ##
%
%
% * `model` [ model ] - Model object for which the empty template
% database will be created.
%
%
% ## Output Arguments ##
%
% * `outputDatabank` [ struct ] - Empty database (a 0x0 struct)
% with a field for each model name (variables, shocks,
% parameters).
%
%
% ## Description ##
%
%
% ## Example ##
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

d = createTemplateDbase(this.Quantity);

end%
