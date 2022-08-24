function [x, inxIncluded, range, inxNotFound, inxNonSeries] = db2array(d, list, range, sw)
% db2array  Convert time series database entries to numeric array.
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
% Input databank with time series objects that will be converted to a numeric
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
% time series objects in columns.
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
% time series included in the `list`, and NAlt is the maximum number of columns
% that any of the time series included in the `list` have.
%
% If all time series data have the same size in 2nd and higher dimensions, the
% output array will respect that size in 3rd and higher dimensions. For
% instance, if all time series data are NPer-by-2-by-5, the output array will
% be NPer-by-Nx-by-2-by-5. If some time series data have unmatching size in 2nd
% or higher dimensions, the output array will be always a 3D array with all
% higher dimensions unfolded in 3rd dimension.
%
% If some time series data have smaller size in 2nd or higher dimensions than
% other time series entries, the last available column will be repeated for the
% missing columns.
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

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

try, sw.BaseYear; catch, sw.BaseYear = @auto; end

try, sw.ExpandMethod; catch, sw.ExpandMethod = 'RepeatLast'; end %#ok<*NOCOM>

% Swap `list` and `Range` if needed
if isnumeric(list) && (iscellstr(range) || ischar(range) || isstring(range))
    [list, range] = deal(range, list);
end

persistent parser
if isempty(parser)
    parser = extend.InputParser('dbase.db2array');
    parser.addRequired('InputDatabank', @validate.databank);
    parser.addRequired('List', @(x) isstring(x) || iscellstr(x) || ischar(x) || isa(x, 'rexp') || isequal(x, @all));
    parser.addRequired('Range', @validate.range);
end
parser.parse(d, list, range);
range = double(range);

%--------------------------------------------------------------------------

if isequal(list, @all)
    list = dbnames(d, 'ClassFilter', 'Series');
elseif isa(list, 'rexp')
    list = dbnames(d, 'ClassFilter', 'Series', 'NameFilter', list);
elseif ischar(list)
    list = regexp(list, '\w+', 'match');
elseif isstring(list)
    list = cellstr(list);
end
list = reshape(list, 1, [ ]);

nList = numel(list);
inxInvalid = false(1, nList);
inxIncluded = false(1, nList);
inxFreqMismatch = false(1, nList);
inxNotFound = false(1, nList);
inxNonSeries = false(1, nList);

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

range = dater.colon(startDate, endDate);
freqRange = dater.getFrequency(startDate);
numPeriods = numel(range);

% If all existing time series have the same size in 2nd and higher
% dimensions, reshape the output array to match that size; otherwise,
% return a 2D array.
sizeOutput = [ ];
isReshape = true;

x = nan(numPeriods, 0);
for i = 1 : nList
    name = list{i};
    try
        numDataSets = max(1, size(x, 3));
        if strcmp(name, '!ttrend')
            ithX = [ ];
            getTtrend( );
            addData( );
        else
            field = d.(name);
            if isa(field, 'Series')
                ithX = [ ];
                getSeriesData( );
                addData( );
            else
                inxNonSeries(i) = true;
            end
        end
    catch
        inxNotFound(i) = true;
        continue
    end
end

inxIncluded = list(inxIncluded);

throwWarning( );

if isempty(x)
    x = nan(numPeriods, nList);
end

if isReshape
    sizeOutput = [ size(x, 1), size(x, 2), sizeOutput ];
    x = reshape(x, sizeOutput);
end

return




    function getSeriesData( )
        freqSeries = field.FrequencyAsNumeric;
        if ~isnan(freqSeries) && freqRange~=freqSeries
            numDataSets = max(1, size(x, 3));
            ithX = nan(numPeriods, numDataSets);
            inxFreqMismatch(i) = true;
        else
            sh = 0;
            if ~isempty(sw.LagOrLead)
                sh = sw.LagOrLead(i);
            end
            ithX = getDataFromTo(field, dater.plus(range, sh));
            iSize = size(ithX);
            iSize(1) = [ ];
            if isempty(sizeOutput)
                sizeOutput = iSize;
            else
                isReshape = isReshape && isequal(sizeOutput, iSize);
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
            x = nan(numPeriods, nList, size(ithX, 2));
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
            inxIncluded(i) = true;
        else
            inxInvalid(i) = true;
        end
        
        
        function x = expand(x, n)
            x = repmat(x, 1, 1, n);
            if strcmpi(sw.ExpandMethod, 'NaN')
                x(:, :, 2:end) = NaN;
            end
        end%
    end%




    function throwWarning( )
        if sw.Warn.NotFound && any(inxNotFound)
            throw( exception.Base('Dbase:NameNotExist', 'warning'), ...
                   list{inxNotFound} );
        end
        
        if sw.Warn.SizeMismatch && any(inxInvalid)
            throw( exception.Base('Dbase:EntrySizeMismatch', 'warning'), ...
                   list{inxInvalid} );
        end
        
        if sw.Warn.FreqMismatch && any(inxFreqMismatch)
            throw( exception.Base('Dbase:EntryFrequencyMismatch', 'warning'), ...
                   list{inxFreqMismatch} );
        end
        
        if sw.Warn.NonTseries && any(inxNonSeries)
            throw( exception.Base('Dbase:EntryNotSeries', 'warning'), ...
                   list{inxNonSeries} );
        end
    end%
end%
