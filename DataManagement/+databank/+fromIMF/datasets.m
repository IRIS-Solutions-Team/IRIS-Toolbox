% >=R2019b
%{
function [summaryTable, json, info] = datasets(opt)

arguments
    opt.URL (1, 1) string = databank.fromIMF.Config.URL + "DataFlow"
    opt.WebOptions = databank.fromIMF.Config.WebOptions
    opt.WriteTable (1, 1) string = ""
end
%}
% >=R2019b


% <=R2019a
%(
function [summaryTable, json, info] = datasets(varargin)

persistent ip
if isempty(ip)
    ip = inputParser(); 
    addParameter(ip, "URL", databank.fromIMF.Config.URL + "DataFlow");
    addParameter(ip, "WebOptions", databank.fromIMF.Config.WebOptions);
    addParameter(ip, "WriteTable", "");
end
parse(ip, varargin{:});
opt = ip.Results;
%)
% <=R2019a


[response, request] = databank.fromIMF.Config.request( ...
    opt.URL, "", opt.WebOptions ...
);

try
    json = response.Structure.Dataflows.Dataflow;
catch
    exception.error([
        "Databank:IMF:InvalidResponse"
        "This request returned no reponse or an invalid response: %s"
    ], request);
end

numDatasets = numel(json);

datasetNames = string.empty(0, 1);
datasetIds = string.empty(0, 1);

for i = 1 : numDatasets
    datasetNames(end+1, 1) = string(json{i}.Name.x_text);
    datasetIds(end+1, 1) = string(json{i}.KeyFamilyRef.KeyFamilyID);
end % for

summaryTable = table(datasetIds, datasetNames);
summaryTable.Properties.VariableNames = {'ID', 'Description'};

if strlength(opt.WriteTable)>0
    databank.fromIMF.Config.writeSummaryTable(opt.WriteTable, summaryTable);
end

info = struct();
info.Request = request;
info.Response = response;

end%

%
% Local function
%

