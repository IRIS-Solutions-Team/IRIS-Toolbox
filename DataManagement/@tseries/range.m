function r = range(x)
% range  Date range from the first to the last available observation.
%
% Syntax
% =======
%
%     rng = range(x)
%
%
% Input arguments
% ================
%
% * `x` [ Series ] - Time series.
%
%
% Output arguments
% =================
%
% * `rng` [ numeric ] - Vector of IRIS serial date numbers representing the
% range from the first to the last available observation in the input
% tseries.
%
%
% Description
% ============
%
% The `range` function is equivalent to calling
%
%     get(x, 'range')
%
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

if isempty(x.Data)
    r = zeros(0, 1);
else
    r = x.Start : (x.Start + size(x.Data, 1) - 1);
end
r = DateWrapper(r);

end
