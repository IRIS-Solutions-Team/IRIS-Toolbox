% adiff  Annnualized first difference
% Type <a href="matlab: ihelp Series/adiff">ihelp Series/adiff</a> for help
%
% <html>
% <h1>Syntax</h1>
%
% Input arguments marked with a `~` sign may be omitted
%
%     this = diff(this, ~shift)
%
%
% ## Input Arguments ##
%
% __`this`__ [ TimeSubscriptable ] -
% Input time series.
%
% __`~shift`__ [ numeric ] - Number of periods over which the first difference
% will be computed; `y=this-this{shift}`; `shift` is a negative number
% for the usual backward differencing; if omitted, `shift=-1`.
%
%
% ## Output Arguments ##
%
% __`this`__ [ TimeSubscriptable ] -
% First difference of the input time series.
%
%
% ## Description ##
%
%
% ## Example ##
% </html>
%

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function this = adiff(this, shift, varargin)

if isempty(this.Data)
    return
end

try, shift;
    catch, shift = -1; end

this = diff(this, shift, varargin{:}, "annualize", true);

end%

