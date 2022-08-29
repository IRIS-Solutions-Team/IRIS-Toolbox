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


% <=R2019a
%(
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
%)
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

