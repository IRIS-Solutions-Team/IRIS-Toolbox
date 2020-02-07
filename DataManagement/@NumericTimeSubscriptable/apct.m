function this = apct(this, varargin)
% apct  Annualized percent rate of change
%
% __Syntax__
%
% Input arguments marked with a `~` sign may be omitted
%
%     X = apct(X, ~Shift)
%
%
% __Input Arguments__
%
% * `X` [ NumericTimeSubscriptable ] - Input time series.
%
% * `~Shift=-1` [ numeric ] - Time shift, i.e. the number of periods over
% which the rate of change will be calculated.
%
%
% __Output Arguments__
%
% * `X` [ NumericTimeSubscriptable ] - Annualized percentage rate of change
% in the input data.
%
%
% __Description__
%
%
% __Example__
%

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

%--------------------------------------------------------------------------

this = pct(this, varargin{:}, 'OutputFreq=', Frequency.YEARLY);

end%

