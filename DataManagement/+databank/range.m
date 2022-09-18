% >=R2019b
%{
function [outputRange, listFreq, namesApplied] = range(inputDb, opt)

arguments
    inputDb {validate.mustBeDatabank}

    opt.SourceNames {local_validateSourceNames} = @all
        opt.NameList__SourceNames = []
    opt.StartDate {local_validateDate} = "unbalanced"
    opt.EndDate {local_validateDate} = "unbalanced"
    opt.Frequency {local_validateFrequency} = @any
    opt.MultiFrequencies (1, 1) logical = true
    opt.Filter (1, :) cell = cell.empty(1, 0)
end
%}
% >=R2019b


% <=R2019a
%(
function [outputRange, listFreq, namesApplied] = range(inputDb, varargin)

% Input parser
persistent ip
if isempty(ip)
    ip = extend.InputParser('databank.range');

    addParameter(ip, "SourceNames", @all);
        addParameter(ip, "NameList__SourceNames", []);
    addParameter(ip, "StartDate", "unbalanced");
    addParameter(ip, "EndDate", "unbalanced");
    addParameter(ip, "Frequency", @any);
    addParameter(ip, "MultiFrequencies", true);
    addParameter(ip, "Filter", cell.empty(1, 0));
end
parse(ip, varargin{:});
opt = ip.Results;
%)
% <=R2019a


opt = iris.utils.resolveOptionAliases(opt, [], true);


listNames = here_filterNames();
listFreq = here_filterFreq();

numFreq = numel(listFreq);
startDates = cell(1, numFreq);
endDates = cell(1, numFreq);
outputRange = cell(1, numFreq);
namesApplied = string.empty(1, 0);
for name = listNames
    if ~isfield(inputDb, name)
        continue
    end
    field = inputDb.(name);
    if ~isa(field, 'Series')
        continue
    end
    namesApplied = [namesApplied, name]; %#ok<*AGROW>
    inxFreq = getFrequencyAsNumeric(field)==listFreq;
    if any(inxFreq)
        startDates{inxFreq}(end+1) = getStartAsNumeric(field);
        endDates{inxFreq}(end+1) = getEndAsNumeric(field);
    end
end

if any(strcmpi(opt.StartDate, {'MaxRange', 'Unbalanced', 'Any'}))
    startDates = cellfun(@min, startDates, 'uniformOutput', false);
else
    startDates = cellfun(@max, startDates, 'uniformOutput', false);
end

if any(strcmpi(opt.EndDate, {'MaxRange', 'Unbalanced', 'Any'}))
    endDates = cellfun(@max, endDates, 'uniformOutput', false);
else
    endDates = cellfun(@min, endDates, 'uniformOutput', false);
end

for i = find(~cellfun(@isempty, startDates))
    outputRange{i} = Dater(startDates{i} : endDates{i});
end

inxEmpty = cellfun(@isempty, outputRange);
if sum(~inxEmpty)==0
    outputRange = [ ];
    listFreq = [ ];
elseif sum(~inxEmpty)==1
    outputRange = outputRange{~inxEmpty};
    listFreq = listFreq(~inxEmpty);
else
    outputRange = outputRange(~inxEmpty);
    listFreq = listFreq(~inxEmpty);
end

if ~opt.MultiFrequencies && iscell(outputRange) && numel(outputRange)>1
    exception.error([
        "Databank"
        "Multiple date frequencies found in the input databank "
        "but disallowed by setting MultiFrequencies=false."
    ]);
end

return

    function listNames = here_filterNames( )
        %(
        if ~isempty(opt.Filter)
            listNames = databank.filter(inputDb, opt.Filter{:});
        else
            allInputEntries = reshape(string(fieldnames(inputDb)), 1, [ ]);
            listNames = opt.SourceNames;
            if validate.string(listNames)
                listNames = reshape(string(listNames), 1, [ ]);
                if numel(listNames)==1
                    if isa(inputDb, 'Dictionary')
                        listNames = regexp(listNames, '[\w\.]+', 'match');
                    else
                        listNames = regexp(listNames, '\w+', 'match');
                    end
                end
            elseif isa(listNames, 'rexp') || isa(listNames, 'Rxp')
                inxMatched = ~cellfun(@isempty, regexp(allInputEntries, string(listNames), 'once'));
                listNames = allInputEntries(inxMatched);
            elseif isequal(listNames, @all) || isequal(listNames, Inf)
                listNames = allInputEntries;
            end
        end
        listNames = textual.stringify(listNames);
        %)
    end%


    function listFreq = here_filterFreq()
        %(
        if isequal(opt.Frequency, @any) || isequal(opt.Frequency, @all)
            listFreq = frequency.ALL_FREQUENCIES;
        else
            listFreq = unique(reshape(double(opt.Frequency), 1, []), 'stable');
        end
        %)
    end%
end%

%
% Local validators
%

function local_validateSourceNames(x)
    %(
    if isequal(x, Inf) || isequal(x, @all) || isstring(x) || ischar(x) || iscellstr(x) || isa(x, 'Rxp')
        return
    end
    error("Input value must be @all, an array of strings, or a Rxp object.");
    %)
end%


function local_validateDate(x)
    %(
    if validate.anyString(x, "maxRange", "minRange", "any", "all", "unbalanced", "balanced")
        return
    end
    error("Input value must be ""balanced"" or ""unbalanced"".");
    %)
end%


function local_validateFrequency(x)
    %(
    if validate.frequency(x) || isequal(x, @all) || isequal(x, @any)
        return
    end
    error("Input values must be a valid Frequency, or @any.");
    %)
end%

