function [range, freqList] = dbrange(varargin)
% dbrange  Find a range that encompasses the ranges of the listed tseries objects
%{
% ## Syntax ##
%
% Input arguments marked with a `~` sign may be omitted
%
%     [range, freqList] = dbrange(d, ~list, ...)
%
%
% ## Input Arguments ##
%
% __`d`__ [ struct ] - 
% Input database.
%
% __`~list`__ [ cellstr | rexp | *`@all`* ] - 
% List of time series that will be included in the range search or a
% regular expression that will be matched to compose the list; `@all` means
% all tseries objects existing in the input databases will be included; may
% be omitted.
%
%
% ## Output Arguments ##
%
% __`range`__ [ numeric | cell ] - 
% Range that encompasses the observations of the tseries objects in the
% input database; if tseries objects with different frequencies exist, the
% ranges are returned in a cell array.
%
% __`freqList`__ [ numeric ] - 
% Vector of date frequencies coresponding to the returned ranges.
%
%
% ## Options ##
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

[d, list, varargin] = irisinp.parser.parse('dbase.dbrange', varargin{:});
opt = passvalopt('dbase.dbrange', varargin{:});

if ischar(list)
    list = regexp(list, '\w+', 'match');
elseif isa(list, 'rexp')
    f = fieldnames(d);
    inxMatched = ~cellfun(@isempty, regexp(f, list, 'once'));
    list = f(inxMatched);
elseif isequal(list, @all)
    list = fieldnames(d);
elseif isstring(list)
    list = cellstr(list);
end
list = reshape(list, 1, [ ]);

%--------------------------------------------------------------------------

freqList = iris.get('freq');
numFreq = length(freqList);
startDates = cell(1, numFreq);
endDates = cell(1, numFreq);
range = cell(1, numFreq);
numEntries = numel(list);
for i = 1 : numEntries
    if isfield(d, list{i}) && isa(d.(list{i}), 'TimeSubscriptable')
        x = d.(list{i});
        inxFreq = freq(x)==freqList;
        if any(inxFreq)
            startDates{inxFreq}(end+1) = x.Start;
            endDates{inxFreq}(end+1) = x.End;
        end
    end
end

if any(strcmpi(opt.startdate, {'maxrange', 'unbalanced'}))
    startDates = cellfun(@min, startDates, 'uniformOutput', false);
else
    startDates = cellfun(@max, startDates, 'uniformOutput', false);
end

if any(strcmpi(opt.enddate, {'maxrange', 'unbalanced'}))
    endDates = cellfun(@max, endDates, 'uniformOutput', false);
else
    endDates = cellfun(@min, endDates, 'uniformOutput', false);
end

for i = find(~cellfun(@isempty, startDates))
    range{i} = DateWrapper(startDates{i} : endDates{i});
end

isEmpty = cellfun(@isempty, range);
if sum(~isEmpty) == 0
    range = [ ];
    freqList = [ ];
elseif sum(~isEmpty) == 1
    range = range{~isEmpty};
    freqList = freqList(~isEmpty);
else
    range = range(~isEmpty);
    freqList = freqList(~isEmpty);
end

end%

