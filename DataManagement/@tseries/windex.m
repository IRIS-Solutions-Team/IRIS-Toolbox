function this = windex(this, weights, range, varargin)
% windex  Simple weighted or Divisia index.
%
% __Syntax__
%
%     Y = windex(X, Weights, Range)
%
%
% __Input Arguments__
%
% * `X` [ tseries ] - Input times series.
%
% * `Weights` [ tseries | numeric ] - Fixed or time-varying weights on the
% input time series.
%
% * `Range` [ numeric ] - Range on which the Divisia index is computed.
%
%
% __Output arguments__
%
% * `Y` [ tseries ] - Weighted index based on `X`.
%
% __Options__
%
% * `'Method='` [ `'divisia'` | *`'simple'`* ] - Weighting method.
%
% * `'Log='` [ `true` | *`false`* ] - Logarithmise the input data before
% computing the index, delogarithmise the output data.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

if nargin<3
    range = Inf;
end

persistent INPUT_PARSER
if isempty(INPUT_PARSER)
    INPUT_PARSER = extend.InputParser('tseries.windex');
    INPUT_PARSER.addRequired('InputSeries', @(x) isa(x, 'TimeSubscriptable'));
    INPUT_PARSER.addRequired('Weights', @(x) isnumeric(x) || isa(x, 'TimeSubscriptable'));
    INPUT_PARSER.addRequired('Range', @(x) isa(x, 'DateWrapper') || isnumeric(x));
    INPUT_PARSER.addParameter('log', false, @(x) isequal(x, true) || isequal(x, false));
    INPUT_PARSER.addParameter('method', 'simple', @(x) any(strcmpi(x, {'simple', 'divisia'})));
end
INPUT_PARSER.parse(this, weights, range, varargin{:});
opt = INPUT_PARSER.Options;

%--------------------------------------------------------------------------

this.Data = this.Data(:, :);
temp = this;
if isa(weights, 'tseries')
    weights.data = weights.data(:, :);
    temp = trim([temp, weights]);
end

% Generate the range.
range = specrange(temp, range);
data = rangedata(this, range);
numPeriods = length(range);

% Get the weights.
if isa(weights, 'tseries')
    weights = rangedata(weights, range);
elseif size(weights, 1)==1
    weights = weights(ones(1, numPeriods), :);
end
weights = weights(:, :);

wSum = sum(weights, 2);
if size(weights, 2)==size(data, 2)
    % Normalise weights.
    for i = 1 : size(weights, 2)
        weights(:, i) = weights(:, i) ./ wSum(:);
    end
elseif size(weights, 2)==size(data, 2)-1
    % Add the last weight.
    weights = [weights, 1-wSum];
end

switch lower(options.method)
    case 'simple'
        if options.log
            data = log(data);
        end
        data = sum(weights .* data, 2);
        if options.log
            data = exp(data);
        end
    case 'divisia'
        % Compute the average weights between t and t-1.
        wavg = (weights(2:end, :) + weights(1:end-1, :))/2;
        % Construct the Divisia index.
        data = sum(wavg .* log(data(2:end, :)./data(1:end-1, :)), 2);
        % Set the first observation to 1 and cumulate back.
        data = exp(cumsum([0; data]));
end

this.Data = data;
this.Start = range(1);
this = resetColumnNames(this);
this = trim(this);

end
