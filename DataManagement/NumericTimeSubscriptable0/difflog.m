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
% ## `x`__ [ TimeSubscriptable ] -
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
% ## `x`__ [ TimeSubscriptable ] -
% First difference of the log of the input time series.
%
%
% ## Description ##
%
%
% ## Example ##
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function this = difflog(this, varargin)

if isempty(this.Data)
    return
end

this.Data = log(this.Data);
this = diff(this, varargin{:});

end%

