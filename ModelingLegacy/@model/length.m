function n = length(this)
% length  Number of parameter variants within model object.
%
% ## Syntax ##
%
%     N = length(M)
%
%
% ## Input Arguments ##
%
% * `M` [ model | esteq ] - Model object.
%
%
% ## Output Arguments ##
%
% * `N` [ numeric ] - Number of parameter variants within the model object,
% `M`.
%
%
% ## Description ##
%
%
% ## Example ##
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2020 IRIS Solutions Team.

%--------------------------------------------------------------------------

n = length(this.Variant);

end%

