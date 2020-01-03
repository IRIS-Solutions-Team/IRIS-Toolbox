function varargout = init(this, dates, data)
% init  Create start date and data for new time series
%
% Backend IRIS function
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 IRIS Solutions Team

% Invoke unit tests
%(
if nargin==2 && isequal(dates, '--test')
    varargout{1} = unitTests( );
    return
end
%)


if ischar(dates) || isa(dates, 'string')
    dates = textinp2dat(dates);
end
numDates = numel(dates);            

if isempty(dates)
    freq = double.empty(1, 0);
else
    if isa(dates, 'DateWrapper')
        freq = DateWrapper.getFrequencyAsNumeric(getFirst(dates));
    else
        freq = DateWrapper.getFrequencyAsNumeric(dates(1));
    end
    freq = freq(~isnan(freq));
    DateWrapper.checkMixedFrequency(freq);
end
serials = DateWrapper.getSerial(dates);
serials = serials(:);

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
    data = data(:);
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
    this = hereCreateEmptySeries(this, sizeData);
    varargout{1} = this;
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
    this = hereCreateEmptySeries(this, sizeData);
    varargout{1} = this;
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
this.Start = DateWrapper.fromSerial(freq, startSerial);

%
% Trim leading and trailing rows containing MissinValues only
%
this = trim(this);


%<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
varargout{1} = this;
%<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

end%

%
% Local functions
%

function this = hereCreateEmptySeries(this, sizeData)
    sizeData(1) = 0;
    this.Start = DateWrapper(NaN);
    this.Data = repmat(this.MissingValue, sizeData);
end%




%
% Unit Tests
%
%(
function tests = unitTests( )
    tests = functiontests({
        @setupOnce
        @trimLeadingTest
        @trimTrailingTest
        @trimLeadingTrailingTest
    });
    tests = reshape(tests, [ ], 1);
end%


function setupOnce(this)
end%


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
%)
