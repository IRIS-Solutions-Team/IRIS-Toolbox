function Def = rpteq( )
% rpteq  Default options for rpteq class.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

Def = struct( );

Def.rpteq = {
    'assign', struct([ ]), @isstruct
    'saveas', '', @ischar
    };

Def.run = {
    'AppendPresample', false, @(x) islogicalscalar(x) || isstruct(x)
    'dboverlay', false, @(x) islogicalscalar(x) || isstruct(x)
    'fresh', false, @islogicalscalar
    };

end
