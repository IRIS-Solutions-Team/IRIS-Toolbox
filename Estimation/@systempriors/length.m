function N = length(This)
% length  Number or priors in system priors object.
%
% Syntax
% =======
%
%     N = length(S)
%
% Input arguments
% ================
%
% * `S` [ systempriors ] - System priors,
% [`systempriors`](systempriors/Contents) object.
%
% Output arguments
% =================
%
% * `N` [ numeric ] - Number of priors imposed in the system priors object,
% `S`.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

N = length(This.Eval);

end