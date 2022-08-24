% >=R2019b
%{
function [summaryTable, dimTables, json, info] = dimensions(dataset, opt)

arguments
    dataset (1, 1) string

    opt.URL (1, 1) string = databank.fromIMF.Config.URL + "DataStructure/"
    opt.WebOptions = databank.fromIMF.Config.WebOptions
    opt.WriteTable (1, 1) string = ""
end
%}
% >=R2019b


% <=R2019a
%(
function [summaryTable, dimTables, json, info] = dimensions(dataset, varargin)

persistent ip
if isempty(ip)
    ip = inputParser(); 
    addParameter(ip, "URL", databank.fromIMF.Config.URL + "DataStructure/");
    addParameter(ip, "WebOptions", databank.fromIMF.Config.WebOptions);
    addParameter(ip, "WriteTable", "");
end
parse(ip, varargin{:});
opt = ip.Results;
%)
% <=R2019a


[response, request] = databank.fromIMF.Config.request( ...
    opt.URL, upper(dataset), opt.WebOptions ...
);

try
    json = response.Structure.CodeLists.CodeList;
catch
    exception.error([
        "Databank:IMF:InvalidResponse"
        "This request returned no reponse or an invalid response: %s"
    ], request);
end

numDimensions = numel(json);
dimTables = cell(1, numDimensions);

summaryID = string.empty(0, 1);
summaryName = string.empty(0, 1);

for i = 1 : numDimensions
    codes = reshape(string({json{i}.Code(:).x_value}), [], 1);
    descriptions = [json{i}.Code(:).Description];
    descriptions = reshape(string({descriptions.x_text}), [], 1);
	json{i}.x_id = locallyFixId(json{i}.x_id);
    summaryID(end+1, 1) = json{i}.x_id;
    summaryName(end+1, 1) = json{i}.Name.x_text;
    dimTables{i} = table(codes, descriptions);
	dimTables{i}.Properties.Description = json{i}.Name.x_text;
	columnName = locallyFixColumnName(json{i}.Name.x_text);
    dimTables{i}.Properties.VariableNames = { 'Code', char(columnName) };
end % for

summaryTable = table(summaryID, summaryName);
summaryTable.Properties.VariableNames = {'ID', 'Name'};

if strlength(opt.WriteTable)>0
    fileName = databank.fromIMF.Config.writeSummaryTable(opt.WriteTable, summaryTable);
    locallyWriteDimTables(fileName, dimTables, json);
end % if

info = struct();
info.Request = request;
info.Response = response;

end%

%
% Local function
%

function locallyWriteDimTables(fileName, dimTables, json)
    %(
    for i = 1 : numel(dimTables)
        writetable( ...
            dimTables{i}, fileName ...
            , "fileType", "spreadsheet" ...
            , "writeMode", "overwritesheet" ...
            , "sheet", json{i}.x_id ...
        );
    end % for
    %)
end%


function id = locallyFixId(id)
	%(
	id = erase(id, "CL_");
	id = erase(id, "Balance of Payments (BOP) ");
	id = erase(id, [" ", "(", ")"]);
	if strlength(id)>31
		id = extractBefore(id, 31);
	end
	%)
end%


function columnName = locallyFixColumnName(columnName)
	%(
	if contains(columnName, "Indicator", "ignoreCase", true)
		columnName = "Indicator";
		return
	end
	%)
end%


