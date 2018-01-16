function chkconsistency(This)
% chkconsistency  [Not a public function] Check consistency of lower and upper bounds relative to centre.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

% TODO: Finish this function.

%--------------------------------------------------------------------------

if This.options.relative
    doRelative( );
else
    doAbsolute( );
end

% Nested functions.

%**************************************************************************
    function doRelative( )
    end % dorelative( ).

%**************************************************************************
    function doAbsolute( )
    end % doabsolute( ).

end