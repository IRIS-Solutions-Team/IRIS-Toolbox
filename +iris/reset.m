function irisConfig = reset( )
% iris.reset  Reset IRIS configuration options to start-up values
%
% __Syntax__
%
%     iris.reset( )
%     irisConfig = iris.reset( )
%
%
% __Output Arguments__
%
% * `irisConfig` [ iris.Configuration ] - Configuration object with the
% current configuration settings.
%
%
% __Description__
%
% The `iris.reset( )` function resets all configuration options to their
% default factory values, or to those in the active `irisuserconfig.m` file
% (if one exists).
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

%--------------------------------------------------------------------------

try
    rmappdata(0, 'IRIS_Configuration');
end
irisConfig = iris.Configuration( );
setappdata(0, 'IRIS_Configuration', irisConfig);

end%

