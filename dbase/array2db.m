function d = array2db(X, date, list, varargin)
% array2db  Convert numeric array to database
%
% __Syntax__
%
%     D = array2db(X, Range, List, ...)
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
% __Options__
%
% * `Comments={ }` [ cellstr | string ] - Cell array or array of strings to
% be assigned to the time series created; number of `Comments` can be
% smaller than the number of names in `List`.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

%#ok<*CTCH>
%#ok<*VUNUS>

TEMPLATE_SERIES = Series( );

persistent ip
if isempty(ip)
    ip = extend.InputParser('dbase.array2db');
    ip.addRequired('InputArray', @isnumeric);
    ip.addRequired('Dates', @isnumeric);
    ip.addRequired('List', @(x) ischar(x) || iscellstr(x) || isa(x, 'string'));
    ip.addOptional('IndexLog', [], @(x) isempty(x) || islogical(x) || isstruct(x));
    ip.addOptional('Databank', struct( ), @isstruct);

    ip.addParameter('Comments', cell.empty(1, 0), @iscellstr);
end
ip.parse(X, date, list, varargin{:});
ixLog = ip.Results.IndexLog;
d = ip.Results.Databank;
opt = ip.Options;

if ischar(list)
    list = regexp(list, '\w+', 'match');
elseif ~iscell(list)
    list = cellstr(list);
end

% TODO: Allow for unsorted dates.

%--------------------------------------------------------------------------

nx = size(X, 2);
date = date(:).';
numDates = length(date);
nList = length(list);
if numDates==1
    isContinuous = true;
    minDate = date;
else
    minDate = min(date);
    maxDate = max(date);
    range = minDate : maxDate;
    nPer = length(range);
    posDates = round(date - minDate + 1);
    isContinuous = isequal(posDates, 1:nPer);
end

if ~iscellstr(opt.Comments)
    opt.Comments = cellstr(opt.Comments);
end
numComments = numel(opt.Comments);


if nx~=nList
    utils.error('dbase:array2db', ...
        ['Number of columns in input array must match ', ...
        'number of variable names.']);
end

if numDates~=1 && size(X, 1)~=numDates
    utils.error('dbase:array2db', ...
        ['Number of rows in input array must match ', ...
        'number of periods.']);
end

sizeX = size(X);
ndimsX = length(sizeX);
ref = repmat({':'}, 1, ndimsX);

for i = 1 : nx
    name = list{i};
    ref{2} = i;
    iX = squeeze(X(ref{:}));
    if ~isempty(ixLog) && getIsLog( )
        iX = exp(iX);
    end
    comment = '';
    if numComments>=i
        comment = opt.Comments{i};
    end
    if isContinuous
        % Continuous range.
        d.(name) = fill(TEMPLATE_SERIES, iX, minDate, comment);
    else
        % Vector of dates.
        if i==1
            iData = nan(size(iX));
            iData(end+1:nPer, :) = NaN;
        end
        iData(posDates, :) = iX;
        d.(name) = fill(TEMPLATE_SERIES, iData, minDate, comment);
    end
end

return


    function isLog = getIsLog( )
        isLog = false;
        islogicalscalar = @(x) islogical(x) && isscalar(x);
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
    end%
end%
