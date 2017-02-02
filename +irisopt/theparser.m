function Def = theparser( )
% theparser  Default options for theparser objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

Def = struct( );

Def.parse = {
    'autodeclareparameters', false, @islogicalscalar
    'multiple,allowmultiple', false, @islogicalscalar
    'sstateonly', false, @islogicalscalar
    };

end
