function Def = fragileobj( )
% fragileobj  [Not a public function] Default options for fragileobj class functions.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2020 IRIS Solutions Team.

%--------------------------------------------------------------------------

Def = struct( );

Def.restore = { ...
    'delimiter,delimiters',true,@islogicalscalar, ...
    };

end