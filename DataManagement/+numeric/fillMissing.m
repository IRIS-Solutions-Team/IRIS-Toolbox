function data = fillMissing(data, missingValue, varargin)
% fillMissing  Fill missing observations for numeric data
%
% Backend [IrisToolbox] function
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2019 IRIS Solutions Team

%--------------------------------------------------------------------------

if ~any(isnan(data(:)))
    return
end

conversionFunction = [ ];
if islogical(data)
    data = double(data);
    conversionFunction = @logical;
end

if any(strcmpi(varargin{1}, {'GlobalLinear', 'GlobalLoglinear', 'GlobalMean'}))
    sizeData = size(data);
    data = data(:, :);
    for i = 1 : size(data, 2)
        if ~any(isnan(data(:, i)))
            continue
        end
        data(:, i) = hereFillGlobal(data(:, i), varargin{1});
    end
    data = reshape(data, sizeData);
else
    try
        % Call built-in `fillmissing` and supply the locations of missing values
        data = fillmissing(data, varargin{:}, 'MissingLocations', inxMissing);
    catch
        % Older Matlab releases do not have the MissingLocation option
        data = fillmissing(data, varargin{:});
    end
end

if ~isempty(conversionFunction)
    inxNaN = isnan(data);
    data(inxNaN) = missingValue;
    data = conversionFunction(data);
end

end%


%
% Local Functions
%


function data = hereFillGlobal(data, method)
    if strcmpi(method, 'GlobalLoglinear')
        data = log(data);
    end

    numData = size(data, 1);
    data(~isfinite(data) | imag(data)~=0) = NaN;
    inxNaN = isnan(data);

    M = ones(numData, 1);
    if any(strcmpi(method, {'GlobalLinear', 'GlobalLoglinear'}))
        meanDiff = mean(diff(data, 1, 1), 1, 'OmitNaN');
        trend = transpose(0:numData-1) * meanDiff;
        M = [M, trend];
    end

    fit = M * (M(~inxNaN, :)\data(~inxNaN, :));
    data(inxNaN) = fit(inxNaN, :);

    if strcmpi(method, 'GlobalLoglinear')
        data = exp(data);
    end
end%

