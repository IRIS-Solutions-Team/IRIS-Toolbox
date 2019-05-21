function d = templatedb(this)
% templatedb  Create model-specific template database
%
%
% __Syntax__
%
%     outputDatabank = templatedb(model)
%
%
% __Input Arguments__
%
%
% * `model` [ model ] - Model object for which the empty template
% database will be created.
%
%
% __Output Arguments__
%
% * `outputDatabank` [ struct ] - Empty database (a 0x0 struct)
% with a field for each model name (variables, shocks,
% parameters).
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2019 IRIS Solutions Team.

%--------------------------------------------------------------------------

d = createTemplateDbase(this.Quantity);

end%
