function f = freq(x)
% freq  Date frequency of tseries object.
%
% Syntax
% =======
%
%     F = freq(X)
%
%
% Input arguments
% ================
%
% * `X` [ tseries ] - Input tseries object.
%
%
% Output arguments
% =================
%
% * `F` [ `0` | `1` | `2` | `4` | `6` | `12` | `52` | `365` ] - Date
% frequency of observations in the input tseries object; `F` is the number
% of periods within a year.
%
%
% Description
% ============
%
% The `freq( )` function is equivalent to calling the `get( )` function:
%
%     get(x,'freq')
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

%--------------------------------------------------------------------------

f = DateWrapper.getFrequencyFromNumeric(x.start);

end
