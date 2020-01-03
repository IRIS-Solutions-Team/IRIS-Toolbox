function Def = dbase( )
% dbase  Default options for dbase functions.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2020 IRIS Solutions Team.

%--------------------------------------------------------------------------

validFn = iris.options.validfn;

Def = struct( );

dateformat = { ...
    'dateformat', @config, @iris.Configuration.validateDateFormat
    'freqletters, freqletter', @config, @iris.Configuration.validateFreqLetters
    'months, month', @config, @iris.Configuration.validateMonths
    'ConversionMonth, standinmonth', @config, @iris.Configuration.validateConversionMonth
    'Wday', @config, @iris.Configuration.validateWDay
    };

Def.dbload = [
    dateformat
    {
    'case, changecase', '', @(x) isempty(x) || any(strcmpi(x, {'lower', 'upper'}))
    'commentrow', {'comment', 'comments'}, @(x) ischar(x) || iscellstr(x)
    'Continuous', false, @(x) isequal(x, false) || any(strcmpi(x, {'Ascending', 'Descending'}))
    'delimiter', ', ', @(x) ischar(x) && length(sprintf(x))==1
    'firstdateonly', false, @islogicalscalar
    'inputformat', 'auto', @(x) ischar(x) && (strcmpi(x, 'auto') || strcmpi(x, 'csv') || strncmpi(x, 'xl', 2))
    'namerow, namesrow, leadingrow', {'', 'variables'}, @(x) ischar(x) || iscellstr(x) || isnumericscalar(x)
    'namefunc, namesFunc', [ ], @(x) isempty(x) || isfunc(x) || (iscell(x) && all(cellfun(@isfunc, x)))
    'freq', [ ], @(x) isempty(x) || (ischar(x) && strcmpi(x, 'daily')) || (length(x)==1 && isnan(x)) || (isnumeric(x) && length(x)==1 && any(x==[0, 1, 2, 4, 6, 12, 52, 365]))
    'nan', 'NaN', @(x) ischar(x)
    'preprocess', [ ], @(x) isempty(x) || isfunc(x) || (iscell(x) && all(cellfun(@isfunc, x)))
    'RemoveFromData', cell.empty(1, 0), @(x) iscellstr(x) || ischar(x) || isa(x, 'string')
    'select', @all, @(x) isequal(x, @all) || ischar(x) || iscellstr(x)
    'skiprows, skiprow', '', @(x) isempty(x) || ischar(x) || iscellstr(x) || isnumeric(x)
    'userdata', Inf, @(x) isequal(x, Inf) || (ischar(x) && isvarname(x))
    'userdatafield', '.', @(x) ischar(x) && length(x)==1
    'userdatafieldlist', { }, @(x) isempty(x) || iscellstr(x) || isnumeric(x)
    } ]; %#ok<CCAT>

Def.dbminuscontrol = { 
    'fresh', true, @islogicalscalar
};

Def.dbprintuserdata = { 
    'output', 'prompt', @(x) ischar(x) && any(strcmpi(x, {'html', 'prompt'}))
};

Def.dbrange = {
    'startdate', 'maxrange', @(x) ischar(x) && any(strcmpi(x, {'maxrange', 'minrange', 'balanced', 'unbalanced'}))
    'enddate', 'maxrange', @(x) ischar(x) && any(strcmpi(x, {'maxrange', 'minrange', 'balanced', 'unbalanced'}))
};

Def.dbsplit = { ...
    'discard', true, @islogicalscalar, ...
    };

Def.xls2csv = { ...
    'sheet', 1, @(x) (isintscalar(x) && x>0) || ischar(x), ...
    };

end%
