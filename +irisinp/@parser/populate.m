function x = populate( )
% populate  Define input arguments for IRIS functions and store them in irisinp.parser.Container.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

x = struct( );

% Dbase folder
%--------------
x.dbase = struct( );

x.dbase.dbfun = irisinp.func( ...
    irisinp.funch, irisinp.dbase );

x.dbase.dbminuscontrol = irisinp.func( ...
    irisinp.model, irisinp.dbase, irisinp.dbaseOptional );

x.dbase.dbrange = irisinp.func( ...
    irisinp.dbase, irisinp.mlistOptional );


% Series class
%--------------
x.tseries = struct( );

x.tseries.arma = irisinp.func( ...
    irisinp.tseries, irisinp.tseries, ...
    irisinp.numeric, irisinp.numeric, ...
    irisinp.rangeProper );

x.tseries.band = irisinp.func( ...
    irisinp.axes, irisinp.rangeTseries('max'), ...
    irisinp.tseries, irisinp.tseries, irisinp.tseries, irisinp.plotspec );

x.tseries.bwf = irisinp.func( ...
    irisinp.tseriesPrimary, irisinp.count('Order'), ...
    irisinp.rangeTseries('max') );

x.tseries.errorbar = irisinp.func( ...
    irisinp.axes, irisinp.rangeTseries('max'), ...
    irisinp.tseries, irisinp.tseries, irisinp.tseriesOptional, ...
    irisinp.plotspec );

x.tseries.filter = irisinp.func( ...
    irisinp.tseriesPrimary, irisinp.rangeTseries('max') );

x.tseries.tseries = irisinp.func( ...
    irisinp.dates, irisinp.tdataOptional, irisinp.commentOptional );

end
