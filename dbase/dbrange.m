function [range, freqList] = dbrange(varargin)
% dbrange  Find a range that encompasses the ranges of the listed tseries objects.
%
%
% __Syntax__
%
% Input arguments marked with a `~` sign may be omitted.
%
%     [Range, FreqList] = dbrange(D, ~List, ...)
%
%
% __Input Arguments__
%
% * `D` [ struct ] - Input database.
%
% * `~List` [ cellstr | rexp | *`@all`* ] - List of time series that will
% be included in the range search or a regular expression that will be
% matched to compose the list; `@all` means all tseries objects existing in
% the input databases will be included; may be omitted.
%
%
% __Output Arguments__
%
% * `Range` [ numeric | cell ] - Range that encompasses the observations of
% the tseries objects in the input database; if tseries objects with
% different frequencies exist, the ranges are returned in a cell array.
%
% * `FreqList` [ numeric ] - Vector of date frequencies coresponding to the
% returned ranges.
%
%
% __Options__
%
% * `'StartDate='` [ *`'maxRange'`* | `'minRange'` ] - `'maxRange'` means
% the output `Range` will start at the earliest start date among all time
% series included in the search; `'minRange'` means the `range` will start
% at the latest start date.
%
% * `'EndDate='` [ *`'maxRange'`* | `'minRange'` ] - `'maxRange'` means the
% `range` will end at the latest end date among all time series included in
% the search; `'minRange'` means the `range` will end at the earliest end
% date.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

[d, list, varargin] = irisinp.parser.parse('dbase.dbrange', varargin{:});
opt = passvalopt('dbase.dbrange', varargin{:});

if ischar(list)
    list = regexp(list, '\w+', 'match');
elseif isa(list, 'rexp')
    f = fieldnames(d);
    ixMatched = ~cellfun(@isempty, regexp(f, list, 'once'));
    list = f(ixMatched);
elseif isequal(list, @all)
    list = fieldnames(d);
end

%--------------------------------------------------------------------------

freqList = iris.get('freq');
nFreq = length(freqList);
startDat = cell(1, nFreq);
endDat = cell(1, nFreq);
range = cell(1, nFreq);
nList = numel(list);

for i = 1 : nList
    if isfield(d, list{i}) && isa(d.(list{i}), 'TimeSubscriptable')
        x = d.(list{i});
        freqInx = freq(x) == freqList;
        if any(freqInx)
            startDat{freqInx}(end+1) = x.Start;
            endDat{freqInx}(end+1) = x.End;
        end
    end
end

if any(strcmpi(opt.startdate, {'maxrange', 'unbalanced'}))
    startDat = cellfun(@min, startDat, 'uniformOutput', false);
else
    startDat = cellfun(@max, startDat, 'uniformOutput', false);
end

if any(strcmpi(opt.enddate, {'maxrange', 'unbalanced'}))
    endDat = cellfun(@max, endDat, 'uniformOutput', false);
else
    endDat = cellfun(@min, endDat, 'uniformOutput', false);
end

for i = find(~cellfun(@isempty, startDat))
    range{i} = DateWrapper(startDat{i} : endDat{i});
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

end
