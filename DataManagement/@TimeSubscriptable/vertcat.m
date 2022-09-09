function x = vertcat(varargin)

if numel(varargin)==1
    x = varargin{1};
    return
end

% All inputs must be TimeSubscriptable or empty numeric
inxToKeep = true(size(varargin));
for i = 1 : numel(varargin)
    if isa(varargin{i}, 'TimeSubscriptable')
        continue
    elseif isnumeric(varargin{i}) && isempty(varargin{i})
        inxToKeep(i) = false;
        continue
    end
    throw(exception.Base('Series:CannotVertCatNonSeries', 'error'));
end
varargin(~inxToKeep) = [ ];

numInputs = numel(varargin);
x = varargin{1};
if numInputs==1
    return
end

% Check date frequency
freq = nan(1, numInputs);
for i = 1 : numInputs
    freq(i) = dater.getFrequency(varargin{i}.Start);
end
inxNaNFreq = isnan(freq);
if any(~inxNaNFreq)
    Frequency.checkMixedFrequency(freq(~inxNaNFreq));
    freq = freq( find(~inxNaNFreq, 1) );
else
    freq = NaN;
end

sizeXData = size(x.Data);
ndimsXData = ndims(x.Data);
x.Data = x.Data(:, :);

serialXStart = dater.getSerial(x.Start);
for i = 2 : numInputs
    y = varargin{i};
    sizeYData = size(y.Data);
    ndimsYData = ndims(y.Data);
    y.Data = y.Data(:, :);
    numColumnsX = size(x.Data, 2);
    numColumnsY = size(y.Data, 2);
    if numColumnsX~=numColumnsY
        if numColumnsX==1
            x.Data = repmat(x.Data, 1, numColumnsY);
            x.Comment = repmat(x.Comment, 1, numColumnsY);
            sizeXData = sizeYData;
            ndimsXData = ndimsYData;
        elseif numColumnsY==1
            y.Data = repmat(y.Data, 1, numColumnsX);
            y.Comment = repmat(y.Comment, 1, numColumnsX);
            sizeYData = sizeXData;
            ndimsYData = ndimsXData;
        else
            throw( exception.Base('Series:InconsistentSizeVertCat', 'error') )
        end
    end
    serialYStart = dater.getSerial(y.Start);
    if isempty(y.Data) || isnan(serialYStart)
        continue
    end
    if isempty(x.Data) || isnan(serialXStart)
        x = y;
        serialXStart = serialYStart;
        sizeXData = size(x.Data);
        ndimsXData = ndims(x.Data);
        x.Data = x.Data(:, :);
        continue
    end

    % Determine the range necessary
    serialStart = min(serialXStart, serialYStart);
    serialXEnd = dater.getSerial(x.End);
    serialYEnd = dater.getSerial(y.End);
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

x.Start = dater.fromSerial(freq, serialXStart);

if ndimsXData>2
    x.Data = reshape(x.Data, [size(x.Data, 1), sizeXData(2:end)]);
end
x.Comment(:) = y.Comment(:);

x = trim(x);

end%
