function [outputDatabank, success] = fromFred(fredSeriesId, varargin)
% fromFred  Download time series from FRED, the St Louis Fed databank
%
% __Syntax__
%
%     [OutputDatabank, Success] = databank.fromFred(FredSeriesId, ...)
%
%
% __Input Arguments__
%
% * `FredSeriesId` [ char | cellstr | string ] - List of Fred series Ids to
% retrieve, or `'Id->Name'` pairs specifying a `Name` different from `Id`
% under which the series will be saved in the databank.
%
%
% __Output Arguments__
%
% * `OutpuDatabank` [ struct ] - Output databank with requested time
% series.
%
% * `Success` [ `true` | `false` ] - True if all requested time series have
% been sucessfully downloaded.
%
%
% __Options__
%
% * `AddToDabank=struct( )` [ struct | empty ] - Requested time series will
% be added to this existing databank, or an empty will be created.
%
% * `AggregationMethod='avg'` [ `'avg'` | `'sum'` | `'eop'` ] - Aggregation
% (frequency conversion) method applied when option `'Frequency='` is used.
%
% * `Frequency=''` [ empty | `'M'` | `'Q'` | `'SA'` | `'A'` ] - Request
% time series converted (aggregated) to the specified frequency; frequency
% conversion will be performed server-side.
%
% * `URL='https://api.stlouisfed.org/fred/series'` [ char | string ] - URL
% for the Fred(R) API.
%
%
% __Description__
%
%
% __Example__
%
%     d = databank.fromFred({'GDPC1', 'PCE'})
%     d = databank.fromFred({'GDPC1', 'PCE'}, 'Frequency=', 'Q')
%     d = databank.fromFred({'GDPC1->gdp', 'PCE->pc'})
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

FRED_API_KEY = iris.get('FredApiKey');
REQUEST = '?series_id=%s&api_key=%s&file_type=json';
FREQUENCY_CONVERSION = '&frequency=%s&aggregation_method=%s';

persistent inputParser
if isempty(inputParser)
    inputParser = extend.InputParser('databank.fromFred');
    inputParser.KeepUnmatched = true;
    inputParser.addRequired('FredSeriesID', @(x) ischar(x) || iscellstr(x) || isa(x, 'string'));
    inputParser.addParameter('AddToDatabank', struct( ), @isstruct);
    inputParser.addParameter('Frequency', '', @(x) isempty(x) || any(strcmpi(x, {'M', 'Q', 'SA', 'A'})));
    inputParser.addParameter('AggregationMethod', 'avg', @(x) any(strcmpi(x, {'avg', 'sum', 'eop'})));
    inputParser.addParameter('URL', 'https://api.stlouisfed.org/fred', @(x) (ischar(x) || isa(x, 'string')) && strlength(x)>0);
end
inputParser.parse(fredSeriesId, varargin{:});
opt = inputParser.Options;

opt.URL = char(opt.URL);
if opt.URL(end)=='/'
    opt.URL(end) = '';
end
URL_INFO = [opt.URL, '/series'];
URL_DATA = [opt.URL, '/series/observations'];

%--------------------------------------------------------------------------

outputDatabank = opt.AddToDatabank;

if ~isempty(opt.Frequency)
    FREQUENCY_CONVERSION = sprintf( FREQUENCY_CONVERSION, ...
                                    lower(opt.Frequency), ...
                                    lower(opt.AggregationMethod) );
    REQUEST = [REQUEST, FREQUENCY_CONVERSION];
else
    FREQUENCY_CONVERSION = '';
end

fredSeriesId = cellstr(fredSeriesId);
numOfSeries = numel(fredSeriesId);
validSeriesId = true(1, numOfSeries);
dataRetrieved = true(1, numOfSeries);
for i = 1 : numOfSeries
    ithFredSeriesId = fredSeriesId{i};
    matches = regexp(ithFredSeriesId, '\w+', 'match');
    if numel(matches)==1
        ithDatabankName = matches{1};
        ithFredSeriesId = matches{1};
    else
        ithDatabankName = matches{2};
        ithFredSeriesId = matches{1};
    end
    try
        ithRequest = sprintf(REQUEST, ithFredSeriesId, FRED_API_KEY);
        jsonInfo = webread([URL_INFO, ithRequest]);
        jsonData = webread([URL_DATA, ithRequest]);
    catch Error
        validSeriesId(i) = false;
        continue
    end
    try
        outputDatabank.(ithDatabankName) = extractDataFromJson(jsonInfo, jsonData, opt);
    catch Error
        dataRetrieved(i) = false;
    end
end

if any(~validSeriesId)
    throw( exception.Base('Databank:InvalidSeriesId', 'warning'), ...
           fredSeriesId{~validSeriesId} );
end

if any(~dataRetrieved)
    throw( exception.Base('Databank:FailedToRetrieveData', 'warning'), ...
           fredSeriesId{~dataRetrieved} );
end

success = all(validSeriesId) && all(dataRetrieved);
end%




function outputSeries = extractDataFromJson(jsonInfo, jsonData, opt)
    outputSeries = [ ];
    frequency = getFrequencyFromJsonInfo(jsonInfo, opt);
    dates = str2dat( {jsonData.observations.date}, ...
                     'DateFormat=', 'YYYY-MM-DD', ...
                     'Freq=', frequency );
    numOfPeriods = numel(jsonData.observations);
    values = nan(numOfPeriods, 1);
    for i = 1 : numOfPeriods
        ithValue = sscanf(jsonData.observations(i).value, '%g');
        if isnumeric(ithValue) && numel(ithValue)==1
            values(i) = ithValue;
        end
    end
    outputSeries = Series(dates, values, jsonInfo.seriess.title, jsonInfo.seriess);
end%




function frequency = getFrequencyFromJsonInfo(jsonInfo, opt)
    if ~isempty(opt.Frequency)
        frequencyLetter = opt.Frequency;
    else
        frequencyLetter = jsonInfo.seriess.frequency_short;
    end
    frequencyLetter = lower(frequencyLetter);
    switch frequencyLetter
        case 'm' 
            frequency = Frequency.MONTHLY;
        case 'q'
            frequency = Frequency.QUARTERLY;
        case 'sa'
            frequency = Frequency.HALFYEARLY;
        case 'a'
            frequency = Frequency.YEARLY;
        otherwise
            if isequaln(frequency, NaN)
                throw( exception.Base('Databank:CannotDetermineFrequencyFromJson', 'error') );
            end
    end
end%

