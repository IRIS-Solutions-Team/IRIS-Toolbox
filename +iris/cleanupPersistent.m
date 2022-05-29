function cleanupPersistent( )
% cleanupPersistent  Clean up appdata and persistent workspaces
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

%--------------------------------------------------------------------------

iris.Configuration.clear( );

try
    rmappdata(0, 'IRIS_ExceptionLookupTable');
end

try
    clear(container( ));
end

end%

