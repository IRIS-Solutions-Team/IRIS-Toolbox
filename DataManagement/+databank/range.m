% range  Find a range that encompasses the ranges of all or selected databank time series
%{
%% Syntax
%--------------------------------------------------------------------------
%
%     [range, listFreq] = databank.range(inputDb, ...)
%
%
%% Input Arguments
%--------------------------------------------------------------------------
%
% __`inputDb`__ [ struct | containers.Map | Dictionary ]
%
%     Input databank; can be either a struct, a containers.Map, or a
%     Dictionary.
%
%
%% Output Arguments
%--------------------------------------------------------------------------
%
% __`range`__ [ numeric | cell ] 
%
%     Range that encompasses the observations of the tseries objects in the
%     input database; if tseries objects with different frequencies exist,
%     the ranges are returned in a cell array.
%
%
% __`listFreq`__ [ numeric ]
%
%     Vector of date frequencies coresponding to the returned ranges.
%
%
% Options
%--------------------------------------------------------------------------
%
% __`List=@all`__ [ cellstr | rexp | `@all` ]
%
%     List of time series that will be included in the range search or a
%     regular expression that will be matched to compose the list; `@all`
%     means all time series objects existing in the input databases will be
%     included.
%
%
% __`StartDate='MaxRange'`__ [ `'MaxRange'` | `'MinRange'` ]
%
%     `'MaxRange'` means the output `Range` will start at the earliest
%     start date among all them time series included in the search;
%     `'MinRange'` means the `range` will start at the latest start date.
%
%
% __`EndDate='MaxRange'`__ [ `'MaxRange'` | `'MinRange'` ] 
%
%     `'MaxRange'` means the `range` will end at the latest end date among
%     all the time series included in the search; `'MinRange'` means the
%     `range` will end at the earliest end date.
%
%
%% Description
%--------------------------------------------------------------------------
%
%
%% Example
%--------------------------------------------------------------------------
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

function [range, listFreq, namesApplied] = range(inputDb, varargin)

%( Input parser
persistent pp
if isempty(pp)
    pp = extend.InputParser('databank.range');
    addRequired(pp, 'inputDb', @validate.databank);

    addParameter(pp, ["SourceNames", "NameList"], @all, @(x) isequal(x, @all) || validate.string(x) || isa(x, 'rexp'));
    addParameter(pp, 'StartDate', 'MaxRange', @(x) validate.anyString(x, 'MaxRange', 'MinRange', 'Any', 'All', 'Unbalanced', 'Balanced'));
    addParameter(pp, 'EndDate', 'MaxRange', @(x) validate.anyString(x, 'MaxRange', 'MinRange', 'Any', 'All', 'Unbalanced', 'Balanced'));
    addParameter(pp, {'Frequency', 'Frequencies'}, @any, @(x) isequal(x, @all) || isequal(x, @any) || validate.frequency(x));
    addParameter(pp, 'Filter', cell.empty(1, 0), @validate.nestedOptions);
end
%)
opt = parse(pp, inputDb, varargin{:});

%--------------------------------------------------------------------------

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
    inxFreq = field.Frequency==listFreq;
    if any(inxFreq)
        startDates{inxFreq}(end+1) = field.StartAsNumeric;
        endDates{inxFreq}(end+1) = field.EndAsNumeric;
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

for i = find(~cellfun("isempty", startDates))
    range{i} = DateWrapper(startDates{i} : endDates{i});
end

inxEmpty = cellfun("isempty", range);
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
                inxMatched = ~cellfun("isempty", regexp(allInputEntries, string(listNames), 'once'));
                listNames = allInputEntries(inxMatched);
            elseif isequal(listNames, @all)
                listNames = allInputEntries;
            end
        end
        %)
    end%


    function listFreq = hereFilterFreq( )
        %(
        if isequal(opt.Frequency, @any) || isequal(opt.Frequency, @all)
            listFreq = reshape(iris.get('freq'), 1, [ ]);
        else
            listFreq = unique(reshape(opt.Frequency, 1, [ ]), 'stable');
        end
        %)
    end%
end%

