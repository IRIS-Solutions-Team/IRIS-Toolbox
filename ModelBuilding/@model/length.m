function n = length(this)
% length  Number of parameter variants within model object.
%
% __Syntax__
%
%     N = length(M)
%
%
% __Input Arguments__
%
% * `M` [ model | esteq ] - Model object.
%
%
% __Output Arguments__
%
% * `N` [ numeric ] - Number of parameter variants within the model object,
% `M`.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

%--------------------------------------------------------------------------

n = length(this.Variant);

end
