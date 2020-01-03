function default = freqdom( )
% freqdom  [Not a public function] Default options for freqdom package functions.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2020 IRIS Solutions Team.

%**************************************************************************

default = struct( );

default.xsf2phase = { ...
    'unwrap',false,@islogicalscalar, ...
    };

end