function x = vertcat(varargin)
% vertcat  Vertical concatenation of tseries objects
%
% __Syntax__
%
%     X = [X1; X2; ...; XN]
%     X = vertcat(X1, X2, ..., XN)
%
%
% __Input Arguments__
%
% * `X1`, ..., `XN` [ tseries ] - Input tseries objects that will be
% vertically concatenated; they all have to have the same size in 2nd and
% higher dimensions.
%
% __Output Arguments__
%
% * `X` [ tseries ] - Output tseries object created by overlaying `X1` with
% `X2`, and so on, see description below.
%
% __Description__
%
% Any NaN observations in `X1` are replaced with the observations from
% `X2`. This replacement is performed separately for the real and imaginary
% parts of the input data, and the real and imaginary parts are combined
% back again.
%
% The input tseries objects must be consistent in 2nd and higher
% dimensions. The only exception is if some of the tseries objects are
% scalar time series (i.e. with one column only) while the rest of them are
% not. In that case, the scalar tseries are automatically expanded to match
% the size of the multivariate tseries.
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

%--------------------------------------------------------------------------

numOfInputs = length(varargin);
x = varargin{1};

if numOfInputs==1
    return
end

% All inputs must be TimeSubscriptable
for i = 1 : nargin
    if ~isa(varargin{i}, 'TimeSubscriptable')
        throw( exception.Base('Series:CannotVertCatNonSeries', 'error') )
    end
end

% Check date frequency
freq = nan(1, nargin);
for i = 1 : nargin
    freq(i) = DateWrapper.getFrequencyAsNumeric(varargin{i}.Start);
end
inxOfNaNFreq = isnan(freq);
if any(~inxOfNaNFreq)
    DateWrapper.checkMixedFrequency(freq(~inxOfNaNFreq));
    freq = freq( find(~inxOfNaNFreq, 1) );
else
    freq = NaN;
end

sizeOfXData = size(x.Data);
ndimsOfXData = ndims(x.Data);
x.Data = x.Data(:, :);

serialXStart = round(x.Start);
for i = 2 : numOfInputs
    y = varargin{i};
    sizeOfYData = size(y.Data);
    ndimsOfYData = ndims(y.Data);
    y.Data = y.Data(:, :);
    numOfColumnsX = size(x.Data, 2);
    numOfColumnsY = size(y.Data, 2);
    if numOfColumnsX~=numOfColumnsY
        if numOfColumnsX==1
            x.Data = repmat(x.Data, 1, numOfColumnsY);
            x.Comment = repmat(x.Comment, 1, numOfColumnsY);
            sizeOfXData = sizeOfYData;
            ndimsOfXData = ndimsOfYData;
        elseif numOfColumnsY==1
            y.Data = repmat(y.Data, 1, numOfColumnsX);
            y.Comment = repmat(y.Comment, 1, numOfColumnsX);
            sizeOfYData = sizeOfXData;
            ndimsOfYData = ndimsOfXData;
        else
            throw( exception.Base('Series:InconsistentSizeVertCat', 'error') )
        end
    end
    serialYStart = round(y.Start);
    if isempty(y.Data) || isnan(serialYStart)
        continue
    end
    if isempty(x.Data) || isnan(serialXStart)
        x = y;
        serialXStart = serialYStart;
        sizeOfXData = size(x.Data);
        ndimsOfXData = ndims(x.Data);
        x.Data = x.Data(:, :);
        continue
    end

    % Determine the range necessary
    serialStart = min(serialXStart, serialYStart);
    serialXEnd = round(x.End);
    serialYEnd = round(y.End);
    serialEnd = max(serialXEnd, serialYEnd);
    
    % Get continuous data from both series on the largest stretch range
    xData = getDataFromTo(x, serialStart, serialEnd);
    yData = getDataFromTo(y, serialStart, serialEnd);
    
    % Identify and overlay NaNs separately in the real and imaginary parts of
    % the data
    xDataReal = real(xData);
    yDataReal = real(yData);
    xDataImag = imag(xData);
    yDataImag = imag(yData);
    indexReal = ~isnan(yDataReal);
    indexImag = ~isnan(yDataImag);
    xDataReal(indexReal) = yDataReal(indexReal);
    xDataImag(indexImag) = yDataImag(indexImag);

    % Combine the real and imaginary parts of the data again
    x.Data = xDataReal + 1i*xDataImag;

    % Update start date for the output series
    serialXStart = serialStart;
end
x.Start = DateWrapper.fromSerial(freq, serialXStart);

if ndimsOfXData>2
    x.Data = reshape(x.Data, [size(x.Data, 1), sizeOfXData(2:end)]);
end
x.Comment(:) = y.Comment(:);

x = trim(x);

end
