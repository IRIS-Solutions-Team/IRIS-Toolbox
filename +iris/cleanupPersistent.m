function cleanupPersistent( )
% cleanupPersistent  Clean up appdata and persistent workspaces
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

%--------------------------------------------------------------------------

iris.Configuration.clear( );

try
    rmappdata(0, 'IRIS_ExceptionLookupTable');
end

try
    rmappdata(0, 'IRIS_DefaultFunctionOptions')
end

try
    clear(container( ));
end

end%

