function n = length(this)
% length  Number or priors in system priors object.
%
% __Syntax__
%
%     N = length(S)
%
%
% __Input Arguments__
%
% * `S` [ systempriors ] - System priors,
% [`systempriors`](systempriors/Contents) object.
%
%
% __Output Arguments__
%
% * `N` [ numeric ] - Number of priors imposed in the system priors object,
% `S`.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

n = length(this.Eval);

end
