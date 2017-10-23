function x = vertcat(varargin)
% vertcat  Vertical concatenation of tseries objects.
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

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

if length(varargin)==1
    x = varargin{1};
    return
end

% Check classes and frequencies.
indexTimeSeries = cellfun(@(x) isa(x, 'TimeSeriesBase'), varargin);
assert( ...
    all(indexTimeSeries), ...
    exception.Base('Series:CannotVertCatNonSeries', 'error') ...
);

% Check date frequency.
start = cellfun(@(x) x.Start, varargin);
freq = getFrequency(start);
indexNaN = isnan(start);
if any(~indexNaN)
    first = find(~indexNaN, 1);
    assert( ...
        all(freq==freq(first) | indexNaN), ...
        exception.Base('Series:CannotCatMixedFrequencies', 'error') ...
    );
end

numInputs = length(varargin);
x = varargin{1};
sizeXData = size(x.Data);
ndimsXData = ndims(x.Data);
x.Data = x.Data(:, :);

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
            utils.error('tseries:vertcat', ...
                ['Vertically concatenated time series objects', ...
                'must be consistent in 2nd and higher dimensions.']);
        end
    end
    if isempty(y.Data) || isnan(y.Start)
        continue
    end
    if isempty(x.Data) || isnan(x.Start)
        x = y;
        sizeXData = size(x.Data);
        ndimsXData = ndims(x.Data);
        x.Data = x.Data(:, :);
        continue
    end

    % Determine the longest stretch range necessary.
    startDate = min(x.Start, y.Start);
    endDate = max(x.End, y.End);    
    range = startDate : endDate;
    
    % Get continuous data from both series on the largest stretch range.
    xData = rangedata(x, range);
    yData = rangedata(y, range);
    
    % Identify and overlay NaNs separately in the real and imaginary parts of
    % the data.
    xDataReal = real(xData);
    yDataReal = real(yData);
    xDataImag = imag(xData);
    yDataImag = imag(yData);
    indexReal = ~isnan(yDataReal);
    indexImag = ~isnan(yDataImag);
    xDataReal(indexReal) = yDataReal(indexReal);
    xDataImag(indexImag) = yDataImag(indexImag);

    % Combine the real and imaginary parts of the data again.
    x.Data = xDataReal + 1i*xDataImag;
    
    % Reset the start date.
    x.Start = startDate;
end

if ndimsXData>2
    x.Data = reshape(x.Data, [size(x.Data, 1), sizeXData(2:end)]);
end

x.Comment = y.Comment;
x = trim(x);

end
