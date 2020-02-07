function this = aroc(this, varargin)
% aroc  Annualized gross rate of change
%{
% ## Syntax ##
%
% Input arguments marked with a `~` sign may be omitted
%
%     x = aroc(x, ~shift)
%
%
% ## Input Arguments ##
%
% __`x`__ [ NumericTimeSubscriptable ] - 
% Input time series.
%
% __`~shift=-1`__ [ numeric ] - 
% Time shift, i.e. the number of periods over which the rate of change will
% be calculated.
%
%
% ## Output Arguments ##
%
% __`x`__ [ NumericTimeSubscriptable ] - 
% Annualized percentage rate of change in the input data.
%
%
% ## Description ##
%
%
% ## Example ##
%
%}

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

%--------------------------------------------------------------------------

this = roc(this, varargin{:}, 'OutputFreq=', Frequency.YEARLY);

end%

