%{
% 
% # `databank.fromECB.data`
% 
% {== Download databank of time series from ECB Statistical Data Warehouse ==}
% 
% 
% ## Syntax
% 
%     [db, info] = databank.fromECB.data(dataset, skeys, ___)
% 
% 
% ## TL;DR
% 
%     [db, info] = databank.fromECB.data("EXR", "M.USD.EUR.SP00.A")
% 
%     [db, info] = databank.fromECB.data("EXR", "M.CHF+USD.EUR.SP00.A")
% 
%     [db, info] = databank.fromECB.data("EXR", {"M", ["CHF", USD"], "EUR.SP00.A"})
% 
% 
% ## Input arguments
% 
% __`dataset`__ [ string ]
% > 
% > Dataset identifier (usualy a three-letter string); only one dataset is
% > allowed in one request.
% > 
% 
% 
% __`skeys`__ [ string | cell ]
% > 
% > Series key or keys specified one of the following ways:
% > 
% > * A single string with requested dimensions separated by periods, `.`; connect
% >   more than one value in a dimension using a plus sign, `+`.
% > 
% > * A cell array of strings or string arrays; the cells will be joined by a
% >   period, `.`; if a cell contains a string array, the individual array
% >   elements will be joind by a plus sign, `+`.
% > 
% 
% 
% ## Output arguments
% 
% __`outputDb`__ [ struct | Dictionay ]
% > 
% > Output databank with the requested series.
% > 
% 
% __`info`__ [ struct ]
% > 
% > Output information struct with the following fields:
% > 
% > * `.Request` - a string with the entire URL request
% > 
% > * `.Response` - a JSON struct with the ECB SDW response
% > 
% 
% 
% ## Options
% 
% __`AddToDatabank=[]`__ [ struct | Dictionary | empty ]
% > 
% > The new time series will be added to this databank.
% > 
% 
% __`Attributes=true`__ [ `true` | `false` ]
% > 
% > Read also the attributes for each time series and populated the time
% > series comments and user data; if `Attributes=false`, the attributes are
% > not requested, and the output time series do not have their comments and
% > user data populated from them.
% > 
% 
% __`OutputType="struct"` [ `"struct"`  | `"Dictionary"` ]
% > 
% > Type of the output databank (struct or Dictionary).
% > 
% 
% __`DimensionSeparator="_"`__ [ string ]
% > 
% > String that will be used to separate the individual dimensions in the
% > names of the series (the dimensions are separated with periods, `.`, in
% > the URL request, which cannot be part of struct fields in Matlab).
% > 
% 
% __`CommentFrom="TITLE"`__ [ string ]
% > 
% > Name of the ECB SDW attribute on which each time series comment will be
% > based.
% > 
% 
% 
% ## Description
% 
% See the
% [ECB SDW API manual](https://sdw-wsrest.ecb.europa.eu/help/#tabData)
% for details on how to look up and specify the datasets and time series
% dimensions.
% 
% Visit the 
% [ECB SDW web interface](https://sdw.ecb.europa.eu)
% to browse the time series.
% 
% 
% ## Examples
% 
% Download a monthly time series for the USD/EUR exchange rate 
% 
% ```matlab
% [db, info] = databank.fromECB.data("EXR", "M.USD.EUR.SP00.A")
% ```
% 
% Download a monthly and a yearly (annual) time series for the USD/EUR exchange rate;
% note the multiple dimension request `A+M`
% 
% ```matlab
% [db, info] = databank.fromECB.data("EXR", "A+M.USD.EUR.SP00.A")
% ```
% 
% The previous data request is equivalent to 
% 
% ```matlab
% [db, info] = databank.fromECB.data("EXR", {["A", "M"], "USD.EUR.SP00.A"})
% ```
% 
% 
% Download monthly and yearly (annual) time series for multiple exchange
% rates: USD, CHF, JPY; the following two requests are eqivalent
% 
% ```matlab
% [db, info] = databank.fromECB.data("EXR", "A+M.USD+CHF+JPY.EUR.SP00.A")
% [db, info] = databank.fromECB.data("EXR", {["A", "M"], ["USD", "CHF", "JPY"], "EUR.SP00.A"})
% ```
% 
%}
% --8<--


% >=R2019b
%(
function [outputDb, info] = data(dataset, skeys, opt)

arguments
    dataset (1, 1) string
    skeys (1, :) 

    opt.Attributes (1, 1) logical = true
    opt.AddToDatabank = []
    opt.OutputType = "__auto__"
    opt.DimensionSeparator = "_"
    opt.CommentFrom = "TITLE"
    opt.Postprocess = []

    opt.URL (1, 1) string = databank.fromECB.Config.URL
    opt.WebOptions = databank.fromECB.Config.WebOptions

    opt.NameFunc = {}
end
%)
% >=R2019b


% <=R2019a
%{
function [outputDb, info] = data(dataset, skeys, varargin)

persistent ip
if isempty(ip)
    ip = inputParser(); 
    addParameter(ip, "Attributes", true);
    addParameter(ip, "AddToDatabank", []);
    addParameter(ip, "OutputType", "__auto__");
    addParameter(ip, "DimensionSeparator", "_");
    addParameter(ip, "CommentFrom", "TITLE");
    addParameter(ip, "Postprocess", []);

    addParameter(ip, "URL", databank.fromECB.Config.URL);
    addParameter(ip, "WebOptions", databank.fromECB.Config.WebOptions);

    addParameter(ip, "NameFunc", {});
end
parse(ip, varargin{:});
opt = ip.Results;
%}
% <=R2019a


info = struct();

params = struct();
if ~opt.Attributes
    params.detail = "dataonly";
end
info.Request = databank.fromECB.Config.createRequest(opt.URL, "data", dataset, skeys, params);
response = webread(info.Request, opt.WebOptions);
info.Response = jsondecode(response);

outputDb = databank.backend.ensureTypeConsistency( ...
    opt.AddToDatabank, ...
    opt.OutputType ...
);


%
% Parse JSON to output databank
%
[outputDb, info.NamesCreated] = local_outputFromResponse(outputDb, info.Response, opt);


%
% Apply postprocess function
%
outputDb = databank.backend.postprocess(outputDb, info.NamesCreated, opt.Postprocess);


end%

%
% Local functions
%

function [db, namesCreated] = local_outputFromResponse(db, response, opt)
    %(
    if ~iscell(opt.NameFunc) && ~isempty(opt.NameFunc)
        opt.NameFunc = {opt.NameFunc};
    end

    refDates = reshape(string({response.structure.dimensions.observation.values.id}), [], 1);;
    refDates = dater.fromSdmxString(refDates);
    if opt.Attributes
        refAttribs = response.structure.attributes.series;
    end
    dimSeries = response.structure.dimensions.series;
    data = response.dataSets.series;
    namesCreated = string.empty(1, 0);
    for raw = textual.fields(data)
        x = data.(raw).observations;
        outputName = local_decodeSkey(raw, dimSeries, opt);
        for i = 1 : numel(opt.NameFunc)
            if ~isempty(opt.NameFunc{i})
                outputName = opt.NameFunc{i}(outputName);
            end
        end
        namesCreated = [namesCreated, outputName];
        values = struct2cell(x);
        if isempty(values)
            db.(outputName) = Series();
            continue
        end
        values = [values{:}];
        values = reshape(values(1, :), [], 1);
        dates = local_decodeDates(textual.fields(x, [], 1), refDates);
        comment = "";
        userData = [];
        if opt.Attributes
            [comment, userData] = local_decodeAttribs(data.(raw).attributes, refAttribs, opt);
        end
        db.(outputName) = Series(dates, values, comment, userData);
    end
    %)
end%


function skey = local_decodeSkey(raw, dimSeries, opt)
    %(
    raw = 1 + double(split(extractAfter(raw, 1), "_"));
    skey = "";
    for i = 1 : numel(raw)
        skey = skey + opt.DimensionSeparator + dimSeries(i).values(raw(i)).id;
    end
    skey = extractAfter(skey, opt.DimensionSeparator);
    %)
end%


function dates = local_decodeDates(raw, refDates)
    raw = 1 + double(extractAfter(raw, 1));
    dates = refDates(raw);
end%


function [comment, userData] = local_decodeAttribs(raw, refAttribs, opt)
    %(
    raw = 1 + raw;
    userData = struct();
    comment = "";
    for i = reshape(find(isfinite(raw)), 1, [])
        id = string(refAttribs(i).id); 
        value = refAttribs(i).values(raw(i)).name;
        if ischar(value)
            value = string(value);
        end
        userData.(id) = value;
        if id==opt.CommentFrom
            comment = string(value);
        end
    end
    %)
end%

