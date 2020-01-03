function [this, weights] = windex(this, weights, varargin)
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
% * `~Range=Inf` [ DateWrapper | `Inf` ] - Range on which the weighted index
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

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

persistent parser
if isempty(parser)
    parser = extend.InputParser('tseries.windex');
    parser.KeepUnmatched = true;
    parser.addRequired('InputSeries', @(x) isa(x, 'TimeSubscriptable'));
    parser.addRequired('Weights', @(x) isnumeric(x) || isa(x, 'TimeSubscriptable'));
    parser.addOptional('Range', Inf, @DateWrapper.validateRangeInput);
end
parser.parse(this, weights, varargin{:});
range = parser.Results.Range;
unmatched = parser.UnmatchedInCell;

%--------------------------------------------------------------------------

checkFrequency(this, range);
[inputData, range] = getData(this, range);
if isa(weights, 'TimeSubscriptable')
    checkFrequency(weights, range);
    weightsData = getData(weights, range);
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

