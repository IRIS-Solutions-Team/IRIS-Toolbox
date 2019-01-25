function def = HData( )
% HData  Default options for the HData class.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2019 IRIS Solutions Team.

%--------------------------------------------------------------------------

def = struct( );

def.hdata2tseries = { ...
    'Delog', true, @islogicalscalar, ...
    };

end
