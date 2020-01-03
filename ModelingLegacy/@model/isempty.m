function flag = isempty(m)
% isempty  True for empty model object
%
% __Syntax__
%
%     flag = isempty(m)
%
%
% __Input Arguments__
%
% * `m` [ model ] - Model object.
%
%
% __Output Arguments__
%
% * `flag` [ `true` | `false` ] - True if the model object has zero
% parameter variants or contains no variables.
%
% 
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

%--------------------------------------------------------------------------

flag = length(m)==0 || isempty(m.Quantity);

end%

