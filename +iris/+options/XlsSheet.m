function def = XlsSheet( )
% XlsSheet  Default options for IRIS XlsSheet class.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

%--------------------------------------------------------------------------

dates = iris.options.dates( );

def = struct( );

def.retrieveDbase = [
    dates.str2dat
    ];

end
