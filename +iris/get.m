function varargout = get(varargin)
% iris.get  Query current IRIS config options.
%
% __Syntax__
%
%     Value = iris.get(Option)
%     S = iris.get( )
%
%
% __Input Arguments__
%
% * `Option` [ char ] - Name of the queried IRIS configuration option.
%
%
% __Output Arguments__
%
% * `Value` [ ... ] - Current value of the queried configuration
% option.
%
% * `S` [ struct ] - Structure with all configuration options and their
% current values.
%
%
% __Description__
%
% You can view any of the modifiable options listed in
% [`irisset`](config/irisset), plus the following non-modifiable ones
% (these cannot be changed by the user):
%
% * `'userConfigPath='` [ char ] - The path to the user configuration file
% called by the last executed `iris.startup`.
%
% * `'irisRoot='` [ char ] - The current IRIS root directory.
%
% * `'version='` [ char ] - The current IRIS version string.
%
% When called without any input arguments, the `irisget` function returns a
% struct with all options and their current values.
%
% When used as input arguments in the `irisget` function, the option names
% are case-insensitive. When referring to field names of an output struct
% returned by the `irisget` function, all option names are lower-case and
% case-sensitive.
%
% __Example__
%
%     iris.get('dateFormat')
%     ans =
%     YFP
% 
%     g = iris.get( );
%     g.dateformat
%     ans =
%     YFP
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

%--------------------------------------------------------------------------

[varargout{1:max(nargout, 1)}] = iris.configMaster('get', varargin{:});

end
