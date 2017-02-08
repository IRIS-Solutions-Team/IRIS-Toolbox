function def = dates( )
% dates  Default options for IRIS date functions.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

def = struct( );

def.dates = {
    'dateformat', @config, @config
    'freqletters, freqletter', @config, @config
    'months, month', @config, @config
    'standinmonth', @config, @config
    'wwday', @config, @config
    };

def.convert = [
    def.dates
    ];

def.dat2str = [
    def.dates
    ];

def.datxtick = [
    def.dates
    {
    'dateposition', 'c', @(x) ischar(x) && ~isempty(x) && any(x(1) == 'sec')
    'datetick, dateticks', @auto, @(x) isequal(x, @auto) || isnumeric(x) || isanystri(x, {'yearstart', 'yearend', 'yearly'}) || isfunc(x)
    } ];

def.str2dat = [
    def.dates
    {
    'freq', [ ], @(x) isempty(x) || (isnumericscalar(x) && any(x == [0, 1, 2, 4, 6, 12, 52, 365])) || isequal(x, 'daily')
    } ];

end
