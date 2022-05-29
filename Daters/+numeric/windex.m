function [data, weights] = windex(data, weights, varargin)
% windex  Weighted index from numeric data
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

persistent inputParser
if isempty(inputParser)
    inputParser = extend.InputParser('numeric.windex');
    inputParser.addRequired('InputData', @isnumeric);
    inputParser.addRequired('Weights', @isnumeric);
    inputParser.addParameter('Log', false, @(x) isequal(x, true) || isequal(x, false));
    inputParser.addParameter('Method', 'plain', @(x) any(strcmpi(x, {'plain', 'simple', 'divisia'})));
end
inputParser.parse(data, weights, varargin{:});
opt = inputParser.Options;

%--------------------------------------------------------------------------

data = data(:, :);
weights = weights(:, :);
numPeriods = size(data, 1);

if size(weights, 1)==1 && numPeriods>1
    weights = repmat(weights, numPeriods, 1);
end

sumWeights = sum(weights, 2);
if size(weights, 2)==size(data, 2)
    % Normalize weights
    for i = 1 : size(weights, 2)
        weights(:, i) = weights(:, i) ./ sumWeights(:);
    end
elseif size(weights, 2)==size(data, 2)-1
    % Add the implicit weight for the last column
    weights = [weights, 1-sumWeights];
end

if any(strcmpi(opt.Method, {'plain', 'simple'}))
    if opt.Log
        data = log(data);
    end
    data = sum(weights .* data, 2);
    if opt.Log
        data = exp(data);
    end
elseif strcmpi(opt.Method, 'divisia')
    % Compute the average weights between t and t-1
    averageWeights = (weights(2:end, :) + weights(1:end-1, :))/2;
    % Compute log growth between t and t-1
    diffLogData = log(data(2:end, :) ./ data(1:end-1, :));
    % Construct the Divisia index
    data = sum(averageWeights .* diffLogData, 2);
    % Set the first observation to 1 and cumulate back
    data = exp(cumsum([0; data]));
end

end
