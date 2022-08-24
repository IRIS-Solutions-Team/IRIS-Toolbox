% windex  Plain weighted or Divisia index
%
% __Syntax__
%
% Input arguments marked with a `~` sign may be omitted.
%
%     Y = windex(X, Weights, ~Range, ...)
%
%
% __Input Arguments__
%
% * `X` [ tseries ] - Input times series.
%
% * `Weights` [ tseries | numeric ] - Fixed or time-varying weights on the
% input time series.
%
% * `~Range=Inf` [ Dater | `Inf` ] - Range on which the weighted index
% is computed.
%
%
% __Output arguments__
%
% * `Y` [ tseries ] - Weighted index based on `X`.
%
% __Options__
%
% * `Method='plain'` [ `'divisia'` | `'plain'` ] - Weighting method.
%
% * `Log=false` [ `true` | `false` ] - Logarithmize the input inputData before
% computing the index, delogarithmize the output inputData.
%
%
% __Description__
%
%
% __Example__
%

% -[IrisToolbox] Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function [this, weights] = windex(this, weights, varargin)

persistent pp
if isempty(pp)
    pp = extend.InputParser('tseries.windex');
    pp.KeepUnmatched = true;
    pp.addRequired('InputSeries', @(x) isa(x, 'TimeSubscriptable'));
    pp.addRequired('Weights', @(x) isnumeric(x) || isa(x, 'TimeSubscriptable'));
    pp.addOptional('Range', Inf, @validate.range);
end
parse(pp, this, weights, varargin{:});
range = double(pp.Results.Range);
unmatched = pp.UnmatchedInCell;

%--------------------------------------------------------------------------

checkFrequency(this, range);
[inputData, from, to, range] = getDataFromTo(this, range);

if isa(weights, 'TimeSubscriptable')
    checkFrequency(weights, range);
    weightsData = getDataFromTo(weights, from, to);
else
    weightsData = weights;
end

[outputData, weightsData] = numeric.windex(inputData, weightsData, unmatched{:});

weights = this;
weights.Start = range(1);
weights.Data = weightsData;
weights = resetComment(weights);
weights = trim(weights);

this.Start = range(1);
this.Data = outputData;
this = resetComment(this);
this = trim(this);

end%

