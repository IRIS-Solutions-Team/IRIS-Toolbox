
% >=R2019b
%{
function [outputSeries, names, dates] = toSeries(inputDb, names, dates, columns)

arguments
    inputDb (1, 1) {validate.databank(inputDb)}

    names {local_validateNames(names)} = @all
    dates {local_validateDates(dates)} = @all
    columns (1, :) {mustBePositive} = 1
end
%}
% >=R2019b


% <=R2019a
%(
function [outputSeries, names, dates] = toSeries(inputDb, varargin)

persistent ip
if isempty(ip)
    ip = inputParser(); 
    addOptional(ip, "names", @all, @local_validateNames);
    addOptional(ip, "dates", @all, @local_validateDates);
    addOptional(ip, "columns", 1, @isnumeric);
end
parse(ip, varargin{:});
names = ip.Results.names;
dates = ip.Results.dates;
columns = ip.Results.columns;
%)
% <=R2019a


if isequal(names, @all)
    names = keys(inputDb);
    inxSeries = cellfun(@(n) isa(inputDb.(n), 'Series'), names);
    names = names(inxSeries);
else
    names = reshape(string(names), 1, [ ]);
end

if isempty(names)
    exception.error([
        "Databank"
        "The list of time series names requested resolved to an empty array."
    ]);
end

if isequal(dates, @all) || isequal(dates, Inf)
    dates = databank.range(inputDb, "sourceNames", names);
    if iscell(dates)
        exception.error([
            "Databank"
            "Time series requested include multiple date frequencies. "
            "Cannot determine the output dates. "
        ]);
    elseif isempty(dates)
        exception.error([
            "Databank"
            "None of the time series requested has proper date frequency. "
            "Cannot determine the output dates. "
        ]);
    end
end

[outputArray, ~, ~, headers, comments] = databank.toArray(inputDb, names, dates, columns);
outputSeries = Series(dates, outputArray, comments);
outputSeries.Headers = headers;

end%

%
% Local Validators
%

function local_validateNames(input)
    %(
    if isequal(input, @all) || isstring(input) || ischar(input) || iscellstr(input)
        return
    end
    error("Validation:Failed", "Input value must be an array of strings");
    %)
end%


function local_validateDates(input)
    %(
    if isequal(input, @all) || isequal(input, Inf) || validate.properDates(input)
        return
    end
    error("Validation:Failed", "Input value must be @all or an array of proper dates");
    %)
end%

