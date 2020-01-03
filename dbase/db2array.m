function [x, inxOfIncluded, range, inxOfNotFound, inxOfNonSeries] = db2array(d, list, range, sw)
% db2array  Convert tseries database entries to numeric array.
%
% __Syntax__
%
%     [x, includedList, range] = db2array(d)
%     [x, includedList, range] = db2array(d, list)
%     [x, includedList, range] = db2array(d, list, range, ...)
%
%
% __Input Arguments__
%
% * `d` [ struct | Dictionary ] -
% Input databank with tseries objects that will be converted to a numeric
% array.
%
% * `list` [ char | cellstr | rexp | `@all` ] - List of time series names
% that will be converted to numeric array and included in the output
% matrix; if not specified, all time series entries found in the input
% database, `d`, will be included in the output array, `x`. The list can be
% specified as a regular expression wrapped in a `rexp` object.
%
% * `range` [ numeric | `@all` ] - Date range; `@all` means a range from the
% very first non-NaN observation to the very last non-NaN observation.
%
%
% __Output Arguments__
%
% * `x` [ numeric ] - Numeric array with observations from individual
% tseries objects in columns.
%
% * `includedList` [ cellstr ] - List of time series names that have been 
% included in the output array.
%
% * `range` [ numeric ] - Date range actually used; this output argument is
% useful when the input argument `range` is missing or `Inf`.
%
%
% __Description__
%
% The output array, `x`, is always NPer-by-NList-by-NAlt, where NPer is the
% length of the `range` (the number of periods), NList is the number of
% tseries included in the `list`, and NAlt is the maximum number of columns
% that any of the tseries included in the `list` have.
%
% If all tseries data have the same size in 2nd and higher dimensions, the
% output array will respect that size in 3rd and higher dimensions. For
% instance, if all tseries data are NPer-by-2-by-5, the output array will
% be NPer-by-Nx-by-2-by-5. If some tseries data have unmatching size in 2nd
% or higher dimensions, the output array will be always a 3D array with all
% higher dimensions unfolded in 3rd dimension.
%
% If some tseries data have smaller size in 2nd or higher dimensions than
% other tseries entries, the last available column will be repeated for the
% missing columns.
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

%#ok<*VUNUS>
%#ok<*CTCH>

try
    list;
catch
    list = @all;
end

try
    if isequal(range, @all)
        range = Inf;
    end
catch
    range = Inf;
end

try
    sw;
catch
    sw = struct( );
end

try
    sw.LagOrLead;
catch
    sw.LagOrLead = [ ];
end

try
    sw.IxLog;
catch
    sw.IxLog = [ ];
end

try
    sw.Warn;
catch
    sw.Warn = struct( );
end

try
    sw.Warn.NotFound;
catch
    sw.Warn.NotFound = true;
end

try
    sw.Warn.SizeMismatch;
catch
    sw.Warn.SizeMismatch = true;
end

try
    sw.Warn.FreqMismatch;
catch
    sw.Warn.FreqMismatch = true;
end

try
    sw.Warn.NonTseries;
catch
    sw.Warn.NonTseries = true;
end

try
    sw.Warn.NoRangeFound;
catch
    sw.Warn.NoRangeFound = true;
end

try, sw.BaseYear; catch, sw.BaseYear = @config; end

try, sw.ExpandMethod; catch, sw.ExpandMethod = 'RepeatLast'; end %#ok<*NOCOM>

% Swap `list` and `Range` if needed.
if isnumeric(list) && (iscellstr(range) || ischar(range))
    [list, range] = deal(range, list);
end

persistent parser
if isempty(parser)
    parser = extend.InputParser('dbase.db2array');
    parser.addRequired('InputDatabank', @validate.databank);
    parser.addRequired('List', @(x) iscellstr(x) || ischar(x) || isa(x, 'rexp') || isequal(x, @all));
    parser.addRequired('Range', @DateWrapper.validateRangeInput);
end
parser.parse(d, list, range);

%--------------------------------------------------------------------------

if isequal(list, @all)
    list = dbnames(d, 'ClassFilter=', 'tseries');
elseif isa(list, 'rexp')
    list = dbnames(d, 'ClassFilter=', 'tseries', 'NameFilter=', list);
elseif ischar(list)
    list = regexp(list, '\w+', 'match');
end
list = list(:).';

nList = length(list);
inxOfInvalid = false(1, nList);
inxOfIncluded = false(1, nList);
inxOfFreqMismatch = false(1, nList);
inxOfNotFound = false(1, nList);
inxOfNonSeries = false(1, nList);

range2 = [ ];
if any(isinf(range([1, end])))
    range2 = dbrange(d, list);
    if isempty(range2)
        if sw.Warn.NoRangeFound
            throw( ...
                exception.Base('Dbase:CannotDetermineRange', 'warning') ...
                );
        end
        x = [ ];
        range = [ ];
        return
    end
end

if isinf(range(1))
    startDate = range2(1);
else
    startDate = range(1);
end

if isinf(range(end))
    endDate = range2(end);
else
    endDate = range(end);
end

range = startDate : endDate;
freqOfRange = DateWrapper.getFrequencyAsNumeric(startDate);
numOfPeriods = numel(range);

% If all existing time series have the same size in 2nd and higher
% dimensions, reshape the output array to match that size; otherwise,
% return a 2D array.
sizeOfOutput = [ ];
isReshape = true;

x = nan(numOfPeriods, 0);
for i = 1 : nList
    name = list{i};
    try
        numOfDataSets = max(1, size(x, 3));
        if strcmp(name, '!ttrend')
            ithX = [ ];
            getTtrend( );
            addData( );
        else
            field = d.(name);
            if isa(field, 'TimeSubscriptable')
                ithX = [ ];
                getSeriesData( );
                addData( );
            else
                inxOfNonSeries(i) = true;
            end
        end
    catch
        inxOfNotFound(i) = true;
        continue
    end
end

inxOfIncluded = list(inxOfIncluded);

throwWarning( );

if isempty(x)
    x = nan(numOfPeriods, nList);
end

if isReshape
    sizeOfOutput = [ size(x, 1), size(x, 2), sizeOfOutput ];
    x = reshape(x, sizeOfOutput);
end

return




    function getSeriesData( )
        freqOfSeries = field.FrequencyAsNumeric;
        if ~isnan(freqOfSeries) && freqOfRange~=freqOfSeries
            numOfDataSets = max(1, size(x, 3));
            ithX = nan(numOfPeriods, numOfDataSets);
            inxOfFreqMismatch(i) = true;
        else
            k = 0;
            if ~isempty(sw.LagOrLead)
                k = sw.LagOrLead(i);
            end
            ithX = rangedata(field, range+k);
            iSize = size(ithX);
            iSize(1) = [ ];
            if isempty(sizeOfOutput)
                sizeOfOutput = iSize;
            else
                isReshape = isReshape && isequal(sizeOfOutput, iSize);
            end
            % Make sure ithX is processed as 2D array.
            ithX = ithX(:, :);
        end
    end% 




    function getTtrend( )
        k = 0;
        if ~isempty(sw.LagOrLead)
            k = sw.LagOrLead(i);
        end
        ithX = dat2ttrend(range+k, sw.BaseYear);
        ithX = ithX(:);
    end%




    function addData( )
        if isempty(x)
            x = nan(numOfPeriods, nList, size(ithX, 2));
        end
        ithX = permute(ithX, [1, 3, 2]);
        nAltX = size(x, 3);
        nAltXi = size(ithX, 3);
        % If needed, expand number of alternatives in current array or current
        % addition.
        if nAltX==1 && nAltXi>1
            x = expand(x, nAltXi);
        elseif nAltX>1 && nAltXi==1
            ithX = expand(ithX, nAltX);
        end
        nAltX = size(x, 3);
        nAltXi = size(ithX, 3);
        if nAltX==nAltXi
            if ~isempty(sw.IxLog) && sw.IxLog(i)
                ithX = log(ithX);
            end
            x(:, i, 1:nAltXi) = ithX;
            inxOfIncluded(i) = true;
        else
            inxOfInvalid(i) = true;
        end
        
        
        function x = expand(x, n)
            x = repmat(x, 1, 1, n);
            if strcmpi(sw.ExpandMethod, 'NaN')
                x(:, :, 2:end) = NaN;
            end
        end%
    end%




    function throwWarning( )
        if sw.Warn.NotFound && any(inxOfNotFound)
            throw( exception.Base('Dbase:NameNotExist', 'warning'), ...
                   list{inxOfNotFound} );
        end
        
        if sw.Warn.SizeMismatch && any(inxOfInvalid)
            throw( exception.Base('Dbase:EntrySizeMismatch', 'warning'), ...
                   list{inxOfInvalid} );
        end
        
        if sw.Warn.FreqMismatch && any(inxOfFreqMismatch)
            throw( exception.Base('Dbase:EntryFrequencyMismatch', 'warning'), ...
                   list{inxOfFreqMismatch} );
        end
        
        if sw.Warn.NonTseries && any(inxOfNonSeries)
            throw( exception.Base('Dbase:EntryNotSeries', 'warning'), ...
                   list{inxOfNonSeries} );
        end
    end%
end%
