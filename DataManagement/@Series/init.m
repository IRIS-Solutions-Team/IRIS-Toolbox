% init  Create start date and data for new time series
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function this = init(this, dates, data)

dates = double(dates);
numDates = numel(dates);            

if isempty(dates)
    freq = double.empty(1, 0);
else
    freq = dater.getFrequency(dates);
    freq = freq(~isnan(freq));
    if isempty(freq)
        freq = NaN;
    else
        Frequency.checkMixedFrequency(freq);
        freq = freq(1);
    end
end
serials = dater.getSerial(dates);
serials = reshape(serials, [ ], 1);

%--------------------------------------------------------------------------

sizeData = size(data);
ndimsData = numel(sizeData);
if isa(data, 'function_handle')
    %
    % Create data from function handle
    %
    data = createDataFromFunction(this, data, numDates);
elseif numDates>1 && sizeData(1)==1 && (numel(data)~=numDates || ~isrow(data))
    %
    % Repeat data along first dimension if size(data,1)==1
    %
    data = repmat(data, [numDates, ones(1, ndimsData-1)]);
elseif sum(size(data)>1)==1 && numel(data)>1 && numDates>1
    %
    % Squeeze `data` if scalar time series is entered as an non-columnwise
    % vector
    %
    data = reshape(data, [ ], 1);
elseif numel(data)==1 && numDates>1
    %
    % Expand scalar observation to match more than one of `dates`
    %
    data = repmat(data, size(serials));
end

%
% Check the class of data
% Reset MissingValue property
%
checkDataClass(this, data);
this = resetMissingValue(this, data);

%
% If `dates` is scalar and `data` have multiple rows, treat
% `dates` as a start date and expand the dates accordingly
%
numRowsInValues = size(data, 1);
if numDates==1 && numRowsInValues>1
    serials = serials + (0 : numRowsInValues-1);
end

numDates = numel(serials);
sizeData = size(data);
if sizeData(1)==0 && (all(isnan(serials)) || numDates==0)
    % No data entered, return empty series
    this = locallyCreateEmptySeries(this, sizeData);
    return
end

if sizeData(1)~=numDates
    throw( exception.Base('Series:DatesDataDimensionMismatch', 'error') );
end

ndimsData = ndims(data);
data = data(:, :);

% Remove NaN serials
inxNaNSerials = isnan(serials);
if any(inxNaNSerials)
    data(inxNaNSerials, :) = [ ];
    serials(inxNaNSerials) = [ ];
end

if isempty(serials)
    % No proper date entered, return empty series
    this = locallyCreateEmptySeries(this, sizeData);
    return
end

% Start date is the minimum date found
startSerial = min(serials);
endSerial = max(serials);

% The actual stretch of the time series range
numDates = round(endSerial - startSerial + 1);
if isempty(numDates)
    numDates = 0;
end
sizeData(1) = numDates;

this.Data = repmat(this.MissingValue, sizeData);
posData = round(serials - startSerial + 1);

%
% Assign user data; higher dimensions will be preserved in
% this.Data
%
this.Data(posData, :) = data;

%
% Create the start date from the serial number, preserve the class of the
% dates input
%
start = dater.fromSerial(freq, startSerial);
this.Start = start;

%
% Trim leading and trailing rows containing MissinValues only
%
this = trim(this);

end%

%
% Local Functions
%

function this = locallyCreateEmptySeries(this, sizeData)
    sizeData(1) = 0;
    this.Start = Series.StartDateWhenEmpty;
    this.Data = repmat(this.MissingValue, sizeData);
end%




%
% Unit Tests
%
%{
##### SOURCE BEGIN #####
% saveAs=Series/initUnitTest.m

testCase = matlab.unittest.FunctionTestCase.fromFunction(@(x)x);

function trimLeadingTest(this)
    data = [NaN NaN;2 NaN;3 4;NaN 5];
    x = Series(qq(2001,1):qq(2001,4), data);
    assertEqual(this, x.Data, data(2:end, :));
end%


function trimTrailingTest(this)
    data = [1 NaN;2 NaN;3 4; NaN NaN];
    x = Series(qq(2001,1):qq(2001,4), data);
    assertEqual(this, x.Data, data(1:3, :));
end%


function trimLeadingTrailingTest(this)
    data = [NaN NaN;2 NaN;3 4; NaN NaN];
    x = Series(qq(2001,1):qq(2001,4), data);
    assertEqual(this, x.Data, data(2:3, :));
end%

##### SOURCE END #####
%}
