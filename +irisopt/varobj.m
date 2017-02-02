function Def = varobj( )
% varobj  [Not a public function] Default options for varobj class functions.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

Def = struct( );

Def.varobj = { ...
    'baseyear',@config,@(x) isempty(x) || isequal(x,@config) || isintscalar(x), ...
    'comment','',@ischar, ...
    'groups,groupnames',{ },@(x) ischar(x) || iscellstr(x), ...
    'userdata',[ ],true, ...
    };

end