function D = dbclip(D, varargin)
% dbclip  Clip all tseries entries in database down to specified date range.
%
% __Syntax__
%
%     D = d(D, Range)
%
%
% __Input Arguments__
%
% * `D` [ struct ] - Database or nested databases with tseries objects.
%
% * `Range` [ numeric | cell ] - Range or a cell array of ranges to which
% all tseries objects will be clipped; multiple ranges can be specified, 
% each for a different date frequency/periodicity.
%
%
% __Output Arguments__
%
% * `D` [ struct ] - Database with tseries objects cut down to `range`.
%
%
% __Description__
%
% This functions looks up all tseries objects within the database `d`, 
% including tseries objects nested in sub-databases, and cuts off any
% values preceding the start date of `Range` or following the end date of
% `range`. The tseries object comments, if any, are preserved in the new
% database.
%
% If a tseries entry does not match the date frequency of the input range, 
% a warning is thrown.
%
% Multiple ranges can be specified in `Range` (as a cell array), each for a
% different date frequency/periodicity (i.e. one or more of the following:
% monthly, bi-monthly, quarterly, half-yearly, yearly, indeterminate). Each
% tseries entry will be clipped to the range that matches its date
% frequency.
%
%
% __Example__
%
%     d = struct( );
%     d.x = Series(qq(2005, 1):qq(2010, 4), @rand);
%     d.y = Series(qq(2005, 1):qq(2010, 4), @rand)
%
%     d =
%        x: [24x1 tseries]
%        y: [24x1 tseries]
%
%     dbclip(d, qq(2007, 1):qq(2007, 4))
%
%     ans =
%         x: [4x1 tseries]
%         y: [4x1 tseries]
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

persistent inputParser
if isempty(inputParser)
    inputParser = extend.InputParser('dbase:dbclip');
    inputParser.addRequired('Databank', @isstruct);
    inputParser.addRequired('RangeOrStartDate', @(x) (iscell(x) && all(cellfun(@(y) DateWrapper.validateRangeInput(y), x))) || DateWrapper.validateRangeInput(x));
    inputParser.addOptional('EndDate', [ ], @(x) isempty(x) || (iscell(x) && all(cellfun(@(y) DateWrapper.validateDateInput(y), x))) || DateWrapper.validateDateInput(x));
end
inputParser.parse(D, varargin{:});
endDate = inputParser.Results.EndDate;
if isempty(endDate)
    range = inputParser.Results.RangeOrStartDate;
    if ~iscell(range)
        range = { range };
    end
    startDate = cell(size(range));
    endDate = cell(size(range));
    for i = 1 : numel(range)
        startDate{i} = range{i}(1);
        endDate{i} = range{i}(end);
    end
else
    startDate = inputParser.Results.RangeOrStartDate;
    if ~iscell(startDate)
        startDate = { startDate };
    end
    for i = 1 : numel(startDate)
        startDate{i} = startDate{i}(1);
    end
end

if ~iscell(endDate)
    endDate = { endDate };
end

%--------------------------------------------------------------------------

freqStart = rngfreq(startDate);
freqEnd = rngfreq(endDate);

list = fieldnames(D);
numList = numel(list);
for i = 1 : numList
    name = list{i};
    if isa(D.(name), 'tseries') && ~isempty(D.(name))
        freqX = DateWrapper.getFrequencyFromNumeric(D.(name).start);
        posStart = find(freqX==freqStart, 1);
        posEnd = find(freqX==freqEnd, 1);
        if isempty(posStart) && isempty(posEnd)
            continue
        end
        if isempty(posStart)
            ithStartDate = -Inf;
        else
            ithStartDate = startDate{posStart}(1);
        end
        if isempty(posEnd)
            ithEndDate = Inf;
        else
            ithEndDate = endDate{posEnd}(1);
        end
        D.(name) = clip(D.(name), ithStartDate, ithEndDate);
    elseif isstruct(D.(name))
        % Clip a subdatabase
        D.(name) = dbclip(D.(name), varargin{:});
    end
end

end%
