% fillMissing  Fill missing observations for numeric data
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2019 [IrisToolbox] Solutions Team

function data = fillMissing(data, inxMissing, varargin)

if ~any(inxMissing(:))
    return
end

if (ischar(varargin{1}) || isstring(varargin{1})) ...
    && startsWith(varargin{1}, "regress", "ignoreCase", true)
    % regressConstant, regressTrend, regressLogTrend
    sizeData = size(data);
    data = data(:, :);
    inxMissing = inxMissing(:, :);
    for i = 1 : size(data, 2)
        if ~any(inxMissing(:, i))
            continue
        end
        data(:, i) = locallyFillTrend(data(:, i), inxMissing(:, min(i, end)), varargin{1});
    end
    data = reshape(data, sizeData);
else
    if validate.numericScalar(varargin{1})
        varargin = [{"constant"}, varargin(1)];
    end

    % Call built-in `fillmissing` and supply the locations of missing values
% >=R2019b
%{
    data = fillmissing(data, varargin{:}, "missingLocations", inxMissing);
%}
% >=R2019b
% <=R2019a
%(
    data = fillmissing(data, varargin{:});
%)
% <=R2019a
end

end%


%
% Local Functions
%


function data = locallyFillTrend(data, inxMissing, method)
    method = string(method);
    needsLog = startsWith(method, "regressLogTrend", "ignoreCase", true);
    if needsLog
        data = log(data);
    end

    numPeriods = size(data, 1);
    M = ones(numPeriods, 1);
    if startsWith(method, ["regressTrend", "regressLogTrend"], "ignoreCase", true)
        meanDiff = mean(diff(data, 1, 1), 1, "OmitNaN");
        trend = transpose(0:numPeriods-1) * meanDiff;
        M = [M, trend];
    end

    fit = M * (M(~inxMissing, :)\data(~inxMissing, :));
    data(inxMissing) = fit(inxMissing, :);

    if needsLog
        data = exp(data);
    end
end%

