function def = rpteq( )
% rpteq  Default options for rpteq class.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

def = struct( );

def.rpteq = {
    'Assign', struct( ), @isstruct
    'saveas', '', @ischar
    };

def.run = {
    'AppendPresample', false, @(x) islogicalscalar(x) || isstruct(x)
    'dboverlay', false, @(x) islogicalscalar(x) || isstruct(x)
    'fresh', false, @islogicalscalar
    };

end
