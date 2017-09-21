function d = array2db(X, date, lsName, ixLog, d)
% array2db  Convert numeric array to database.
%
% __Syntax__
%
%     D = array2db(X, Range, List)
%
%
% __Input arguments__
%
% * `X` [ numeric ] - Numeric array with individual time series in columns.
%
% * `Dates` [ numeric ] - Vector of dates for individual rows of `X`.
%
% * `List` [ cellstr | char ] - List of names for time series in individual
% columns of `X`.
%
%
% __Output arguments__
%
% * `D` [ struct ] - Output database.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%#ok<*CTCH>
%#ok<*VUNUS>

TIME_SERIES_CONSTRUCTOR = getappdata(0, 'IRIS_TimeSeriesConstructor');
TEMPLATE_SERIES = TIME_SERIES_CONSTRUCTOR( );

try, ixLog; catch, ixLog = [ ]; end %#ok<NOCOM>
try, d; catch, d = struct( ); end %#ok<NOCOM>

if ischar(lsName)
    lsName = regexp(lsName, '\w+', 'match');
end

pp = inputParser( );
pp.addRequired('X', @isnumeric);
pp.addRequired('Dates', @isnumeric);
pp.addRequired('IxLog', @(x) isempty(x) || islogical(x) || isstruct(x));
pp.addRequired('D', @isstruct);
pp.parse(X, date, ixLog, d);

% TODO: Allow for unsorted dates.

%--------------------------------------------------------------------------

nx = size(X, 2);
date = date(:).';
nDate = length(date);
minDate = min(date);
maxDate = max(date);
range = minDate : maxDate;
nPer = length(range);
nList = length(lsName);
posDates = round(date - minDate + 1);
isRange = isequal(posDates, 1:nPer);

if nx~=nList
    utils.error('dbase:array2db', ...
        ['Number of columns in input array must match ', ...
        'number of variable names.']);
end

if size(X, 1)~=nDate
    utils.error('dbase:array2db', ...
        ['Number of rows in input array must match ', ...
        'number of periods.']);
end

sizeX = size(X);
ndimsX = length(sizeX);

ref = repmat({':'}, 1, ndimsX);

for i = 1 : nx
    name = lsName{i};
    ref{2} = i;
    iX = squeeze(X(ref{:}));
    if ~isempty(ixLog) && getIsLog( )
        iX = exp(iX);
    end
    if isRange
        % Continuous range.
        d.(name) = replace(TEMPLATE_SERIES, iX, minDate);
    else
        % Vector of dates.
        if i==1
            iData = nan(size(iX));
            iData(end+1:nPer, :) = NaN;
        end
        iData(posDates, :) = iX;
        d.(name) = replace(TEMPLATE_SERIES, iData, minDate);
    end
end

return


    function isLog = getIsLog( )
        isLog = false;
        if islogicalscalar(ixLog)
            isLog = ixLog;
            return
        end        
        if islogical(ixLog)
            isLog = ixLog( min(i, end) );
            return
        end
        if isstruct(ixLog) ...
                && isfield(ixLog, name) ...
                && islogicalscalar(ixLog.(name))
            isLog = ixLog.(name);
            return
        end
    end
end
