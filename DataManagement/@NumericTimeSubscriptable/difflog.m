function this = diff(this, shifts)
% diff  First difference of log
%{
% ## Syntax ##
%
% Input arguments marked with a `~` sign may be omitted
%
%     x = difflog(x, ~shift)
%
%
% ## Input Arguments ##
%
% ## `x`__ [ NumericTimeSubscriptable ] -
% Input time series.
%
% ## `~shift`__ [ numeric ] - 
% Number of periods over which the first difference will be computed;
% `y=log(x)-log(x{shift})`; `shift` is a negative number for the usual
% backward differencing; if omitted, `shift=-1`.
%
%
% ## Output Arguments ##
%
% ## `x`__ [ NumericTimeSubscriptable ] -
% First difference of the log of the input time series.
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
    this = numeric.empty(this, 2);
    return
end

%--------------------------------------------------------------------------

this.Data = log(this.Data);
this = unop(@numeric.diff, this, 0, shifts);

end%

