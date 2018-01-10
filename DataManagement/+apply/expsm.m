function [smooth, sse] = expsm(x, beta, init, h)
% expsm  Apply exponential smoothing to numeric data
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2017 IRIS Solutions Team

%--------------------------------------------------------------------------

if beta<0 || beta>1
    sse = Inf;
    return
end

sizeX = size(x);
x = x(:, :);
numColumns = size(x, 2);

if isempty(init)
    init = nan(1, numColumns);
else
    init = init(:).';
    if length(init)<numColumns
        init(end+1:numColumns) = init(end);
    end
end

smooth = nan(size(x));
numPeriods0 = NaN;
for i = 1 : numColumns
    data = x(:, i);    
    ixNaNData = isnan(data);
    first = find(~ixNaNData, 1);
    last = find(~ixNaNData, 1, 'last');
    data = data(first:last);
    isInit = ~isnan(init(i));
    if isInit
        data = [init(i); data]; %#ok<AGROW>
    end
    numPeriods = size(data, 1);
    if numPeriods~=numPeriods0
        w = TimeSubscriptable.getExpSmoothMatrix(beta, numPeriods);
    end
    data = w*data;
    if isInit
        data = data(2:end);
    end
    smooth(first:last, i) = data;
    numPeriods0 = numPeriods;
end

if length(sizeX)>2
    x = reshape(x, sizeX);
    smooth = reshape(smooth, sizeX);
end

if nargout>1
    forecast = nan(size(smooth));
    forecast(h+1:end, :) = smooth(1:end-h, :);
    forecastError = forecast - x;
    sse = sum(forecastError(~isnan(forecastError)).^2);
end

end
