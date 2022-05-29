function numVariants = length(this)
% length  Number of parameter variants in VAR object
%
% __Syntax__
%
%     N = length(V)
%
%
% __Input Arguments__
%
% * `V` [ VAR ] - VAR object.
%
% __Output Arguments__
%
% * `N` [ numeric ]  - Number of parameter variants in `V`.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

numVariants = size(this.A, 3);

end
