function x = diff(x, shifts)
% diff  First difference
%{
% ## Syntax ##
%
% Input arguments marked with a `~` sign may be omitted
%
%     x = diff(x, ~shift)
%
%
% ## Input Arguments ##
%
% __`x`__ [ NumericTimeSubscriptable ] -
% Input time series.
%
% __`~shift`__ [ numeric ] - Number of periods over which the first difference
% will be computed; `y=x-x{shift}`; `shift` is a negative number
% for the usual backward differencing; if omitted, `shift=-1`.
%
%
% ## Output Arguments ##
%
% __`x`__ [ NumericTimeSubscriptable ] -
% First difference of the input time series.
%
%
% ## Description ##
%
%
% ## Example ##
%
%}

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

% diff, df, pct, apct

if nargin<2
    shifts = -1;
end

if isempty(shifts)
    x = numeric.empty(x, 2);
    return
end

%--------------------------------------------------------------------------

x = unop(@numeric.diff, x, 0, shifts);

end%

