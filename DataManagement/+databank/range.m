% Type `web +databank/range.md` for help on this function
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2021 [IrisToolbox] Solutions Team

% <=R2019a
%(
function [range, listFreq, namesApplied] = range(inputDb, options)

arguments
    inputDb {validate.mustBeDatabank}

    options.SourceNames {locallyValidateSourceNames} = @all
    options.NameList {locallyValidateSourceNames} = @all
    options.StartDate {locallyValidateDate} = "unbalanced"
    options.EndDate {locallyValidateDate} = "unbalanced"
    options.Frequency {locallyValidateFrequency} = @any
    options.Filter (1, :) cell = cell.empty(1, 0)
end

if ~isequal(options.NameList, @all)
    options.SourceNames = options.NameList;
end
%)
% <=R2019a


% <=R2019a
%{
function [range, listFreq, namesApplied] = range(inputDb, varargin)

% Input parser
persistent pp
if isempty(pp)
    pp = extend.InputParser('databank.range');
    addRequired(pp, 'inputDb', @validate.databank);

    addParameter(pp, ["SourceNames", "NameList"], @all, @(x) isequal(x, @all) || validate.string(x) || isa(x, "Rxp"));
    addParameter(pp, 'StartDate', 'MaxRange', @(x) validate.anyString(x, 'MaxRange', 'MinRange', 'Any', 'All', 'Unbalanced', 'Balanced'));
    addParameter(pp, 'EndDate', 'MaxRange', @(x) validate.anyString(x, 'MaxRange', 'MinRange', 'Any', 'All', 'Unbalanced', 'Balanced'));
    addParameter(pp, {'Frequency', 'Frequencies'}, @any, @(x) isequal(x, @all) || isequal(x, @any) || validate.frequency(x));
    addParameter(pp, 'Filter', cell.empty(1, 0), @validate.nestedOptions);
end
options = parse(pp, inputDb, varargin{:});
%}
% <=R2019a


stringify = @(x) reshape(string(x), 1, []);

listNames = hereFilterNames( );
listFreq = hereFilterFreq( );

numFreq = numel(listFreq);
startDates = cell(1, numFreq);
endDates = cell(1, numFreq);
range = cell(1, numFreq);
namesApplied = string.empty(1, 0);
for name = listNames
    if ~isfield(inputDb, name)
        continue
    end
    field = inputDb.(name);
    if ~isa(field, 'TimeSubscriptable')
        continue
    end
    namesApplied = [namesApplied, name]; %#ok<*AGROW>
    inxFreq = getFrequencyAsNumeric(field)==listFreq;
    if any(inxFreq)
        startDates{inxFreq}(end+1) = getStartAsNumeric(field);
        endDates{inxFreq}(end+1) = getEndAsNumeric(field);
    end
end

if any(strcmpi(options.StartDate, {'MaxRange', 'Unbalanced', 'Any'}))
    startDates = cellfun(@min, startDates, 'uniformOutput', false);
else
    startDates = cellfun(@max, startDates, 'uniformOutput', false);
end

if any(strcmpi(options.EndDate, {'MaxRange', 'Unbalanced', 'Any'}))
    endDates = cellfun(@max, endDates, 'uniformOutput', false);
else
    endDates = cellfun(@min, endDates, 'uniformOutput', false);
end

for i = find(~cellfun(@isempty, startDates))
    range{i} = DateWrapper(startDates{i} : endDates{i});
end

inxEmpty = cellfun(@isempty, range);
if sum(~inxEmpty)==0
    range = [ ];
    listFreq = [ ];
elseif sum(~inxEmpty)==1
    range = range{~inxEmpty};
    listFreq = listFreq(~inxEmpty);
else
    range = range(~inxEmpty);
    listFreq = listFreq(~inxEmpty);
end

return

    function listNames = hereFilterNames( )
        %(
        if ~isempty(options.Filter)
            listNames = databank.filter(inputDb, options.Filter{:});
        else
            allInputEntries = reshape(string(fieldnames(inputDb)), 1, [ ]);
            listNames = options.SourceNames;
            if validate.string(listNames)
                listNames = reshape(string(listNames), 1, [ ]);
                if numel(listNames)==1
                    if isa(inputDb, 'Dictionary')
                        listNames = regexp(listNames, '[\w\.]+', 'match');
                    else
                        listNames = regexp(listNames, '\w+', 'match');
                    end
                end
            elseif isa(listNames, "rexp") || isa(listNames, "Rxp")
                inxMatched = ~cellfun(@isempty, regexp(allInputEntries, string(listNames), 'once'));
                listNames = allInputEntries(inxMatched);
            elseif isequal(listNames, @all)
                listNames = allInputEntries;
            end
        end
        listNames = stringify(listNames);
        %)
    end%


    function listFreq = hereFilterFreq( )
        %(
        if isequal(options.Frequency, @any) || isequal(options.Frequency, @all)
            listFreq = reshape(double(iris.get('freq')), 1, [ ]);
        else
            listFreq = unique(reshape(double(options.Frequency), 1, [ ]), 'stable');
        end
        %)
    end%
end%

%
% Local validators
%

function locallyValidateSourceNames(x)
    %(
    if isequal(x, @all) || isstring(x) || ischar(x) || iscellstr(x) || isa(x, 'Rxp')
        return
    end
    error("Input value must be @all, an array of strings, or a Rxp object.");
    %)
end%


function locallyValidateDate(x)
    %(
    if validate.anyString(x, "maxRange", "minRange", "any", "all", "unbalanced", "balanced")
        return
    end
    error("Input value must be ""balanced"" or ""unbalanced"".");
    %)
end%


function locallyValidateFrequency(x)
    %(
    if validate.frequency(x) || isequal(x, @all) || isequal(x, @any)
        return
    end
    error("Input values must be a valid Frequency, or @any.");
    %)
end%

