% adiff  Annnualized first difference
%{
% ## Syntax ##
%
% Input arguments marked with a `~` sign may be omitted
%
%     this = diff(this, ~shift)
%
%
% ## Input Arguments ##
%
% __`this`__ [ NumericTimeSubscriptable ] -
% Input time series.
%
% __`~shift`__ [ numeric ] - Number of periods over which the first difference
% will be computed; `y=this-this{shift}`; `shift` is a negative number
% for the usual backward differencing; if omitted, `shift=-1`.
%
%
% ## Output Arguments ##
%
% __`this`__ [ NumericTimeSubscriptable ] -
% First difference of the input time series.
%
%
% ## Description ##
%
%
% ## Example ##
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2021 [IrisToolbox] Solutions Team

function this = adiff(this, varargin)

if isempty(this.Data)
    return
end

this = diff(this, varargin{:}, "annualize", true);

end%

