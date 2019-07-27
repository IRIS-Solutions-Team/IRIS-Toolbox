function [outputDatabank, status] = fromFred(fredSeriesId, varargin)
% fromFred  Download time series from FRED, the St Louis Fed databank
%
% ## Syntax ##
%
%     [outputDatabank, status] = databank.fromFred(fredSeriesId, ...)
%
%
% ## Input Arguments ##
%
% __`fredSeriesId`__ [ char | cellstr | string ] - 
% List of Fred series Ids to retrieve, or `'Id->Name'` pairs specifying a
% `Name` different from `Id` under which the series will be saved in the
% databank.
%
%
% ## Output Arguments ##
%
% __`outputDatabank`__ [ struct ] - 
% Output databank with requested time series.
%
% __`status`__ [ `true` | `false` ] - 
% True if all requested time series have been sucessfully downloaded.
%
%
% ## Options ##
%
% __`AddToDatabank=struct( )`__ [ struct | empty ] - 
% Requested time series will
% be added to this existing databank, or an empty will be created.
%
% __`AggregationMethod='avg'`__ [ `'avg'` | `'sum'` | `'eop'` ] - 
% Aggregation
% (frequency conversion) method applied when option `'Frequency='` is used.
%
% __`Frequency=''`__ [ empty | Frequency | `'M'` | `'Q'` | `'SA'` | `'A'` ] - 
% Request time series conversion (aggregation) to the specified frequency;
% frequency conversion will be performed server-side.
%
% __`URL='https://api.stlouisfed.org/fred/series'`__ [ char | string ] - 
% URL for the Fred(R) API.
%
%
% ## Description ##
%
%
% ## Example ##
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

persistent parser
if isempty(parser)
    parser = extend.InputParser('databank.fromFred');
    parser.KeepUnmatched = true;
    addRequired(parser,  'fredSeriesID', @(x) ischar(x) || iscellstr(x) || isa(x, 'string'));
    addParameter(parser, 'AddToDatabank', struct( ), @isstruct);
    addParameter(parser, 'Frequency', '', @hereValidateFrequency);
    addParameter(parser, 'AggregationMethod', 'avg', @(x) any(strcmpi(x, {'avg', 'sum', 'eop'})));
    addParameter(parser, 'URL', 'https://api.stlouisfed.org/fred', @(x) (ischar(x) || isa(x, 'string')) && strlength(x)>0);
end
parse(parser, fredSeriesId, varargin{:});
opt = parser.Options;

opt.URL = char(opt.URL);
if opt.URL(end)=='/'
    opt.URL(end) = '';
end
URL_INFO = [opt.URL, '/series'];
URL_DATA = [opt.URL, '/series/observations'];

%--------------------------------------------------------------------------

outputDatabank = opt.AddToDatabank;

if ~isempty(opt.Frequency)
    if isa(opt.Frequency, 'Frequency')
        opt.Frequency = toFredLetter(opt.Frequency);
    end
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
        outputDatabank.(ithDatabankName) = hereExtractDataFromJson(jsonInfo, jsonData, opt);
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

status = all(validSeriesId) && all(dataRetrieved);

end%


%
% Local Functions
%


function outputSeries = hereExtractDataFromJson(jsonInfo, jsonData, opt)
    outputSeries = [ ];
    frequency = hereGetFrequencyFromJsonInfo(jsonInfo, opt);
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




function frequency = hereGetFrequencyFromJsonInfo(jsonInfo, opt)
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




function flag = hereValidateFrequency(input)
    FREQUENCIES_ALLOWED = [ Frequency.YEARLY
                            Frequency.HALFYEARLY
                            Frequency.QUARTERLY
                            Frequency.MONTHLY ];
    if isempty(input)
        flag = true;
        return
    end
    if any(strcmpi(input, {'M', 'Q', 'SA', 'A'}))
        flag = true;
        return
    end
    if isa(input, 'Frequency') && any(input==FREQUENCIES_ALLOWED)
        flag = true;
        return
    end
    flag = false;
end%

