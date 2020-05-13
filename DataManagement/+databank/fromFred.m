function [outputDb, status] = fromFred(fredSeriesId, varargin)
% fromFred  Download time series from FRED, the St Louis Fed databank
%{
% ## Syntax ##
%
%     [outputDb, status] = databank.fromFred(fredSeriesId, ...)
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
% __`outputDb`__ [ struct ] - 
% Output databank with requested time series.
%
% __`status`__ [ `true` | `false` ] - 
% True if all requested time series have been sucessfully downloaded.
%
%
% ## Options ##
%
% __`AddToDatabank=[ ]`__ [ struct | empty ] - 
% Requested time series will be added to this existing databank; if empty,
% a new databank of the `OutputType=` class will be created; the type of
% `AddToDatabank=` option must be consistent with the `OutputType=`.
%
% __`AggregationMethod='avg'`__ [ `'avg'` | `'sum'` | `'eop'` ] - 
% Aggregation (frequency conversion) method applied when option
% `'Frequency='` is used.
%
% __`Frequency=''`__ [ empty | Frequency | `'M'` | `'Q'` | `'SA'` | `'A'` ] - 
% Request time series conversion to the specified frequency; frequency
% conversion will be performed server-side; only high- to low-frequency
% conversion is possible (aggregation).
%
% __`OutputType='struct'` [ `struct` | `Dictionary` ] - 
% Type (Matlab class) of the output databank; the type of `AddToDatabank=`
% option must be consistent with the `OutputType=`.
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
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 IRIS Solutions Team

FRED_API_KEY = iris.get('FredApiKey');
REQUEST = '?series_id=%s&api_key=%s&file_type=json';
FREQUENCY_CONVERSION = '&frequency=%s&aggregation_method=%s';

persistent pp
if isempty(pp)
    pp = extend.InputParser('databank.fromFred');
    pp.KeepUnmatched = true;
    addRequired(pp,  'fredSeriesId', @(x) ischar(x) || iscellstr(x) || isa(x, 'string'));

    addParameter(pp, 'AddToDatabank', [ ], @(x) isequal(x, [ ]) || validate.databank(x));
    addParameter(pp, 'AggregationMethod', 'avg', @(x) any(strcmpi(x, {'avg', 'sum', 'eop'})));
    addParameter(pp, 'Frequency', '', @locallyValidateFrequency);
    addParameter(pp, 'OutputType', 'struct', @validate.databankType);
    addParameter(pp, 'URL', 'https://api.stlouisfed.org/fred', @(x) (ischar(x) || isa(x, 'string')) && strlength(x)>0);
end
parse(pp, fredSeriesId, varargin{:});
opt = pp.Options;

outputDb = databank.backend.ensureTypeConsistency( ...
    opt.AddToDatabank, opt.OutputType ...
);

opt.URL = char(opt.URL);
if opt.URL(end)=='/'
    opt.URL(end) = '';
end
URL_INFO = [opt.URL, '/series'];
URL_DATA = [opt.URL, '/series/observations'];

%--------------------------------------------------------------------------

if ~isempty(opt.Frequency)
    if isa(opt.Frequency, 'Frequency')
        opt.Frequency = toFredLetter(opt.Frequency);
    end
    FREQUENCY_CONVERSION = sprintf( ...
        FREQUENCY_CONVERSION, lower(opt.Frequency), lower(opt.AggregationMethod) ...
    );
    REQUEST = [REQUEST, FREQUENCY_CONVERSION];
end

fredSeriesId = cellstr(fredSeriesId);
numSeries = numel(fredSeriesId);
validSeriesId = true(1, numSeries);
dataRetrieved = true(1, numSeries);
for i = 1 : numSeries
    fredSeriesId__ = fredSeriesId{i};
    matches = regexp(fredSeriesId__, '\w+', 'match');
    if numel(matches)==1
        databankName__ = matches{1};
        fredSeriesId__ = matches{1};
    else
        databankName__ = matches{2};
        fredSeriesId__ = matches{1};
    end
    try
        request__ = sprintf(REQUEST, fredSeriesId__, FRED_API_KEY);
        jsonInfo = webread([URL_INFO, request__]);
        jsonData = webread([URL_DATA, request__]);
    catch Error
        validSeriesId(i) = false;
        continue
    end
    try
        x = locallyExtractDataFromJson(jsonInfo, jsonData, opt);
        outputDb.(char(databankName__)) = x;
    catch Error
        dataRetrieved(i) = false;
    end
end

if any(~validSeriesId)
    throw( ...
        exception.Base('Databank:InvalidSeriesId', 'warning'), ...
        fredSeriesId{~validSeriesId} ...
    );
end

if any(~dataRetrieved)
    throw( ...
        exception.Base('Databank:FailedToRetrieveData', 'warning'), ...
        fredSeriesId{~dataRetrieved} ...
    );
end

status = all(validSeriesId) && all(dataRetrieved);

end%


%
% Local Functions
%


function outputSeries = locallyExtractDataFromJson(jsonInfo, jsonData, opt)
    freq = locallyGetFrequencyFromJsonInfo(jsonInfo, opt);
    if freq==Frequency.DAILY
        dates = datenum( {jsonData.observations.date} );
    else
        dates = str2dat( ...
            {jsonData.observations.date}, ...
            'DateFormat=', 'YYYY-MM-DD', ...
            'Freq=', freq ...
        );
    end
    numPeriods = numel(jsonData.observations);
    values = nan(numPeriods, 1);
    for i = 1 : numPeriods
        value__ = sscanf(jsonData.observations(i).value, '%g');
        if isnumeric(value__) && numel(value__)==1
            values(i) = value__;
        end
    end
    outputSeries = Series( ...
        dates, values, jsonInfo.seriess.title, jsonInfo.seriess, "--SkipInputParser" ...
    );
end%




function freq = locallyGetFrequencyFromJsonInfo(jsonInfo, opt)
    if ~isempty(opt.Frequency)
        frequencyLetter = opt.Frequency;
    else
        frequencyLetter = jsonInfo.seriess.frequency_short;
    end
    frequencyLetter = lower(frequencyLetter);
    switch frequencyLetter
        case 'm' 
            freq = Frequency.MONTHLY;
        case 'q'
            freq = Frequency.QUARTERLY;
        case 'sa'
            freq = Frequency.HALFYEARLY;
        case 'a'
            freq = Frequency.YEARLY;
        case 'd'
            freq = Frequency.DAILY;
        otherwise
            throw( exception.Base('Databank:CannotDetermineFrequencyFromJson', 'error') );
    end
end%




function flag = locallyValidateFrequency(input)
    FREQUENCIES_ALLOWED = [ 
        Frequency.YEARLY
        Frequency.HALFYEARLY
        Frequency.QUARTERLY
        Frequency.MONTHLY
    ];
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

