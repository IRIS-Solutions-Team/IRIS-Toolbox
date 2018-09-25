function cleanupPersistent( )
% cleanupPersistent  Clean up appdata and persistent workspaces
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

%--------------------------------------------------------------------------

try
    rmappdata(0, 'IRIS_Configuration')
end

try
    rmappdata(0, 'IRIS_ExceptionLookupTable');
end

try
    rmappdata(0, 'IRIS_DefaultFunctionOptions')
end

try
    rmappdata(0, 'IRIS_TimeSeriesConstructor')
end

try
    rmappdata(0, 'IRIS_IsDesktop')
end

try
    rmappdata(0, 'IRIS_StringContinuationMark')
end

try
    rmappdata(0, 'IRIS_DateFromSerial')
end

try
    clear(container( ));
end

end
