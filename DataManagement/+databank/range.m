function [range, listFreq] = range(inputDatabank, varargin)
% range  Find a range that encompasses the ranges of the listed tseries objects
%{
% ## Syntax ##
%
%     [range, listFreq] = databank.range(inputDatabank, ...)
%
%
% ## Input Arguments ##
%
% __`inputDatabank`__ [ struct | containers.Map | Dictionary ] -
% Input databank; can be either a struct, a containers.Map, or a
% Dictionary.
%
% ## Output Arguments ##
%
% __`range`__ [ numeric | cell ] - 
% Range that encompasses the observations of the tseries objects in the
% input database; if tseries objects with different frequencies exist, the
% ranges are returned in a cell array.
%
% __`listFreq`__ [ numeric ] - 
% Vector of date frequencies coresponding to the returned ranges.
%
%
% ## Options ##
%
% __`List=@all`__ [ cellstr | rexp | `@all` ] - 
% List of time series that will be included in the range search or a
% regular expression that will be matched to compose the list; `@all` means
% all tseries objects existing in the input databases will be included; may
% be omitted.
%
%
% __`StartDate='MaxRange'`__ [ `'MaxRange'` | `'MinRange'` ] - 
% `'MaxRange'` means the output `Range` will start at the earliest start
% date among all time series included in the search; `'MinRange'` means the
% `range` will start at the latest start date.
%
% __`EndDate='MaxRange'`__ [ `'MaxRange'` | `'MinRange'` ] - 
% `'MaxRange'` means the `range` will end at the latest end date among all
% time series included in the search; `'MinRange'` means the `range` will
% end at the earliest end date.
%
%
% ## Description ##
%
%
% ## Example ##
%
%}

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

persistent pp
if isempty(pp)
    pp = extend.InputParser('databank.range');
    addRequired(pp, 'inputDatabank', @validate.databank);

    addParameter(pp, 'NameList', @all, @(x) isequal(x, @all) || validate.string(x) || isa(x, 'rexp'));
    addParameter(pp, 'StartDate', 'MaxRange', @(x) validate.anyString(x, 'MaxRange', 'MinRange', 'Any', 'All', 'Unbalanced', 'Balanced'));
    addParameter(pp, 'EndDate', 'MaxRange', @(x) validate.anyString(x, 'MaxRange', 'MinRange', 'Any', 'All', 'Unbalanced', 'Balanced'));
    addParameter(pp, {'Frequency', 'Frequencies'}, @any, @(x) isequal(x, @any) || isa(x, 'Frequency'));
end
parse(pp, inputDatabank, varargin{:});
opt = pp.Options;

allInputEntries = fieldnames(inputDatabank);
allInputEntries = reshape(cellstr(allInputEntries), 1, [ ]);

list = opt.NameList;
if validate.string(list)
    list = regexp(list, '\w+', 'match');
elseif isa(list, 'rexp')
    inxMatched = ~cellfun(@isempty, regexp(allInputEntries, list, 'once'));
    list = allInputEntries(inxMatched);
elseif isequal(list, @all)
    list = allInputEntries;
end

%--------------------------------------------------------------------------

if isequal(opt.Frequency, @any)
    listFreq = reshape(iris.get('freq'), 1, [ ]);
else
    listFreq = unique(reshape(opt.Frequency, 1, [ ]), 'stable');
end

numFreq = numel(listFreq);
startDates = cell(1, numFreq);
endDates = cell(1, numFreq);
range = cell(1, numFreq);
numEntries = numel(list);
for i = 1 : numEntries
    if ~any(strcmp(list{i}, allInputEntries))
        continue
    end
    name__ = list{i};
    field__ = inputDatabank.(name__);
    if ~isa(field__, 'TimeSubscriptable')
        continue
    end
    inxFreq = field__.Frequency==listFreq;
    if any(inxFreq)
        startDates{inxFreq}(end+1) = field__.StartAsNumeric;
        endDates{inxFreq}(end+1) = field__.EndAsNumeric;
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

end%

