function reset( )
% iris.reset  Reset IRIS configuration options to start-up values.
%
% __Syntax__
%
%     iris.reset
%
%
% __Description__
%
% The `iris.reset` function resets all configuration options to their
% default factory values, or to those in the active `irisuserconfig.m` file
% (if one exists).
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

%--------------------------------------------------------------------------

iris.config( );
iris.configMaster( );

end
